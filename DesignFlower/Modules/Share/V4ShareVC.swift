//
//  V4ShareVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/26.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class V4ShareVC: V4ReviewVC {
  
  var flowDelegate: V4ShareVCFlowDelegate?
  
  var shareViewModel: V4ShareViewModel? { return viewModel as? V4ShareViewModel }
  
  var scenario: ShareScenario = .new
  
  // MARK: - ► Object lifecycle
  static func make(flowDelegate: V4ShareVCFlowDelegate,
                   scenario: ShareScenario) -> V4ShareVC {
    let vc = UIStoryboard(name: "V4Share", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ShareVC")
              as! V4ShareVC
    vc.flowDelegate = flowDelegate
    vc.scenario = scenario
    return vc
  }
  
  // MARK: - ► View lifecycle
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
  
  // MARK: - ► IB Actions
  @objc func clickedMore(_ sender: Any) {
    
  }
  
  @objc func clickedSaveShare(_ sender: Any) {
    viewModel?.saveReview()
  }
  
  override func clickedCancel(_ sender: Any) {
    leave()
  }
  
  // MARK: - ► Navigation Bar Configuration
  override func configureNavigationController() {
    switch scenario {
      case .new:
        let sendButton = UIBarButtonItem(title: "送出", style: .plain,
                                         target: self, action: #selector(self.clickedSaveShare(_:)))
        self.navigationItem.rightBarButtonItems = [sendButton]
        self.navigationItem.leftBarButtonItem
          = UIBarButtonItem(title: "取消", style: .plain,
                            target: self, action: #selector(self.clickedCancel(_:)))
      case .edit:
        let moreButton = UIBarButtonItem(title: "...", style: .plain,
                                         target: self, action: #selector(self.clickedMore(_:)))
        let sendButton = UIBarButtonItem(title: "儲存", style: .plain,
                                         target: self, action: #selector(self.clickedSaveShare(_:)))
        self.navigationItem.rightBarButtonItems = [moreButton, sendButton]
        self.navigationItem.leftBarButtonItem
          = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain,
                            target: self, action: #selector(self.clickedCancel(_:)))
    }
    
    self.navigationItem.title = "編輯分享筆記"
    let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    self.navigationItem.leftBarButtonItem?.tintColor = .white
    self.navigationItem.rightBarButtonItems?.forEach {
      $0.tintColor = .white
    }
    self.navigationController?.navigationBar.barTintColor = DishRankColor.darkTan

    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  // MARK: - ► Refresh Methods
  override func refreshDirty() {
    
  }
  
  // MARK: - ► ViewModel Manipulation
  override func createViewModel() {
    viewModel = V4ShareViewModel(output: self, reviewUUID: nil)
  }
  
  // MARK: - ► Table DataSource / Delegate
  override func numberOfSections(in tableView: UITableView) -> Int {
    var number = 5
    if viewModel?.review?.isShowComment == true {
      number += 1
    }
    return number
  }
  
  override func tableSectionType(_ section: Int) -> V4ReviewVC.TableSection {
    switch section {
    case 0: return .restaurantName
    case 1: return .diningTime
    case 2: return .reviewTitle
    case 3: return .dishReviewHeader
    case 4: return .dishReviews
    case 5: return .restaurantRating
    default: return .delete // TODO: other default
    }
  }

  // MARK: - ► Type Definitions
  typealias FlowDelegate = V4ShareVCFlowDelegate
}

protocol V4ShareVCFlowDelegate: class {
  func leave()
}

enum ShareScenario {
  case new
  case edit
}
