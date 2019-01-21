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

  internal var realmService = RLMServiceV4.shared
  
  required init(object: KVOImageV4, service: RLMServiceV4?) {
    if let service = service {
      self.realmService = service
    }
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
             self.realmService.image.update(dbObject, phassetID: newValue)
          }
        },
        object.observe(\.localName, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, localName: newValue)
          }
        },
        object.observe(\.imageID, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, imageID: newValue)
          }
        },
        object.observe(\.url, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, url: newValue)
          }
        },
        object.observe(\.imageStatus, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, imageStatus: newValue)
          }
        },
        object.observe(\.photoLatitude, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, photoLatitude: newValue)
          }
        },
        object.observe(\.photoLongtitude, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, photoLongtitude: newValue)
          }
        },
        object.observe(\.order, options: [.initial, .old, .new]) { (image, change) in
          if let newValue = change.newValue {
            self.realmService.image.update(dbObject, order: newValue)
          }
        }
    ]

  }
}
