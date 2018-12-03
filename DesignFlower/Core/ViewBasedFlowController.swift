//
//  ViewBasedFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

enum ViewLifecycle {
  case viewDidLoad
  case viewWillAppear(_ isFirstTimeAppear: Bool)
  case viewDidAppear(_ isFirstTimeAppear: Bool)
  case viewWillDisappear
  case viewDidDisappear
}



class ViewBasedFlowController: FlowController {
  func handle(viewLifecycle: ViewLifecycle) {
    
  }
}
