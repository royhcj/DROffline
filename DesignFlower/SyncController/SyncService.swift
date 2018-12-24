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
        $0.registerNotificationObserver(for: realm, callback: SyncService.Upload.handleUpload)
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
      update.modifications.forEach { upload($0) }
      update.deletedIds.forEach { delete(with: $0)}
    }

    static func upload(_ object: Syncable) {

      let uuid = object.getUUID()
      guard let queueReview = RLMServiceV4.shared.getQueueReview(uuid: uuid) else {
        print("can't find object")
        return
      }

      let encoder = JSONEncoder()
      let data = try? encoder.encode(queueReview)

      if let id = object.getId().id {
        // use post new review
              let decoder = JSONDecoder()
              if let data = data {
                let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
                print(String(decoding: data, as: UTF8.self))
                RLMServiceV4.shared.delete(queue: queueReview)
              }

      } else {
        // use put update review
        let decoder = JSONDecoder()
        if let data = data {
          let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
          print(String(decoding: data, as: UTF8.self))
          RLMServiceV4.shared.delete(queue: queueReview)
        }

      }
    }

    private static func delete(with identification: Identification) {

      guard let queueReview = RLMServiceV4.shared.getQueueReview(uuid: identification.uuid) else {
        print("can't find object")
        return
      }
      print("uuid: \(identification.uuid), id:\(identification.id)")
      RLMServiceV4.shared.delete(queue: queueReview)
      //      let url = type.resourceURL.appendingPathComponent("/\(id)")
      //      performRequest(method: "DELETE", url: url)
    }
  }

}


