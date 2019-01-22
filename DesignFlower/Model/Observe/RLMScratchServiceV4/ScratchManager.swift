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
}
