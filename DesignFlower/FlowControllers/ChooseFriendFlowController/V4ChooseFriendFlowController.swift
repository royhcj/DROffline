//
//  V4ChooseFriendFlowController.swift
//  DesignFlower
//
//  Created by roy on 1/15/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

class V4ChooseFriendFlowController: ViewBasedFlowController,
                                    ChooseFriendViewControllerFlowDelegate {
  
  var chooseFriendVC: ChooseFriendViewController?
  
  var sourceDisplayContext: DisplayContext
  var initialChosenFriendIDs: [Int] = []
  
  weak var delegate: V4ChooseFriendFlowControllerDelegate?
  
  init(delegate: V4ChooseFriendFlowControllerDelegate,
       sourceDisplayContext: DisplayContext,
       initialChosenFriendIDs: [Int] = []) {
    self.delegate = delegate
    self.sourceDisplayContext = sourceDisplayContext
    self.initialChosenFriendIDs = initialChosenFriendIDs
  }
  
  deinit {
    print("V4ChooseFriendFlowController.deinit")
  }
  
  override func prepare() {
    let storyboard = UIStoryboard.init(name: "ChooseFriend", bundle: nil)
    if let vc = storyboard.instantiateViewController(withIdentifier: "ChooseFriendViewController") as? ChooseFriendViewController {
      vc.providesPresentationContextTransitionStyle = true
      vc.definesPresentationContext = true
      vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
      vc.flowDelegate = self
      
      chooseFriendVC = vc
    }
  }
  
  override func start() {
    guard let chooseFriendVC = chooseFriendVC
    else { return }
    
    sourceDisplayContext.display(chooseFriendVC)
  }
  
  func leave() {
    sourceDisplayContext.undisplay(chooseFriendVC)
  }
  
  func choseFriends(_ friends: [FriendListViewController.Friend]) {
    delegate?.choseFriends(friends)
    leave()
  }
  
  
}

protocol V4ChooseFriendFlowControllerDelegate: class {
  func choseFriends(_ friends: [FriendListViewController.Friend])
}
