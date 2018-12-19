//
//  RLMDishReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/14.
//

import Foundation
import Realm
import RealmSwift

class RLMDishReviewV4: SubObject, Decodable {

  @objc dynamic var rank: String? // 分數
  @objc dynamic var comment: String? // 評比
  var id = RealmOptional<Int>() // 評比ID
  @objc dynamic var isCreate = false // 不透過圖片直接建立新的評比
  @objc dynamic var createDate: Date = Date()
  var parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  var isLike = RealmOptional<Bool>() // 是否為使用者蒐藏
  var order = RealmOptional<Int>() // 順序
  var images = List<RLMImageV4>() // 圖片
  var dish = List<RLMDishV4>() // 菜餚
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
                   dish: List<RLMDishV4>) {
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
    let rank = try container.decode(String.self, forKey: .rank)
    let comment = try container.decode(String.self, forKey: .comment)
    let id = try container.decode(Int.self, forKey: .id)
    let isCreate = try container.decode(Bool.self, forKey: .isCreate)
    let createDate = try container.decode(Date.self, forKey: .createDate)
    let parentID = try container.decode(Int.self, forKey: .parentID)
    let isLike = try container.decode(Bool.self, forKey: .isLike)
    let order = try container.decode(Int.self, forKey: .order)
    let images = try container.decode([RLMImageV4].self, forKey: .images)
    let dish = try container.decode([RLMDishV4].self, forKey: .dish)

    let realmID = RealmOptional<Int>()
    realmID.value = id
    let realmParentID = RealmOptional<Int>()
    realmParentID.value = parentID
    let realmOrder = RealmOptional<Int>()
    realmOrder.value = order
    let realmImages = List<RLMImageV4>()
    realmImages.append(objectsIn: images)
    let realmDishes = List<RLMDishV4>()
    realmDishes.append(objectsIn: dish)
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
              dish: realmDishes)
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
