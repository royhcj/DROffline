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
  
  private weak var kvoObject: KVOType?
  
  internal var realmService = RLMServiceV4.shared

  required init(object: KVORestReviewV4, service: RLMServiceV4?) {
    if let service = service {
      self.realmService = service
    }
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
    kvoObject = object
    
    observers =
    [
      object.observe(\.serviceRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, serviceRank: newValue)
        }
      },
      object.observe(\.environmentRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, environmentRank: newValue)
        }
      },
      object.observe(\.priceRank, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, priceRank: newValue)
        }
      },
      object.observe(\.title, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let title = newValue {
          self.realmService.update(dbObject, title: title)
        }
      },
      object.observe(\.comment, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let comment = newValue {
          self.realmService.update(dbObject, comment: comment)
        }
      },
      object.observe(\.id, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, id: newValue)
        }
      },
      object.observe(\.isScratch, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, isScratch: newValue)
        }
      },
      object.observe(\.allowedReaders, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, allowedReaders: newValue)
        }
      },
      object.observe(\.createDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, createDate: newValue)
        }
      },
      object.observe(\.eatingDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, eatingDate: newValue)
        }
      },
      object.observe(\.parentID, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, parentID: newValue)
        }
      },
      object.observe(\.parentUUID, options:
          [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, parentUUID: newValue)
        }
      },
      object.observe(\.isShowComment, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, isShowComment: newValue)
        }
      },
      object.observe(\.isSync, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, isSync: newValue)
        }
      },
      object.observe(\.updateDate, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, updateDate: newValue)
        }
      },
      object.observe(\.isFirst, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, isFirst: newValue)
        }
      },
      object.observe(\.restaurant, options: [.initial, .old, .new]) { (restReview, change) in
        if let newValue = change.newValue, let restaurant = newValue {
          self.restObservers.append(RestaurantObserve(object: restaurant,
                                                      service: self.realmService))
          self.realmService.update(dbObject, restaurant: restaurant)
        } else if
          let oldValue = change.oldValue,
          let restUUID = oldValue?.uuid,
          let newValue = change.newValue,
          newValue == nil
        {
          self.realmService.delete(restUUID: restUUID)
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
    
    // 加入新的DishReview
    for dishReview in willBeAdded {
      self.realmService.dishReview.create(from: dbObject, dishReview: dishReview)
      dishObservers.append(DishReviewObserve.init(object: dishReview,
                                                  service: realmService))
    }
    // 刪除多出來的dishReview
    for dishReview in willBeDeleted {
      // 刪除該dishReview的observer
      let dishObserveIndex = dishObservers.index(where: {
          $0.dbObject?.uuid == dishReview.uuid
        })
      if let dishObserveIndex = dishObserveIndex{
        dishObservers[dishObserveIndex].cancelObserve()
        dishObservers.remove(at: dishObserveIndex)
      }
      realmService.delete(dishReviewUUID: dishReview.uuid)
    }
    
    // Reorder
    guard let kvoObject = kvoObject
    else { return }
    
    for (index, dishReview) in kvoObject.dishReviews.enumerated() {
      if index != dishReview.order {
        dishReview.order = index
      }
    }
    
    realmService.sortDishReviewsByOrder(for: dbObject)
  }

  deinit {
    print("observe deinit")
  }

}
