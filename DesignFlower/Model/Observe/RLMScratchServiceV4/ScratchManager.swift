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
        = RLMRestReviewV4(uuid: rlmOriginal.uuid,
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

    updateIDsFromOriginal(for: scratch)
    
    // 寫入更新時間
    scratch.updateDate = Date.now
    
    // 利用observe寫回Database
      if let rlmScratch = RLMScratchServiceV4.scratchShared.getRestReview(uuid: scratch.uuid) {
        guard let rlmRestReview = RLMServiceV4.shared.getRestReview(uuid: reviewUUID, id: nil) else {
          let rlmRestReview = RLMServiceV4.shared.createRLMRestReviewV4()!
          RLMServiceV4.shared.update(rlmRestReview, with: rlmScratch)
          RLMServiceV4.shared.update(rlmRestReview, isSync: needSync)
          completion()
          return
        }
          RLMServiceV4.shared.update(rlmRestReview, with: rlmScratch)
          RLMServiceV4.shared.update(rlmRestReview, isSync: needSync)
          completion()
      }
  }
  
  func updateIDsFromOriginal(for scratch: KVORestReviewV4) {
    let reviewUUID = scratch.uuid
    
    guard RLMServiceV4.shared.isExist(reviewUUID: reviewUUID,
                                      reviewID: nil)
    else {
      return
    }
    
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
            scratchImage.url = rlmImage.url
          }
        }
      }
    } // end for scratch DishReviews
  
  }

}
