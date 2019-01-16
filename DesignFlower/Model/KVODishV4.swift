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
      
      load(withUUID: uuid)
    }
  }
  
  init(with rlmDish: RLMDishV4) {
    super.init()
    set(with: rlmDish)
  }
  
  func set(with rlmDish: RLMDishV4) {
    name = rlmDish.name
    id = rlmDish.id.value ?? -1
    if let uuid = rlmDish.uuid {
      self.uuid = uuid
    }
  }
  
  func load(withUUID uuid: String) {
    guard let rlmDish = RLMServiceV4.shared.dish.getDish(uuid: uuid)
    else { return }
    
    set(with: rlmDish)
  }

}
