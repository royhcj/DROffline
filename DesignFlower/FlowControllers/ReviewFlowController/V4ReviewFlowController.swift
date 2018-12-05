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
  
  var scenario: Scenario = .writeBegin
  
  var reviewVC: V4ReviewVC?
  var review: KVORestReviewV4?
  
  init(scenario: Scenario) {
    self.scenario = scenario
  }
  
  deinit {
    print("V4ReviewFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    reviewVC = V4ReviewVC.make(flowDelegate: self)
    reviewVC?.viewBasedFlowController = self
  }
  
  override func start() {
    switch scenario {
    case .writeBegin:
      let flow = V4ReviewFlows.WriteBeginFlow(flowController: self)
      flow.execute()
    }
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
  
  // MARK: - Type Definitions
  typealias Delegate = V4ReviewFlowControllerDelegate
  
  enum Scenario {
    case writeBegin // 點羽毛寫筆記
  }
}

protocol V4ReviewFlowControllerDelegate: class {
  func getDisplayContext(for sender: V4ReviewFlowController) -> DisplayContext
}

// MARK: - Photo Picker Manipulation
extension V4ReviewFlowController: V4PhotoPickerFlowControllerDelegate {
  
  func showPhotoPicker(_ scenario: V4PhotoPickerModule.Scenario) {
    let photoPickerFlowController = V4PhotoPickerFlowController(delegate: self, scenario: scenario)
    addChild(flowController: photoPickerFlowController)
    photoPickerFlowController.delegate = self
    photoPickerFlowController.prepare()
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      
    }
  }
  
  func photoPickerDidCancel(_ sender: V4PhotoPickerFlowController) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    delegate?.getDisplayContext(for: self).undisplay(reviewVC)
  }
}

extension V4ReviewFlowController: V4ReviewVC.FlowDelegate {
  
  
}
