//
//  RLMServiceV4+Dish.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/26.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  // no.1
  internal func createRLMDish(in rlmDishReview: RLMDishReviewV4,
                       kvoDish: KVODishV4) {
    do {
      try realm.write {
        let rlmDish = realm.create(RLMDishV4.self)
        rlmDish.name = kvoDish.name
        rlmDish.id.value = kvoDish.id
        rlmDish.uuid = kvoDish.uuid
        rlmDishReview.dish = rlmDish
      }
    } catch {
      print("RLMServiceV4+Dish file's no.1 func error")
    }
  }

  // no.2
  internal func update(_ dish: RLMDishV4,
                       name: String?) {
    do {
      try realm.write {
        dish.name = name
      }
    } catch {
      print("RLMServiceV4+Dish file's no.2 func error")
    }
  }

  // no.3
  internal func update(_ dish: RLMDishV4,
                       id: Int?) {
    do {
      try realm.write {
        dish.id.value = id
      }
    } catch {
      print("RLMServiceV4+Dish file's no.2 func error")
    }
  }
  
  // no.
  internal func getDish(uuid: String) -> RLMDishV4? {
    let predicate = NSPredicate(format: "uuid == '\(uuid)'")
    let dish = realm.objects(RLMDishV4.self).filter(predicate).first
    return dish
  }

  // no.4
  internal func delete(dishUUID: String) {
    do {
      try realm.write {
        let predicate = NSPredicate.init(format: "uuid == '\(dishUUID)'")
        if let dish = realm.objects(RLMDishV4.self).filter(predicate).first {
          realm.delete(dish)

        }
      }
    } catch {
      print("RLMServiceV4+Image file's no.4 func error")
    }
  }

}
