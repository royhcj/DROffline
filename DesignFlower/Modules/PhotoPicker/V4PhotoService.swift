//
//  V4PhotoService.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/24.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import RealmSwift
import Photos


public class V4PhotoSelection: Object {
  @objc dynamic var identifier: String?
  @objc dynamic var selectedDate: Date? // 照片選擇日期
  
  convenience init(identifier: String, selectedDate: Date?) {
    self.init()
    self.identifier = identifier
    self.selectedDate = selectedDate
  }
}

public class V4PhotoService {
  public static var shared = V4PhotoService()
  private var realm: Realm = try! Realm()
  
  public func getPhotoSelections() -> Results<V4PhotoSelection> {
    return realm.objects(V4PhotoSelection.self)
  }
  
  public func addPhotoSelection(_ selection: V4PhotoSelection,
                                isSingle: Bool) {
    if isSingle {
      deleteAllPhotoSelections()
    }
    
    do {
      try realm.write {
        realm.add(selection)
      }
    } catch {
      print(error)
    }
  }
  
  public func deleteNotePhotoSelection(with identifier: String) {
    let selections = realm.objects(V4PhotoSelection.self).filter {
      $0.identifier == identifier
    }
    do {
      try realm.write {
        selections.forEach {
          realm.delete($0)
        }
      }
    } catch {
      print(error)
    }
  }
  
  public func deleteAllPhotoSelections() {
    let selections = realm.objects(V4PhotoSelection.self)
    do {
      try realm.write {
        selections.forEach {
          realm.delete($0)
        }
      }
    } catch {
      print(error)
    }
  }
  
  public func getAssets(withIdentifiers identifiers: [String],
                        completion: @escaping((PHFetchResult<PHAsset>?) -> Void)) {
    guard identifiers.isEmpty == false else {
      DispatchQueue.main.async {
        completion(nil)
      }
      return
    }
    
    PHPhotoLibrary.requestAuthorization({ status in
      if status != .authorized {
        DispatchQueue.main.async {
          completion(nil)
        }
        return
      }
      
      // 则获取所有资源
      let allPhotosOptions = PHFetchOptions()
      // 按照创建时间倒序排列
      allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                           ascending: false)]
      // 只获取图片
      //allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
      //                                         PHAssetMediaType.image.rawValue)
      let predicateFormat = identifiers.map { _ in
        String(format: "(localIdentifier = %%@)")
        }.joined(separator: " OR ")
      
      allPhotosOptions.predicate = NSPredicate(format: predicateFormat,
                                               argumentArray: identifiers)
      let result = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                       options: allPhotosOptions)
      DispatchQueue.main.async {
        completion(result)
      }
    })
  }
  
  public func getAssets(withCreationDates creationDates: [Date],
                        completion: @escaping((PHFetchResult<PHAsset>?) -> Void)) {
    guard creationDates.isEmpty == false else {
      DispatchQueue.main.async {
        completion(nil)
      }
      return
    }
    
    PHPhotoLibrary.requestAuthorization({ status in
      if status != .authorized {
        DispatchQueue.main.async {
          completion(nil)
        }
        return
      }
      
      // 则获取所有资源
      let allPhotosOptions = PHFetchOptions()
      // 按照创建时间倒序排列
      allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                           ascending: false)]
      // 只获取图片
      //allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
      //                                         PHAssetMediaType.image.rawValue)
      let predicateFormat = creationDates.map { _ in
        String(format: "(creationDate = %%@)")
        }.joined(separator: " OR ")
      
      allPhotosOptions.predicate = NSPredicate(format: predicateFormat,
                                               argumentArray: creationDates)
      let result = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                       options: allPhotosOptions)
      DispatchQueue.main.async {
        completion(result)
      }
    })
  }
  
  func getUIImage(for asset: PHAsset,
                  completion: @escaping ((UIImage?) -> ())) {
    let manager = PHImageManager.default()
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.isNetworkAccessAllowed = true
    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: options, resultHandler: { (result, _) in
      completion(result)
    })
  }
  
  func createKVOImage(with asset: PHAsset,
                      resolution: UIImage.ResizeResolution = .fullHD,
                      completion: @escaping ((KVOImageV4?) -> Void)) {
    getUIImage(for: asset) { uiImage in
      guard let uiImage = uiImage
      else {
        completion(nil)
        return
      }
      
      var uiImageResized: UIImage
      do {
        uiImageResized = try UIImage.resize(image: uiImage,
                                            to: resolution,
                                            keepAspectRatio: true,
                                            scaleDownOnly: true)
      } catch {
        print(error)
        completion(nil)
        return
      }
      
      guard let imageData = UIImageJPEGRepresentation(uiImageResized, 1.0)
      else {
        completion(nil)
        return
      }
      
      let uuid = UUID().uuidString.lowercased()
      let filename = "\(uuid).jpg"
      let path = KVOImageV4.localFolder.appendingPathComponent(filename)
      
      do {
        try imageData.write(to: path)
        
        let image = KVOImageV4(uuid: nil)
        image.imageStatus = ImageStatus.waitForUpload.rawValue
        image.localName = filename
        completion(image)
      } catch {
        print("error saving file:", error)
        completion(nil)
      }
    }
  }
}
