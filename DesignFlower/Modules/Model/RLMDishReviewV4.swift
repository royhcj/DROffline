//
//  RLMDishReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/14.
//

import Foundation
import RealmSwift

class RLMDishReviewV4: SubObject {

  @objc dynamic var rank: String? // 分數
  @objc dynamic var comment: String? // 評比
  let id = RealmOptional<Int>() // 評比ID
  @objc dynamic var isCreate = false // 不透過圖片直接建立新的評比
  @objc dynamic var createDate: Date = Date()
  let parentID = RealmOptional<Int>() // 複製品紀錄本尊的ID
  let isLike = RealmOptional<Bool>() // 是否為使用者蒐藏
  let order = RealmOptional<Int>() // 順序
  let images = List<RLMImageV4>() // 圖片
  let dish = List<RLMDishV4>() // 菜餚
//  @objc dynamic var uuid: String? // dish uuid

  // 自動會管理
  let restReview = LinkingObjects(fromType: RLMRestReviewV4.self, property: "dishReviews")

}
