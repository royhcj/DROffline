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
  var shareSelections: ShareSelections?
  var cancel: (() -> Void)?
  
  init(sourceDisplayContext: DisplayContext,
       originalReviewUUID: String?,
       shareSelections: ShareSelections? = nil) {
    self.sourceDisplayContext = sourceDisplayContext
    self.originalReviewUUID = originalReviewUUID
    self.shareSelections = shareSelections
  }
  
  deinit {
    print("V4ShareFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    shareVC = V4ShareVC.make(flowDelegate: self, scenario: .new)
    if !sourceDisplayContext.containsNavigationController(),
       let vc = shareVC {
      navigationVC = UINavigationController(rootViewController: vc) 
    }
    
    shareVC?.loadViewIfNeeded() // Force load to make sure view model created
    
    if let originalReviewUUID = originalReviewUUID {
      // Make a share copy
      let review = KVORestReviewV4(uuid: originalReviewUUID)
      let shareReview = review.copyForShare(withSelections: shareSelections)
      print("shared copy: \(shareReview.uuid))")
      shareVC?.setReview(shareReview)
    }
  }
  
  override func start() {
    showShareVC()
  }

  func showShareVC() {
    if let navigationVC = navigationVC {  // if shareVC wrapped inside navigationVC
      sourceDisplayContext.display(navigationVC)
    } else if let shareVC = shareVC {     // else just show shareVC
      sourceDisplayContext.display(shareVC)
    }
  }
  
  func leave() {
    if let cancel = cancel {
      cancel()
    } else {
      sourceDisplayContext.undisplay(navigationVC)
    }
  }
  
  // Choose Friend
  func showChooseFriend(initialFriendIDs: [Int]) {
    guard let sourceVC = navigationVC ?? shareVC
    else { return }
    
    let displayContext: DisplayContext = .present(vc: sourceVC, animated: true, style: .overCurrentContext)
    let chooseFriendFlowController = V4ChooseFriendFlowController(delegate: self,
                                          sourceDisplayContext: displayContext,
                                          initialChosenFriendIDs: initialFriendIDs)
    
    addChild(flowController: chooseFriendFlowController)
    
    chooseFriendFlowController.prepare()
    chooseFriendFlowController.start()
  }
  


  
  // MARK: - Type Definitions
}


extension V4ShareFlowController: V4ChooseFriendFlowControllerDelegate {
  func choseFriends(_ friends: [FriendListViewController.Friend]) {
    shareVC?.changeSharedFriends(friends)
  }
}
