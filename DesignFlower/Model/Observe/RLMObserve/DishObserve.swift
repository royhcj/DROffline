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

  required init(object: KVODishV4) {
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
          RLMServiceV4.shared.dish.update(dbObject, name: newValue)
        }
      }),
      object.observe(\.id, options: [.initial, .old, .new], changeHandler: { (dish, change) in
          RLMServiceV4.shared.dish.update(dbObject, id: change.newValue)
      })
    ]
  }




}
