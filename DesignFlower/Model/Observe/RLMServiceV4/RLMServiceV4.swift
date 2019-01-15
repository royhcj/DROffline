//
//  RLMServiceV4.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/22.
//

import Foundation
import RealmSwift

internal class RLMServiceV4 {

  static var shared = RLMServiceV4()

  internal var realm: Realm

  private init() {
    realm = try! Realm()
  }

  internal func createRLM<T: SubObject>(uuid: String, type: T.Type) -> T? {
    do {
      var rlmObject: T?
      try realm.write {
        rlmObject = realm.create(type)
        rlmObject?.uuid = uuid
      }
      return rlmObject
    } catch {
      print("realm create error")
      return nil
    }
  }

  // no.1
  internal func update(_ restReview: RLMRestReviewV4, serviceRank: String?) {
    do {
      try realm.write {
        restReview.serviceRank = serviceRank
      }
    } catch {
      print("RLMServiceV4 file's no.1 func error")
    }
  }

  // no.2
  internal func update(_ restReview: RLMRestReviewV4, environmentRank: String?) {
    do {
      try realm.write {
        restReview.environmentRank = environmentRank
      }
    } catch {
      print("RLMServiceV4 file's no.2 func error")
    }
  }

  // no.3
  internal func update(_ restReview: RLMRestReviewV4, priceRank: String?) {
    do {
      try realm.write {
        restReview.priceRank = priceRank
      }
    } catch {
      print("RLMServiceV4 file's no.3 func error")
    }
  }

  // no.4-2
  internal func update(_ restReview: RLMRestReviewV4, title: String?) {
    do {
      try realm.write {
        restReview.title = title
      }
    } catch {
      print("RLMServiceV4 file's no.4 func error")
    }
  }

  internal func update(_ restReview: RLMRestReviewV4, comment: String?) {
    do {
      try realm.write {
        restReview.comment = comment
      }
    } catch {
      print("RLMServiceV4 file's no.4-2 func error")
    }
  }
  
  // no.5
  internal func update(_ restReview: RLMRestReviewV4, id: Int?) {
    do {
      try realm.write {
        restReview.id.value = id
      }
    } catch {
      print("RLMServiceV4 file's no.5 func error")
    }
  }
  // no.6
  internal func update(_ restReview: RLMRestReviewV4, isScratch: Bool) {
    do {
      try realm.write {
        restReview.isScratch.value = isScratch
      }
    } catch {
      print("RLMServiceV4 file's no.6 func error")
    }
  }
  // no.7
  internal func update(_ restReview: RLMRestReviewV4, allowedReaders: [Int]) {
    do {
      try realm.write {
        restReview.allowedReaders.removeAll()
        restReview.allowedReaders.append(objectsIn: allowedReaders)
      }
    } catch {
      print("RLMServiceV4 file's no.7 func error")
    }
  }
  // no.8
  internal func update(_ restReview: RLMRestReviewV4, createDate: Date) {
    do {
      try realm.write {
        restReview.createDate = createDate
      }
    } catch {
      print("RLMServiceV4 file's no.8 func error")
    }
  }
  // no.9
  internal func update(_ restReview: RLMRestReviewV4, eatingDate: Date?) {
    do {
      try realm.write {
        restReview.eatingDate = eatingDate
      }
    } catch {
      print("RLMServiceV4 file's no.9 func error")
    }
  }
  // no.10
  internal func update(_ restReview: RLMRestReviewV4, parentID: Int?) {
    do {
      try realm.write {
        restReview.parentID.value = parentID
      }
    } catch {
      print("RLMServiceV4 file's no.10 func error")
    }
  }
  // no.
  internal func update(_ restReview: RLMRestReviewV4, parentUUID: String?) {
    do {
      try realm.write {
        restReview.parentUUID = parentUUID
      }
    } catch {
      print("RLMServiceV4 file's no.11 func error")
    }
  }
  
  // no.11
  internal func update(_ restReview: RLMRestReviewV4, isShowComment: Bool) {
    do {
      try realm.write {
        restReview.isShowComment = isShowComment
      }
    } catch {
      print("RLMServiceV4 file's no.11 func error")
    }
  }
  // no.12
  internal func update(_ restReview: RLMRestReviewV4, isSync: Bool) {
    do {
      try realm.write {
        restReview.isSync = isSync
      }
    } catch {
      print("RLMServiceV4 file's no.12 func error")
    }
  }
  // no.13
  internal func update(_ restReview: RLMRestReviewV4, updateDate: Date?) {
    do {
      try realm.write {
        restReview.updateDate = updateDate
      }
    } catch {
      print("RLMServiceV4 file's no.13 func error")
    }
  }
  // no.14
  internal func update(_ restReview: RLMRestReviewV4, isFirst: Bool) {
    do {
      try realm.write {
        restReview.isFirst = isFirst
      }
    } catch {
      print("RLMServiceV4 file's no.14 func error")
    }
  }

  // no.15
  internal func delete(dishReviewUUID: String, forScratch: Bool? = nil) {
    do {
      try realm.write {
        var predicate: NSPredicate
        if let forScratch = forScratch {
          predicate = NSPredicate.init(format: "uuid == '\(dishReviewUUID)' && isScratch == \(forScratch ? true : false)")
        } else {
          predicate = NSPredicate.init(format: "uuid == '\(dishReviewUUID)'")
        }
        if let dishReview = realm.objects(RLMDishReviewV4.self).filter(predicate).first {

          var uuids = [String]() //記錄刪除後關聯的image uuid
          for image in dishReview.images {
            if let uuid = image.uuid {
              uuids.append(uuid)
            }
          }

          realm.delete(dishReview)

          guard uuids.count > 0  else {
            return
          }
          // 判斷是否有其他菜餚筆記使用，若無則刪除
          uuids.forEach({ (uuid) in

          guard self.isDishReviewContainImage(uuid: uuid) else {
            if let image = RLMServiceV4.shared.getImage(uuid: uuid) {
                realm.delete(image)
              }
            return
            }
            
          })
        }
      }
    } catch {
       print("RLMServiceV4 file's no.15 func error")
    }
  }

  func isDishReviewContainImage(uuid: String) -> Bool {
    let dishReviews = realm.objects(RLMDishReviewV4.self)
    for (i, dishReview)in dishReviews.enumerated() {
      if dishReview.images.contains(where: { (image) -> Bool in
        return image.uuid == uuid
      }) {
        return true
      } else {
        if i == ( dishReviews.count - 1 ) {
          return false
        }
        continue
      }
    }
    return false
  }
  
  // no.15-1
  internal func sortDishReviewsByOrder(for restReview: RLMRestReviewV4) {
    let needSort: Bool = {
      for (index, dishReview) in restReview.dishReviews.enumerated() {
        if dishReview.order.value != index {
          return true
        }
      }
      return false
    }()
    guard needSort else { return }
    
    do {
      try realm.write {
        restReview.dishReviews.sort {
          $0.order.value ?? 0 < $1.order.value ?? 0
        }
      }
    } catch {
      print("RLMServiceV4 file's no. 15-1 func error")
    }
  }

  // no.16
  internal func getRestReview(uuid: String) -> RLMRestReviewV4? {
    let predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
    let restReview = realm.objects(RLMRestReviewV4.self).filter(predicate).first
    return restReview
  }
  
  // no. 17
  internal func delete(reviewUUID: String, forScratch: Bool? = nil) {
    do {
      try realm.write {
        var predicate: NSPredicate
        if let forScratch = forScratch {
          predicate = NSPredicate.init(format: "uuid == '\(reviewUUID)' && isScratch == \(forScratch ? true : false)")
        } else {
          predicate = NSPredicate.init(format: "uuid == '\(reviewUUID)'")
        }
        if let review = realm.objects(RLMRestReviewV4.self).filter(predicate).first {
          realm.delete(review)
        }
      }
    } catch {
      print("RLMServiceV4 file's no.17 func error")
    }
  }

}
