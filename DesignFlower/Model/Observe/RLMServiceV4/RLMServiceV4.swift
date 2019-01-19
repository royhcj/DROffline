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
  internal var dishReview: DishReview
  internal var dish: Dish
  internal var image: RLMServiceV4.Image

  private init() {
    realm = try! Realm()
    dishReview = RLMServiceV4.DishReview(realm: realm)
    dish = RLMServiceV4.Dish(realm: realm)
    image = RLMServiceV4.Image(realm: realm)
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
  
  // no.
  internal func update(_ restReview: RLMRestReviewV4, restaurant: KVORestaurantV4) {
    let rlmRestaurant = realm.objects(RLMRestaurantV4.self).filter {
      $0.uuid == restaurant.uuid
    }.first
    
    do {
      try realm.write {
        if let rlmRestaurant = rlmRestaurant {
          restReview.restaurant = rlmRestaurant
        } else {
          let rlmRestaurant = RLMRestaurantV4()
          rlmRestaurant.name = restaurant.name
          rlmRestaurant.latitude.value = restaurant.latitude
          rlmRestaurant.longitude.value = restaurant.longitude
          rlmRestaurant.address = restaurant.address
          rlmRestaurant.country = restaurant.country
          rlmRestaurant.area.value = restaurant.area
          rlmRestaurant.phoneNumber = restaurant.phoneNumber
          rlmRestaurant.openHour = restaurant.openHour
          restReview.restaurant = rlmRestaurant
        }
      }
    } catch {
      print(error)
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
              if let image = RLMServiceV4.shared.image.getImage(uuid: uuid) {
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
  internal func getRestReview(uuid: String?, id: Int? = nil) -> RLMRestReviewV4? {

    var predicate: NSPredicate
    var review: RLMRestReviewV4?
    if let uuid = uuid {
      predicate = NSPredicate.init(format: "uuid == '\(uuid)'")
      review = realm.objects(RLMRestReviewV4.self).filter(predicate).first
    }

    if let id = id {
      predicate = NSPredicate.init(format: "id == \(id)")
      review = review != nil ? review : realm.objects(RLMRestReviewV4.self).filter(predicate).first
    }
    return review
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

  // no. 18
  internal func isExist(reviewUUID: String?, reviewID: Int?) -> Bool {
    var predicate: NSPredicate
    if let uuid = reviewUUID {
      predicate = NSPredicate(format: "uuid == '\(uuid)'")
      guard realm.objects(RLMRestReviewV4.self).filter(predicate).count == 0 else {
        return true
      }
    }
    if let id = reviewID {
      predicate = NSPredicate(format: "id == \(id)")
      guard realm.objects(RLMRestReviewV4.self).filter(predicate).count == 0 else {
        return true
      }
    }
    return false
  }

  internal func createRLMRestReviewV4() -> RLMRestReviewV4? {
    do {
      var review: RLMRestReviewV4?
      try realm.write {
        review = realm.create(RLMRestReviewV4.self)
      }
      return review
    } catch {
      return nil
    }
    return nil
  }

  // no.19
  internal func createRLM(with remoteRestReview: RLMRestReviewV4) {
    guard let localRestReview = createRLMRestReviewV4() else {
      return
    }
    RLMServiceV4.shared.update(localRestReview, with: remoteRestReview)
  }

  internal func update(_ localRestReview: RLMRestReviewV4, with remoteReview: RLMRestReviewV4) {
    do {
      try realm.write {
        localRestReview.allowedReaders = remoteReview.allowedReaders
        localRestReview.comment = remoteReview.comment
        localRestReview.createDate = remoteReview.createDate
        localRestReview.id.value = remoteReview.id.value
        localRestReview.uuid = remoteReview.uuid
        localRestReview.eatingDate = remoteReview.eatingDate
        localRestReview.environmentRank = remoteReview.environmentRank
        localRestReview.isFirst = remoteReview.isFirst
        localRestReview.isScratch.value = remoteReview.isScratch.value
        localRestReview.isShowComment = remoteReview.isShowComment
        localRestReview.isSync = remoteReview.isSync
        localRestReview.parentID.value = remoteReview.parentID.value
        localRestReview.parentUUID = remoteReview.parentUUID
        localRestReview.priceRank = remoteReview.priceRank
        localRestReview.restaurant = remoteReview.restaurant
        localRestReview.serviceRank = remoteReview.serviceRank
        localRestReview.title = remoteReview.title
        localRestReview.updateDate = remoteReview.updateDate

        if let local = localRestReview.restaurant {
         if let remote = remoteReview.restaurant {
          updateRestaurant(local: local, remote: remote)
         } else {
          realm.delete(local)
         }
        } else {
          localRestReview.restaurant = realm.create(RLMRestaurantV4.self)
          updateRestaurant(local: localRestReview.restaurant!, remote: remoteReview.restaurant)
        }
      }


      func updateRestaurant(local: RLMRestaurantV4, remote: RLMRestaurantV4?) {
        guard let remote = remote else {
          return
        }

        local.address = remote.address
        local.area = remote.area
        local.country = remote.country
        local.latitude = remote.latitude
        local.longitude = remote.longitude
        local.name = remote.name
        local.openHour = remote.openHour
        local.phoneNumber = remote.phoneNumber

      }

      for remoteDishReview in remoteReview.dishReviews {
        if let localDishReview = localRestReview.filter(remoteObject: remoteDishReview, localObjects:  Array(localRestReview.dishReviews)) as? RLMDishReviewV4 {
          // TODO: 更新
          RLMServiceV4.shared.dishReview.update(remoteDishReview: remoteDishReview, to: localDishReview)
        } else {
          // TODO: 新增
          do {
            try realm.write {
               localRestReview.dishReviews.append(remoteDishReview)
            }
          } catch {

          }
        }
      }
    } catch {

    }
  }

  // no.20
  internal func getRestReviewList() -> [RLMRestReviewV4]? {
    return Array(realm.objects(RLMRestReviewV4.self).sorted(byKeyPath: "updateDate", ascending: false))
  }
//  func filter(remoteObject: SubObject, localObjects: [SubObject]) -> SubObject? {
//    if let localObject = localObjects.filter({ (localDishReview) -> Bool in
//      if let localID = localDishReview.id.value, let remoteID = remoteObject.id.value {
//        return localID == remoteID
//      }
//      if let localUUID = localDishReview.uuid, let remoteUUID = remoteObject.uuid {
//        return localUUID == remoteUUID
//      }
//      return false
//    }).first {
//      return localObject
//    }
//    return nil
//  }
}


