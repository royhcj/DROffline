//
//  RLMDishReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/14.
//

import Foundation
import Realm
import RealmSwift

class RLMDishReviewV4: SubObject, Uploadable {

  @objc dynamic var rank: String? // 分數
  @objc dynamic var comment: String? // 評比
//  var id = RealmOptional<Int>() // 評比ID
  @objc dynamic var isCreate = false // 不透過圖片直接建立新的評比
  @objc dynamic var createDate: Date = Date.now
  var parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  var isLike = RealmOptional<Bool>() // 是否為使用者蒐藏
  var order = RealmOptional<Int>() // 順序
  var images = List<RLMImageV4>() // 圖片
  @objc dynamic var dish: RLMDishV4?  // 菜餚
  //  @objc dynamic var uuid: String? // dish uuid

  // 自動會管理
  let restReview = LinkingObjects(fromType: RLMRestReviewV4.self, property: "dishReviews")

  convenience init(rank: String?,
                   comment: String?,
                   id: RealmOptional<Int>,
                   isCreate: Bool = false,
                   createDate: Date = Date.now,
                   parentID: RealmOptional<Int>,
                   isLike: RealmOptional<Bool>,
                   order: RealmOptional<Int>,
                   images: List<RLMImageV4>,
                   dish: RLMDishV4?,
                   uuid: String?) {
    self.init()
    self.rank = rank
    self.comment = comment
    self.id = id
    self.isCreate = isCreate
    self.createDate = createDate
    self.parentID = parentID
    self.isLike = isLike
    self.order = order
    self.images = images
    self.dish = dish
    self.uuid = uuid
  }

  enum RLMDishReviewV4DecodeKey: String, CodingKey {
    case rank
    case comment
    case id
    case isCreate
    case createDate
    case parentID
    case isLike
    case order
    case images
    case dish
    case uuid
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMDishReviewV4DecodeKey.self)
    let rank = try container.decodeIfPresent(Float.self, forKey: .rank)
    let comment = try container.decodeIfPresent(String.self, forKey: .comment)
    let id = try container.decodeIfPresent(Int.self, forKey: .id)
//    let isCreate = try container.decode(Bool.self, forKey: .isCreate)
    let createDate = try container.decode(Date.self, forKey: .createDate)
    let parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
    let isLike = try container.decodeIfPresent(Bool.self, forKey: .isLike)
    let order = try container.decodeIfPresent(Int.self, forKey: .order)
    let images = try container.decode([RLMImageV4].self, forKey: .images)
    let dish = try container.decode(RLMDishV4.self, forKey: .dish)
    var uuid = try? container.decode(String.self, forKey: .uuid)
    if uuid == nil {
      uuid = UUID().uuidString.lowercased()
    }


    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmParentID = RealmOptional<Int>()
    realmParentID.value = parentID
    let realmOrder = RealmOptional<Int>()
    realmOrder.value = order
    let realmImages = List<RLMImageV4>()
    realmImages.append(objectsIn: images)
    let realmIsLike = RealmOptional<Bool>()
    realmIsLike.value = isLike
    let rankString = rank?.toString()

    self.init(rank: rankString,
              comment: comment,
              id: realmID,
              createDate: createDate,
              parentID: realmParentID,
              isLike: realmIsLike,
              order: realmOrder,
              images: realmImages,
              dish: dish,
              uuid: uuid)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RLMDishReviewV4DecodeKey.self)
    let rankFloat = Float(rank ?? "0.0")
    try container.encode(rankFloat, forKey: .rank)
    try container.encode(comment, forKey: .comment)
//    try container.encode(isCreate, forKey: .isCreate)
    if let parentID = parentID.value, parentID != -1 {
       try container.encode(parentID, forKey: .parentID)
    }
    try container.encode(createDate.timeIntervalSince1970, forKey: .createDate)

    try container.encode(isLike.value, forKey: .isLike)
    try container.encode(order.value, forKey: .order)
    var imgs = [RLMImageV4]()
    imgs.append(contentsOf: images)
    try container.encode(imgs, forKey: .images)

    try container.encode(dish ?? RLMDishV4(), forKey: .dish)

    try container.encode(uuid, forKey: .uuid)
    if let id = id.value, id != -1 {
       try container.encode(id, forKey: .id)
    }

  }

//  func update(from dishReview: RLMDishReviewV4) {
//    self.rank = dishReview.rank
//    self.comment = dishReview.comment
//    self.id = dishReview.id
//    self.isCreate = dishReview.isCreate
//    self.createDate = dishReview.createDate
//    self.parentID = dishReview.parentID
//    self.isLike = dishReview.isLike
//    self.order = dishReview.order
////    self.images = dishReview.images
////    self.dish = dishReview.dish
//  }

}
