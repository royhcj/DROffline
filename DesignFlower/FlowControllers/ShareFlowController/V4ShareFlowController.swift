//
//  V4ShareFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/27.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit

class V4ShareFlowController: ViewBasedFlowController,
                             V4ShareVCFlowDelegate {
  var shareVC: V4ShareVC?
  var navigationVC: UINavigationController?
  var sourceDisplayContext: DisplayContext
  var originalReviewUUID: String?
  
  init(sourceDisplayContext: DisplayContext,
       originalReviewUUID: String?) {
    self.sourceDisplayContext = sourceDisplayContext
    self.originalReviewUUID = originalReviewUUID
  }
  
  deinit {
    print("V4ShareFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    shareVC = V4ShareVC.make(flowDelegate: self)
    if let vc = shareVC {
      navigationVC = UINavigationController(rootViewController: vc) 
    }
    
    shareVC?.loadViewIfNeeded() // Force load to make sure view model created
    
    if let originalReviewUUID = originalReviewUUID {
      let review = KVORestReviewV4(uuid: originalReviewUUID)
      let shareReview = review.copyForShare()
      print("shared copy: \(shareReview.uuid))")
      self.shareVC?.setReview(shareReview)
    }
  }
  
  override func start() {
    showShareVC()
  }

  func showShareVC() {
    guard let navigationVC = navigationVC else { return }
    sourceDisplayContext.display(navigationVC)
  }
  
  func leave() {
    sourceDisplayContext.undisplay(navigationVC)
  }
  
}
