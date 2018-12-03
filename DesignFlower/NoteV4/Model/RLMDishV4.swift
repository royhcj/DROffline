//
//  RLMDishV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import RealmSwift

class RLMDishV4: SubObject {

  @objc dynamic var name: String? // 菜餚名稱
  let id = RealmOptional<Int>() // 菜餚ID

}
