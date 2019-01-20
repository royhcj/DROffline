//
//  ScrachServiceV4.swift
//  DesignFlower
//
//  Created by roy on 1/20/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class RLMScratchServiceV4: RLMServiceV4 {
  static var scratchShared = RLMScratchServiceV4()
  
  private override init() {
    super.init()
  }
  
  override func getRestReview(uuid: String?, id: Int?) -> RLMRestReviewV4? {
    var predicate: NSPredicate
    var review: RLMRestReviewV4?
    if let uuid = uuid {
      predicate = NSPredicate.init(format: "uuid == '\(uuid)' && isScratch == true")
      review = realm.objects(RLMRestReviewV4.self).filter(predicate).first
    }
    
    if let id = id {
      predicate = NSPredicate.init(format: "id == \(id) && isScratch == true")
      review = review != nil ? review : realm.objects(RLMRestReviewV4.self).filter(predicate).first
    }
    return review
  }
}
