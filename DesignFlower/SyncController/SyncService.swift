//
//  SyncService.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/12/12.
//

import RealmSwift


enum SyncServiceFactory {
  case upload
  case addToQueue //加入待上傳的Queue
}

class SyncService {
  private let realm: Realm
  private let tokens: [NotificationToken]

  init(modelTypes: [Syncable.Type], realm: Realm = try! Realm(), factory: SyncServiceFactory = .addToQueue) {
    self.realm = realm
    switch factory {
    case .addToQueue:
      tokens = modelTypes.map {
        $0.registerNotificationObserver(for: realm, callback: SyncService.AddToQueue.handleQueue)
      }
    case .upload:
      tokens = modelTypes.map {
        $0.registerNotificationObserver(for: realm, factory: .upload, callback: SyncService.Upload.handleUpload)
      }
    }

  }

  private class AddToQueue {

    static func handleQueue(_ update: Update) {
      update.modifications.forEach { AddToQueue.add($0) }
      update.deletedIds.forEach { AddToQueue.delete($0) }
    }

    static func add(_ object: Syncable) {

      // TODO: isConnected internet
      guard object.isSync() else {
        return
      }

      let uuid = object.getUUID()
      guard let restReview = RLMServiceV4.shared.getRestReview(uuid: uuid) else {
        print("can't find object")
        return
      }
      // 加入到Queue的列表
      self.addToRLMQueue(review: restReview)
    }

    static func delete(_ object: Identification) {
      addToRLMQueue(delete: object.uuid, id: object.id)
    }

    private static func addToRLMQueue(review: RLMRestReviewV4) {

      RLMServiceV4.shared.queue.createRLMQueue(copyBy: review)
      RLMServiceV4.shared.update(review, isSync: false)

    }

    private static func addToRLMQueue(delete uuid: String, id: Int?) {
      RLMServiceV4.shared.queue.createDeleteQueue(uuid: uuid, id: id)
    }
  }


}

extension SyncService {

  private class Upload {
    static func handleUpload(_ update: Update) {
      self.upload(update.insertions)
//      self.upload(update.modifications)
    }

    static func upload(_ objects: [Syncable]) {

      guard let object = objects.first else {
        return
      }

      let uuid = object.getUUID()
      guard let queueReview = RLMServiceV4.shared.queue.getQueueReview(uuid: uuid) else {
        print("can't find object")
        return
      }

      guard !queueReview.isDelete else {
        self.delete(with: queueReview)
        return
      }

      //判斷是否有未上傳的圖
      guard !hasUnUploadIMG(review: queueReview) else {
        uploadIMG(review: queueReview) { finish in
          if finish {
            self.upload(objects)
            print("upload img finish")
          } else {
            print("image uploaded fail")
          }
        }
        print("fail")
        return
      }

      let encoder = JSONEncoder()
      let data = try? encoder.encode(queueReview)

      if let id = object.getId().id, id != -1 {
        // TODO: 更新筆記
        // use put new review
//        let decoder = DRDecoder.decoder()
        if data != nil {
          UserService.RestReview.put(queueReview: queueReview) {
            switch $0 {
            case .success:
              RLMServiceV4.shared.queue.delete(queue: queueReview)
              var newObjects = objects
              newObjects.remove(at: 0)
              upload(newObjects)
              print("put review finish")
            case .failure(let error):
              upload(objects)
              print(error.localizedDescription)
            }
          }
        }
      } else {
        // TODO: 新增筆記 完成要回填id
        // use post update review
//        let decoder = DRDecoder.decoder()
        if data != nil {
//          let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
          UserService.RestReview.update(queueReview: queueReview) {
            switch $0 {
            case .success:
              RLMServiceV4.shared.queue.delete(queue: queueReview)
              var newObjects = objects
              newObjects.remove(at: 0)
              upload(newObjects)
              print("post review finish")
            case .failure(let error):
              upload(objects)
              print(error.localizedDescription)
            }
          }
        }
      }
    }

    private static func hasUnUploadIMG(review: RLMQueue) -> Bool {

      for dishReview in review.dishReviews {
        guard dishReview.images.count > 0 else {
          continue
        }
        for image in dishReview.images {
          if image.url == nil {
            return true
          }
        }
      }
      return false
    }

    private static func uploadIMG(review: RLMQueue, completion: @escaping (Bool) -> ()) {
      var images = [RLMImageV4]()

      review.dishReviews.forEach {
        for image in $0.images {
          if image.url == nil {
            images.append(image)
          } else if let url = image.url, !(url.contains("http")) {
            images.append(image)
          }
        }
      }
      guard images.count != 0 else {
        completion(true)
        return
      }
      self.update(images: images) {
        if $0 {
          completion(true)
        }
      }

    }

    static private func update(images: [RLMImageV4], completion: @escaping ((Bool) -> ()) ) {
      var imgs = images
      guard let image = imgs.first else {
        completion(true)
        return
      }
      guard image.url == nil, image.imageID == nil else {
        completion(false)
        return
      }
      let imgDocumentURLString = KVOImageV4.localFolder.path
      let imgURLString = "\(imgDocumentURLString)/\(image.localName ?? "")"
      guard let img = UIImage.init(contentsOfFile: imgURLString) else {
        completion(false)
        return
      }
      RLMServiceV4.shared.image.update(image, imageStatus: 3)
      UserService.RestReview.upload(img: img, completion: { (result) in
        switch result {
        case .success(let uploadIMGResponseAPI):
          RLMServiceV4.shared.image.update(image, url: uploadIMGResponseAPI.link)
          RLMServiceV4.shared.image.update(image, imageID: uploadIMGResponseAPI.id)
          RLMServiceV4.shared.image.update(image, imageStatus: 4)
        case .failure(let error):
          print(error.localizedDescription)
        }
        imgs.remove(at: 0)
        if imgs.count == 0 {
          completion(true)
        } else {
          self.update(images: imgs) {
            completion($0)
          }
        }

      })
    }

    private static func delete(with queueReview: RLMQueue) {
      //call API to delete
      print("uuid: \(String(describing: queueReview.uuid)), id:\(queueReview.id)")
      RLMServiceV4.shared.queue.delete(queue: queueReview)
      //let url = type.resourceURL.appendingPathComponent("/\(id)")
      // performRequest(method: "DELETE", url: url)
    }
  }

}


