//
//  RLMQueue.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2018/12/22.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RLMQueue: RLMRestReviewV4 {

//  @objc dynamic var serviceRank: String? // 服務分數
//  @objc dynamic var environmentRank: String? // 環境分數
//  @objc dynamic var priceRank: String? // 環境分數
//  @objc dynamic var title: String? // 標題
//  @objc dynamic var comment: String? // 評比內容
//  //  var id = RealmOptional<Int>() // reviewID
//  var isScratch = RealmOptional<Bool>() // 是否為草稿
//  //  @objc dynamic var isScratch = false
//  var allowedReaders = List<Int>() // 白名單
//  @objc dynamic var createDate: Date = Date() // 創造日期
//  @objc dynamic var eatingDate: Date? = Date() // 吃飯時間
//  var parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
//  @objc dynamic var parentUUID: String? // 複製品紀錄本尊的UUID(本尊可能沒有ID)
//  @objc dynamic var isShowComment = true // 是否顯示餐廳評比
//  @objc dynamic var isSync = false //是否同步
//  @objc dynamic var updateDate: Date? //上次上傳日期
//  //  @objc dynamic var uuid: String? // uuid 與 KVO內的一樣
//  @objc dynamic var isFirst = false //判斷是不是第一次建立
//  var dishReviews = List<RLMDishReviewV4>()
//  @objc dynamic var restaurant: RLMRestaurantV4?
  // -------- only for queue
  @objc dynamic var queueDate: Date = Date.now // 加入排成時間
  @objc dynamic var isDelete: Bool = false // 是刪除筆記


  convenience init(uuid: String?,
                   serviceRank: String?,
                   environmentRank: String?,
                   priceRank: String?,
                   title: String?,
                   comment: String?,
                   id: RealmOptional<Int>,
                   isScratch: RealmOptional<Bool> = RealmOptional<Bool>.init(false),
                   allowedReaders: List<Int>,
                   createDate: Date = Date.now,
                   eatingDate: Date? = Date.now,
                   parentID: RealmOptional<Int>,
                   isShowComment: Bool = true,
                   isSync: Bool = false,
                   updateDate: Date?,
                   isFirst: Bool = false,
                   dishReviews: List<RLMDishReviewV4>,
                   restaurant: RLMRestaurantV4) {
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
    if let uuid = uuid {
      self.uuid = uuid
    }
  }

//  enum RLMRestReviewV4DecoderKey: String, CodingKey {
//    case serviceRank
//    case environmentRank
//    case priceRank
//    case title
//    case comment
//    case id
//    case isScratch
//    case allowedReaders
//    case createDate
//    case eatingDate
//    case parentID
//    case isShowComment
//    case isSync
//    case updateDate
//    case isFirst
//    case dishReviews
//    case restaurant
//    case uuid
//  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMRestReviewV4DecoderKey.self)
    let serviceRank = try container.decodeIfPresent(Float.self, forKey: .serviceRank)
    let uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
    let environmentRank =  try container.decodeIfPresent(Float.self, forKey: .environmentRank)
    let priceRank =  try container.decodeIfPresent(Float.self, forKey: .priceRank)
    let title =  try container.decodeIfPresent(String.self, forKey: .title)
    let comment =  try container.decodeIfPresent(String.self, forKey: .comment)
    let id =  try container.decodeIfPresent(Int.self, forKey: .id)
    //    let isScratch =  try container.decode(Bool.self, forKey: .isScratch)
    let allowedReaders =  try container.decode([Int].self, forKey: .allowedReaders)
    let createDate =  try container.decode(Date.self, forKey: .createDate)
    let eatingDate =  try container.decodeIfPresent(Date.self, forKey: .eatingDate)
    let parentID =  try container.decodeIfPresent(Int.self, forKey: .parentID)
    let isShowComment =  try container.decode(Int.self, forKey: .isShowComment)
    //    let isSync =  try container.decode(Bool.self, forKey: .isSync)
    let updateDate =  try container.decodeIfPresent(Date.self, forKey: .updateDate)
    //    let isFirst =  try container.decode(Bool.self, forKey: .isFirst)
    let dishReviews =  try container.decode([RLMDishReviewV4].self, forKey: .dishReviews)
    let restaurant =  try container.decode(RLMRestaurantV4.self, forKey: .restaurant)


    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmAllowedReaders = List<Int>()
    realmAllowedReaders.append(objectsIn: allowedReaders)
    let realmParentID = RealmOptional<Int>()
    realmParentID.value = parentID
    let realmDishReviews = List<RLMDishReviewV4>()
    realmDishReviews.append(objectsIn: dishReviews)
    let serviceRankString = serviceRank?.toString()
    let environmentRankString = environmentRank?.toString()
    let priceRankString = priceRank?.toString()
    let isScra = RealmOptional<Bool>()
    isScra.value = false
    let isShowCommentBool = isShowComment == 1 ? true : false

    self.init(uuid: uuid,
              serviceRank: serviceRankString,
              environmentRank: environmentRankString,
              priceRank: priceRankString,
              title: title,
              comment: comment,
              id: realmID,
              isScratch: isScra,
              allowedReaders: realmAllowedReaders,
              createDate: createDate,
              eatingDate: eatingDate,
              parentID: realmParentID,
              isShowComment: isShowCommentBool,
              isSync: false,
              updateDate: updateDate,
              isFirst: false,
              dishReviews: realmDishReviews,
              restaurant: restaurant)
  }

//  func encode(to encoder: Encoder) throws {
//    var continer = encoder.container(keyedBy: RLMRestReviewV4DecoderKey.self)
//    let sRank = Float(serviceRank ?? "0.0")
//    try continer.encode(sRank, forKey: .serviceRank)
//    let eRank = Float(environmentRank ?? "0.0")
//    try continer.encode(eRank, forKey: .environmentRank)
//    let pRank = Float(priceRank ?? "0.0")
//    try continer.encode(pRank, forKey: .priceRank)
//    try continer.encode(title, forKey: .title)
//    try continer.encode(comment, forKey: .comment)
//    try continer.encode(id.value, forKey: .id)
//    //    let isScra = isScratch.value
//    //    try continer.encode(isScra, forKey: .isScratch)
//    var allR = [Int]()
//    allR.append(contentsOf: allowedReaders)
//    try continer.encode(allR, forKey: .allowedReaders)
//    let cDate = Date.getString(any: createDate)
//    try continer.encode(cDate, forKey: .createDate)
//    let eDate = Date.getString(any: eatingDate)
//    try continer.encode(eatingDate, forKey: .eatingDate)
//    try continer.encode(parentID.value, forKey: .parentID)
//    let isShowCommentInt = isShowComment ? 1 : 0
//    try continer.encode(isShowCommentInt, forKey: .isShowComment)
//    //    try continer.encode(isSync, forKey: .isSync)
//    let uDate = Date.getString(any: updateDate ?? Date())
//    try continer.encode(uDate, forKey: .updateDate)
//    //    try continer.encode(isFirst, forKey: .isFirst)
//    var dishR = [RLMDishReviewV4]()
//    dishR.append(contentsOf: dishReviews)
//    try continer.encode(dishR, forKey: .dishReviews)
//    try continer.encode(restaurant, forKey: .restaurant)
//    try continer.encode(uuid, forKey: .uuid)
//  }

}
