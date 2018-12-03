//
//  FlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class FlowController {
  
  // MARK: - FlowController hierarchy
  var childFlowControllers: [FlowController] = []
  
  // MARK: - Flow Members
  var rootFlow: Flow?
  
  // MARK: - Flow Execution
  func prepare() {
    
  }
  
  func start() {
    
  }
  
  func addChild(flowController: FlowController) {
    childFlowControllers.append(flowController)
  }
}
