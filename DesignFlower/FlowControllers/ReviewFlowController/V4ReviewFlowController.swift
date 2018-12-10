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
  //var review: KVORestReviewV4?
  
  init(scenario: Scenario) {
    self.scenario = scenario
  }
  
  deinit {
    print("V4ReviewFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    createReviewVC()
  }
  
  override func start() {
    switch scenario {
    case .writeBegin:
      let flow = V4ReviewFlows.WriteBeginFlow(flowController: self)
      flow.execute()
    }
  }
  
  // MARK: - Review VC Manipulation
  func createReviewVC() {
    reviewVC = V4ReviewVC.make(flowDelegate: self)
    reviewVC?.viewBasedFlowController = self
  }
  
  func showReviewVC() {
    guard let reviewVC = reviewVC else { return }
    
    delegate?.getDisplayContext(for: self).display(reviewVC)
  }
  
  func askContinueUnsavedReview() {
    reviewVC?.askContinueUnsavedReview()
  }
  
  // MARK: - Review Manipulation
  func loadReview(_ reviewUUID: String) {
    let review = KVORestReviewV4(uuid: reviewUUID)
    reviewVC?.setReview(review)
  }
  
  func createNewReview() {
    let review = KVORestReviewV4(uuid: nil)
    reviewVC?.setReview(review)
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
                   picked assets: [PHAsset],
                   scenario: V4PhotoPickerModule.Scenario) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    
    addDishReviews(with: assets)
  }
  
  func photoPickerDidCancel(_ sender: V4PhotoPickerFlowController) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    delegate?.getDisplayContext(for: self).undisplay(reviewVC)
  }
}

// MARK: - DishReview Manipulation
extension V4ReviewFlowController {
  func addDishReviews(with assets: [PHAsset]) {
    reviewVC?.addDishReviews(with: assets)
  }
}

extension V4ReviewFlowController: V4ReviewVC.FlowDelegate {
  
  func answerContinueLastUnsavedReview(_ yesOrNo: Bool) {
    if yesOrNo == false {
      let oldReviewVC = reviewVC
      delegate?.getDisplayContext(for: self).undisplay(oldReviewVC,
                                                       completion: {
        self.createReviewVC()
        self.showReviewVC()
      })
    }
  }
  
}
