//
//  RLMRestaurantV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import Realm
import RealmSwift

class RLMRestaurantV4: SubObject, Decodable {

  var id = RealmOptional<Int>() // 餐廳ID
  @objc dynamic var name: String? // 餐廳名字
  var latitude = RealmOptional<Float>() // 存放latitude
  var longitude = RealmOptional<Float>() // 存放longitude
  @objc dynamic var address: String? // 存放subtitle
  @objc dynamic var country: String? // 存放國家
  @objc dynamic var area: String? // 存放區域
  @objc dynamic var phoneNumber: String? //電話
  @objc dynamic var openHour: String? //營業時間
  var images = List<RLMImageV4>() //餐廳圖片

  convenience init(id: RealmOptional<Int>,
                   name: String?,
                   latitude: RealmOptional<Float>,
                   longitude: RealmOptional<Float>,
                   address: String?,
                   country: String?,
                   area: String?,
                   phoneNumber: String?,
                   openHour: String?,
                   images: List<RLMImageV4>) {
    self.init()
    self.id = id
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.country = country
    self.area = area
    self.phoneNumber = phoneNumber
    self.openHour = openHour
    self.images = images
  }

  enum RLMRestReviewV4DecodeKey: String, CodingKey {
    case id
    case name
    case latitude
    case longitude
    case address
    case country
    case area
    case phoneNumber
    case openHour
    case images
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMRestReviewV4DecodeKey.self)
    let id = try container.decode(Int.self, forKey: .id)
    let name = try container.decode(String.self, forKey: .name)
    let latitude = try container.decode(Float.self, forKey: .latitude)
    let longitude = try container.decode(Float.self, forKey: .longitude)
    let address = try container.decode(String.self, forKey: .address)
    let country = try container.decode(String.self, forKey: .country)
    let area = try container.decode(String.self, forKey: .area)
    let phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    let openHour = try container.decode(String.self, forKey: .openHour)
    let images = try container.decode([RLMImageV4].self, forKey: .images)

    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmLatitude = RealmOptional<Float>()
    realmLatitude.value = latitude
    let realmLongitude = RealmOptional<Float>()
    realmLongitude.value = longitude
    let realmImages = List<RLMImageV4>()
    realmImages.append(objectsIn: images)
    
    self.init(id: realmID,
              name: name,
              latitude: realmLatitude,
              longitude: realmLongitude,
              address: address,
              country: country,
              area: area,
              phoneNumber: phoneNumber,
              openHour: openHour,
              images: realmImages)
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
