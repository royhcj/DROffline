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
  var id = RealmOptional<Int>() // 評比ID
  @objc dynamic var isCreate = false // 不透過圖片直接建立新的評比
  @objc dynamic var createDate: Date = Date()
  var parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  var isLike = RealmOptional<Bool>() // 是否為使用者蒐藏
  var order = RealmOptional<Int>() // 順序
  var images = List<RLMImageV4>() // 圖片
  var dish = RLMDishV4()  // 菜餚
  //  @objc dynamic var uuid: String? // dish uuid

  // 自動會管理
  let restReview = LinkingObjects(fromType: RLMRestReviewV4.self, property: "dishReviews")

  convenience init(rank: String?,
                   comment: String?,
                   id: RealmOptional<Int>,
                   isCreate: Bool = false,
                   createDate: Date = Date(),
                   parentID: RealmOptional<Int>,
                   isLike: RealmOptional<Bool>,
                   order: RealmOptional<Int>,
                   images: List<RLMImageV4>,
                   dish: RLMDishV4) {
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
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMDishReviewV4DecodeKey.self)
    let rank = try container.decodeIfPresent(String.self, forKey: .rank)
    let comment = try container.decodeIfPresent(String.self, forKey: .comment)
    let id = try container.decodeIfPresent(Int.self, forKey: .id)
    let isCreate = try container.decode(Bool.self, forKey: .isCreate)
    let createDate = try container.decode(Date.self, forKey: .createDate)
    let parentID = try container.decodeIfPresent(Int.self, forKey: .parentID)
    let isLike = try container.decodeIfPresent(Bool.self, forKey: .isLike)
    let order = try container.decodeIfPresent(Int.self, forKey: .order)
    let images = try container.decode([RLMImageV4].self, forKey: .images)
    let dish = try container.decode(RLMDishV4.self, forKey: .dish)

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

    self.init(rank: rank,
              comment: comment,
              id: realmID,
              isCreate: isCreate,
              createDate: createDate,
              parentID: realmParentID,
              isLike: realmIsLike,
              order: realmOrder,
              images: realmImages,
              dish: dish)
  }

  override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RLMDishReviewV4DecodeKey.self)
    try container.encode(rank, forKey: .rank)
    try container.encode(comment, forKey: .comment)
    try container.encode(isCreate, forKey: .isCreate)
    try container.encode(parentID.value, forKey: .parentID)
    try container.encode(createDate, forKey: .createDate)
    try container.encode(isLike.value, forKey: .isLike)
    try container.encode(order.value, forKey: .order)
    var imgs = [RLMImageV4]()
    imgs.append(contentsOf: images)
    try container.encode(imgs, forKey: .images)
    try container.encode(dish, forKey: .dish)

  }

}
