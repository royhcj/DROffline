//
//  FlowedViewController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class FlowedViewController: UIViewController {
  
  weak var viewFlower: ViewFlower?
  var isFirstTimeAppear = false // 是否為第一次顯示(只有在viewWillAppear裡有用)
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    viewFlower?.handle(viewLifecycle: .viewDidLoad)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewFlower?.handle(viewLifecycle: .viewWillAppear(isFirstTimeAppear))
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewFlower?.handle(viewLifecycle: .viewDidAppear(isFirstTimeAppear))
    isFirstTimeAppear = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewFlower?.handle(viewLifecycle: .viewWillDisappear)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewFlower?.handle(viewLifecycle: .viewDidDisappear)
  }
}

