//
//  RLMServiceV4+DishReview.swift
//  DishRank
//
//  Created by 馮仰靚 on 2018/11/26.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {

  internal class DishReview {
    internal var realm: Realm

    init(realm: Realm) {
      self.realm = realm
    }

    // no.1
    internal func create(from restReview: RLMRestReviewV4, dishReview: KVODishReviewV4) {
      do {
        var rlmNewDishReview: RLMDishReviewV4?
        try realm.write {
          let rlmDishReview = realm.create(RLMDishReviewV4.self)
          rlmDishReview.uuid = dishReview.uuid
          rlmDishReview.rank = dishReview.rank
          rlmDishReview.comment = dishReview.comment
          rlmDishReview.id.value = dishReview.id
          rlmDishReview.isCreate = dishReview.isCreate
          rlmDishReview.createDate = dishReview.createDate
          rlmDishReview.parentID.value = dishReview.parentID
          rlmDishReview.isLike.value = dishReview.isLike
          rlmDishReview.order.value = dishReview.order
          restReview.dishReviews.append(rlmDishReview)

          rlmNewDishReview = rlmDishReview
        }

        if let rlmDishReview = rlmNewDishReview {
          for kvoImage in dishReview.images {
            RLMServiceV4.shared.image.createRLMImage(in: rlmDishReview, kvoImage: kvoImage)
          }
          if let dish = dishReview.dish {
            RLMServiceV4.shared.dish.createRLMDish(in: rlmDishReview, kvoDish: dish)
          }
        }

      } catch {
        print("RLMServiceV4+DihsReview file's no.1 func error")
      }
    }

    // no.2
    internal func update(_ dishReview: RLMDishReviewV4, comment: String?) {
      do {
        try realm.write {
          dishReview.comment = comment
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.2 func error")
      }
    }

    // no.3
    internal func update(_ dishReview: RLMDishReviewV4, rank: String?) {
      do {
        try realm.write {
          dishReview.rank = rank
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.3 func error")
      }
    }

    // no.4
    internal func update(_ dishReview: RLMDishReviewV4, id: Int?) {
      do {
        try realm.write {
          dishReview.id.value = id
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.4 func error")
      }
    }

    // no.5
    internal func update(_ dishReview: RLMDishReviewV4, isCreate: Bool) {
      do {
        try realm.write {
          dishReview.isCreate = isCreate
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.5 func error")
      }
    }

    // no.6
    internal func update(_ dishReview: RLMDishReviewV4, createDate: Date) {
      do {
        try realm.write {
          dishReview.createDate = createDate
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.6 func error")
      }
    }

    // no.7
    internal func update(_ dishReview: RLMDishReviewV4, parentID: Int?) {
      do {
        try realm.write {
          dishReview.parentID.value = parentID
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.7 func error")
      }
    }

    // no.8
    internal func update(_ dishReview: RLMDishReviewV4, isLike: Bool?) {
      do {
        try realm.write {
          dishReview.isLike.value = isLike
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.8 func error")
      }
    }

    // no.9
    internal func update(_ dishReview: RLMDishReviewV4, order: Int?) {
      do {
        try realm.write {
          dishReview.order.value = order
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.9 func error")
      }
    }

    // no. 10
    internal func getDishReview(uuid: String) -> RLMDishReviewV4? {
      let predicate = NSPredicate(format: "uuid == '\(uuid)'")
      let dishReview = realm.objects(RLMDishReviewV4.self).filter(predicate).first
      return dishReview
    }

    // no.11
    internal func update(remoteDishReview: RLMDishReviewV4,to localDishReview: RLMDishReviewV4) {
      do {
        try realm.write {
          localDishReview.uuid = remoteDishReview.uuid
          localDishReview.rank = remoteDishReview.rank
          localDishReview.comment = remoteDishReview.comment
          localDishReview.id.value = remoteDishReview.id.value
          localDishReview.isCreate = remoteDishReview.isCreate
          localDishReview.createDate = remoteDishReview.createDate
          localDishReview.parentID.value = remoteDishReview.parentID.value
          localDishReview.isLike.value = remoteDishReview.isLike.value
          localDishReview.order.value = remoteDishReview.order.value
        }
        // 更新菜餚資訊

        if let remoteDish = remoteDishReview.dish {
           RLMServiceV4.shared.dish.update(remoteDish: remoteDish, to: localDishReview.dish)
        }


        // 更新圖片資訊
        var uuid = [String]()
        for remoteImage in remoteDishReview.images {
          if let localImage = localDishReview.images.filter({ (localImage) -> Bool in
            if let localImageID = localImage.imageID, let remoteImageID = remoteImage.imageID {
              return localImageID == remoteImageID
            }
            if let localUUID = localImage.uuid, let remoteUUID = remoteImage.uuid {
              return localUUID == remoteUUID
            }
            return false
          }).first  {
            RLMServiceV4.shared.image.update(remote: remoteImage, to: localImage)
            uuid.append(localImage.uuid!)
          } else {
            RLMServiceV4.shared.image.create(in: localDishReview, with: remoteImage)
            uuid.append(remoteImage.uuid!)
          }
        }

        // 紀錄沒有的
        var removedUUID = [String]()
        for localImage in localDishReview.images {
          if !uuid.contains(localImage.uuid!) {
            removedUUID.append(localImage.uuid!)
          }
        }

        // 移除沒有的
        for uuid in removedUUID {
           RLMServiceV4.shared.image.delete(imageUUID: uuid)
        }

      } catch {
        print("RLMServiceV4+DihsReview file's no.11 func error")
      }
    }
    
    // no. 12
    internal func update(_ dishReview: RLMDishReviewV4, dish: KVODishV4) {
      let rlmDish = realm.objects(RLMDishV4.self).filter {
        $0.uuid == dish.uuid
      }.first
      
      do {
        try realm.write {
          if let rlmDish = rlmDish {
            dishReview.dish = rlmDish
          } else {
            let rlmDish = RLMDishV4(name: dish.name, id: RealmOptional<Int>(dish.id))
            dishReview.dish = rlmDish
          }
        }
      } catch {
        print("RLMServiceV4+DihsReview file's no.12 func error")
      }
    }

  }


}
