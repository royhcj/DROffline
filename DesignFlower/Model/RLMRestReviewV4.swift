//
//  RLMRestReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/14.
//

import Foundation
import RealmSwift

class RLMRestReviewV4: SubObject {

  @objc dynamic var serviceRank: String? // 服務分數
  @objc dynamic var environmentRank: String? // 環境分數
  @objc dynamic var priceRank: String? // 環境分數
  @objc dynamic var title: String? // 標題
  @objc dynamic var comment: String? // 評比內容
  let id = RealmOptional<Int>() // reviewID
  @objc dynamic var isScratch = false // 是否為草稿
  let allowedReaders = List<String>() // 白名單
  @objc dynamic var createDate: Date = Date() // 創造日期
  @objc dynamic var eatingDate: Date? = Date() // 吃飯時間
  let parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  @objc dynamic var isShowComment = true // 是否顯示餐廳評比
  @objc dynamic var isSync = false //是否同步
  @objc dynamic var updateDate: Date? //上次上傳日期
//  @objc dynamic var uuid: String? // uuid 與 KVO內的一樣
  @objc dynamic var isFirst = false //判斷是不是第一次建立
  let dishReviews = List<RLMDishReviewV4>()
  let restaurant = List<RLMRestaurantV4>()


}
