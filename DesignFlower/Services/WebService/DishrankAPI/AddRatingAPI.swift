//
//  AddRatingAPI.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2017/10/28.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON
import HTTPStatusCodes

extension WebService {
  class AddRating: ServiceBase {
    // 新增新的餐廳
    class func createRestaurant(accessToken: String, shopName: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/restaurants/create"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "shopName": shopName
        ]
        return parameters
      }
    }

    // 新增新的餐廳
    class func createDish(accessToken: String, dishName: String, shopID: Int
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/dishes/create"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "shopID": shopID,
          "dishName": dishName
        ] as [String: Any]
        return parameters
      }
    }

    // 取得餐廳列表
    class func getRestaurants(accessToken: String,
                              latitude: String? = nil,
                              longitude: String? = nil,
                              filter: String? = nil,
                              googleQuery: Bool = false
    ) -> Promise<[Restaurant]> {
      return firstly { () -> Promise<JSON> in
        response(url: "\(configuration.environment.apiURL)/restaurants", method: .post,
                 timeout: 12, headerParameters: nil) {
          var parameters = [
            "accessToken": accessToken
          ] as [String: Any]
          parameters["latitude"] = latitude
          parameters["longitude"] = longitude
          parameters["filter"] = filter
          parameters["googleQuery"] = googleQuery
          return parameters
        }
      }.then { json in
        var restaurants = [Restaurant]()
        if json["statusCode"].intValue == 0 {
          for restaurant in json["restaurantData"].arrayValue {
            restaurants.append(Restaurant(json: restaurant))
          }
          return Promise(value: restaurants)
        } else {
          return Promise(error: json["statusCode"].stringValue)
        }
      }
    }
    
    //取得搜尋餐廳的placeholder
    class func getPlaceholder(accessToken: String,
                              local: String) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/restaurants/placeholder"
      return response(url: url, method: .get) {
        var parameters = ["accessToken": accessToken]
        parameters["local"] = local
        return parameters
      }
    }
    
    //取得城市列表
    class func getCitys(type: String,
                        limit: Int,
                        accessToken: String,
                        locale: String,
                        q: String
      ) -> Promise<JSON> {
      let url = "https://graph.facebook.com/v2.11/search"
      return response(url: url, method: .get) {
        let parameters = [
          "type": type,
          "limit": limit,
          "access_token": accessToken,
          "locale": locale,
          "q": q
          ] as [String: Any]
        
        return parameters
      }
    }
/* TODO:
    // 影像辨識
    class func recongnition(accessToken: String,
                            imgURL: String,
                            restaurantId: Int,
                            checkThreshold: Int? = nil,
                            firstN: Int? = nil
    ) -> Promise<Recongnition> {
      let url = "\(configuration.environment.apiURL)/recognition/api/recognition"
      return response(url: url, method: .post) {
        var parameters = [
          "img_url": imgURL,
          "restaurant_id": restaurantId,
          "token": accessToken
        ] as [String: Any]
        if let myFirstN = firstN {
          parameters["first_n"] = myFirstN
        }
        if let myCheckThreshold = checkThreshold {
          parameters["check_threshold"] = myCheckThreshold
        }
        return parameters
      }
    }
*/
    // 取得菜餚列表
    class func getDishList(accessToken: String, shopID: Int
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/dishes"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "shopID": shopID
        ] as [String: Any]
        return parameters
      }
    }

    // 取得餐廳單筆評比
    class func getResSingleComment(accessToken: String, id: Int
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/restaurants/comments/\(id)"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken
        ]
        return parameters
      }
    }

    enum RatingType: String {
      case restaurant
      case dish
      case all
    }

    // 刪除評比
    class func delete(accessToken: String, commentID: Int, type: RatingType, reviewID: Int
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/comments/delete"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "commentID": commentID,
          "type": type.rawValue,
          "reviewID": reviewID
        ] as [String: Any]
        return parameters
      }
    }

    // swiftlint:disable function_parameter_count
    class func createRating(accessToken: String,
                            shopID: Int,
                            isScratch: Bool,
                            shareType: Int,
                            recommandRank: String?,
                            serviceRank: String?,
                            environmentRank: String?,
                            comment: String?,
                            title: String?,
                            uploadMedia: [String]?,
                            commentID: Int?,
                            allowedReaders: [String]?
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/restaurants/comments/create"
      return response(url: url, method: .post) {
        var parameters = [
          "accessToken": accessToken,
          "shopID": shopID,
          "isScratch": isScratch,
          "shareType": shareType
        ] as [String: Any]

        if let recomRank = recommandRank {
          parameters["recommandRank"] = recomRank
        }
        if let serRank = serviceRank {
          parameters["serviceRank"] = serRank
        }
        if let envirRank = environmentRank {
          parameters["environmentRank"] = envirRank
        }
        if let comment = comment {
          parameters["comment"] = comment
        }
        if let title = title {
          parameters["title"] = title
        }
        if let uploadMedia = uploadMedia {
          parameters["uploadMedia"] = uploadMedia
        }

        if let commentID = commentID {
          parameters["commentID"] = commentID
        }

        if let allowedReaders = allowedReaders {
          parameters["allowedReaders"] = allowedReaders
        }

        return parameters
      }
    }

    class func createDishRating(accessToken: String,
                                dishID: Int,
                                isScratch: Bool,
                                shareType: Int,
                                dishRank: String?,
                                comment: String?,
                                commentID: Int?,
                                uploadMedia: [String]?,
                                reviewID: Int,
                                allowedReaders: [String]?

    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/dishes/comments/create"
      return response(url: url, method: .post) {
        var parameters = [
          "accessToken": accessToken,
          "dishID": dishID,
          "isScratch": isScratch,
          "reviewID": reviewID,
          "shareType": shareType
        ] as [String: Any]

        if let dish = dishRank {
          parameters["dishRank"] = dish
        }
        if let commentID = commentID {
          parameters["commentID"] = commentID
        }
        if let comment = comment {
          parameters["comment"] = comment
        }
        if let uploadMedia = uploadMedia {
          parameters["uploadMedia"] = uploadMedia
        }

        if let allowedReaders = allowedReaders {
          parameters["allowedReaders"] = allowedReaders
        }

        return parameters
      }
    }
/* TODO:
    class func createReview(accessToken: String,
                            restReview: RestaurantReview,
                            dishReviews: [DishReview],
                            otherReviews: [OtherReview]
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/reviews/store"
      return response(url: url, method: .post, headerParameters: nil) {
        var parameters = [
          "accessToken": accessToken
        ] as [String: Any]

        var restaurantReview = [String: Any]()

        restaurantReview["shopID"] = restReview.shopID ?? ""
        restaurantReview["isScratch"] = restReview.isScratch == "Y" ? true : false
        restaurantReview["shareType"] = restReview.shareType ?? 1

        if let recomRank = restReview.recommandRank {
          restaurantReview["recommandRank"] = recomRank
        }
        if let serRank = restReview.serviceRank {
          restaurantReview["serviceRank"] = serRank
        }
        if let envirRank = restReview.environmentRank {
          restaurantReview["environmentRank"] = envirRank
        }

        if let comment = restReview.comment {
          restaurantReview["comment"] = comment
        }
        if let title = restReview.title {
          restaurantReview["title"] = title
        }
        if let uploadMedia = restReview.uploadMedia {
          restaurantReview["uploadMedia"] = uploadMedia
        }

        if let commentID = restReview.commentID {
          restaurantReview["commentID"] = commentID
        }

        if let allowedReaders = restReview.allowedReaders {
          restaurantReview["allowedReaders"] = allowedReaders
        }

        parameters["restaurantReview"] = restaurantReview

        if dishReviews.count > 0 {
          var review = [Any]()
          for dishReview in dishReviews {
            var temp = [String: Any]()
            temp["dishID"] = dishReview.dishID ?? 0
            if let dishRank = dishReview.dishRank {
              temp["dishRank"] = dishRank
            }
            if let comment = dishReview.comment {
              temp["comment"] = comment
            }
            temp["uploadMedia"] = dishReview.uploadMedia
            review.append(temp)
          }
          parameters["dishReview"] = review
        }

        if otherReviews.count > 0 {
          var review = [Any]()
          for otherReview in otherReviews {
            var temp = [String: Any]()
            temp["title"] = otherReview.title ?? ""
            if let rank = otherReview.rank {
              temp["rank"] = rank
            }
            if let comment = otherReview.comment {
              temp["comment"] = comment
            }
            temp["uploadMedia"] = otherReview.uploadMedia ?? []
            review.append(temp)
          }
          parameters["otherReview"] = review
        }
        return parameters
      }
    }
*/
/* TODO:
    // swiftlint:enable function_parameter_count
    class func updateImage(photoFile: UIImage, photoKind _: String
    ) -> Promise<JSON> {
      return Promise { resolve, reject in

        // Server address (replace this with the address of your own server):
        let url = "\(configuration.environment.apiURL)/media/upload"

        // Use Alamofire to upload the image

        let parameters = ["accessToken": LoggedInUser.sharedInstance().accessToken!]

        Alamofire.upload(multipartFormData: { multipartFormData in
          let imgData = UIImageJPEGRepresentation(photoFile, 0.2)!
          multipartFormData.append(imgData, withName: "file", fileName: "file", mimeType: "image/jpeg")

          for (key, value) in parameters {
            multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
          }
        }, to: url, method: .post) { result in
          switch result {
          case let .success(upload, _, _):
            upload.uploadProgress(closure: { progress in
              print("Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON { response in
              switch response.result {
              case .success(let data):
                let json = JSON(data)
                if let message = json["id"].string {
                  resolve(json)
                } else if let message = json["statusMsg"].string {
                  reject(message)
                } else if let code = response.response?.statusCode,
                  let statusCode = HTTPStatusCode.init(rawValue: code){
                  reject(statusCode)
                } else {
                  reject("Unknown Upload Error")
                }
              case .failure(let error):
                reject(error)
              }
            }
          case let .failure(encodingError):
            print(encodingError)
            reject(encodingError)
          }
        }
      }
    }
*/
  }
}
