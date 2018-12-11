//
//  V4RestaurantPickerVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/11.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class V4RestaurantPickerVC: FlowedViewController {
  
  weak var flowDelegate: FlowDelegate?
  
  var initialLocation: Location?
  
  // MARK: - Object lifecycle
  static func make(flowDelegate: FlowDelegate,
                   initialLocation: Location?) -> V4RestaurantPickerVC {
    let vc = UIStoryboard(name: "V4RestaurantPicker", bundle: nil)
              .instantiateViewController(withIdentifier: "V4RestaurantPickerVC")
              as! V4RestaurantPickerVC
    
    vc.flowDelegate = flowDelegate
    vc.initialLocation = initialLocation
    
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: -
 
  // MARK: - Type Definition
  typealias FlowDelegate = V4RestaurantPickerFlowControllerDelegate
}



protocol V4RestaurantPickerVCDelegate: class {
  func restaurantPickerVC(_ sender: V4RestaurantPickerVC, completedWithRestaurant: KVORestaurantV4?)
}
