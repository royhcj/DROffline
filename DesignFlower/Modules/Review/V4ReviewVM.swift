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
  
  private weak var output: Output?
  
  var review: KVORestReviewV4? {
                didSet {
                  if let review = review {
                    observe = RestReviewObserve(object: review)
                  } else {
                    observe = nil
                  }
                }
              }
  var observe: RestReviewObserve?
  var dirty: Bool = false

  init(output: Output?, reviewUUID: String?) {
    review = {
      let review = KVORestReviewV4(uuid: reviewUUID)
      self.observe = RestReviewObserve(object: review)
      print("new review: \(review.uuid))")
//      DispatchQueue.main.asyncAfter(deadline: .now()) {
//        self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
//      }
      self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
      return review
    }()
    
    self.output = output
  }
  
  func setReview(_ review: KVORestReviewV4) {
    clearScratch()
    
    self.review = review
//    DispatchQueue.main.asyncAfter(deadline: .now()) {
//      self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
//    }
    self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
    
    output?.refreshReview()
  }
  
  // MARK: - DishReview Manipulation
  func addDishReview() {
    let dishReview = KVODishReviewV4(uuid: nil)
    review?.dishReviews.append(dishReview)
    
    setDirty(true)
    output?.refreshReview()
  }
  
  func addDishReviews(with assets: [PHAsset]) {
    for asset in assets {
      let dishReview = KVODishReviewV4(uuid: nil)
      
      review?.dishReviews.append(dishReview)
      
      V4PhotoService.shared.createKVOImage(with: asset) { [weak self] image in
        guard let image = image
        else { return }
        
        dishReview.images.append(image)

        self?.output?.refreshReview()
      }
    }
    setDirty(!assets.isEmpty)
    output?.refreshReview()
  }
  
  func getDishReview(_ dishReviewUUID: String) -> KVODishReviewV4? {
    return review?.dishReviews.first(where: {
      $0.uuid == dishReviewUUID
    })
  }
  
  // MARK: - Save Review
  func saveReview() {
    // TODO: Call Save
    setDirty(false)
  }
  
  // MARK: - Dirty Manipulation
  func setDirty(_ dirty: Bool) {
    self.dirty = dirty
    
    output?.refreshDirty()
  }
  
  // MARK: - Review Change Methods
  func changeReviewTitle(_ title: String?) {
    review?.title = title
    setDirty(true)
  }
  
  func changeReviewComment(_ comment: String?) {
    review?.comment = comment
    setDirty(true)
  }
  
  func changePriceRank(_ rank: Float) {
    review?.priceRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func changeServiceRank(_ rank: Float) {
    review?.serviceRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func changeEnvironmentRank(_ rank: Float) {
    review?.environmentRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func clearScratch() {
    if let oldReviewUUID = self.review?.uuid {
      print("deleting \(oldReviewUUID) TODO: ***")
      DispatchQueue.main.asyncAfter(deadline: .now()) {
        RLMServiceV4.shared.delete(reviewUUID: oldReviewUUID) // TODO: 應該只刪scratch
      }
    }
    review = nil
  }
  
  // MARK: - Dish Review Change Methods
  func changeDishReviewDish(for dishReviewUUID: String, name: String, dishID: Int?) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.dish?.name = name
    if let dishID = dishID {
      dishReview.dish?.id = dishID
    }
    setDirty(true)
  }
  
  func changeDishReviewComment(for dishReviewUUID: String, comment: String) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.comment = comment
    setDirty(true)
  }
  
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.rank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func deleteDishReview(for dishReviewUUID: String) {
    guard let dishReview = getDishReview(dishReviewUUID),
          let index = review?.dishReviews.firstIndex(where: {
            $0 == dishReview
          })
    else { return }
    
    review?.dishReviews.remove(at: index)
    setDirty(true)
  }
  
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
  func refreshDirty()
}
