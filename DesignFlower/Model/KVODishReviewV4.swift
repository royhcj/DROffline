//
//  KVODishReviewV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation

class KVODishReviewV4: NSObject {

  static func == (lhs: KVODishReviewV4, rhs: KVODishReviewV4) -> Bool {
    return lhs.uuid == rhs.uuid 
  }

  @objc dynamic var rank: String? // 分數
  @objc dynamic var comment: String? // 評比
  @objc dynamic var id = -1 // 評比ID
  @objc dynamic var isCreate = false // 不透過圖片直接建立新的評比
  @objc dynamic var createDate: Date = Date.now
  @objc dynamic var parentID = -1// 複製品紀錄本尊的ID
  @objc dynamic var isLike = false // 是否為使用者蒐藏
  @objc dynamic var order = -1 // 順序
  @objc dynamic var dish: KVODishV4? // 菜餚
  @objc dynamic var images = [KVOImageV4]() // 圖片
  var uuid = UUID().uuidString.lowercased() // local uuid

  init(uuid: String? = nil, service: RLMServiceV4 = RLMServiceV4.shared) {
    super.init()
    if let uuid = uuid {
      self.uuid = uuid
      load(withUUID: uuid, service: service)
    }
  }
  
  init(with rlmDishReview: RLMDishReviewV4) {
    super.init()
    set(with: rlmDishReview)
  }
  
  func set(with rlmDishReview: RLMDishReviewV4) {
    
    rank = rlmDishReview.rank
    comment = rlmDishReview.comment
    id = rlmDishReview.id.value ?? -1
    isCreate = rlmDishReview.isCreate
    createDate = rlmDishReview.createDate
    parentID = rlmDishReview.parentID.value ?? -1
    isLike = rlmDishReview.isLike.value ?? false
    order = rlmDishReview.order.value ?? -1
    if let dish = rlmDishReview.dish {
      self.dish = KVODishV4(with: dish)
    }

    images = []
    for image in rlmDishReview.images {
      let image = KVOImageV4(with: image)
      images.append(image)
    }
    
    if let uuid = rlmDishReview.uuid {
      self.uuid = uuid
    }
  }
  
  func load(withUUID uuid: String, service: RLMServiceV4) {
    guard let rlmDishReview = service.dishReview.getDishReview(uuid: uuid)
    else { return }
    
    set(with: rlmDishReview)
  }
  
  func copyForShare() -> KVODishReviewV4 {
    let dreview = KVODishReviewV4(uuid: nil)
    dreview.rank = rank
    dreview.comment = comment
    //dreview.id =
    dreview.isCreate = false
    dreview.createDate = createDate
    //dreview.parentID = id
    dreview.isLike = isLike
    dreview.order = order
    dreview.dish = dish
    dreview.images = images
    
    return dreview
  }

}
