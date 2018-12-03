//
//  ImageObserve.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/22.
//

import Foundation

class ImageObserve: RLMObserveDelegate {

  typealias KVOType = KVOImageV4
  typealias RLMType = RLMImageV4
  var dbObject: RLMImageV4?
  var observers = [NSKeyValueObservation]()

  required init(object: KVOImageV4) {
    bindRLM(uuid: object.uuid)
    observe(object: object)
  }

  internal func observe(object: KVOImageV4) {
    guard let dbObject = self.dbObject else {
      print("『\(RLMType.description())』 bind error")
      return
    }

    observers =
      [
        object.observe(\.phassetID, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
             RLMServiceV4.shared.update(dbObject, phassetID: newValue)
          }
        },
        object.observe(\.localName, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, localName: newValue)
          }
        },
        object.observe(\.imageID, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, imageID: newValue)
          }
        },
        object.observe(\.url, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, url: newValue)
          }
        },
        object.observe(\.imageStatus, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, imageStatus: newValue)
          }
        },
        object.observe(\.photoLatitude, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, photoLatitude: newValue)
          }
        },
        object.observe(\.photoLongtitude, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, photoLongtitude: newValue)
          }
        },
        object.observe(\.order, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            RLMServiceV4.shared.update(dbObject, order: newValue)
          }
        }
    ]

  }
}
