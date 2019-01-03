//
//  RLMServiceV4+DishReview.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/26.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  // no.1
  internal func create(from restReview: RLMRestReviewV4, dishReview: KVODishReviewV4) {
    do {
      try realm.write {
        let rlmDishReview = realm.create(RLMDishReviewV4.self)
        rlmDishReview.uuid = dishReview.uuid
        rlmDishReview.rank = dishReview.rank
        rlmDishReview.comment = dishReview.comment
        rlmDishReview.id.value = dishReview.id
        rlmDishReview.isCreate = dishReview.isCreate
        rlmDishReview.createDate = dishReview.createDate
        rlmDishReview.parentID.value = dishReview.parentID
        rlmDishReview.isLike.value = dishReview.isLike
        rlmDishReview.order.value = dishReview.order
        restReview.dishReviews.append(rlmDishReview)
        for kvoImage in dishReview.images {
          RLMServiceV4.shared.createRLMImage(in: rlmDishReview, kvoImage: kvoImage)
        }
        if let dish = dishReview.dish {
          RLMServiceV4.shared.createRLMDish(in: rlmDishReview, kvoDish: dish)
        }
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.1 func error")
    }
  }

  // no.2
  internal func update(_ dishReview: RLMDishReviewV4, comment: String?) {
    do {
      try realm.write {
        dishReview.comment = comment
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.2 func error")
    }
  }

  // no.3
  internal func update(_ dishReview: RLMDishReviewV4, rank: String?) {
    do {
      try realm.write {
          dishReview.rank = rank
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.3 func error")
    }
  }

  // no.4
  internal func update(_ dishReview: RLMDishReviewV4, id: Int?) {
    do {
      try realm.write {
        dishReview.id.value = id
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.4 func error")
    }
  }

  // no.5
  internal func update(_ dishReview: RLMDishReviewV4, isCreate: Bool) {
    do {
      try realm.write {
        dishReview.isCreate = isCreate
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.5 func error")
    }
  }

  // no.6
  internal func update(_ dishReview: RLMDishReviewV4, createDate: Date) {
    do {
      try realm.write {
        dishReview.createDate = createDate
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.6 func error")
    }
  }

  // no.7
  internal func update(_ dishReview: RLMDishReviewV4, parentID: Int?) {
    do {
      try realm.write {
        dishReview.parentID.value = parentID
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.7 func error")
    }
  }

  // no.8
  internal func update(_ dishReview: RLMDishReviewV4, isLike: Bool?) {
    do {
      try realm.write {
         dishReview.isLike.value = isLike
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.8 func error")
    }
  }

  // no.9
  internal func update(_ dishReview: RLMDishReviewV4, order: Int?) {
    do {
      try realm.write {
        dishReview.order.value = order
      }
    } catch {
      print("RLMServiceV4+DihsReview file's no.9 func error")
    }
  }
  
  // no. 10
  internal func getDishReview(uuid: String) -> RLMDishReviewV4? {
    let predicate = NSPredicate(format: "uuid == \(uuid)'")
    let dishReview = realm.objects(RLMDishReviewV4.self).filter(predicate).first
    return dishReview
  }

}
