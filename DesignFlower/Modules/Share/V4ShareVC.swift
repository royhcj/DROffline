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
  
  // MARK: - ► Object lifecycle
  static func make(flowDelegate: V4ShareVCFlowDelegate) -> V4ShareVC {
    let vc = UIStoryboard(name: "V4Share", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ShareVC")
              as! V4ShareVC
    vc.flowDelegate = flowDelegate
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
  
  // MARK: - ► IB Actions
  @objc func clickedMore(_ sender: Any) {
    
  }
  
  @objc func clickedSaveShare(_ sender: Any) {
    viewModel?.saveReview()
  }
  
  // MARK: - ► Navigation Bar Configuration
  override func configureNavigationController() {
    self.navigationItem.leftBarButtonItem
      = UIBarButtonItem(title: "取消", style: .plain,
                        target: self, action: #selector(self.clickedCancel(_:)))
    
    let moreButton = UIBarButtonItem(title: "...", style: .plain,
                                     target: self, action: #selector(self.clickedMore(_:)))
    let sendButton = UIBarButtonItem(title: "儲存", style: .plain,
                                     target: self, action: #selector(self.clickedSaveShare(_:)))
//    self.navigationItem.leftBarButtonItem
//      = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back"), style: .plain,
//                        target: self, action: #selector(self.clickedCancel(_:)))
//
//    let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Icon_More"), style: .plain,
//                                     target: self, action: #selector(self.clickedMore(_:)))
//    let sendButton = UIBarButtonItem(title: "儲存", style: .plain,
//                                     target: self, action: #selector(self.clickedSaveShare(_:)))
    self.navigationItem.rightBarButtonItems = [moreButton, sendButton]
    self.navigationItem.title = "編輯分享筆記"
    let textAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    self.navigationItem.leftBarButtonItem?.tintColor = .white
    self.navigationItem.rightBarButtonItems?[0].tintColor = .white
    self.navigationController?.navigationBar.barTintColor = DishRankColor.darkTan
    self.navigationItem.rightBarButtonItems?[1].tintColor = .white
    self.navigationController?.navigationBar.isTranslucent = false
  }
  
  // MARK: - ► Refresh Methods
  override func refreshDirty() {
    
  }
  
  // MARK: - ► ViewModel Manipulation
  override func createViewModel() {
    viewModel = V4ShareViewModel(output: self, reviewUUID: nil)
  }
  

  // MARK: - ► Type Definitions
  typealias FlowDelegate = V4ShareVCFlowDelegate
}

protocol V4ShareVCFlowDelegate: class {
  
}
