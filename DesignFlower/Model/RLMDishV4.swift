//
//  RLMDishV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import RealmSwift

class RLMDishV4: SubObject, Decodable {

  @objc dynamic var name: String? // 菜餚名稱
  let id = RealmOptional<Int>() // 菜餚ID

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
    let name = try container.decode(String.self, forKey: .name)
    let id = try container.decode(Int.self, forKey: .id)
    let realmID = RealmOptional<Int>()
    realmID.value = id
    self.init(name: name, id: realmID)
  }

  required init() {
    super.init()
  }

  required init(realm: RLMRealm, schema: RLMObjectSchema) {
    fatalError("init(realm:schema:) has not been implemented")
  }

  required init(value: Any, schema: RLMSchema) {
    fatalError("init(value:schema:) has not been implemented")
  }
}
