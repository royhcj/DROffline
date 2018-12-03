//
//  KVOImageV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation

class KVOImageV4: NSObject {

  @objc dynamic var phassetID: String? // PHAsset 的 identifier
  @objc dynamic var localName: String? // app bundle 內存檔的名稱
  @objc dynamic var imageID: String? // DB的ID
  @objc dynamic var url: String? // 圖片連結
  @objc dynamic var imageStatus = ImageStatus.initial.rawValue // 是否上傳中
  @objc dynamic var photoLatitude: Float = -1.0 // 精度
  @objc dynamic var photoLongtitude: Float = -1.0 // 緯度
  @objc dynamic var order: Int = -1// 圖片排序
  var uuid = UUID().uuidString.lowercased() // local uuid
    //所屬dishReview
  init(uuid: String? = nil) {
    super.init()
    if let uuid = uuid {
      self.uuid = uuid
    }
  }

}
