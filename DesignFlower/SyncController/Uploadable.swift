//
//  Uploadable.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/12/18.
//

import Foundation
import RealmSwift

protocol Uploadable: Codable {
//  static var resourceURL: URL { get }
}

typealias Syncable = SubObject & Uploadable

struct Identification {
  var id: Int?
  var uuid: String
}

struct Update {
  let insertions: [Syncable]
  let modifications: [Syncable]
  let deletedIds: [Identification]
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

  func getId() -> Identification {

    guard let uuidKey = type(of: self).uuidKey() else {
      fatalError("Object can't be managed without a uuidKey")
    }

    guard let uuid = self.value(forKey: uuidKey) else {
      fatalError("Objects uuidKey isn't set")
    }
    var identification = Identification.init(id: nil, uuid: String(describing: uuid))

    guard let idKey = type(of: self).idKey() else {
      return identification
    }

    guard let id = self.value(forKey: idKey) as? Int else {
      return identification
    }

    identification.id = id

    return identification
  }

  static func registerNotificationObserver(for realm: Realm,factory:  SyncServiceFactory = .addToQueue, callback: @escaping (Update) -> Void) -> NotificationToken {
    let objects = realm.objects(self)
    var objectIds: [Identification]!

    return objects.observe { changes in
      switch changes {
      case .initial(let collection):
        objectIds = objects.map { $0.getId() }
        switch factory {
        case .addToQueue:
          break
        case .upload:
          var insertedObjects = [Syncable]()
          collection.forEach({ (object) in
            insertedObjects.append(object)
          })
          let update = Update(insertions: insertedObjects, modifications: [], deletedIds: [], type: Self.self)
          callback(update)
          break
        }
      case .update(let collection, let deletions, let insertions, let modifications):
        let insertedObjects = insertions.map { collection[$0] }
        let modifiedObjects = modifications.map { collection[$0] }
        //let deletedIds = deletions.map { objectIds[$0] } // 會當機
        let deletedIds = deletions.compactMap { objectIds.at($0) } // TODO: 先改這樣, 稍後再修

        let update = Update(insertions: insertedObjects, modifications: modifiedObjects, deletedIds: deletedIds, type: Self.self)
        callback(update)

        objectIds = objects.map { $0.getId() }
      case .error(_):
        break
      }
    }
  }
}
