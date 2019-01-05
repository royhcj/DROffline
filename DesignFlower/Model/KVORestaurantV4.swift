//
//  KVORestaurantV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation

class KVORestaurantV4: NSObject {

  @objc dynamic var id = -1 // 餐廳ID
  @objc dynamic var name: String? // 餐廳名字
  @objc dynamic var latitude: Float = -1.0 // 存放latitude
  @objc dynamic var longitude: Float = -1.0 // 存放longitude
  @objc dynamic var address: String? // 存放subtitle
  @objc dynamic var country: String? // 存放國家
  @objc dynamic var area: String? // 存放區域
  @objc dynamic var phoneNumber: String? //電話
  @objc dynamic var openHour: String? //營業時間
  @objc dynamic var images = [KVOImageV4]() //餐廳圖片
  var uuid = UUID().uuidString.lowercased() // local uuid

  init(uuid: String? = nil) {
    super.init()
    if let uuid = uuid {
      self.uuid = uuid
      
      load(withUUID: uuid)
    }
  }
  
  init(with rlmRestaurant: RLMRestaurantV4) {
    super.init()
    set(with: rlmRestaurant)
  }
  
  func set(with rlmRestaurant: RLMRestaurantV4) {
    id = rlmRestaurant.id.value ?? -1
    name = rlmRestaurant.name
    latitude = rlmRestaurant.latitude.value ?? -1
    longitude = rlmRestaurant.longitude.value ?? -1
    address = rlmRestaurant.address
    country = rlmRestaurant.country
    area = rlmRestaurant.area
    phoneNumber = rlmRestaurant.phoneNumber
    openHour = rlmRestaurant.openHour
    if let uuid = rlmRestaurant.uuid {
      self.uuid = uuid
    }
    self.images = []
    for rlmImage in rlmRestaurant.images {
      let image = KVOImageV4(with: rlmImage)
      self.images.append(image)
    }
    
  }
  
  func load(withUUID uuid: String) {
    guard let rlmRestaurant = RLMServiceV4.shared.getRestaurant(uuid: uuid)
    else { return }
    
    set(with: rlmRestaurant)
  }

}


struct ShareSelections {
  var selectedDishReviewUUIDs: [String]
  var selectedRestaurantRating: Bool
}
