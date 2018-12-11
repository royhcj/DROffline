//
//  RLMRestaurantV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import RealmSwift

class RLMRestaurantV4: SubObject {

  let id = RealmOptional<Int>() // 餐廳ID
  @objc dynamic var name: String? // 餐廳名字
  let latitude = RealmOptional<Float>() // 存放latitude
  let longitude = RealmOptional<Float>() // 存放longitude
  @objc dynamic var address: String? // 存放subtitle
  @objc dynamic var country: String? // 存放國家
  @objc dynamic var area: String? // 存放區域
  @objc dynamic var phoneNumber: String? //電話
  @objc dynamic var openHour: String? //營業時間
  let images = List<RLMImageV4>() //餐廳圖片

}
