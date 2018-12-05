//
//  V4ReviewVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/29.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4ReviewViewModel {
  
  weak var output: Output?
  
  var review: KVORestReviewV4?

  init(output: Output?, reviewUUID: String?) {
    review = KVORestReviewV4(uuid: reviewUUID)
  }
  
  func setReview(_ review: KVORestReviewV4) {
    self.review = review
    output?.refreshReview()
  }
  
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
}
