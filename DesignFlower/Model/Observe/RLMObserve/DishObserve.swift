//
//  DishObserve.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/22.
//

import Foundation

class DishObserve: RLMObserveDelegate {

  typealias RLMType = RLMDishV4
  typealias KVOType = KVODishV4
  var dbObject: RLMDishV4?
  var observers: [NSKeyValueObservation] = []

  internal var realmService = RLMServiceV4.shared
  
  required init(object: KVODishV4, service: RLMServiceV4?) {
    if let service = service {
      self.realmService = service
    }
    bindRLM(uuid: object.uuid)
    observe(object: object)
  }

  func observe(object: KVODishV4) {
    guard let dbObject = dbObject else {
      return
    }
    observers = [
      object.observe(\.name, options: [.initial, .old,  .new], changeHandler: { (dish, change) in
        if let newValue = change.newValue {
          self.realmService.dish.update(dbObject, name: newValue)
        }
      }),
      object.observe(\.id, options: [.initial, .old, .new], changeHandler: { (dish, change) in
          self.realmService.dish.update(dbObject, id: change.newValue)
      })
    ]
  }




}
