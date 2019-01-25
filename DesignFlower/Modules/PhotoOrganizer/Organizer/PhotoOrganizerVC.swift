//
//  PhotoOrganizerVC.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/22.
//

import UIKit
import iCarousel
import RxSwift
import RxCocoa

class PhotoOrganizerVC: UIViewController,
                        iCarouselDataSource,
                        iCarouselDelegate,
                        DishPhotoOrganizerVC.Delegate {

  @IBOutlet var carousel: iCarousel!
  
  var vm: PhotoOrganizerVM?
  
  var dishOrganizerVCs: [Int: DishPhotoOrganizerVC] = [:] // key為dishItemIndex
  
  weak var flowDelegate: V4PhotoOrganizerVCFlowDelegate?
  
  // IB Outlets
  @IBOutlet var closeButton: UIButton!
  @IBOutlet var pageLabel: UILabel!
  @IBOutlet var leftPageButton: UIButton!
  @IBOutlet var rightPageButton: UIButton!
  
  
  // Rx Members
  var disposeBag = DisposeBag()
  
  var deleteDishItem = PublishSubject<DishItem>()
  var undoLastDeletedDishItem = PublishSubject<Void>()
  
  
  // MARK: - Object lifecycle
  static func make(flowDelegate: V4PhotoOrganizerVCFlowDelegate,
                   dishItems: [DishItem],
                   initialDisplayIndex: Int?) -> PhotoOrganizerVC {
    let vc = UIStoryboard(name: "PhotoOrganizer", bundle: nil)
      .instantiateViewController(withIdentifier: "PhotoOrganizerVC")
      as! PhotoOrganizerVC
    vc.flowDelegate = flowDelegate
    vc.loadViewIfNeeded()
    vc.setDishItems(dishItems)
    if let initialDisplayIndex = initialDisplayIndex {
      //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak vc] in
        vc.flipToDishItem(to: initialDisplayIndex, animated: false)
      //}
    }
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    carousel.type = .rotary
    carousel.perspective = -1.0/1300.0
    carousel.decelerationRate = 0.2
    
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    carousel.reloadData()
    updatePage()
  }
  
  // MARK: -
  func setDishItems(_ dishItems: [DishItem]) {
    vm?.dishItems.accept(dishItems)
  }
  
  func bindViewModel() {
    vm = PhotoOrganizerVM()
    
    let input = PhotoOrganizerVM.Input(deleteDishItem: deleteDishItem,
                                       undoLastDeletedDishItem: undoLastDeletedDishItem)
    let output = vm?.bind(input: input)
    output?.dishItems
      .subscribe(onNext: { [weak self] dishItems in
        //self?.dishOrganizerVCs.removeAll()
        self?.carousel.reloadData()
        self?.updatePage()
        
        if let count = dishItems?.count {
          if count <= 1 {
            self?.carousel.decelerationRate = 0.0
            self?.carousel.scrollSpeed = 0
          } else if count == 2 {
            self?.carousel.decelerationRate = 0.25
            self?.carousel.scrollSpeed = 1.2
          } else if count < 11 {
            self?.carousel.decelerationRate = 0.15
            self?.carousel.scrollSpeed = 1.0
          } else {
            self?.carousel.decelerationRate = 0.93
            self?.carousel.scrollSpeed = 1.0
          }
        }
      }).disposed(by: disposeBag)
    
    // Bind Output
    output?.lastDeletedDishItem
      .subscribe(onNext: { [weak self] dishItem in
        if dishItem != nil {
          self?.showDishDeletedMessage()
        }
      }).disposed(by: disposeBag)
    
    // Self Bindings
    closeButton.rx.tap
      .asObservable()
      .subscribe(onNext: { [weak self] () in
        guard let strongSelf = self else { return }
        
        // 縮起鍵盤，打到一半的字才會被紀錄
        self?.view.endEditing(true)

        // 蒐集各DishOrganizer的更動
        var requests: [DishModificationRequest] = []
/* MARKOFF - no need anymore. removing modifications
        for (_, vc) in strongSelf.dishOrganizerVCs {
          guard let request = vc.vm?.dishModificationRequest
          else { continue }

          requests.append(request)
        }
*/
        // 蒐集刪除的動作
        if let deleteRequests = self?.vm?.dishDeleteRequests {
          requests.append(contentsOf: deleteRequests)
        }

        // 傳回所有更動
        let modified = strongSelf.dishOrganizerVCs.reduce(false, { (result, pair) -> Bool in
          result || (pair.value.vm?.isDirty.value ?? false)
        })
        strongSelf.flowDelegate?
            .photoOrganizer(self, modified: modified, requestDishModifications: requests)
      }).disposed(by: disposeBag)
    
    leftPageButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        guard var index: Int = self?.carousel.currentItemIndex,
              let total = self?.carousel.numberOfItems, total > 0
        else { return }
        
        index = (index - 1) % total
        self?.carousel.scrollToItem(at: index, animated: true)
        
      }).disposed(by: disposeBag)
    
    rightPageButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        guard var index: Int = self?.carousel.currentItemIndex,
          let total = self?.carousel.numberOfItems, total > 0
          else { return }
        
        index = (index + 1) % total
        self?.carousel.scrollToItem(at: index, animated: true)
      }).disposed(by: disposeBag)
  }
  

  // MARK: - iCarousel DataSource/Delegate
  func numberOfItems(in carousel: iCarousel) -> Int {
    return vm?.dishItems.value?.count ?? 0
  }
  
  func carousel(_ carousel: iCarousel,
                viewForItemAt index: Int,
                reusing view: UIView?) -> UIView {
    //註：dishItemIndex係指所有dishReviews的索引，index係指目前顯示的dishReviews索引，
    guard let dishItemIndex = vm?.dishItems.value?[index].itemIndex
    else { return UIView() }
    
    if let vc = dishOrganizerVCs[dishItemIndex] {
      return vc.view
    } else {
      let dishItem = vm?.dishItems.value?.at(index)
      let vc = DishPhotoOrganizerVC.make(dishItem: dishItem)
      vc.delegate = self
      dishOrganizerVCs[dishItemIndex] = vc
      
      let insets = UIEdgeInsets(top: 5, left: 25, bottom: 15, right: 25)
      
      vc.view.frame = CGRect(x: insets.left, y: insets.top,
                width: carousel.bounds.width - insets.left - insets.right,
                height: carousel.bounds.height - insets.top - insets.bottom)
      return vc.view
    }
  }
  
  func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
    updatePage()
  }
  
  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    if option == .offsetMultiplier {
      return carousel.numberOfItems > 1 ? 1.0 : 0.1
    } else {
      return value
    }
  }
  
  func updatePage() {
    if let total = vm?.dishItems.value?.count {
      let itemIndex = carousel.currentItemIndex
      pageLabel.text = "\(itemIndex+1)/\(total)"
    } else {
      pageLabel.text = "--/--"
    }
  }
  
  public func flipToDishItem(to index: Int, animated: Bool) {
    guard index < carousel.numberOfItems
    else { return }
    
    carousel.scrollToItem(at: index, animated: animated)
  }
  
  // MARK: - DishOrganizer Delegate
  func dishPhotoOrganizer(_ sender: DishPhotoOrganizerVC,
                deleteWithDishItem dishItem: PhotoOrganizer.DishItem) {
    let index = carousel.currentItemIndex
    carousel.removeItem(at: index, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.deleteDishItem.onNext(dishItem)
    }
  }
  
  // MARK: - Delete Dish Methods
  func showDishDeletedMessage() {
    let message = "已刪除這道菜餚"
    TipBar.showTip(
      for: self,
      on: ((UIApplication.shared.delegate?.window)!)!,
      message: message,
      font: UIFont.systemFont(ofSize: 15),
      backgroundColor: UIColor(white: 83/255, alpha: 1),
      iconName: "S.select friends",
      height: 60,
      animationDirection: .downward,
      duration: 3,
      showCloseButton: true,
      isMakeConstrains: false,
      resetButtonAction: { [weak self] in
        guard let this = self else { return }
        this.undoLastDeletedDishItem.onNext(())
        $0.isEnabled = false
      }, action: nil)
  }
  
  
  // MARK: - Type Definitions
  typealias DishItem = PhotoOrganizer.DishItem
  typealias DishModificationRequest = PhotoOrganizer.DishModificationRequest
}

protocol V4PhotoOrganizerVCFlowDelegate: class {
  func photoOrganizer(_ sender: PhotoOrganizerVC?,
                      modified: Bool,
                      requestDishModifications:[PhotoOrganizer.DishModificationRequest])
}
