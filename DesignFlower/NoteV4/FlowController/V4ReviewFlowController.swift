//
//  V4ReviewFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit
import Photos

class V4ReviewFlowController: ViewBasedFlowController {
  
  weak var delegate: Delegate?
  
  var reviewVC: V4ReviewVC?
  var review: KVORestReviewV4?
  
  // MARK: - Flow Execution
  override func prepare() {
    let viewModel = V4ReviewViewModel(reviewUUID: nil)
    reviewVC = V4ReviewVC.make(flowDelegate: self, viewModel: viewModel)
    reviewVC?.viewBasedFlowController = self
    //reviewVC?.flowDelegate = self
  }
  
  override func start() {
    
  }
  
  // MARK: - Review VC Manipulation
  func showReviewVC() {
    guard let reviewVC = reviewVC else { return }
    
    let displayContext = delegate?.getDisplayContext(for: self)
    displayContext?.display(reviewVC)
  }
  
  // MARK: - Review Manipulation
  func loadReview(_ reviewUUID: String) {
    review = KVORestReviewV4(uuid: reviewUUID)
  }
  
  typealias Delegate = V4ReviewFlowControllerDelegate
}


protocol V4ReviewFlowControllerDelegate: class {
  func getDisplayContext(for sender: V4ReviewFlowController) -> DisplayContext
}

// MARK: - Photo Picker Manipulation
extension V4ReviewFlowController: V4PhotoPickerFlowControllerDelegate {
  
  func showPhotoPicker(_ scenario: V4PhotoPickerModule.Scenario) {
    let photoPickerFlowController = V4PhotoPickerFlowController(delegate: self, scenario: scenario)
    addChild(flowController: photoPickerFlowController)
    
    photoPickerFlowController.start()
  }
  
  func getDisplayContext(for sender: V4PhotoPickerFlowController) -> DisplayContext {
    guard let reviewVC = reviewVC
    else { assert(false, "Failed unwrapping reviewVC") }
    
    switch sender.scenario {
    case .addNewPhotos:
      return .embed(vc: reviewVC, on: reviewVC.view)
    default:
      return .present(vc: reviewVC, animated: true, style: .fullScreen)
    }
  }
  
  func photoPicker(_ sender: V4PhotoPickerFlowController,
                   picked: [PHAsset],
                   scenario: V4PhotoPickerModule.Scenario) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    
  }
  
  func photoPickerDidCancel(_ sender: V4PhotoPickerFlowController) {
    
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
  }
}

extension V4ReviewFlowController: V4ReviewVC.FlowDelegate {
  
}
