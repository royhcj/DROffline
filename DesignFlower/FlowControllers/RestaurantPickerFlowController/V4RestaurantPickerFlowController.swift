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
  var restaurantListVC: V4RestaurantListVC?
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
    restaurantListVC = V4RestaurantListVC.make(flowDelegate: self,
                                                   initialLocation: initialLocation)
    
  }
  
  override func start() {
    showRestaurantListVC()
  }
  
  // MARK: - Type definitions
  typealias Delegate = V4RestaurantPickerFlowControllerDelegate
}

// MARK: - RestaurantVC Manipulation
extension V4RestaurantPickerFlowController: V4RestaurantListVC.FlowDelegate {
  
  func showRestaurantListVC() {
    guard let vc = restaurantListVC
    else { return }
    
    sourceDisplayContext.display(vc)
  }
  
  func selectRest(restaurant: Restaurant, locationInfo: V4RestaurantListVC.LocationInfo?) {
    delegate?.restaurantPicker(self, selected: restaurant, locationInfo: locationInfo)
    sourceDisplayContext.undisplay(restaurantListVC)
  }
  
  func restaurantListDismissed(locationInfo: V4RestaurantListVC.LocationInfo?) {
    delegate?.restaurantPicker(self, dismissedWithLocationInfo: locationInfo)
    sourceDisplayContext.undisplay(restaurantListVC)
  }
}

protocol V4RestaurantPickerFlowControllerDelegate: class {
  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        selected: Restaurant,
                        locationInfo: V4RestaurantListVC.LocationInfo?)
  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        dismissedWithLocationInfo: V4RestaurantListVC.LocationInfo?)
}
