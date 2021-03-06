//
//  RLMDishV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import Realm
import RealmSwift

class RLMDishV4: SubObject, Uploadable {

  @objc dynamic var name: String? // 菜餚名稱
//  var id = RealmOptional<Int>() // 菜餚ID

  convenience init(name: String?, id: RealmOptional<Int>) {
    self.init()
    self.name = name
    self.id = id
  }

  private enum RLMDishV4CodingKeys: String, CodingKey {
    case name
    case id
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMDishV4CodingKeys.self)
    let name = try container.decodeIfPresent(String.self, forKey: .name)
    let id = try container.decodeIfPresent(Int.self, forKey: .id)
    let realmID = RealmOptional<Int>()
    realmID.value = id
    self.init(name: name, id: realmID)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RLMDishV4CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(self.id.value, forKey: .id)
  }

}
