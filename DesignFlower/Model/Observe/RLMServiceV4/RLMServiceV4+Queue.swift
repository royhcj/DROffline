//
//  RLMServiceV4+Queue.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2018/12/22.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  // no.1
  internal func createRLMQueue(copyBy restReview: RLMRestReviewV4) {
    do {
      try realm.write {
        let queueReview = realm.create(RLMQueue.self)
        queueReview.queueDate = Date()

        queueReview.allowedReaders = restReview.allowedReaders
        queueReview.comment = restReview.comment
        queueReview.createDate = restReview.createDate
        queueReview.dishReviews = restReview.dishReviews
        queueReview.eatingDate = restReview.eatingDate
        queueReview.environmentRank = restReview.environmentRank
        queueReview.id = restReview.id
        queueReview.isFirst = restReview.isFirst
        queueReview.isScratch = restReview.isScratch
        queueReview.isShowComment = restReview.isShowComment
        queueReview.isSync = restReview.isSync
        queueReview.parentID = restReview.parentID
        queueReview.priceRank = restReview.priceRank
        queueReview.restaurant = restReview.restaurant
        queueReview.serviceRank = restReview.serviceRank
        queueReview.title = restReview.title
        queueReview.updateDate = restReview.updateDate
        queueReview.uuid = restReview.uuid
      }
    } catch {
      print("RLMServiceV4+Queue file's no.1 func error")
    }
  }

  // no.2
  internal func delete(queue: RLMQueue) {
    do {
      try realm.write {
        realm.delete(queue)
      }
    } catch {
      print("RLMServiceV4+Queue file's no.2 func error")
    }
  }

  // no.3
  internal func getQueueReview(uuid: String) -> RLMQueue? {
    do {
      var queueReview: RLMQueue?
      try realm.write {
        let predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
        queueReview = realm.objects(RLMQueue.self).filter(predicate).first
      }
      return queueReview
    } catch {
      print("RLMServiceV4+Queue file's no.3 func error")
      return nil
    }
  }

  // no.4
  internal func createDeleteQueue(uuid: String, id: Int?) {
    do {
      try realm.write {
        let queueReview = realm.create(RLMQueue.self)
        queueReview.queueDate = Date()
        queueReview.isDelete = true
        queueReview.uuid = uuid
        queueReview.id.value = id

      }

    } catch {
      print("RLMServiceV4+Queue file's no.4 func error")
    }
  }
}
