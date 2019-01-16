//
//  RLMServiceV4+Restaurant.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/26.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  // no.1
  internal func createRLMRest(in rlmRestReview: RLMRestReviewV4,
                               kvoRest: KVORestaurantV4) {
    do {
      try realm.write {
        let rlmRest = realm.create(RLMRestaurantV4.self)
        rlmRest.uuid = kvoRest.uuid
        rlmRest.address = kvoRest.address
        rlmRest.area.value = kvoRest.area
        rlmRest.country = kvoRest.country
        rlmRest.id.value = kvoRest.id
        for image in kvoRest.images {
          RLMServiceV4.shared.image.createRLMImage(in: rlmRest, kvoImage: image)
        }
        rlmRestReview.restaurant = rlmRest
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.1 func error")
    }
  }

  // no.2
  internal func update(_ restaurant: RLMRestaurantV4,
                       name: String?) {
    do {
      try realm.write {
        restaurant.name = name
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.2 func error")
    }
  }

  // no.3
  internal func update(_ restaurant: RLMRestaurantV4,
                       id: Int) {
    do {
      try realm.write {
        restaurant.id.value = id
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.3 func error")
    }
  }

  // no.4
  internal func update(_ restaurant: RLMRestaurantV4,
                       latitude: Float?) {
    do {
      try realm.write {
        restaurant.latitude.value = latitude
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.4 func error")
    }
  }

  internal func update(_ restaurant: RLMRestaurantV4,
                       longitude: Float?) {
    do {
      try realm.write {
        restaurant.longitude.value = longitude
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.4 func error")
    }
  }

  // no.5
  internal func update(_ restaurant: RLMRestaurantV4,
                       address: String?) {
    do {
      try realm.write {
        restaurant.address = address
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.5 func error")
    }
  }

  // no.6
  internal func update(_ restaurant: RLMRestaurantV4,
                       country: String?) {
    do {
      try realm.write {
        restaurant.country = country
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.6 func error")
    }
  }

  // no.7
  internal func update(_ restaurant: RLMRestaurantV4,
                       area: Int?) {
    do {
      try realm.write {
        restaurant.area.value = area
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.7 func error")
    }
  }

  // no.8
  internal func update(_ restaurant: RLMRestaurantV4,
                       phoneNumber: String?) {
    do {
      try realm.write {
        restaurant.phoneNumber = phoneNumber
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.8 func error")
    }
  }

  // no.9
  internal func update(_ restaurant: RLMRestaurantV4,
                       openHour: String?) {
    do {
      try realm.write {
        restaurant.openHour = openHour
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.9 func error")
    }
  }

  // no.
  internal func getRestaurant(uuid: String) -> RLMRestaurantV4? {
    let predicate = NSPredicate(format: "uuid == '\(uuid)'")
    let restaurant = realm.objects(RLMRestaurantV4.self).filter(predicate).first
    return restaurant
  }
  
  // no.10
  internal func delete(restUUID: String) {
    do {
      try realm.write {
        let predicate = NSPredicate.init(format: "uuid == '\(restUUID)'")
        if let rlmRest = realm.objects(RLMRestaurantV4.self).filter(predicate).first {
          realm.delete(rlmRest)
        }
      }
    } catch {
      print("RLMServiceV4+Restaurant file's no.10 func error")
    }
  }
}
