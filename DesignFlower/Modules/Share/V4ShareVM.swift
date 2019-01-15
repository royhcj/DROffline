//
//  V4ShareVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/26.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4ShareViewModel: V4ReviewViewModel {
  
  weak var output: V4ShareViewModelOutput?
  
  var sharedFriends: [FriendListViewController.Friend] = []
  
  
  override init(output: Output?, reviewUUID: String?) {
    super.init(output: output, reviewUUID: reviewUUID)
    if let output = output as? V4ShareViewModelOutput {
      self.output = output
    }
  }
  
  // MARK: - ► Friend Related
  func changeSharedFriends(_ friends: [FriendListViewController.Friend]) {
    sharedFriends = friends
    review?.allowedReaders = friends.map { String($0.id) }
    //review?.shareType = 2
    self.output?.refreshReview()
  }
}

protocol V4ShareViewModelOutput: class {
  func refreshReview()
}
