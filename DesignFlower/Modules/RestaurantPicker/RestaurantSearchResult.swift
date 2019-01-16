//
//  RestaurantSearechResult.swift
//  DesignFlower
//
//  Created by roy on 1/16/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import CoreLocation

class RestaurantSearchResult {
  
  public private(set) var restaurants: [Restaurant] = []
  var count: Int { return restaurants.count }
  
  func insert(restaurant: Restaurant,
              condition: FilterCondition,
              policy: FilterPolicy = .overwrite) {
    switch condition {
      case .none:
        restaurants.append(restaurant)
      case .byID:
        let index = restaurants.firstIndex {
          $0.shopID != nil && $0.shopID == restaurant.shopID
        }
        if let index = index {
          if case .overwrite = policy {
            restaurants.remove(at: index)
            restaurants.insert(restaurant, at: index)
          }
        } else {
          restaurants.append(restaurant)
        }
      case .byAddressAndName:
        let index = restaurants.firstIndex {
          $0.address != nil && $0.shopName != nil
            && $0.address == restaurant.address
            && $0.shopName == restaurant.shopName
        }
        if let index = index {
          if case .overwrite = policy {
            restaurants.remove(at: index)
            restaurants.insert(restaurant, at: index)
          }
        } else {
          restaurants.append(restaurant)
        }
    }
  }
  
  func clearAll() {
    restaurants.removeAll()
  }
  
  enum FilterCondition {
    case none // always insert
    case byID // filter by ID
    case byAddressAndName // filter by adddress or name
  }
  
  enum FilterPolicy {
    case ignore     // 有條件相同者 則不加入
    case overwrite  // 有條件相同者 則覆蓋前者
  }
  
  static func calculateDistance(coordinateA: CLLocationCoordinate2D,
                                coordinateB: CLLocationCoordinate2D) -> Double {
    
    let latitudeA = Measurement(value: Double(coordinateA.latitude), unit: UnitAngle.degrees)
                      .converted(to: UnitAngle.radians).value
    let longitudeA = Measurement(value: Double(coordinateA.longitude), unit: UnitAngle.degrees)
                      .converted(to: UnitAngle.radians).value
    let latitudeB = Measurement(value: Double(coordinateB.latitude), unit: UnitAngle.degrees)
                      .converted(to: UnitAngle.radians).value
    let longitudeB = Measurement(value: Double(coordinateB.longitude), unit: UnitAngle.degrees)
                      .converted(to: UnitAngle.radians).value
    
    let distance = 6371 * acos(cos(latitudeA) * cos(latitudeB) * cos(longitudeB - longitudeA) + sin(latitudeA) * sin(latitudeB))
    return distance
  }
}
