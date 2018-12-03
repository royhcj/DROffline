//
//  FlowedViewController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class FlowedViewController: UIViewController {
  
  weak var viewBasedFlowController: ViewBasedFlowController?
  var isFirstTimeAppear = false // 是否為第一次顯示(只有在viewWillAppear裡有用)
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    viewBasedFlowController?.handle(viewLifecycle: .viewDidLoad)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewBasedFlowController?.handle(viewLifecycle: .viewWillAppear(isFirstTimeAppear))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewBasedFlowController?.handle(viewLifecycle: .viewDidAppear(isFirstTimeAppear))
    isFirstTimeAppear = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewBasedFlowController?.handle(viewLifecycle: .viewWillDisappear)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewBasedFlowController?.handle(viewLifecycle: .viewDidDisappear)
  }
}

