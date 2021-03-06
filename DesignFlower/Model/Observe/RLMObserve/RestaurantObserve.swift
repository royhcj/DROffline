//
//  RestaurantObserve.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/22.
//

import Foundation
import RealmSwift

class RestaurantObserve: RLMObserveDelegate {

  typealias RLMType = RLMRestaurantV4
  typealias KVOType = KVORestaurantV4
  var dbObject: RLMRestaurantV4?
  var observers = [NSKeyValueObservation]()
  var imageObservers = [ImageObserve]()

  internal var realmService = RLMServiceV4.shared
  
  required init(object: KVORestaurantV4, service: RLMServiceV4?) {
    if let service = service {
      self.realmService = service
    }
    bindRLM(uuid: object.uuid, service: realmService)
    observe(object: object)
  }

  func observe(object: KVORestaurantV4) {
    guard let dbObject = dbObject else {
      return
    }

    observers = [
      object.observe(\.name, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, name: newValue)
        }
      }),
      object.observe(\.id, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, id: newValue)
        }
      }),
      object.observe(\.latitude, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, latitude: newValue)
        }
      }),
      object.observe(\.longitude, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, longitude: newValue)
        }
      }),
      object.observe(\.address, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, address: newValue)
        }
      }),
      object.observe(\.country, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, country: newValue)
        }
      }),
      object.observe(\.area, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, area: newValue)
        }
      }),
      object.observe(\.phoneNumber, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, phoneNumber: newValue)
        }
      }),
      object.observe(\.openHour, options: [.initial, .old, .new], changeHandler: { (restaurant, change) in
        if let newValue = change.newValue {
          self.realmService.update(dbObject, openHour: newValue)
        }
      }),
      object.observe(\.images, options: [.initial, .old, .new]) { (dishReview, change) in
        if let oldValue = change.oldValue, let newValue = change.newValue {
          self.restaurantLinkImage(olds: oldValue, news: newValue)
        }
      }
    ]
  }

  private func restaurantLinkImage(olds: [KVOImageV4], news: [KVOImageV4]) {
    guard let dbObject = self.dbObject else {
      return
    }
    let willBeAdded = Set(news).subtracting(Set(olds))
    let willBeDeleted = Set(olds).subtracting(Set(news))
    for kvoImage in willBeAdded {
      realmService.image.createRLMImage(in: dbObject, kvoImage: kvoImage)
      imageObservers.append(ImageObserve(object: kvoImage,
                                         service: realmService))
    }
    for kvoImage in willBeDeleted {
      realmService.image.delete(imageUUID: kvoImage.uuid)
    }
  }


}
