//
//  ScratchManager.swift
//  DesignFlower
//
//  Created by roy on 1/20/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class ScratchManager {
  
  static var shared = ScratchManager()
  var scratchService: RLMServiceV4 = RLMScratchServiceV4.scratchShared
  
  // MARK: - Get Scratch Methods
  func getScratch(originalUUID: String?) -> KVORestReviewV4 {
    guard let originalUUID = originalUUID
    else {
      let scratch = KVORestReviewV4(uuid: nil)
      scratch.isScratch = true
      return scratch
    }
    
    if let rlmScratch = scratchService.getRestReview(uuid: originalUUID, id: nil) {
      let scratch = KVORestReviewV4(with: rlmScratch)
      scratch.isScratch = true
      return scratch
    }
    else if let rlmOriginal = RLMServiceV4.shared.getRestReview(uuid: originalUUID) {
      let rlmScratch
        = RLMRestReviewV4(uuid: nil,
                          serviceRank: rlmOriginal.serviceRank,
                          environmentRank: rlmOriginal.environmentRank,
                          priceRank: rlmOriginal.priceRank,
                          title: rlmOriginal.title,
                          comment: rlmOriginal.comment,
                          id: rlmOriginal.id,
                          allowedReaders: rlmOriginal.allowedReaders,
                          parentID: rlmOriginal.parentID,
                          updateDate: rlmOriginal.updateDate,
                          dishReviews: rlmOriginal.dishReviews,
                          restaurant: rlmOriginal.restaurant)
      rlmScratch.isScratch.value = true
      scratchService.createRLM(with: rlmScratch)
      
      let scratch = KVORestReviewV4(with: rlmScratch)
      return scratch
    } else {
      print("Error: Unable to create scratch with uuid \(originalUUID).")
      let scratch = KVORestReviewV4(uuid: nil)
      scratch.isScratch = true
      return scratch
    }
  }
  
  // MARK: - Commit Scratch
  func commitScratch(_ scratch: KVORestReviewV4,
                     needSync: Bool,
                     completion: @escaping (() -> ())) {
    let reviewUUID = scratch.uuid
    
    // 先把id等資料寫回scratch, 避免等下原稿的id被洗掉
    if RLMServiceV4.shared.isExist(reviewUUID: reviewUUID, reviewID: nil) {
      let review = KVORestReviewV4(uuid: reviewUUID,
                                   service: RLMServiceV4.shared)
      scratch.id = review.id
      scratch.restaurant?.id = review.restaurant?.id ?? -1
      for scratchDishReview in scratch.dishReviews {
        if let dishReview = review.dishReviews.first(where: { $0.uuid == scratchDishReview.uuid }) {
          scratchDishReview.id = dishReview.id
          scratchDishReview.dish?.id = dishReview.dish?.id ?? -1
          
          for scratchImage in scratchDishReview.images {
            if let rlmImage = RLMServiceV4.shared.image.getImage(uuid: scratchImage.uuid) {
              scratchImage.imageID = rlmImage.imageID
            }
          }
        }
      } // end for scratch DishReviews
    }
    
    // 寫入更新時間
    scratch.updateDate = Date.now
    
    // 利用observe寫回Database
    let observe = RestReviewObserve(object: scratch,
                                    service: RLMServiceV4.shared)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      observe.cancelObserve()
      
      if let rlmRestReview = RLMServiceV4.shared.getRestReview(uuid: reviewUUID, id: nil) {
        RLMServiceV4.shared.update(rlmRestReview, isSync: needSync)
      }
      completion()
    }
  }
}
