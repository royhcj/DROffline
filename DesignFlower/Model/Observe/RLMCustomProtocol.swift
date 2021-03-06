//
//  RLMCustomProtocol.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/23.
//

import Foundation
import RealmSwift

/*

 若建立新的 KVO class
 1.同樣建立新的 RLM class 並且繼承 SubObject
 2.並再建立 KVO 的 Observe 且遵從 RLMObserveDelegate

 若在 KVO 系列的 class 加入新的 variable
 1.需要在同樣的 RLM class 也加入相同名字的 variable
 2.Observe 內需要將新的參數加入觀測
 3.若新的 variable 是物件，則需要建立 Link function 跟避免被丟棄的 [observe]

 */

class SubObject: Object {
  @objc dynamic var uuid: String? = UUID().uuidString.lowercased()
  var id = RealmOptional<Int>()

  static func uuidKey() -> String? {
    return "uuid"
  }

  static func isSyncKey() -> String? {
    return "isSync"
  }

  static func idKey() -> String? {
    return "id"
  }

 func filter(remoteObject: SubObject, localObjects: [SubObject]) -> SubObject? {
    if let localObject = localObjects.filter({ (localDishReview) -> Bool in
      if let localID = localDishReview.id.value, let remoteID = remoteObject.id.value, remoteID != -1 {
        return localID == remoteID
      }
      if let localUUID = localDishReview.uuid, let remoteUUID = remoteObject.uuid {
        return localUUID == remoteUUID
      }
      return false
    }).first {
      return localObject
    }
    return nil
  }

}

protocol RLMObserveDelegate: class {
  associatedtype RLMType: SubObject
  associatedtype KVOType: NSObject
  var dbObject: RLMType? { get set }
  var observers: [NSKeyValueObservation] { get set }
  func bindRLM(uuid: String, service: RLMServiceV4)
  func observe(object: KVOType)
  func cancelObserve()
  init(object: KVOType, service: RLMServiceV4?)
}

extension RLMObserveDelegate {
  /// 將 SubObject的物件 與 Realm的dbObject 綁定
  /// - 名詞解釋:
  ///   - RLMType: 代表realm的物件類型，必須繼承SubObject。
  ///   - dbObject: 代表realm內的物件。
  /// - Parameters:
  ///   - uuid: SubObject物件，建立後帶的uuid
  func bindRLM(uuid: String, service: RLMServiceV4 = RLMServiceV4.shared) {
    let realm = service.realm
    let predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
    guard let rlmObject = realm.objects(RLMType.self).filter(predicate).first else {
      let rlmObject = service.createRLM(uuid: uuid, type: RLMType.self)
      self.dbObject = rlmObject
      return
    }
    self.dbObject = rlmObject
  }
  
  /// 停止Observe
  /// - 移除observe物件前須先移除observers以免物件無法被釋放。
  /// - 如果有子obersers，應該撰寫此function，並取消子observers。
  func cancelObserve() {
    observers = []
  }
}


