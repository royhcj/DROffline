//
//  V4ChooseShareFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2019/1/3.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

class V4ChooseShareFlowController: ViewBasedFlowController,
                                   V4ChooseShareVCFlowDelegate {
  var chooseShareVC: V4ChooseShareVC?
  var navigationVC: UINavigationController?
  var sourceDisplayContext: DisplayContext
  var originalReviewUUID: String?
  
  init(sourceDisplayContext: DisplayContext,
       originalReviewUUID: String?) {
    self.sourceDisplayContext = sourceDisplayContext
    self.originalReviewUUID = originalReviewUUID
  }
  
  deinit {
    print("V4ChooseShareFlowController.deinit")
  }
  
  // MARK: Flow Execution
  override func prepare() {
    chooseShareVC = V4ChooseShareVC.make(chooseShareFlowDelegate: self)
    if let vc = chooseShareVC {
      navigationVC = UINavigationController(rootViewController: vc)
    }

    chooseShareVC?.loadViewIfNeeded() // Force load to make sure view model created

    if let originalReviewUUID = originalReviewUUID {
      let review = KVORestReviewV4(uuid: originalReviewUUID, service: RLMServiceV4.shared) // 從原稿讀取
      chooseShareVC?.setReview(review)
    }
  }
  
  override func start() {
    showChooseShareVC()
  }
  
  func showChooseShareVC() {
    guard let navigationVC = navigationVC else { return }
    sourceDisplayContext.display(navigationVC)
  }
  
  // MARK: - ChooseShareVC FlowDelegate
  func leave() {
    sourceDisplayContext.undisplay(navigationVC)
  }
  
  func showShare(originalReviewUUID: String, selections: ShareSelections) {
    guard let navigationVC = navigationVC else { return }
    
    let sourceDisplayContext = DisplayContext.push(vc: navigationVC, animated: true)
    
    let shareFlowController =
          V4ShareFlowController(sourceDisplayContext: sourceDisplayContext,
                                originalReviewUUID: originalReviewUUID,
                                shareSelections: selections)
    shareFlowController.cancel = { [weak self] in
      self?.leave()
    }
    
    addChild(flowController: shareFlowController)
    
    shareFlowController.prepare()
    shareFlowController.start()
  }
}
