//
//  KVODishV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation

class KVODishV4: NSObject {
  @objc dynamic var name: String? // 菜餚名稱
  @objc dynamic var id = -1 // 菜餚ID
  var uuid = UUID().uuidString.lowercased() // local uuid

  init(uuid: String? = nil) {
    super.init()
    if let uuid = uuid {
      self.uuid = uuid
    }
  }

}
