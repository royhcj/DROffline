//
//  RLMImageV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import RealmSwift

enum ImageStatus: Int {
  case initial
  case zipping
  case waitForUpload
  case uploading
  case finish
}

class RLMImageV4: SubObject {

  @objc dynamic var phassetID: String? // PHAsset 的 identifier
  @objc dynamic var localName: String? // app bundle 內存檔的名稱
  @objc dynamic var imageID: String? // DB的ID
  @objc dynamic var url: String? // 圖片連結
  @objc dynamic var imageStatus = ImageStatus.initial.rawValue // 是否上傳中
  let photoLatitude = RealmOptional<Float>() // 精度
  let photoLongtitude = RealmOptional<Float>()  // 緯度
  let order = RealmOptional<Int>() // 圖片排序
  let dishReview = LinkingObjects(fromType: RLMDishReviewV4.self, property: "images") //所屬dishReview

}
