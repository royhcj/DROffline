//
//  V4RestaurantPickerFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/11.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4RestaurantPickerFlowController: ViewBasedFlowController {
  
  weak var delegate: Delegate?
  
  var sourceDisplayContext: DisplayContext
  var restaurantPickerVC: V4RestaurantPickerVCTemp?
  var initialLocation: Location?
  
  // MARK: - Object lifecycle
  init(delegate: Delegate, sourceDisplayContext: DisplayContext, initialLocation: Location?) {
    self.delegate = delegate
    self.sourceDisplayContext = sourceDisplayContext
    self.initialLocation = initialLocation
  }
  
  deinit {
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    restaurantPickerVC = V4RestaurantPickerVCTemp.make(flowDelegate: self,
                                                   initialLocation: initialLocation)
    
  }
  
  override func start() {
    showRestaurantPickerVC()
  }
  
  // MARK: - Type definitions
  typealias Delegate = V4RestaurantPickerFlowControllerDelegate
}

// MARK: - RestaurantVC Manipulation
extension V4RestaurantPickerFlowController: V4RestaurantPickerVCTemp.FlowDelegate {
  func showRestaurantPickerVC() {
    guard let vc = restaurantPickerVC
    else { return }
    
    sourceDisplayContext.display(vc)
  }
  
  
}

protocol V4RestaurantPickerFlowControllerDelegate: class {
  
}
