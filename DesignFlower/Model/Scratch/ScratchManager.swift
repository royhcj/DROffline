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
  
  func createNewScratch() -> KVORestReviewV4 {
    let restReview = KVORestReviewV4(uuid: nil)
    restReview.isScratch = true
    return restReview
  }
  
  func getScratch(originalUUID: String) -> KVORestReviewV4 {
    if let rlmScratch = RLMScratchServiceV4.scratchShared.getRestReview(uuid: originalUUID, id: nil) {
      let scratch = KVORestReviewV4(with: rlmScratch)
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
                          dishReviews: rlmOriginal.dishReviews, // TODO: Should make a copy
                          restaurant: rlmOriginal.restaurant)
      rlmScratch.isScratch.value = true
      RLMServiceV4.shared.createRLM(with: rlmScratch)
      
      let scratch = KVORestReviewV4(with: rlmScratch)
      return scratch
    } else {
      print("Error: Unable to create scratch with uuid \(originalUUID).")
      let scratch = KVORestReviewV4(uuid: nil)
      scratch.isScratch = true
      return scratch
    }
  }
}
