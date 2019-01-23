//
//  V4PickDishFlowController.swift
//  DesignFlower
//
//  Created by roy on 1/23/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class V4PickDishFlowController: ViewBasedFlowController {
  
  weak var delegate: Delegate?
  
  var sourceDisplayContext: DisplayContext
  var pickDishVC: V4PickDishVC?
  var restaurantID: Int
  var dishReviewUUID: String?
  
  // MARK: - Object lifecycle
  init(delegate: Delegate,
       sourceDisplayContext: DisplayContext,
       restaurantID: Int,
       dishReviewUUID: String?) {
    self.delegate = delegate
    self.sourceDisplayContext = sourceDisplayContext
    self.restaurantID = restaurantID
    self.dishReviewUUID = dishReviewUUID
  }
  
  deinit {
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    pickDishVC = V4PickDishVC.make(flowDelegate: self,
                                   restaurantID: restaurantID)
  }
  
  override func start() {
    guard let vc = pickDishVC
    else { return }
    
    sourceDisplayContext.display(vc)
  }
  
  
  // MARK: - Type Definition
  typealias Delegate = V4PickDishFlowControllerDelegate
}

// MARK: - Flow Delegate Extension
extension V4PickDishFlowController: V4PickDishVC.FlowDelegate {
  func pickDishVC(_ sender: V4PickDishVC, pickedDishName: String?, dishID: Int?) {
    delegate?.pickedDish(for: dishReviewUUID, dishName: pickedDishName, dishID: dishID)
    
    sourceDisplayContext.undisplay(pickDishVC)
  }
}


protocol V4PickDishFlowControllerDelegate: class {
  func pickedDish(for dishReviewUUID: String?, dishName: String?, dishID: Int?)
}
