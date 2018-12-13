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
  var restaurantPickerVC: V4RestaurantPickerVC?
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
    restaurantPickerVC = V4RestaurantPickerVC.make(flowDelegate: self,
                                                   initialLocation: initialLocation)
    
  }
  
  override func start() {
    showRestaurantPickerVC()
  }
  
  // MARK: - Type definitions
  typealias Delegate = V4RestaurantPickerFlowControllerDelegate
}

// MARK: - RestaurantVC Manipulation
extension V4RestaurantPickerFlowController: V4RestaurantPickerVC.FlowDelegate {
  
  func showRestaurantPickerVC() {
    guard let vc = restaurantPickerVC
    else { return }
    
    sourceDisplayContext.display(vc)
  }
  
  func selectRest(restaurant: Restaurant, locationInfo: V4RestaurantPickerVC.LocationInfo?) {
    delegate?.restaurantPicker(self, selected: restaurant, locationInfo: locationInfo)
    sourceDisplayContext.undisplay(restaurantPickerVC)
  }
  
  func restaurantListDismissed(locationInfo: V4RestaurantPickerVC.LocationInfo?) {
    delegate?.restaurantPicker(self, dismissedWithLocationInfo: locationInfo)
    sourceDisplayContext.undisplay(restaurantPickerVC)
  }
}

protocol V4RestaurantPickerFlowControllerDelegate: class {
  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        selected: Restaurant,
                        locationInfo: V4RestaurantPickerVC.LocationInfo?)
  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        dismissedWithLocationInfo: V4RestaurantPickerVC.LocationInfo?)
}
