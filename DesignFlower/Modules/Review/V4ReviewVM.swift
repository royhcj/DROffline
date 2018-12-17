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
  
  var review: KVORestReviewV4? {
    didSet {
      if let review = review {
        observe = RestReviewObserve(object: review)
      }
    }
  }
  var observe: RestReviewObserve?

  init(output: Output?, reviewUUID: String?) {
    review = {
      let review = KVORestReviewV4(uuid: reviewUUID)
      self.observe = RestReviewObserve(object: review)
      return review
    }()
    
    self.output = output
  }
  
  func setReview(_ review: KVORestReviewV4) {
    self.review = review
    output?.refreshReview()
  }
  
  func addDishReview() {
    let dishReview = KVODishReviewV4(uuid: nil)
    review?.dishReviews.append(dishReview)
    
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
  
  
  
  // Change Methods
  func changeReviewTitle(_ title: String?) {
    review?.title = title
  }
  
  func changeReviewComment(_ comment: String?) {
    review?.comment = comment
  }
  
  func changePriceRank(_ rank: Float) {
    review?.priceRank = String(format: "%.1f", rank)
  }
  
  func changeServiceRank(_ rank: Float) {
    review?.serviceRank = String(format: "%.1f", rank)
  }
  
  func changeEnvironmentRank(_ rank: Float) {
    review?.environmentRank = String(format: "%.1f", rank)
  }
  
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
}
