//
//  RLMImageV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/15.
//

import Foundation
import Realm
import RealmSwift

enum ImageStatus: Int {
  case initial
  case zipping
  case waitForUpload
  case uploading
  case finish
}

class RLMImageV4: SubObject, Codable {

  @objc dynamic var phassetID: String? // PHAsset 的 identifier
  @objc dynamic var localName: String? // app bundle 內存檔的名稱
  @objc dynamic var imageID: String? // DB的ID
  @objc dynamic var url: String? // 圖片連結
  @objc dynamic var imageStatus = ImageStatus.initial.rawValue // 是否上傳中
  var photoLatitude = RealmOptional<Float>() // 精度
  var photoLongtitude = RealmOptional<Float>()  // 緯度
  var order = RealmOptional<Int>() // 圖片排序
  var dishReview = LinkingObjects(fromType: RLMDishReviewV4.self, property: "images") //所屬dishReview

  convenience init(phassetID: String?,
                   localName: String?,
                   imageID: String?,
                   url: String?,
                   imageStatus: Int,
                   photoLatitude: RealmOptional<Float>,
                   photoLongtitude: RealmOptional<Float>,
                   order: RealmOptional<Int>) {
    self.init()
    self.phassetID = phassetID
    self.localName = localName
    self.imageID = imageID
    self.imageStatus = imageStatus
    self.photoLatitude = photoLatitude
    self.photoLongtitude = photoLongtitude
    self.order = order

  }

  enum RLMImageV4CodingKey: String, CodingKey {
    case phassetID
    case localName
    case imageID
    case url
    case imageStatus
    case photoLatitude
    case photoLongtitude
    case order
  }

  convenience required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RLMImageV4CodingKey.self)
    let phassetID = try container.decode(String.self, forKey: .phassetID)
    let localName = try container.decode(String.self, forKey: .localName)
    let imageID = try container.decode(String.self, forKey: .photoLatitude)
    let url = try container.decode(String.self, forKey: .url)
    let imageStatus = try container.decode(Int.self, forKey: .imageStatus)
    let photoLongtitude = try container.decode(Float.self, forKey: .photoLongtitude)
    let photoLatitude = try container.decode(Float.self, forKey: .photoLatitude)
    let order = try container.decode(Int.self, forKey: .order)
    let latitude = RealmOptional<Float>()
    latitude.value = photoLatitude
    let longtitude = RealmOptional<Float>()
    longtitude.value = photoLongtitude
    let ord = RealmOptional<Int>()
    ord.value = order
    self.init(phassetID: phassetID,
              localName: localName,
              imageID: imageID,
              url: url,
              imageStatus: imageStatus,
              photoLatitude: latitude,
              photoLongtitude: longtitude,
              order: ord)

  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: RLMImageV4CodingKey.self)
    try container.encode(phassetID, forKey: .phassetID)
    try container.encode(localName, forKey: .localName)
    try container.encode(imageID, forKey: .imageID)
    try container.encode(url, forKey: .url)
    try container.encode(imageStatus, forKey: .imageStatus)
    try container.encode(photoLongtitude.value, forKey: .photoLongtitude)
    try container.encode(photoLatitude.value, forKey: .photoLatitude)
    try container.encode(order.value, forKey: .order)
    
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
