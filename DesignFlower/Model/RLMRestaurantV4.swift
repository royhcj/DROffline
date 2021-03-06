//
//  RLMRestaurantV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import Realm
import RealmSwift

class RLMRestaurantV4: SubObject, Uploadable {

//  var id = RealmOptional<Int>() // 餐廳ID
  @objc dynamic var name: String? // 餐廳名字
  var latitude = RealmOptional<Float>() // 存放latitude
  var longitude = RealmOptional<Float>() // 存放longitude
  @objc dynamic var address: String? // 存放subtitle
  @objc dynamic var country: String? // 存放國家
  var area = RealmOptional<Int>() // 存放區域
  @objc dynamic var phoneNumber: String? //電話
  @objc dynamic var openHour: String? //營業時間
//  var images = List<RLMImageV4>() //餐廳圖片

  convenience init(id: RealmOptional<Int>,
                   name: String?,
                   latitude: RealmOptional<Float>,
                   longitude: RealmOptional<Float>,
                   address: String?,
                   country: String?,
                   area: RealmOptional<Int>,
                   phoneNumber: String?,
                   openHour: String?
//                   images: List<RLMImageV4>
    ) {
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
//    self.images = images
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
//    case images
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMRestReviewV4DecodeKey.self)
    let id = try container.decodeIfPresent(Int.self, forKey: .id)
    let name = try container.decodeIfPresent(String.self, forKey: .name)
    let latitude = try container.decodeIfPresent(Float.self, forKey: .latitude)
    let longitude = try container.decodeIfPresent(Float.self, forKey: .longitude)
    let address = try container.decodeIfPresent(String.self, forKey: .address)
    let country = try container.decodeIfPresent(Int.self, forKey: .country)
    let area = try container.decodeIfPresent(Int.self, forKey: .area)
    let phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    let openHour = try container.decodeIfPresent(String.self, forKey: .openHour)
//    let images = try container.decode([RLMImageV4].self, forKey: .images)

    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmLatitude = RealmOptional<Float>()
    realmLatitude.value = latitude
    let realmLongitude = RealmOptional<Float>()
    realmLongitude.value = longitude
//    let realmImages = List<RLMImageV4>()
//    realmImages.append(objectsIn: images)
    let areaR = RealmOptional<Int>()
    areaR.value = area

    // TODO:
    let countryString = "\(country)"
    
    self.init(id: realmID,
              name: name,
              latitude: realmLatitude,
              longitude: realmLongitude,
              address: address,
              country: countryString,
              area: areaR,
              phoneNumber: phoneNumber,
              openHour: openHour
              )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RLMRestReviewV4DecodeKey.self)
    if let id = id.value, id != -1 {
       try container.encode(id, forKey: .id)
    }
    try container.encode(name, forKey: .name)
    if let lat = latitude.value == -1 ? nil : latitude.value {
       try container.encode(lat, forKey: .latitude)
    }
    if let long = longitude.value == -1 ? nil : longitude.value {
        try container.encode(long, forKey: .longitude)
    }
    try container.encode(address, forKey: .address)
//    try container.encode(country, forKey: .country)
    if let areaI = area.value, areaI != -1 {
       try container.encode(areaI, forKey: .area)
    }
    try container.encode(phoneNumber, forKey: .phoneNumber)
    try container.encode(openHour, forKey: .openHour)
//    var imgs = [RLMImageV4]()
//    imgs.append(contentsOf: images)
//    try container.encode(imgs, forKey: .images)
  }

}
