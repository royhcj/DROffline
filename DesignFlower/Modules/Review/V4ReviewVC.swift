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

  var flowDelegate: FlowDelegate?
  
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
    viewModel = V4ReviewViewModel(output: self, reviewUUID: nil)
    
    // Configure Navigation Bar
    configureNavigationController()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshReview()
  }
  
  // MARK: - ► IB Action
  @IBAction func clickedAddDishReview(_ sender: Any) {
    viewModel?.addDishReview()
  }
  
  @objc func clickedCancel(_ sender: Any) {
    
  }
  
  @objc func clickedSave(_ sender: Any) {
    viewModel?.saveReview()
  }
  
  @objc func clickedShare(_ sender: Any) {
    guard viewModel?.dirty != true
    else {
      print("Unsaved")
      return
    }
  }
  
  // MARK: - ► Navigation Controller Manipulation
  func configureNavigationController() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(clickedCancel(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(clickedShare(_:)))
    navigationItem.title = "寫筆記"
  }
  
  // MARK: - ► Table DataSource/Delegate
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 7
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    guard let sectionType = TableSection(rawValue: section)
    else { return 0 }
    
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
    guard let sectionType = TableSection(rawValue: indexPath.section)
    else { return UITableViewCell() }
    
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
  
  // MARK: - Cell Delegate
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
  
  // MARK: - Flow Related
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
  
  // MARK: - ► Review Manipulation
  public func setReview(_ review: KVORestReviewV4) {
    viewModel?.setReview(review)
  }
  
  // MARK: - ► DishReview Manipulation
  public func addDishReviews(with assets: [PHAsset]) {
    viewModel?.addDishReviews(with: assets)
  }
  
  // MARK: - ► ViewModel Output
  func refreshReview() {
    tableView.reloadData()
  }
  
  func refreshDirty() {
    guard let dirty = viewModel?.dirty else { return }
    
    if dirty {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(clickedSave(_:)))
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(clickedShare(_:)))
    }
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
}
