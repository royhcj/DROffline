//
//  RLMServiceV4+Image.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/26.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  internal class Image {
    internal var realm: Realm

    init(realm: Realm) {
      self.realm = realm
    }

    // no.0
    internal func createRLMImage(in rlmRestaurant: RLMRestaurantV4,
                                 kvoImage: KVOImageV4) {
      do {
        try realm.write {
          let rlmImage = realm.create(RLMImageV4.self)
          rlmImage.uuid = kvoImage.uuid
          rlmImage.phassetID = kvoImage.phassetID
          rlmImage.localName = kvoImage.localName
          rlmImage.imageID = kvoImage.imageID
          rlmImage.url = kvoImage.url
          rlmImage.imageStatus = kvoImage.imageStatus
          rlmImage.photoLatitude.value = kvoImage.photoLatitude
          rlmImage.photoLongtitude.value = kvoImage.photoLongtitude
          rlmImage.order.value = kvoImage.order
          //        rlmRestaurant.images.append(rlmImage)
        }
      } catch {
        print("RLMServiceV4+Image file's no.0 func error")
      }
    }

    // no.1
    internal func createRLMImage(in rlmDishReview: RLMDishReviewV4,
                                 kvoImage: KVOImageV4) {
      do {
        try realm.write {
          let rlmImage = realm.create(RLMImageV4.self)
          rlmImage.uuid = kvoImage.uuid
          rlmImage.phassetID = kvoImage.phassetID
          rlmImage.localName = kvoImage.localName
          rlmImage.imageID = kvoImage.imageID
          rlmImage.url = kvoImage.url
          rlmImage.imageStatus = kvoImage.imageStatus
          rlmImage.photoLatitude.value = kvoImage.photoLatitude
          rlmImage.photoLongtitude.value = kvoImage.photoLongtitude
          rlmImage.order.value = kvoImage.order
          rlmDishReview.images.append(rlmImage)
        }
      } catch {
        print("RLMServiceV4+Image file's no.1 func error")
      }
    }

    // no.2
    internal func update(_ image: RLMImageV4,
                         phassetID: String?) {
      do {
        try realm.write {
          if let phassetID = phassetID {
            image.phassetID = phassetID
          }
        }
      } catch {
        print("RLMServiceV4+Image file's no.2 func error")
      }
    }

    // no.3
    internal func update(_ image: RLMImageV4,
                         localName: String?) {
      do {
        try realm.write {
          image.localName = localName
        }
      } catch {
        print("RLMServiceV4+Image file's no.3 func error")
      }
    }

    // no.4
    internal func update(_ image: RLMImageV4,
                         imageID: String?) {
      do {
        try realm.write {
          image.imageID = imageID
        }
      } catch {
        print("RLMServiceV4+Image file's no.4 func error")
      }
    }

    // no.5
    internal func update(_ image: RLMImageV4,
                         url: String?) {
      do {
        try realm.write {
          image.url = url
        }
      } catch {
        print("RLMServiceV4+Image file's no.5 func error")
      }
    }

    // no.6
    internal func update(_ image: RLMImageV4,
                         imageStatus: Int?) {
      do {
        try realm.write {
          if let imageStatus = imageStatus {
            image.imageStatus = imageStatus
          }
        }
      } catch {
        print("RLMServiceV4+Image file's no.6 func error")
      }
    }

    // no.7
    internal func update(_ image: RLMImageV4,
                         photoLatitude: Float?) {
      do {
        try realm.write {
          image.photoLatitude.value = photoLatitude
        }
      } catch {
        print("RLMServiceV4+Image file's no.7 func error")
      }
    }

    // no.8
    internal func update(_ image: RLMImageV4,
                         photoLongtitude: Float? = nil) {
      do {
        try realm.write {
          image.photoLongtitude.value = photoLongtitude
        }
      } catch {
        print("RLMServiceV4+Image file's no.8 func error")
      }
    }

    // no.9
    internal func update(_ image: RLMImageV4,
                         order: Int? = nil) {
      do {
        try realm.write {
          image.order.value = order
        }
      } catch {
        print("RLMServiceV4+Image file's no.9 func error")
      }
    }

    // no.
    internal func getImage(uuid: String) -> RLMImageV4? {
      let predicate = NSPredicate(format: "uuid == '\(uuid)'")
      let rlmImage = realm.objects(RLMImageV4.self).filter(predicate).first
      return rlmImage
    }

    // no.10
    internal func delete(imageUUID: String) {
      do {
        try realm.write {
          let predicate = NSPredicate.init(format: "uuid == '\(imageUUID)'")
          if let rlmImage = realm.objects(RLMImageV4.self).filter(predicate).first {
            realm.delete(rlmImage)
          }
        }
      } catch {
        print("RLMServiceV4+Image file's no.10 func error")
      }
    }

    // no.11
    internal func update(remote: RLMImageV4, to local: RLMImageV4) {
      do {
        try realm.write {
          local.imageID = remote.imageID
          local.imageStatus = remote.imageStatus
          local.localName = remote.localName
          local.order.value = remote.order.value
          local.phassetID = remote.phassetID
          local.photoLatitude.value = remote.photoLatitude.value
          local.photoLongtitude.value = remote.photoLongtitude.value
          local.url = remote.url
        }
      } catch {
        print("RLMServiceV4+Image file's no.10 func error")
      }
    }

    // no.12
    internal func create(in dishReview: RLMDishReviewV4, with remote: RLMImageV4) {
      do {
        try realm.write {
          let local = realm.create(RLMImageV4.self)
          local.imageID = remote.imageID
          local.imageStatus = remote.imageStatus
          local.localName = remote.localName
          local.order.value = remote.order.value
          local.phassetID = remote.phassetID
          local.photoLatitude.value = remote.photoLatitude.value
          local.photoLongtitude.value = remote.photoLongtitude.value
          local.url = remote.url
          local.uuid = remote.uuid
          dishReview.images.append(local)
        }
      } catch {
        print("RLMServiceV4+Image file's no.12 func error")
      }
    }
  }

}
