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
                  // 清除observer
                  if observe != nil {
                    observe?.cancelObserve()
                    observe = nil
                  }
                  // 製造observer
                  if let review = review {
                    observe = RestReviewObserve(object: review)
                  }
                }
              }
  var observe: RestReviewObserve?
  var dirty: Bool = false
  
  var lastBlankDishReviewUUID: String?

  init(output: Output?, reviewUUID: String?) {
    review = {
      let review = KVORestReviewV4(uuid: reviewUUID)
      self.observe = RestReviewObserve(object: review)
      print("new review: \(review.uuid))")
      self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
      return review
    }()
    
    self.output = output
  }
  
  func setReview(_ review: KVORestReviewV4) {
    clearScratch()
    
    self.review = review
    self.review?.isScratch = true // TODO: 暫時先這樣，稍後設計scratch機制
    
    output?.refreshReview()
  }
  
  // MARK: - DishReview Manipulation
  func addDishReview() {
    guard let review = review else { return }
    
    // 如果有空白的dish review, 捲動至該dish review即可
    if let blankDishReviewUUID = lastBlankDishReviewUUID,
       let index = review.dishReviews.firstIndex(where: { $0.uuid == blankDishReviewUUID }) {
      output?.scrollToDishReviewAtIndex(index)
      return
    }
    
    // 加入新的空白dish review
    let dishReview = KVODishReviewV4(uuid: nil)
    review.dishReviews.append(dishReview)
    lastBlankDishReviewUUID = dishReview.uuid
    
    setDirty(true)
    output?.refreshReview()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.output?.scrollToDishReviewAtIndex(review.dishReviews.count - 1)
    }
  }
  
  func addDishReviews(with assets: [PHAsset]) {
    guard let review = review else { return }
    
    for asset in assets {
      let dishReview = KVODishReviewV4(uuid: nil)
      
      review.dishReviews.append(dishReview)
      
      V4PhotoService.shared.createKVOImage(with: asset) { [weak self] image in
        guard let image = image
        else { return }
        
        dishReview.images.append(image)

        self?.output?.refreshReview()
        
        if asset == assets.last {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.output?.scrollToDishReviewAtIndex(review.dishReviews.count - 1)
          }
        }
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
  
  func setDirty(_ dirty: Bool, forDishReview dishReview: KVODishReviewV4) {
    if dishReview.uuid == lastBlankDishReviewUUID {
      lastBlankDishReviewUUID = nil
    }
    setDirty(dirty)
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
  
  func changeDiningTime(_ date: Date?) {
    review?.eatingDate = date
    setDirty(true)
    output?.refreshReview()
  }
  
  func deleteReview() {
    if let oldReviewUUID = self.review?.uuid {
      RLMServiceV4.shared.delete(reviewUUID: oldReviewUUID)
    }
    review = nil
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
    setDirty(true, forDishReview: dishReview)
  }
  
  func changeDishReviewComment(for dishReviewUUID: String, comment: String) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.comment = comment
    setDirty(true, forDishReview: dishReview)
  }
  
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.rank = String(format: "%.1f", rank)
    setDirty(true, forDishReview: dishReview)
  }
  
  func mergeDishReview(from sourceDishReviewUUID: String, to targetDishReviewUUID: String) {
    guard let source = getDishReview(sourceDishReviewUUID),
          let target = getDishReview(targetDishReviewUUID)
    else { return }
    
    // merge photos
    target.images.append(contentsOf: source.images)

    deleteDishReview(for: sourceDishReviewUUID)
  }
  
  func reorderDishReview(from indexA: Int, to indexB: Int) -> Bool {
    guard let review = review,
          UInt(indexA) < review.dishReviews.count,
          UInt(indexB) < review.dishReviews.count
    else { return false}
    
    let orderA = review.dishReviews[indexA].order
    review.dishReviews[indexA].order = review.dishReviews[indexB].order
    review.dishReviews[indexB].order = orderA
    review.dishReviews.sort {
      $0.order < $1.order
    }
    setDirty(true)
    
    return true
  }
  
  func deleteDishReview(for dishReviewUUID: String) {
    guard let dishReview = getDishReview(dishReviewUUID),
          let index = review?.dishReviews.firstIndex(where: {
            $0 == dishReview
          })
    else { return }
    
    review?.dishReviews.remove(at: index)
    setDirty(true, forDishReview: dishReview)
    output?.refreshReview()
  }
  
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
  func refreshDirty()
  func scrollToDishReviewAtIndex(_ index: Int)
}
