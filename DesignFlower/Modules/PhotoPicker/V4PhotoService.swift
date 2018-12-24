//
//  V4PhotoService.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/24.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import RealmSwift

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
}
