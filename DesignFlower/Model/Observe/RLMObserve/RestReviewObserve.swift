////
////  RLMObserve.swift
////  DishRank
////
////  Created by 馮仰靚 on 2018/11/16.
////
//
import Foundation
import RealmSwift

class RestReviewObserve: RLMObserveDelegate {

  typealias KVOType = KVORestReviewV4
  typealias RLMType = RLMRestReviewV4
  internal var observers = [NSKeyValueObservation]()
  internal var dbObject: RLMRestReviewV4?

  private var dishObservers = [DishReviewObserve]()
  private var restObservers = [RestaurantObserve]()

  required init(object: KVORestReviewV4) {
    bindRLM(uuid: object.uuid)
    observe(object: object)
  }
  
  func cancelObserve() {
    dishObservers.forEach { $0.cancelObserve() }
    restObservers.forEach { $0.cancelObserve() }
    observers = []
  }

  /// 將變數全部加入observe，除了物件類型的變數
  ///
  /// - Parameter object: KVORestReviewV4
  internal func observe(object: KVORestReviewV4) {
    guard let dbObject = self.dbObject else {
      return
    }
    observers =
    [
      object.observe(\.serviceRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, serviceRank: newValue)
        }
      },
      object.observe(\.environmentRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, environmentRank: newValue)
        }
      },
      object.observe(\.priceRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, priceRank: newValue)
        }
      },
      object.observe(\.title, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let title = newValue {
          RLMServiceV4.shared.update(dbObject, title: title)
        }
      },
      object.observe(\.comment, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let comment = newValue {
          RLMServiceV4.shared.update(dbObject, comment: comment)
        }
      },
      object.observe(\.id, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, id: newValue)
        }
      },
      object.observe(\.isScratch, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, isScratch: newValue)
        }
      },
      object.observe(\.allowedReaders, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, allowedReaders: newValue)
        }
      },
      object.observe(\.createDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, createDate: newValue)
        }
      },
      object.observe(\.eatingDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, eatingDate: newValue)
        }
      },
      object.observe(\.parentID, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, parentID: newValue)
        }
      },
      object.observe(\.parentUUID, options:
          [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, parentUUID: newValue)
        }
      },
      object.observe(\.isShowComment, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, isShowComment: newValue)
        }
      },
      object.observe(\.isSync, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, isSync: newValue)
        }
      },
      object.observe(\.updateDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, updateDate: newValue)
        }
      },
      object.observe(\.isFirst, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          RLMServiceV4.shared.update(dbObject, isFirst: newValue)
        }
      },
      object.observe(\.restaurant, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let restaurant = newValue {
          self.restObservers.append(RestaurantObserve(object: restaurant))
        } else if
          let oldValue = change.oldValue,
          let restUUID = oldValue?.uuid,
          let newValue = change.newValue,
          newValue == nil
        {
          RLMServiceV4.shared.delete(restUUID: restUUID)
        }
      },
      object.observe(\.dishReviews, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let oldValue = change.oldValue {
          self.restReviewLinkDishReview(olds: oldValue, news: newValue)
        }
      }
    ]
  }

  private func restReviewLinkDishReview(olds: [KVODishReviewV4], news: [KVODishReviewV4]) {
    guard let dbObject = self.dbObject else {
      return
    }
    let willBeAdded = Set(news).subtracting(Set(olds))
    let willBeDeleted = Set(olds).subtracting(Set(news))
    for dishReview in willBeAdded {
      RLMServiceV4.shared.create(from: dbObject, dishReview: dishReview)
      dishObservers.append(DishReviewObserve.init(object: dishReview))
    }
    for dishReview in willBeDeleted {
      let dishObserveIndex = dishObservers.index(where: {
          $0.dbObject?.uuid == dishReview.uuid
        })
      if let dishObserveIndex = dishObserveIndex{
        dishObservers[dishObserveIndex].cancelObserve()
        dishObservers.remove(at: dishObserveIndex)
        print("test")
      }
      RLMServiceV4.shared.delete(dishReviewUUID: dishReview.uuid)
    }
  }

  deinit {
    print("observe deinit")
  }

}
