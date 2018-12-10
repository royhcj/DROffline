//
//  V4ReviewVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/29.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import Photos

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
  
  func addDishReviews(with assets: [PHAsset]) {
    for asset in assets {
      let image = KVOImageV4(uuid: nil)
      image.phassetID = asset.localIdentifier
      image.imageStatus = ImageStatus.initial.rawValue
      
      let dishReview = KVODishReviewV4(uuid: nil)
      dishReview.images.append(image)
      
      review?.dishReviews.append(dishReview)
    }
    output?.refreshReview()
  }
  
  
  
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
}
