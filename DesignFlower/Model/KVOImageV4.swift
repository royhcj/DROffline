//
//  KVOImageV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/20.
//

import Foundation
import UIKit
import Photos

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
  
  init(with rlmImage: RLMImageV4) {
    super.init()
    set(with: rlmImage)
  }
  
  func set(with rlmImage: RLMImageV4) {
    phassetID = rlmImage.phassetID
    localName = rlmImage.localName
    imageID = rlmImage.imageID
    url = rlmImage.url
    imageStatus = rlmImage.imageStatus
    photoLatitude = rlmImage.photoLatitude.value ?? -1
    photoLongtitude = rlmImage.photoLatitude.value ?? -1
    order = rlmImage.order.value ?? -1
    if let uuid = rlmImage.uuid {
      self.uuid = uuid
    }
  }

  func load(withUUID uuid: String) {
    guard let rlmImage = RLMServiceV4.shared.image.getImage(uuid: uuid)
    else { return }
    
    set(with: rlmImage)
  }

  func fetchUIImage(_ completion: @escaping ((UIImage?) -> ())) {
    if let localName = localName { // 來源1. 從local檔案取得
      do {
        let url = KVOImageV4.localFolder.appendingPathComponent(localName)
        let data = try Data.init(contentsOf: url)
        let image = UIImage.init(data: data, scale: 1)
        completion(image)
      } catch {
        completion(nil)
      }
    } else if let phassetID = phassetID {
      PHPhotoLibrary.requestAuthorization { status in
        if status != .authorized {
          DispatchQueue.main.async {
            completion(nil)
          }
          return
        }
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(localIdentifier = %@)", phassetID)
        
        let result = PHAsset.fetchAssets(with: .image, options: options)
        if let asset = result.firstObject {
          let manager = PHImageManager.default()
          manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: nil, resultHandler: { (result, _) in
            completion(result)
          })
        }
        
      } // end requestAuthorization
    }
  }

  
  static let localFolder: URL = {
    do {
      let documentUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      let url = documentUrl.appendingPathComponent("localImages")
      if !FileManager.default.fileExists(atPath: url.path) {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      }
      return url
    } catch {
      assert(false, "Error: Failed getting local image folder URL")
    }
  }()
}
