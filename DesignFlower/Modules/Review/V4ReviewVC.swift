//
//  V4ReviewVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class V4ReviewVC: FlowedViewController,
                  UITableViewDataSource,
                  UITableViewDelegate,
                  V4ReviewViewModel.Output {
  
  var flowDelegate: FlowDelegate?
  
  var viewModel: V4ReviewViewModel?
  
  @IBOutlet var tableView: UITableView!
 
  // MARK: - ► Object lifecycle
  
  static func make(flowDelegate: FlowDelegate?) -> V4ReviewVC {
    let vc = UIStoryboard(name: "V4Review", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ReviewVC")
              as! V4ReviewVC
    return vc
  }
  
  // MARK: - ► View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create View Model
    viewModel = V4ReviewViewModel(output: self, reviewUUID: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshReview()
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
      return 0
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
    
    if let cell = cell as? RestaurantNameCell {
      cell.configure(with: viewModel?.review)
    } else if let cell = cell as? DiningTimeCell {
      cell.configure(with: viewModel?.review)
    } else if let cell = cell as? ReviewTitleCell {
      cell.configure(with: viewModel?.review)
    } else if let _ = cell as? DishReviewHeaderCell {
      
    } else if let _ = cell as? DishReviewCell {
      
    } else if let cell = cell as? RestaurantRatingCell {
      cell.configure(with: viewModel?.review)
    } else if let _ = cell as? DeleteCell {
      
    }
    
    return cell
  }
  
  // MARK: - ► Review Manipulation
  public func setReview(_ review: KVORestReviewV4) {
    viewModel?.setReview(review)
  }
  
  // MARK: - ► ViewModel Output
  func refreshReview() {
    tableView.reloadData()
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
  
}
