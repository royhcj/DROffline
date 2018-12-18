//
//  Uploadable.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/12/18.
//

import Foundation
import RealmSwift

protocol Uploadable {
//  static var resourceURL: URL { get }
}

typealias Syncable = SubObject & Uploadable

struct Update {
//  let insertions: [Syncable]
  let modifications: [Syncable]
  let deletedIds: [String]
  let type: Syncable.Type
}

extension Uploadable where Self: SubObject {

  func getUUID() -> String {
    guard let uuidKey = type(of: self).uuidKey() else {
      fatalError("Object can't be managed without a uuidKey")
    }

    guard let uuid = self.value(forKey: uuidKey) else {
      fatalError("Objects uuidKey isn't set")
    }

    return String(describing: uuid)
  }

  func isSync() -> Bool {
    guard let isSyncKey = type(of: self).isSyncKey() else {
      fatalError("Object can't be managed without isSyncKey")
    }

    guard let isSync = self.value(forKey: isSyncKey) as? Bool else {
      fatalError("Object isSync isn't set")
    }

    return isSync
  }

  func isFirst() -> Bool {
    guard let isFirstKey = type(of: self).isFirstKey() else {
      fatalError("Object can't be managed without isFirstKey")
    }

    guard let isFirst = self.value(forKey: isFirstKey) as? Bool else {
      fatalError("Object isFirst isn't set")
    }

    return isFirst
  }

  static func registerNotificationObserver(for realm: Realm, callback: @escaping (Update) -> Void) -> NotificationToken {
    let objects = realm.objects(self)
    var objectIds: [String]!

    return objects.observe { changes in
      switch changes {
      case .initial(_):
        objectIds = objects.map { $0.getUUID() }
      case .update(let collection, let deletions, _, let modifications):
//        let insertedObjects = insertions.map { collection[$0] }
        let modifiedObjects = modifications.map { collection[$0] }
        let deletedIds = deletions.map { objectIds[$0] }

        let update = Update(modifications: modifiedObjects, deletedIds: deletedIds, type: Self.self)
        callback(update)

        objectIds = objects.map { $0.getUUID() }
      case .error(_):
        break
      }
    }
  }
}
