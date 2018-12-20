//
//  SyncService.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/12/12.
//

import RealmSwift

class SyncService {
  private let realm: Realm
  private let tokens: [NotificationToken]

  init(modelTypes: [Syncable.Type], realm: Realm = try! Realm()) {
    self.realm = realm

    tokens = modelTypes.map {
      $0.registerNotificationObserver(for: realm, callback: SyncService.handleUpdate)
    }
  }

  private static func handleUpdate(_ update: Update) {
    update.modifications.forEach { upload($0) }
    update.deletedIds.forEach { deleteObject(withId: $0, ofType: update.type) }
  }

  private static func upload(_ object: Syncable) {

    guard object.isSync() else {
      return
    }

    let uuid = object.getUUID()
    guard let restReview = RLMServiceV4.shared.getRestReview(uuid: uuid) else {
      print("can't find object")
      return
    }

    let encoder = JSONEncoder()
    let data = try? encoder.encode(restReview)


//    print(json)
    let decoder = JSONDecoder()
    if let data = data {
       let review = try? decoder.decode(RLMRestReviewV4.self, from: data)
      print(String(decoding: data, as: UTF8.self))
    }


    if let id = object.getId() {
      // use post new review
    } else {
      // use put update review
    }
  }

  private static func deleteObject(withId id: String, ofType type: Syncable.Type) {
    //      let url = type.resourceURL.appendingPathComponent("/\(id)")
    //      performRequest(method: "DELETE", url: url)
  }

}
