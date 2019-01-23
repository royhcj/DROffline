//
//  DishReviewObserve.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/22.
//

import Foundation

class DishReviewObserve: RLMObserveDelegate {

  typealias RLMType = RLMDishReviewV4
  typealias KVOType = KVODishReviewV4
  var dbObject: RLMDishReviewV4?
  internal var observers = [NSKeyValueObservation]()
  private var imageObservers = [ImageObserve]()
  private var dishObserves = [DishObserve]()

  internal var realmService = RLMServiceV4.shared
  
  required init(object: KVODishReviewV4, service: RLMServiceV4?) {
    if let service = service {
      self.realmService = service
    }
    bindRLM(uuid: object.uuid, service: realmService)
    observe(object: object)
  }
  
  func cancelObserve() {
    imageObservers.forEach { $0.cancelObserve() }
    dishObserves.forEach { $0.cancelObserve() }
    observers = []
  }

  internal func observe(object: KVODishReviewV4) {
    guard let dbObject = self.dbObject else {
      return
    }
    observers =
    [
      object.observe(\.comment, options: [.initial, .old, .new]) { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, comment: newValue)
        }
      },
      object.observe(\.rank, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, rank: newValue)
        }
      }),
      object.observe(\.id, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, id: newValue)
        }
      }),
      object.observe(\.isCreate, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, isCreate: newValue)
        }
      }),
      object.observe(\.createDate, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, createDate: newValue)
        }
      }),
      object.observe(\.parentID, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, parentID: newValue)
        }
      }),
      object.observe(\.isLike, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, isLike: newValue)
        }
      }),
      object.observe(\.order, options: [.initial, .old, .new], changeHandler: { (dishReview, change) in
        if let newValue = change.newValue {
          self.realmService.dishReview.update(dbObject, order: newValue)
        }
      }),
      object.observe(\.images, options: [.initial, .old, .new]) { (dishReview, change) in
        if let oldValue = change.oldValue, let newValue = change.newValue {
          self.dishReviewLinkImage(olds: oldValue, news: newValue)
        }
      },
      object.observe(\.dish, options: [.initial, .old, .new]) { (dishReview, change) in
        if let newValue = change.newValue, let dish = newValue {
          self.dishObserves.append(DishObserve(object: dish,
                                               service: self.realmService))
          self.realmService.dishReview.update(dbObject, dish: dish)
        } else if
            let oldValue = change.oldValue,
            let dishUUID = oldValue?.uuid,
            let newValue = change.newValue,
            newValue == nil {
            self.realmService.dish.delete(dishUUID: dishUUID)
        }
      }
    ]
  }


  private func dishReviewLinkImage(olds: [KVOImageV4], news: [KVOImageV4]) {
    guard let dbObject = self.dbObject else {
      return
    }
    let willBeAdded = Set(news).subtracting(Set(olds))
    let willBeDeleted = Set(olds).subtracting(Set(news))
    for kvoImage in willBeAdded {
      self.realmService.image.createRLMImage(in: dbObject, kvoImage: kvoImage)
      imageObservers.append(ImageObserve(object: kvoImage,
                                         service: realmService))
    }
    for kvoImage in willBeDeleted {
      realmService.image.delete(imageUUID: kvoImage.uuid)
    }
  }

  deinit {
    print("RLMDishReveiwV4 deinit")
  }


}
