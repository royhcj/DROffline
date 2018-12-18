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
    
    if object.isFirst() {
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
