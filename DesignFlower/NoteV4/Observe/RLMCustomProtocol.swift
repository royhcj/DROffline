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
  @objc dynamic var uuid: String?
}

protocol RLMObserveDelegate: class {
  associatedtype RLMType: SubObject
  associatedtype KVOType: NSObject
  var dbObject: RLMType? { get set }
  var observers: [NSKeyValueObservation] { get set }
  func bindRLM(uuid: String)
  func observe(object: KVOType)
  init(object: KVOType)
}

extension RLMObserveDelegate {
  /// 將 SubObject的物件 與 Realm的dbObject 綁定
  /// - 名詞解釋:
  ///   - RLMType: 代表realm的物件類型，必須繼承SubObject。
  ///   - dbObject: 代表realm內的物件。
  /// - Parameters:
  ///   - uuid: SubObject物件，建立後帶的uuid
  func bindRLM(uuid: String) {
    let realm = try! Realm()
    let predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
    guard let rlmObject = realm.objects(RLMType.self).filter(predicate).first else {
      let rlmObject = RLMServiceV4.shared.createRLM(uuid: uuid, type: RLMType.self)
      self.dbObject = rlmObject
      return
    }
    self.dbObject = rlmObject
  }
}


