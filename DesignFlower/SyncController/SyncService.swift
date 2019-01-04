//
//  SyncService.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/12/12.
//

import RealmSwift

enum SyncServiceFactory {
  case upload
  case addToQueue
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
      RLMServiceV4.shared.createRLMQueue(copyBy: review)
    }

    private static func addToRLMQueue(delete uuid: String, id: Int?) {
      RLMServiceV4.shared.createDeleteQueue(uuid: uuid, id: id)
    }
  }


}

extension SyncService {

  private class Upload {
    static func handleUpload(_ update: Update) {
      self.upload(update.insertions)
    }

    static func upload(_ objects: [Syncable]) {

      guard let object = objects.first else {
        return
      }

      let uuid = object.getUUID()
      guard let queueReview = RLMServiceV4.shared.getQueueReview(uuid: uuid) else {
        print("can't find object")
        return
      }

      guard !queueReview.isDelete else {
        self.delete(with: queueReview)
        return
      }

      guard !hasUnUploadIMG(review: queueReview) else {
        uploadIMG(review: queueReview) { finish in
          if finish {
            self.upload(objects)
          }
        }
        return
      }

      let encoder = JSONEncoder()
      let data = try? encoder.encode(queueReview)

      if object.getId().id != nil {
        // TODO: 更新筆記
        // use post new review
//        let decoder = JSONDecoder()
        if let data = data {
//        let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
          print(String(decoding: data, as: UTF8.self))
          RLMServiceV4.shared.delete(queue: queueReview)
          var newObjects = objects
          newObjects.remove(at: 0)
          upload(newObjects)
        }
      } else {
        // TODO: 新增筆記 完成要回填id
        // use put update review
//        let decoder = JSONDecoder()
        if let data = data {
//          let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
          print(String(decoding: data, as: UTF8.self))
          RLMServiceV4.shared.delete(queue: queueReview)
          var newObjects = objects
          newObjects.remove(at: 0)
          upload(newObjects)
        }
      }
    }

    private static func hasUnUploadIMG(review: RLMQueue) -> Bool {
      for dishReview in review.dishReviews {
        for image in dishReview.images {
          if image.url == nil {
            return true
          }
        }
      }
      return false
    }

    private static func uploadIMG(review: RLMQueue, completion: (Bool) -> ()) {

      review.dishReviews.forEach {
        // TODO: 上傳圖片
        $0.images.forEach({
          RLMServiceV4.shared.update($0, url: "http://xxx.xxx.xxx")
        })
      }
      completion(true)
    }

    private static func delete(with queueReview: RLMQueue) {
      //call API to delete
      print("uuid: \(queueReview.uuid), id:\(queueReview.id)")
      RLMServiceV4.shared.delete(queue: queueReview)
      //      let url = type.resourceURL.appendingPathComponent("/\(id)")
      //      performRequest(method: "DELETE", url: url)
    }
  }

}


