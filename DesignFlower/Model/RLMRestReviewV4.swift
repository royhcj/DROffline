//
//  RLMRestReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/14.
//

import Foundation
import RealmSwift

class RLMRestReviewV4: SubObject, Decodable {

  @objc dynamic var serviceRank: String? // 服務分數
  @objc dynamic var environmentRank: String? // 環境分數
  @objc dynamic var priceRank: String? // 環境分數
  @objc dynamic var title: String? // 標題
  @objc dynamic var comment: String? // 評比內容
  var id = RealmOptional<Int>() // reviewID
  @objc dynamic var isScratch = false // 是否為草稿
  var allowedReaders = List<String>() // 白名單
  @objc dynamic var createDate: Date = Date() // 創造日期
  @objc dynamic var eatingDate: Date? = Date() // 吃飯時間
  var parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  @objc dynamic var isShowComment = true // 是否顯示餐廳評比
  @objc dynamic var isSync = false //是否同步
  @objc dynamic var updateDate: Date? //上次上傳日期
//  @objc dynamic var uuid: String? // uuid 與 KVO內的一樣
  @objc dynamic var isFirst = false //判斷是不是第一次建立
  var dishReviews = List<RLMDishReviewV4>()
  var restaurant = List<RLMRestaurantV4>()

  convenience init(serviceRank: String?,
                   environmentRank: String?,
                   priceRank: String?,
                   title: String?,
                   comment: String?,
                   id: RealmOptional<Int>,
                   isScratch: Bool = false,
                   allowedReaders: List<String>,
                   createDate: Date = Date(),
                   eatingDate: Date? = Date(),
                   parentID: RealmOptional<Int>,
                   isShowComment: Bool = true,
                   isSync: Bool = false,
                   updateDate: Date?,
                   isFirst: Bool = false,
                   dishReviews: List<RLMDishReviewV4>,
                   restaurant: List<RLMRestaurantV4>) {
    self.init()
    self.serviceRank = serviceRank
    self.environmentRank = environmentRank
    self.priceRank = priceRank
    self.title = title
    self.comment = comment
    self.id = id
    self.isScratch = isScratch
    self.allowedReaders = allowedReaders
    self.createDate = createDate
    self.eatingDate = eatingDate
    self.parentID = parentID
    self.isShowComment = isShowComment
    self.isSync = isSync
    self.updateDate = updateDate
    self.isFirst = isFirst
    self.dishReviews = dishReviews
    self.restaurant = restaurant
  }

  enum RLMRestReviewV4DecoderKey: String, CodingKey {
    case serviceRank
    case environmentRank
    case priceRank
    case title
    case comment
    case id
    case isScratch
    case allowedReaders
    case createDate
    case eatingDate
    case parentID
    case isShowComment
    case isSync
    case updateDate
    case isFirst
    case dishReviews
    case restaurant
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMRestReviewV4DecoderKey.self)
    let serviceRank = try container.decode(String.self, forKey: .serviceRank)
    let environmentRank =  try container.decode(String.self, forKey: .environmentRank)
    let priceRank =  try container.decode(String.self, forKey: .priceRank)
    let title =  try container.decode(String.self, forKey: .title)
    let comment =  try container.decode(String.self, forKey: .comment)
    let id =  try container.decode(Int.self, forKey: .id)
    let isScratch =  try container.decode(Bool.self, forKey: .isScratch)
    let allowedReaders =  try container.decode([String].self, forKey: .allowedReaders)
    let createDate =  try container.decode(Date.self, forKey: .createDate)
    let eatingDate =  try container.decode(Date.self, forKey: .eatingDate)
    let parentID =  try container.decode(Int.self, forKey: .parentID)
    let isShowComment =  try container.decode(Bool.self, forKey: .isShowComment)
    let isSync =  try container.decode(Bool.self, forKey: .isSync)
    let updateDate =  try container.decode(Date.self, forKey: .updateDate)
    let isFirst =  try container.decode(Bool.self, forKey: .isFirst)
    let dishReviews =  try container.decode([RLMDishReviewV4].self, forKey: .dishReviews)
    let restaurant =  try container.decode([RLMRestaurantV4].self, forKey: .restaurant)

    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmAllowedReaders = List<String>()
    realmAllowedReaders.append(objectsIn: allowedReaders)
    let realmParentID = RealmOptional<Int>()
    realmParentID.value = parentID
    let realmDishReviews = List<RLMDishReviewV4>()
    realmDishReviews.append(objectsIn: dishReviews)
    let realmRestaurant = List<RLMRestaurantV4>()
    realmRestaurant.append(objectsIn: restaurant)

    self.init(serviceRank: serviceRank,
              environmentRank: environmentRank,
              priceRank: priceRank,
              title: title,
              comment: comment,
              id: realmID,
              isScratch: isScratch,
              allowedReaders: realmAllowedReaders,
              createDate: createDate,
              eatingDate: eatingDate,
              parentID: realmParentID,
              isShowComment: isShowComment,
              isSync: isSync,
              updateDate: updateDate,
              isFirst: isFirst,
              dishReviews: realmDishReviews,
              restaurant: realmRestaurant)
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
