//
//  PhotoOrganizerGroupVC.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/22.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import YCRateView
import Photos

class DishPhotoOrganizerVC: UIViewController,
                            NoteV3PhotoPickerViewControllerDelegate,
                            ImageEditorDelegate {
  
  @IBOutlet var dishNameTextField: UITextField!
  @IBOutlet var photoImageView: UIImageView!
  @IBOutlet var dishRateView: YCRateView!
  @IBOutlet var dishCommentTextField: UITextField!
  @IBOutlet var trashButton: UIButton!
  @IBOutlet var downloadButton: UIButton!
  @IBOutlet var editButton: UIButton!
  @IBOutlet var changeButton: UIButton!
  
  var vm: DishPhotoOrganizerVM?
  
  // Rx Members
  var disposeBag = DisposeBag()
  
  var dishRating = PublishSubject<Float?>()
  var changePhoto = PublishSubject<ImageRepresentation?>()
  
  // Delegate
  weak var delegate: Delegate?
  
  // MARK: - Object lifecycle
  static func make(dishItem: DishItem?) -> DishPhotoOrganizerVC {
    let vc = UIStoryboard(name: "DishPhotoOrganizer", bundle: nil)
              .instantiateViewController(withIdentifier: "DishPhotoOrganizerVC")
              as! DishPhotoOrganizerVC
    vc.loadViewIfNeeded()
    vc.setDishItem(dishItem)
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize
    photoImageView.image = nil
    
    // Setup Dish Rate View
    setupDishRateView()
    
    //
    bindViewModel()
  }
  
  // MARK: -
  func setDishItem(_ dishItem: DishItem?) {
    vm?.dishItem.accept(dishItem)
  }
  
  // MARK: - MVVM Bindings
  func bindViewModel() {
    // Create View Model
    vm = DishPhotoOrganizerVM()
    
    // Generate Input
    let deleteDishReview = PublishSubject<Void>()
    
    let input = DishPhotoOrganizerVM.Input(
      changeDishName: dishNameTextField.rx
        .controlEvent(.editingDidEnd)
        .map { [weak self] in self?.dishNameTextField.text }
        .asObservable(),
      changeComment: dishCommentTextField.rx
        .controlEvent(.editingDidEnd)
        .map { [weak self] in self?.dishCommentTextField.text }
        .asObservable(),
      changePhoto: changePhoto,
      changeRating: dishRating,
      deleteDishReview: deleteDishReview.asObservable(),
      savePhoto: downloadButton.rx.tap.asObservable())
    
    // Bind Output
    let output = vm?.bind(input: input)
    
    output?.dishItem
      .subscribe(onNext: { [weak self] dishItem in
        guard let dishReview = dishItem?.dishReview
        else { return }
        
        if let imageRepresentation = self?.vm?.getCurrentDishImageRepresentation() {
          imageRepresentation.fetchImage { image in
              self?.photoImageView.image = image
          }
          
          switch imageRepresentation {
          case .image, .url, .localFile:
            self?.downloadButton.isEnabled = true
          case .phAsset:
            self?.downloadButton.isEnabled = false
          }
        } else {
          self?.photoImageView.image = nil
        }

        self?.dishNameTextField.text = dishReview.dish?.name
        self?.dishCommentTextField.text = dishReview.comment
        self?.dishRateView.yc_InitValue = Float(dishReview.rank ?? "0.0")!
      }).disposed(by: disposeBag)

    output?.changedPhoto
      .subscribe(onNext: { [weak self] imageRepresentation in
        guard let imageRepresentation = imageRepresentation
        else { self?.photoImageView.image = nil; return }
        
        imageRepresentation.fetchImage(completion: { [weak self] (image) in
          self?.photoImageView.image = image
        })
        
        switch imageRepresentation {
        case .image, .url, .localFile:
          self?.downloadButton.isEnabled = true
        case .phAsset:
          self?.downloadButton.isEnabled = false
        }
      }).disposed(by: disposeBag)
    
    output?.savedPhoto
      .subscribe(onNext: { [weak self] successful in
        if successful {
          self?.downloadButton.isEnabled = false
        }
        
        self?.showPhotoSavedMessage(successful: successful)
      }).disposed(by: disposeBag)
    
    // Self binding
    trashButton.rx.tap
      .map { _ -> Void in return }
      .subscribe(onNext: { [weak self] () in
        self?.showAlert(title: "是否刪除此菜餚？", message: nil,
                        confirmTitle: "確認", confirmAction: {
          guard let strongSelf = self,
                let dishItem = strongSelf.vm?.dishItem.value
          else { return }

          self?.delegate?.dishPhotoOrganizer(strongSelf,
                                deleteWithDishItem: dishItem)
        }, cancelTitle: "取消", cancelAction: nil)
      }).disposed(by: disposeBag)
    
    changeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showPhotoPicker()
      }).disposed(by: disposeBag)
    
    editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showPhotoEditor()
      }).disposed(by: disposeBag)
  }
  
  // MARK: - RateView Manipulaiton
  func setupDishRateView() {
    dishRateView.yc_IsSliderEnabled = true
    dishRateView.yc_IsTextHidden = false
    dishRateView.sliderAddTarget(target: self,
                                 selector: #selector(dishRateViewValueChanged),
                                 event: .valueChanged)
  }
  
  @objc func dishRateViewValueChanged(sender: UISlider, value: Float) {
    dishRating.onNext(sender.value)
  }
  
  // MARK: - Photo Picker Manipulation
  func showPhotoPicker() {
/* TODO: later
    guard let itemIndex = vm?.dishItem.value?.itemIndex
    else { return }
    
    let indexPath = IndexPath(item: itemIndex, section: 0)
          // indexPath應該沒用處
    
    let vc = NoteV3PhotoPickerViewController
              .make(scenario: .choosePhoto(indexPath: indexPath),
                    isPresented: true, photoLimit: 1)
    vc?.modalPresentationStyle = .overFullScreen
    vc?.pickerDelegate = self
    
    if let vc = vc {
      present(vc, animated: true, completion: nil)
    }
 */
  }
  
  func notePhotoPikcerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     choosed asset: PHAsset,
                                     for indexPath: IndexPath) {
/* TODO: later
    changePhoto.onNext(.phAsset(asset))
    NoteV3Service.shared.deleteAllNotePhotoSelections()
    sender.dismiss(animated: true, completion: nil)
 */
  }
  
  func notePhotoPickerViewController(_ sender: NoteV3PhotoPickerViewController, dismissWithAbort: Bool, wasPresented: Bool) {
    sender.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Download-related methods
  func showPhotoSavedMessage(successful: Bool) {
    let message = successful ? "已從雲端下載圖片" : "儲存相片失敗"
    TipBar.showTip(
      for: self,
      on: ((UIApplication.shared.delegate?.window)!)!,
      message: message,
      font: UIFont.systemFont(ofSize: 15),
      //backgroundColor: tipBackgroundColor,
      iconName: "S.select friends",
      height: 60,
      animationDirection: .downward,
      duration: 3,
      showCloseButton: false,
      isMakeConstrains: false) {
        TipBar.clearTip(for: self)
    }
  }
  
  // MARK: - Photo Editor Related
  func showPhotoEditor() {
    guard let imageRepresentation = vm?.getCurrentDishImageRepresentation()
    else { return }
    
    imageRepresentation.fetchImage { [weak self] in
      guard let image = $0
      else { return }
      
      let vc = ImageEditorViewController.make(image: image, delegate: self)
      vc.modalPresentationStyle = .overFullScreen
      vc.modalPresentationCapturesStatusBarAppearance = false
      self?.present(vc, animated: true, completion: nil)
    }
  }
  
  func imageEditor(_ sender: ImageEditorViewController, commit image: UIImage) {
    // 存入library
    let library = PHPhotoLibrary.shared()
    let creationDate = Date()
    library.performChanges({
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      request.creationDate = creationDate
      
      // 填入位置資訊
      if LocationService.shared.locationServiceAccessible(),
         LocationService.shared.coordinate?.isInvalid() == false,
        let location = LocationService.shared.coordinate {
        request.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
      }
    }, completionHandler: { (success, error) in
      if !success || error != nil {
        DispatchQueue.main.async { [weak self] in
          self?.showAlert(title: "無法儲存相片",
                          message: "\(error?.localizedDescription ?? "")",
                          buttonTitle: "確認", buttonAction: nil)
          return
        }
      }
/* TODO: later
      NoteV3Service.shared.getAssets(creationDates: [creationDate], completion: { [weak self] assets in
        guard let asset = assets?.firstObject else { return }
        
        let imageRepresentation = ImageRepresentation.phAsset(asset)
        self?.changePhoto.onNext(imageRepresentation)
      })
 */
    })
    
    sender.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Type Definitions
  typealias DishItem = PhotoOrganizer.DishItem
  typealias ImageRepresentation = PhotoOrganizer.ImageRepresentation
  typealias Delegate = DishPhotoOrganizerVCDelegate
}


protocol DishPhotoOrganizerVCDelegate: class {
  func dishPhotoOrganizer(_ sender: DishPhotoOrganizerVC,
                          deleteWithDishItem: PhotoOrganizer.DishItem)
}