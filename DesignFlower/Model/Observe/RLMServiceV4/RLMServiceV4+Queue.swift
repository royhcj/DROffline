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

  internal class Queue {

    internal var realm: Realm
    internal var realmService: RLMServiceV4

    init(realmService: RLMServiceV4) {
      self.realmService = realmService
      self.realm = realmService.realm
    }

    // no.1
    internal func createRLMQueue(copyBy restReview: RLMRestReviewV4) {
      do {
        try realm.write {
          let queueReview = realm.create(RLMQueue.self)
          queueReview.queueDate = Date.now

          for allowReader in restReview.allowedReaders {
            queueReview.allowedReaders.append(allowReader)
          }

          queueReview.comment = restReview.comment
          queueReview.createDate = restReview.createDate
          for dishReview in restReview.dishReviews {
            queueReview.dishReviews.append(dishReview)
          }
          queueReview.eatingDate = restReview.eatingDate
          queueReview.environmentRank = restReview.environmentRank
          queueReview.id.value = restReview.id.value
          queueReview.isFirst = restReview.isFirst
          queueReview.isScratch.value = restReview.isScratch.value
          queueReview.isShowComment = restReview.isShowComment
          queueReview.isSync = restReview.isSync
          queueReview.parentID.value = restReview.parentID.value
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

      let predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
      let queueReview = realm.objects(RLMQueue.self).filter(predicate).first
      return queueReview

    }

    // no.4
    internal func createDeleteQueue(uuid: String, id: Int?) {
      do {
        try realm.write {
          let queueReview = realm.create(RLMQueue.self)
          queueReview.queueDate = Date.now
          queueReview.isDelete = true
          queueReview.uuid = uuid
          queueReview.id.value = id

        }

      } catch {
        print("RLMServiceV4+Queue file's no.4 func error")
      }
    }

    // no.5
    internal func update(queue: RLMQueue, isStartUpload: Bool) {
      do {
        try realm.write {
          queue.isStartUpload = isStartUpload
        }
      } catch {
        print("RLMServiceV4+Queue file's no.5 func error")
      }
    }

  }


}
