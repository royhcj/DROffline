//
//  RLMScratchServiceV4.swift
//  DesignFlower
//
//  Created by Roy Hu on 2019/1/21.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import RealmSwift

class RLMScratchServiceV4: RLMServiceV4 {
  
  static var scratchShared = RLMScratchServiceV4()
  
  override var realm: Realm { return _scratchRealm }
  internal var _scratchRealm: Realm = {
    let documentUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let realm = try! Realm(fileURL: documentUrl.appendingPathComponent("scratch.realm"))
    return realm
  }()
  
  override init() {
    super.init()
    dishReview = RLMServiceV4.DishReview(realmService: self)
    dish = RLMServiceV4.Dish(realmService: self)
    image = RLMServiceV4.Image(realmService: self)
  }
  
  
}
