//
//  V4ReviewVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import Photos
import YCRateView

class V4ReviewVC: FlowedViewController,
                  UITableViewDataSource,
                  UITableViewDelegate,
                  V4ReviewVCCommonCellDelegate,
                  V4ReviewViewModel.Output {

  private var flowDelegate: FlowDelegate?
  
  var viewModel: V4ReviewViewModel?
  
  @IBOutlet var tableView: UITableView!
 
  // MARK: - ► Object lifecycle
  
  static func make(flowDelegate: FlowDelegate?) -> V4ReviewVC {
    let vc = UIStoryboard(name: "V4Review", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ReviewVC")
              as! V4ReviewVC
    vc.flowDelegate = flowDelegate
    return vc
  }
  
  // MARK: - ► View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create View Model
    createViewModel()
    
    // Register Table Cells
    registerTableCells()
    
    // Configure Navigation Bar
    configureNavigationController()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshReview()
    refreshDirty()
  }
  
  func leave() {
    flowDelegate?.leave()
    viewModel?.clearScratch()
  }
  
  // MARK: - ► IB Action
  @IBAction func clickedAddDishReview(_ sender: Any) {
    viewModel?.addDishReview()
  }
  
  @objc func clickedCancel(_ sender: Any) {
    if viewModel?.dirty == true {
      showAlert(title: nil, message: "編輯中的資料將不會被保存，確認離開", confirmTitle: "離開", confirmAction: { [weak self] in
        self?.leave()
      }, cancelTitle: "取消", cancelAction: nil)
    } else {
      leave()
    }
  }
  
  @objc func clickedSave(_ sender: Any) {
    viewModel?.saveReview()
  }
  
  @objc func clickedShare(_ sender: Any) {
    //
    guard viewModel?.dirty != true
    else {
      print("Unsaved")
      return
    }
    
    askShare()
  }
  
  // MARK: - ► Navigation Controller Manipulation
  func configureNavigationController() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(clickedCancel(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(clickedShare(_:)))
    navigationItem.title = "寫筆記"

    self.navigationItem.leftBarButtonItem?.tintColor = DishRankColor.darkTan
    self.navigationItem.rightBarButtonItems?.first?.tintColor = DishRankColor.darkTan
    self.navigationController?.navigationBar.barTintColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  // MARK: - ► Table DataSource/Delegate
  
  func registerTableCells() {
    tableView.register(UINib(nibName: "V4Review_RestaurantNameCell", bundle: nil), forCellReuseIdentifier: "RestaurantName")
    tableView.register(UINib(nibName: "V4Review_DiningTimeCell", bundle: nil), forCellReuseIdentifier: "DiningTime")
    tableView.register(UINib(nibName: "V4Review_ReviewTitleCell", bundle: nil), forCellReuseIdentifier: "ReviewTitle")
    tableView.register(UINib(nibName: "V4Review_DishReviewHeaderCell", bundle: nil), forCellReuseIdentifier: "DishReviewHeader")
    tableView.register(UINib(nibName: "V4Review_DishReviewCell", bundle: nil), forCellReuseIdentifier: "DishReview")
    tableView.register(UINib(nibName: "V4Review_RestaurantRatingCell", bundle: nil), forCellReuseIdentifier: "RestaurantRating")
    tableView.register(UINib(nibName: "V4Review_DeleteCell", bundle: nil), forCellReuseIdentifier: "Delete")
    
  }
  
  func tableSectionType(_ section: Int) -> TableSection {
    switch section {
      case 0: return .restaurantName
      case 1: return .diningTime
      case 2: return .reviewTitle
      case 3: return .dishReviewHeader
      case 4: return .dishReviews
      case 5: return .restaurantRating
      case 6: return .delete
      default: return .delete // TODO: other default
    }
  }
  
  func tableSectionIndex(_ sectionType: TableSection) -> Int {
    switch sectionType {
      case .restaurantName:   return 0
      case .diningTime:       return 1
      case .reviewTitle:      return 2
      case .dishReviewHeader: return 3
      case .dishReviews:      return 4
      case .restaurantRating: return 5
      case .delete:           return 6
      //default:                return -1
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 7
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    
    let sectionType = tableSectionType(section)
    
    switch sectionType {
    case .restaurantName:
      return 1
    case .diningTime:
      return 1
    case .reviewTitle:
      return 1
    case .dishReviewHeader:
      return 1
    case .dishReviews:
      return viewModel?.review?.dishReviews.count ?? 0
    case .restaurantRating:
      return 1
    case .delete:
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let sectionType = tableSectionType(indexPath.section)
    
    var cellID: String
    switch sectionType {
    case .restaurantName:   cellID = "RestaurantName"
    case .diningTime:       cellID = "DiningTime"
    case .reviewTitle:      cellID = "ReviewTitle"
    case .dishReviewHeader: cellID = "DishReviewHeader"
    case .dishReviews:      cellID = "DishReview"
    case .restaurantRating: cellID = "RestaurantRating"
    case .delete:           cellID = "Delete"
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    
    if let cell = cell as? CommonCell {
      cell.delegate = self
    }
    
    if let cell = cell as? RestaurantNameCell {
      cell.configure(with: viewModel?.review)
    } else if let cell = cell as? DiningTimeCell {
      cell.configure(with: viewModel?.review)
    } else if let cell = cell as? ReviewTitleCell {
      cell.configure(with: viewModel?.review)
    } else if let _ = cell as? DishReviewHeaderCell {
      
    } else if let cell = cell as? DishReviewCell {
      let dishReview = viewModel?.review?.dishReviews.at(indexPath.row)
      cell.configure(with: dishReview)
    } else if let cell = cell as? RestaurantRatingCell {
      cell.configure(with: viewModel?.review)
    } else if let _ = cell as? DeleteCell {
      
    }
    
    return cell
  }
  
  // MARK: - ► Cell Delegate
  func changeReviewTitle(_ title: String?) {
    viewModel?.changeReviewTitle(title)
  }
  
  func changeReviewComment(_ comment: String?) {
    viewModel?.changeReviewComment(comment)
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func changePriceRank(_ rank: Float) {
    viewModel?.changePriceRank(rank)
  }
  
  func changeServiceRank(_ rank: Float) {
    viewModel?.changeServiceRank(rank)
  }
  
  func changeEnvironmentRank(_ rank: Float) {
    viewModel?.changeEnvironmentRank(rank)
  }
  
  func changeDishReviewDish(for dishReviewUUID: String, name: String, dishID: Int?) {
    viewModel?.changeDishReviewDish(for: dishReviewUUID, name: name, dishID: dishID)
  }
  
  func changeDishReviewComment(for dishReviewUUID: String, comment: String) {
    viewModel?.changeDishReviewComment(for: dishReviewUUID, comment: comment)
    
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float) {
    viewModel?.changeDishReviewRank(for: dishReviewUUID, rank: rank)
  }
  
  func showMoreForDishReview(_ dishReviewUUID: String) {
    // TODO:
  }
  
  func deleteDishReview(for dishReviewUUID: String) {
    viewModel?.deleteDishReview(for: dishReviewUUID)
  }
  
  func addDishReview() {
    viewModel?.addDishReview()
  }
  
  func toggleDishReviewSelection(dishReviewUUID: String) {
  }
  
  func toggleRestaurantRatingSelection() {
  }
  
  // MARK: - ► Flow Related
  public func askContinueUnsavedReview() {
    let alert = UIAlertController(title: "您有未儲存筆記", message: "是否繼續編輯？", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "繼續編輯", style: .default, handler: { [weak self] _ in
      self?.flowDelegate?.answerContinueLastUnsavedReview(true)
    }))
    alert.addAction(UIAlertAction(title: "放棄上次未儲存筆記", style: .destructive, handler: { [weak self] _ in
      self?.flowDelegate?.answerContinueLastUnsavedReview(false)
    }))
    present(alert, animated: true, completion: nil)
  }
  
  public func askShare() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "分享整篇筆記", style: .default, handler: { [weak self] _ in
      guard let reviewUUID = self?.viewModel?.review?.uuid else { return }
      self?.flowDelegate?.showShare(originalReviewUUID: reviewUUID)
    }))
    alert.addAction(UIAlertAction(title: "分享部分筆記", style: .default, handler: { [weak self] _ in
      guard let reviewUUID = self?.viewModel?.review?.uuid else { return }
      self?.flowDelegate?.showChooseShare(originalReviewUUID: reviewUUID)
    }))
    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
    }))
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - ► Review Manipulation
  public func setReview(_ review: KVORestReviewV4) {
    viewModel?.setReview(review)
  }
  
  // MARK: - ► DishReview Manipulation
  public func addDishReviews(with assets: [PHAsset]) {
    viewModel?.addDishReviews(with: assets)
  }

  // MARK: - ► ViewModel Manipulation
  func createViewModel() {
    viewModel = V4ReviewViewModel(output: self, reviewUUID: nil)
  }
  
  // MARK: - ► ViewModel Output
  func refreshReview() {
    tableView.reloadData()
  }
  
  func refreshDirty() {
    guard let dirty = viewModel?.dirty else { return }
    
    if dirty {
      let saveButton: UIButton = {
        let saveButton = UIButton(type: .system)
        let nsattributeString = NSAttributedString.init(string: "儲存", attributes: [NSAttributedStringKey.font:
          UIFont(name: "Helvetica", size: 17.0)!])
        saveButton.setAttributedTitle(nsattributeString, for: .normal)
        saveButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        saveButton.addTarget(self, action: #selector(clickedSave(_:)), for: .touchUpInside)
        saveButton.sizeToFit()
        return saveButton
      }()
      
      navigationItem.title = "編輯筆記" // TODO: 判斷 寫筆記 or 編輯筆記
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(clickedCancel(_:)))
      self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: saveButton)]
    } else { // if not dirty
      navigationItem.title = "檢視筆記"
      navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(clickedCancel(_:)))
      navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(clickedShare(_:)))]
    }
    
    self.navigationItem.leftBarButtonItem?.tintColor = DishRankColor.darkTan
    self.navigationItem.rightBarButtonItems?.first?.tintColor = DishRankColor.darkTan
    self.navigationController?.navigationBar.barTintColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  func scrollToDishReviewAtIndex(_ index: Int) {
    let indexPath = IndexPath(row: index, section: tableSectionIndex(.dishReviews))
    guard indexPath.section < tableView.numberOfSections,
          indexPath.row < tableView.numberOfRows(inSection: indexPath.section)
    else { return }
    
    tableView.scrollToRow(at: indexPath, at: .none, animated: true)
  }
  
  // MARK: - ► Type definitions
  typealias FlowDelegate = V4ReviewVCFlowDelegate
  
  enum TableSection: Int {
    case restaurantName
    case diningTime
    case reviewTitle
    case dishReviewHeader
    case dishReviews
    case restaurantRating
    case delete
  }
}


protocol V4ReviewVCFlowDelegate {
  func answerContinueLastUnsavedReview(_ yesOrNo: Bool)
  func leave()
  func showShare(originalReviewUUID: String)
  func showChooseShare(originalReviewUUID: String)
}
