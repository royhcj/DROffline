//
//  NoteV3DishReviewAPI.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/6/7.
//

import UIKit
import PromiseKit
import SwiftyJSON
import RealmSwift

extension WebService {
  class NoteV3FriendAPI: ServiceBase {
    class func postFriends(accessToken: String
      ) -> Promise<FriendJSON> {
      let url = "\(configuration.environment.apiURL)/me/friends"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    class func getRecentFriends(accessToken: String
      ) -> Promise<FriendJSON> {
      let url = "\(configuration.environment.apiURL)/last-allowed-reader"
      return response(url: url, method: .get) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }
  }


  class NoteV3DishReviewAPI: ServiceBase {
/* TODO: Add back later.
    // 96 新版新增菜餚評比
    class func postDishReview(accessToken: String,
                              restaurantReviewID: Int,
                              dishID: Int,
                              shareType: Int,
                              dishReview: RLMDishReviewV3) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)/dish"
      return response(url: url, method: .post, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken,
                                         "dishID": dishID,
                                         "shareType": shareType]
        //parameters["allowedReaders"] = ... // TODO: Check later
        parameters["comment"] = dishReview.comment
        parameters["dishRank"] = dishReview.rank
        if let imageID = dishReview.imageID {
          parameters["uploadMedia"] = [imageID]
        }
        return parameters
      }
    }

    // 97 新版修改菜餚評比
    class func putDishReview(accessToken: String,
                             restaurantReviewID: Int,
                             dishReviewID: Int,
                             dishReview: RLMDishReviewV3) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)/dish/\(dishReviewID)"
      return response(url: url, method: .put, headerParameters: nil) {
        guard let dishID = dishReview.dishID.value
        else { throw "❗️Error: Invalid arguments in putDishReview." }
        var parameters: [String: Any] = ["accessToken": accessToken]
        parameters["dishID"] = dishID
        parameters["shareType"] = 0 // TODO: Check later
        //parameters["allowedReaders"] = ... // TODO: Check later
        parameters["comment"] = dishReview.comment
        parameters["dishRank"] = dishReview.rank
        if let imageID = dishReview.imageID {
          parameters["uploadMedia"] = [imageID]
        }
        return parameters
      }
    }
*/
  }
}

extension WebService {

  class NoteV3RestaurantReviewAPI: ServiceBase {
/* TODO: add back later
    // 93 新版新增餐廳評比
    class func postRestaurantReview(accessToken: String,
                                    shopID: Int,
                                    restaurantReview: RLMRestReviewV3) -> Promise<JSON> {
      
      let url = "\(configuration.environment.apiURL)/v1/reviews/restaurant/"
      return response(url: url, method: .post, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken,
                                         "shopID": shopID]
        parameters["title"] = restaurantReview.title
        parameters["comment"] = restaurantReview.comment
        parameters["recommandRank"] = restaurantReview.recommandRank
        parameters["serviceRank"] = restaurantReview.serviceRank
        parameters["environmentRank"] = restaurantReview.environmentRank
        //parameters["uploadMedia"] = restaurantReview. ... // TODO: Check later
        parameters["shareType"] = restaurantReview.sharedType
        parameters["allowedReaders"] = Array(restaurantReview.allowedReaders)
        if let eatingDate = restaurantReview.eatingDate?.timeIntervalSince1970 {
          parameters["diningTime"] = Int(eatingDate)
        }
        return parameters
      }
    }

    // 94 新版修改餐廳評比
    class func putRestaurantReview(accessToken: String,
                                   restaurantReviewID: Int,
                                   restaurantReview: RLMRestReviewV3) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/restaurant/{\(restaurantReviewID)"
      return response(url: url, method: .put, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken]
        parameters["shopID"] = restaurantReview.shopID
        parameters["title"] = restaurantReview.title
        parameters["comment"] = restaurantReview.comment
        parameters["recommandRank"] = restaurantReview.recommandRank
        parameters["serviceRank"] = restaurantReview.serviceRank
        parameters["environmentRank"] = restaurantReview.environmentRank
        //parameters["uploadMedia"] = restaurantReview.uploadMedia // TODO: Check later
        parameters["shareType"] = restaurantReview.sharedType
        parameters["allowedReaders"] = Array(restaurantReview.allowedReaders)
        if let eatingDate = restaurantReview.eatingDate?.timeIntervalSince1970 {
          parameters["diningTime"] = Int(eatingDate)
        }
        return parameters
      }
    }
 */
  }
}

extension WebService {

  class NoteReviewAPI: ServiceBase {
    // 102 取得我的最新評比 (30分鐘內)
    class func checkLastReview(accessToken: String, latitude: String, longitude: String) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/last-created"
      return response(url: url, method: .post) {
        return ["accessToken": accessToken,
                "latitude": latitude,
                "longitude": longitude]
      }
    }
/* TODO: add back later
    // 103 取得評比的所有資訊
    class func getWholeRestaurantReview(accessToken: String,
                                        restaurantReviewID: Int
                                       ) -> Promise<CommonResponse<RestaurantReview>> {

      return firstly { () -> Promise<JSON> in
        let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)"
        return response(url: url, method: .get) {
          return ["accessToken": accessToken]
        }
      }.then { json -> CommonResponse<RestaurantReview> in
        print("❤️❤️ \(json) ❤️❤️")
        let response = CommonResponse<RestaurantReview>.init(json: json)
        return Promise(value: response)
      }
    }
*/


    // 104 新增 餐廳，菜餚，其他，評比 (V4只有share用到)
    class func postNewRestaurantShare(accessToken: String,
                                       restaurantReview review: KVORestReviewV4,
                                       latitude: String?,
                                       longitude: String?,
                                       phoneNumber: String?
                                    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/restaurant/review" 
      return response(url: url, method: .post, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken]
        parameters["shareType"] = 2 // TODO: check share type是什麼
        parameters["allowedReaders"] = Array(review.allowedReaders).map { Int($0) }
        parameters["parentID"] = review.parentID

        var rreview: [String: Any] = [:]
        
        if let shopID = review.restaurant?.id { // 註：分享應該一定有restaurantID
          rreview["restaurantID"] = String(shopID) // api用string
        }
        /* TODO: V4目前沒有placeID
        else if let placeID = review.placeID, !placeID.isEmpty {
          rreview["placeID"] = placeID
        } */
        else {
          rreview["shopName"] = review.restaurant?.name
        }

        rreview["title"] = review.title
        rreview["recommandRank"] = review.priceRank
        rreview["serviceRank"] = review.serviceRank
        rreview["environmentRank"] = review.environmentRank
        rreview["comment"] = review.comment
        if let eatingTime = review.eatingDate?.timeIntervalSince1970 {
          rreview["diningTime"] = Int(eatingTime)
        }
        rreview["uploadMedia"] = []
        rreview["shareBlock"] = review.isShowComment
        if let address = review.restaurant?.address {
/* TODO: 地址來源 (已經有restaurantID了，也許分享不需要填地址？待確認)
          var addressKey = "address"

          if let addressSource = RLMRestReviewV3.AddressSource(rawValue: review.addressSource) {
            switch addressSource {
            case .manual: addressKey = "address"
            case .apple: addressKey = "appleAddress"
            }
          }

          rreview[addressKey] = address
 */
        }
/* TODO: country city
        rreview["country"] = review.countryName
        rreview["city"] = review.cityName
*/
        if review.restaurant?.phoneNumber != nil {
          rreview["phoneNumber"] = review.restaurant?.phoneNumber
        } else {
          rreview["phoneNumber"] = phoneNumber
        }
        
        if let latitude = latitude {
          rreview["latitude"] = latitude
        }
        if let longitude = longitude {
          rreview["longitude"] = longitude
        }


        parameters["restaurantReview"] = rreview

        let dishReviews = Array(review.dishReviews)
        var dreviews = [[String: Any]]()
        for dishReview in dishReviews {
          var dreview: [String: Any] = [:]
//          if let dishID = dishReview.dishID.value {
//            dreview["dishID"] = String(dishID) // api用string
//          }
          if let dishName = dishReview.dish?.name {
            dreview["dishName"] = dishName
          }
          dreview["dishRank"] = dishReview.rank
          dreview["comment"] = dishReview.comment

          dreview["uploadMedia"] = dishReview.images.compactMap({
            $0.imageID
          })

          dreviews.append(dreview)
        }
        parameters["dishReview"] = dreviews

/* no use
        let otherReviews = Array(review.dishReviews).filter { $0.type == 0 }
        var oreviews = [[String: Any]]()
        for otherReview in otherReviews {
          if otherReview.name == nil,
            otherReview.rank == nil,
            otherReview.comment == nil,
            otherReview.imageID == nil { continue }
          var oreview: [String: Any] = [:]
          oreview["title"] = otherReview.name
          oreview["dishRank"] = otherReview.rank
          oreview["comment"] = otherReview.comment
          if let imageID = otherReview.imageID {
            oreview["uploadMedia"] = [imageID]
          }

          oreviews.append(oreview)
        }
//        parameters["otherReview"] = oreviews
*/
        return parameters
      }
    }
    
    // 105 新版更新評比 餐廳，菜餚，其他，評比 (V4只有share用到)
    class func putNewRestaurantShare(accessToken: String,
                                      restaurantReview review: KVORestReviewV4,
                                      latitude: String?,
                                      longitude: String?,
                                      phoneNumber: String?
      ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/restaurant/review"
      return response(url: url, method: .post, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken]
        parameters["shareType"] = 2 // TODO: check share type是什麼
        parameters["allowedReaders"] = Array(review.allowedReaders).map { Int($0) }
        parameters["parentID"] = review.parentID
        
        var rreview: [String: Any] = [:]
        
        if let shopID = review.restaurant?.id { // 註：分享應該一定有restaurantID
          rreview["restaurantID"] = String(shopID) // api用string
        }
          /* TODO: V4目前沒有placeID
           else if let placeID = review.placeID, !placeID.isEmpty {
           rreview["placeID"] = placeID
           } */
        else {
          rreview["shopName"] = review.restaurant?.name
        }
        
        rreview["title"] = review.title
        rreview["recommandRank"] = review.priceRank
        rreview["serviceRank"] = review.serviceRank
        rreview["environmentRank"] = review.environmentRank
        rreview["comment"] = review.comment
        if let eatingTime = review.eatingDate?.timeIntervalSince1970 {
          rreview["diningTime"] = Int(eatingTime)
        }
        rreview["uploadMedia"] = []
        rreview["shareBlock"] = review.isShowComment
        if let address = review.restaurant?.address {
          /* TODO: 地址來源 (已經有restaurantID了，也許分享不需要填地址？待確認)
           var addressKey = "address"
           
           if let addressSource = RLMRestReviewV3.AddressSource(rawValue: review.addressSource) {
           switch addressSource {
           case .manual: addressKey = "address"
           case .apple: addressKey = "appleAddress"
           }
           }
           
           rreview[addressKey] = address
           */
        }
        /* TODO: country city
         rreview["country"] = review.countryName
         rreview["city"] = review.cityName
         */
        if review.restaurant?.phoneNumber != nil {
          rreview["phoneNumber"] = review.restaurant?.phoneNumber
        } else {
          rreview["phoneNumber"] = phoneNumber
        }
        
        if let latitude = latitude {
          rreview["latitude"] = latitude
        }
        if let longitude = longitude {
          rreview["longitude"] = longitude
        }
        
        
        parameters["restaurantReview"] = rreview
        
        let dishReviews = Array(review.dishReviews)
        var dreviews = [[String: Any]]()
        for dishReview in dishReviews {
          var dreview: [String: Any] = [:]
          //          if let dishID = dishReview.dishID.value {
          //            dreview["dishID"] = String(dishID) // api用string
          //          }
          if let dishName = dishReview.dish?.name {
            dreview["dishName"] = dishName
          }
          dreview["dishRank"] = dishReview.rank
          dreview["comment"] = dishReview.comment
          
          dreview["uploadMedia"] = dishReview.images.compactMap({
            $0.imageID
          })
          
          dreviews.append(dreview)
        }
        parameters["dishReview"] = dreviews
        
        /* no use
         let otherReviews = Array(review.dishReviews).filter { $0.type == 0 }
         var oreviews = [[String: Any]]()
         for otherReview in otherReviews {
         if otherReview.name == nil,
         otherReview.rank == nil,
         otherReview.comment == nil,
         otherReview.imageID == nil { continue }
         var oreview: [String: Any] = [:]
         oreview["title"] = otherReview.name
         oreview["dishRank"] = otherReview.rank
         oreview["comment"] = otherReview.comment
         if let imageID = otherReview.imageID {
         oreview["uploadMedia"] = [imageID]
         }
         
         oreviews.append(oreview)
         }
         //        parameters["otherReview"] = oreviews
         */
        return parameters
      }
    }
/*
    // 105 新版更新評比
    class func putWholeRestaurantReview(accessToken: String,
                                        restaurantReviewID: Int,
                                        restaurantReview review: RLMRestReviewV3) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)"
      return response(url: url, method: .put, headerParameters: nil) {
        var parameters: [String: Any] = ["accessToken": accessToken]
        parameters["shareType"] = review.sharedType
        parameters["allowedReaders"] = Array(review.allowedReaders).map { Int($0) }
        parameters["parentID"] = review.parentID.value

        var rreview: [String: Any] = [:]
        if let shopID = review.shopID.value {
          rreview["restaurantID"] = shopID
        } else if let placeID = review.placeID, !placeID.isEmpty {
          rreview["placeID"] = placeID
        } else {
          rreview["shopName"] = review.shop
        }
        rreview["title"] = review.title
        rreview["recommandRank"] = review.recommandRank
        rreview["serviceRank"] = review.serviceRank
        rreview["environmentRank"] = review.environmentRank
        rreview["comment"] = review.comment
        if let eatingTime = review.eatingDate?.timeIntervalSince1970 {
          rreview["diningTime"] = Int(eatingTime)
        }
        rreview["shareBlock"] = review.isShowComment
        if let address = review.address {
          rreview["address"] = address
        }

        parameters["restaurantReview"] = rreview

        let dishReviews = Array(review.dishReviews)
        var dreviews = [[String: Any]]()
        for dishReview in dishReviews {
          var dreview: [String: Any] = [:]
          dreview["dishReviewID"] = dishReview.id.value
//          if let dishID = dishReview.dishID.value {
//            dreview["dishID"] = dishID
//          }
          if let dishName = dishReview.name {
            dreview["dishName"] = dishName
          }
          dreview["dishRank"] = dishReview.rank
          dreview["comment"] = dishReview.comment
          if let imageID = dishReview.imageID {
            dreview["uploadMedia"] = [imageID]
          }

          dreviews.append(dreview)
        }
        parameters["dishReview"] = dreviews

        let otherReviews = Array(review.dishReviews).filter { $0.type == 0 }
        var oreviews = [[String: Any]]()
        for otherReview in otherReviews {
          var oreview: [String: Any] = [:]
          oreview["otherReviewID"] = otherReview.id.value
          oreview["title"] = otherReview.name
          oreview["dishRank"] = otherReview.rank
          oreview["comment"] = otherReview.comment
          if let imageID = otherReview.imageID {
            oreview["uploadMedia"] = [imageID]
          }

          oreviews.append(oreview)
        }
//        parameters["otherReview"] = oreviews

        return parameters
      }
    }
*/
    // 106 刪除評比
    class func deleteWholeRestaurantReview(accessToken: String,
                                           restaurantReviewID: Int) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)"
      return response(url: url, method: .delete) {
        return ["accessToken": accessToken]
      }
    }

/* TODO: add back later
    // 107 取得評比分享紀錄
    class func getShareRecords(accessToken: String,
                               restaurantReviewID: Int)
      -> Promise<CommonResponse<[ShareInfo]>> {
        return firstly { () -> Promise<JSON> in
          let url = "\(configuration.environment.apiURL)/v1/reviews/\(restaurantReviewID)/share-record"
          return response(url: url, method: .get) {
            return ["accessToken": accessToken]
          }
        }.then { json in
          let response = CommonResponse<[ShareInfo]>.init(json: json)
          return Promise(value: response)
        }.catch { error in
          print(error)
        }
    }

    // 108 收藏餐廳評比
    class func likeRestaurantReview(accessToken: String,
                                    restaurantReviewID: Int)
                -> Promise<CommonResponse<Bool>> {
      return firstly { () -> Promise<JSON> in
        let url = "\(configuration.environment.apiURL)/v1/reviews/restaurant/\(restaurantReviewID)/like"
        return response(url: url, method: .get) {
          return ["accessToken": accessToken]
        }
      }.then { json in
        var response = CommonResponse<Bool>.init(json: json)
        if response.statusMsg == "收藏成功" {
          response.data = true
        } else if response.statusMsg == "取消收藏成功" {
          response.data = false
        }
        return Promise(value: response)
      }.catch { error in
        print(error)
      }
    }

    // 109 收藏菜餚評比
    class func likeDishReview(accessToken: String,
                              dishReviewID: Int)
                -> Promise<CommonResponse<Bool>> {
      return firstly { () -> Promise<JSON> in
        let url = "\(configuration.environment.apiURL)/v1/reviews/dish/\(dishReviewID)/like"
        return response(url: url, method: .get) {
          return ["accessToken": accessToken]
        }
      }.then { json in
        var response = CommonResponse<Bool>.init(json: json)
        if response.statusMsg == "收藏成功" {
          response.data = true
        } else if response.statusMsg == "取消收藏成功" {
          response.data = false
        }
        return Promise(value: response)
      }.catch { error in
        print(error)
      }
    }

    // 110 收藏其他評比
    class func likeOtherReview(accessToken: String,
                              otherReviewID: Int)
      -> Promise<CommonResponse<Bool>> {
        return firstly { () -> Promise<JSON> in
          let url = "\(configuration.environment.apiURL)/v1/reviews/other/\(otherReviewID)/like"
          return response(url: url, method: .get) {
            return ["accessToken": accessToken]
          }
        }.then { json in
          var response = CommonResponse<Bool>.init(json: json)
          if response.statusMsg == "收藏成功" {
            response.data = true
          } else if response.statusMsg == "取消收藏成功" {
            response.data = false
          }
          return Promise(value: response)
        }.catch { error in
          print(error)
      }
    }
*/
  }

}

// MARK: - Models for API
extension WebService.NoteReviewAPI {

  struct RestaurantReview: Codable {
    let shopName: String?
    let shopID: Int?
    let placeID: String?
    let restaurantReviewID: Int?
    let parentID: Int?
    let averageRank: String?
    let title: String?
    let comment: String?
    let createDate: Date?
    let recommandRank: String?
    let serviceRank: String?
    let environmentRank: String?
    let allowedReaders: [Int]?
    let shareType: Int?
    let diningTime: Int?
    let dishReview: [DishReview]?
    let otherReview: [OtherReview]?
    let isMine: Bool?
    let shareBlock: Bool?
    let isReviewLike: Bool?
    let isRestaurantLike: Bool?
    let author: RestaurantReviewAuthor?
/* TODO: later
    func toRLMRestReviewV3() -> RLMRestReviewV3 {
      let review = RLMRestReviewV3()
      review.shop = shopName
      review.shopID.value = shopID
      review.placeID = placeID
      review.id.value = restaurantReviewID
      review.parentID.value = parentID
      review.restaurantRank = averageRank != nil ? String(averageRank!) : nil
      review.recommandRank = recommandRank != nil ? String(recommandRank!) : nil
      review.serviceRank = serviceRank != nil ? String(serviceRank!) : nil
      review.environmentRank = environmentRank != nil ? String(environmentRank!) : nil
      review.title = title
      review.comment = comment
      review.isShowComment = shareBlock ?? true
      review.isReviewLike.value = isReviewLike
      review.isRestaurantLike.value = isRestaurantLike
      review.authorName = author?.name
      review.authorAvatarURL = author?.avatarURL

      if let createDate = createDate { review.createDate = createDate }
      for reader in allowedReaders ?? [] { review.allowedReaders.append(String(reader)) }
      if let shareType = shareType { review.sharedType = shareType }
      if let diningTime = diningTime {
        review.eatingDate = Date(timeIntervalSince1970: TimeInterval(diningTime))
      } else {
        review.eatingDate = nil
      }
      for dishReview in dishReview ?? [] {
        review.dishReviews.append(dishReview.toRLMDishReviewV3())
      }
      for otherReview in otherReview ?? [] {
        review.dishReviews.append(otherReview.toRLMDishReviewV3())
      }

      return review
    }
 */
  }

  struct RestaurantReviewAuthor: Codable {
    let name: String?
    let avatarURL: String?
  }

  struct DishReview: Codable {
    let dishReviewID: Int?
    let dishID: Int?
    let dishName: String?
    let comment: String?
    let dishRank: String?
    let media: [Media]?
    let isDishLike: Bool?
/* TODO: add back later
    func toRLMDishReviewV3() -> RLMDishReviewV3 {
      let review = RLMDishReviewV3()
      review.id.value = dishReviewID
      review.type = 1
      review.dishID.value = dishID
      review.name = dishName
      review.comment = comment
      review.isLike.value = isDishLike
      if let dishRank = dishRank {
        review.rank = String(dishRank)
      }
      for media in media ?? [] {
        review.imageID = media.id
        review.url = media.url
        break // 目前只存一張
      }
      review.isUpdate = true
      review.isRecongnition = true
      review.recongniting = false

      return review
    }
 */
  }

  struct OtherReview: Codable {
    let otherReviewID: Int?
    let title: String?
    let comment: String?
    let dishRank: String?
    let media: [Media]?
/* TODO: add back later
    func toRLMDishReviewV3() -> RLMDishReviewV3 {
      let review = RLMDishReviewV3()
      review.id.value = otherReviewID
      review.type = 0
      review.name = title
      review.comment = comment
      review.rank = dishRank

      for media in media ?? [] {
        review.imageID = media.id
        review.url = media.url
        break // 目前只存一張
      }
      review.isRecongnition = true
      review.recongniting = false

      return review
    }
 */
  }

  struct Media: Codable {
    let id: String?
    let url: String?
  }

}
