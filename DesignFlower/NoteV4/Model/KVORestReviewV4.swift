//
//  KVORestReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation

class KVORestReviewV4: NSObject {

  @objc dynamic var serviceRank: String? // 服務分數
  @objc dynamic var environmentRank: String? // 環境分數
  @objc dynamic var priceRank: String? // 環境分數
  @objc dynamic var title: String? // 標題
  @objc dynamic var comment: String? // 評比內容
  @objc dynamic var id: Int = -1
  @objc dynamic var isScratch = false // 是否為草稿
  @objc dynamic var allowedReaders = [String]() // 白名單
  @objc dynamic var createDate: Date = Date() // 創造日期
  @objc dynamic var eatingDate: Date? = Date() // 吃飯時間
  @objc dynamic var parentID: Int = -1 // 複製品紀錄本尊的ID
  @objc dynamic var isShowComment = true // 是否顯示餐廳評比
  @objc dynamic var isSync = false //是否同步
  @objc dynamic var updateDate: Date? //上次上傳日期
  var uuid = UUID().uuidString.lowercased() //產生uuid
  @objc dynamic var isFirst = false
  @objc dynamic var dishReviews = [KVODishReviewV4]() // 菜餚
  @objc dynamic var restaurant: KVORestaurantV4?

  init(uuid: String? = nil) {
    super.init()
    if let uuid = uuid {
      self.uuid = uuid
    }
  }

}
