//
//  V4ChooseShareVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2019/1/3.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class V4ChooseShareVC: V4ReviewVC,
                       V4ChooseShareViewModelOutput {
  
  var flowDelegate: V4ChooseShareVCFlowDelegate?
  
  var chooseShareViewModel: V4ChooseShareViewModel? {
    return viewModel as? V4ChooseShareViewModel
  }
  
  // MARK: - ► Object lifecycle
  static func make(chooseShareFlowDelegate: V4ChooseShareVCFlowDelegate) -> V4ChooseShareVC {
    let vc = UIStoryboard(name: "V4ChooseShare", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ChooseShareVC")
              as! V4ChooseShareVC
    vc.flowDelegate = chooseShareFlowDelegate
    return vc
  }
  
  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register Table Cells
    registerTableCells()
    
    // Configure Navigation Bar
    configureNavigationController()
  }
  
  override func leave() {
    super.leave()
    flowDelegate?.leave()
  }
  
  // MARK: - IB Actions
  override func clickedCancel(_ sender: Any) {
    leave()
  }
  
  @objc func clickedDone(_ sender: Any) {
    guard let reviewUUID = viewModel?.review?.uuid
    else { return }
    
    let selections: ShareSelections = {
      let selectedRetaurantRating = chooseShareViewModel?.selectedRestaurantReview ?? false
      let dishReviewUUIDs: [String] = chooseShareViewModel?.selectedDishReviewUUIDs ?? []
      
      return ShareSelections(selectedDishReviewUUIDs: dishReviewUUIDs,
                             selectedRestaurantRating: selectedRetaurantRating)
    }()
    
    flowDelegate?.showShare(originalReviewUUID: reviewUUID, selections: selections)
  }
  
  // MARK: - ► ViewModel Manipulation
  override func createViewModel() {
    viewModel = V4ChooseShareViewModel(output: self, reviewUUID: nil)
  }
  
  // MARK: - ► Navigation Bar Configuration
  override func configureNavigationController() {
    self.navigationController?.navigationBar.barTintColor = DishRankColor.darkTan
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedStringKey.foregroundColor: UIColor.white]
    
    self.navigationItem.title = "選擇筆記分享內容"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認", style: .plain,
                                                             target: self, action: #selector(self.clickedDone(_:)))
    self.navigationItem.leftBarButtonItem
      = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain,
                        target: self, action: #selector(self.clickedCancel(_:)))
    
    self.navigationItem.leftBarButtonItem?.tintColor = .white
    self.navigationItem.rightBarButtonItem?.tintColor = .white
  }
  
  // MARK: - Table DataSource/Delegate
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  override func tableSectionType(_ section: Int) -> V4ReviewVC.TableSection {
    switch section {
      case 0: return .dishReviewHeader
      case 1: return .dishReviews
      case 2: return .restaurantRating
      default: return .delete
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
    if let cell = cell as? V4Review_SelectableCommonCell {
      cell.createSelectionViews()
    }
    
    if let cell = cell as? DishReviewCell,
       let selectionStatus = chooseShareViewModel?.getSelectionStatus(forDishReviewIndex: indexPath.row) {
      cell.setSelectionStatus(selectionStatus)
    } else if let cell = cell as? RestaurantRatingCell {
      let selectionStatus: V4ReviewVC.SelectableCommonCell.SelectionStatus
        = chooseShareViewModel?.selectedRestaurantReview == true ?
            .selected : .unselected
      cell.setSelectionStatus(selectionStatus)
    }
    
    
    return cell
  }
  
  // MARK: - ► Cell Delegate
  override func toggleDishReviewSelection(dishReviewUUID: String) {
    chooseShareViewModel?.toggleDishReviewSelection(dishReviewUUID: dishReviewUUID)
  }
  
  override func toggleRestaurantRatingSelection() {
    chooseShareViewModel?.toggleRestaurantRatingSelection()
  }
  
  // MARK: - Refresh Methods
  override func refreshDirty() {
    configureNavigationController()
  }
}

protocol V4ChooseShareVCFlowDelegate: class {
  func leave()
  func showShare(originalReviewUUID: String, selections: ShareSelections)
}
