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
    }
  }


}
