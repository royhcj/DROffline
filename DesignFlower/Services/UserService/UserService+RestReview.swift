//
//  UserService+RestReview.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/21.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import SVProgressHUD
import SwiftyJSON
import Result
import Moya

class UserService {

}

struct UploadIMGResponseAPI: Codable {
  var id: String?
  var link: String?
}

extension UserService {
  class RestReview {
    static func upload(img: UIImage, completion: ((Result<UploadIMGResponseAPI, MoyaError>) -> ())? ) {
      let data = UIImageJPEGRepresentation(img, 0.5)
      guard let imgData = data else {
        let result = Result<UploadIMGResponseAPI, MoyaError>(error: .requestMapping("img to data error"))
        completion?(result)
        return
      }
      let provider = DishRankService.RestaurantReview.provider
      provider.request(.uploadIMG(fileData: imgData)) { result in
        switch result {
        case .success(let response):
          let decoder = JSONDecoder()
          guard let uploadIMGResponseAPI = try? decoder.decode(UploadIMGResponseAPI.self, from: response.data) else {
            completion?(Result<UploadIMGResponseAPI,MoyaError>(error: MoyaError.requestMapping("decode uploadIMGResponseAPI error")))
            return
          }
          completion?(Result<UploadIMGResponseAPI,MoyaError>.init(value: uploadIMGResponseAPI))
        case .failure(let error):
          completion?(Result<UploadIMGResponseAPI,MoyaError>.init(error: error))
        }
      }

    }

    static func put(queueReview: RLMQueue, completion: ((Result<String,MoyaError>) -> ())? = nil ) {
      let provider = DishRankService.RestaurantReview.provider
      provider.request(.put(queueReview: queueReview)) { (result) in
        switch result {
        case .success(let response):
          let decoder = JSONDecoder()
          struct MyData: Codable {
            let data: RLMRestReviewV4
          }
          var myData: MyData?
          do {
            myData = try decoder.decode(MyData.self, from: response.data)
          } catch {
            print("decode error")
          }
          if
            let rlmRestReview = RLMServiceV4.shared.getRestReview(uuid: myData?.data.uuid),
            let remoteRestReview = myData?.data
          {
            RLMServiceV4.shared.update(rlmRestReview, id: remoteRestReview.id.value)
            for remoteDishReview in remoteRestReview.dishReviews {
              guard
                let uuid = remoteDishReview.uuid,
                let localDishReview = RLMServiceV4.shared.dishReview.getDishReview(uuid: uuid)
                else {
                  continue
              }
              RLMServiceV4.shared.dishReview.update(localDishReview, id: remoteDishReview.id.value)
            }
          }
          completion?(Result<String,MoyaError>(value: "success"))
        case .failure(let error):
          completion?(Result<String,MoyaError>(error: error))
          print(error.localizedDescription)
        }
      }
    }


    static func update(queueReview: RLMQueue, completion: ((Result<String,MoyaError>) -> ())? = nil ) {
      let provider = DishRankService.RestaurantReview.provider
      provider.request(.post(queueReview: queueReview)) { (result) in
        switch result {
        case .success(let response):
          let decoder = JSONDecoder()
          struct MyData: Codable {
            let data: RLMRestReviewV4
          }
          var myData: MyData?
          do {
            myData = try decoder.decode(MyData.self, from: response.data)
          } catch {
            print("decode error")
          }
          if
            let rlmRestReview = RLMServiceV4.shared.getRestReview(uuid: myData?.data.uuid),
            let remoteRestReview = myData?.data
          {
            RLMServiceV4.shared.update(rlmRestReview, id: remoteRestReview.id.value)
            for remoteDishReview in remoteRestReview.dishReviews {
              guard
                let uuid = remoteDishReview.uuid,
                let localDishReview = RLMServiceV4.shared.dishReview.getDishReview(uuid: uuid)
              else {
                continue
              }
              RLMServiceV4.shared.dishReview.update(localDishReview, id: remoteDishReview.id.value)
            }
          }
          completion?(Result<String,MoyaError>(value: "success"))
        case .failure(let error):
          completion?(Result<String,MoyaError>(error: error))
          print(error.localizedDescription)
        }
      }
    }

    static internal func downloadImgs(url: URL, imageName: String, count: Int, total: Int,completion: ((Bool) -> ())? = nil ) {
      let provider = DishRankService.RestaurantReview.provider
      provider.request(.download(url: url, fileName: imageName),
                       callbackQueue: nil,
                       progress: { (progressResponse) in
                        // progress

                        SVProgressHUD.showProgress(Float(count)/Float(total), status: "\(count)/\(total)")
      }) { (result) in
        // finish
        switch result {
        case .success:
          completion?(true)
        case .failure(let error):
          completion?(false)
          print("download img error: \(error.localizedDescription)")
        }


      }
    }

    static func download(imgs: [RLMImageV4]) {

      let total = imgs.count
      SVProgressHUD.show(withStatus: "開始下載圖片")
      downloadImgQueue(count: 0, total: total, imgs: imgs)
    }

    static internal func downloadImgQueue(count: Int, total: Int, imgs: [RLMImageV4]) {

      guard count != (total - 1) else {
        SVProgressHUD.show(withStatus: "下載完成")
        SVProgressHUD.dismiss(withDelay: 1)
        return
      }
      guard
        let urlString = imgs[count].url,
        let uuid = imgs[count].uuid,
        let url = URL.init(string: urlString)
        else {
          downloadImgQueue(count: count + 1, total: total, imgs: imgs)
          return
      }

      let imgName = uuid + ".jpeg"

      self.downloadImgs(url: url, imageName: imgName, count: count, total: total) {
        if $0 {
          RLMServiceV4.shared.image.update(imgs[count], localName: imgName)
        } else {
          RLMServiceV4.shared.image.update(imgs[count], imageID: nil)
        }
        downloadImgQueue(count: count + 1, total: total, imgs: imgs)
      }
    }

    static func getRestaurantReview(updateDateMin: Date?, updateDateMax: Date?, url: String?) {

      let provider = DishRankService.RestaurantReview.provider
      provider.request(DishRankService.RestaurantReview.get(updateDateMin: updateDateMin, updateDateMax: updateDateMax, url: url)) { ( result) in
        switch result {
        case .success(let response):
          do {
            let decoder = JSONDecoder()
            let restaurants = try decoder.decode(Restaurants.self, from: response.data)
            SVProgressHUD.show(withStatus: "筆記更新中...\(restaurants.meta.currentPage ?? 0)/\(restaurants.meta.lastPage ?? 0)")
            if let next = restaurants.links?.next, next != "" {
              update(restaurants: restaurants) {
                if $0 {
                  let max = Date.getDate(any: restaurants.meta.updateDateMax)
                  UserDefaults.standard.set(max, forKey: UserDefaultKey.updateDateMax.rawValue)
                  self.getRestaurantReview(updateDateMin: nil, updateDateMax: nil, url: restaurants.links?.next)
                }
              }
            } else {
              let min = Date.getDate(any: restaurants.meta.updateDateMax)
              UserDefaults.standard.set(min, forKey: UserDefaultKey.updateDateMin.rawValue)
              UserDefaults.standard.set(nil, forKey: UserDefaultKey.updateDateMax.rawValue)
              update(restaurants: restaurants)
              SVProgressHUD.show(withStatus: "下載完成")

              let imgs = RLMServiceV4.shared.image.getImgs()
              if imgs.count > 0 {
                self.download(imgs: imgs)
              }
            }

          } catch {
            SVProgressHUD.show(withStatus: "更新失敗")
            SVProgressHUD.dismiss(withDelay: 1)
            print(error.localizedDescription)
          }
        case .failure(let error):
          print("get restaurant review error: \(error.localizedDescription)")
        }
      }
    }



    private static func update(restaurants: Restaurants, completion: ((Bool) -> ())? = nil) {

      guard let restaurantReviews = restaurants.data else {
        return
      }


      for remoteReview in restaurantReviews {
        guard let localReview = RLMServiceV4.shared.getRestReview(uuid: remoteReview.uuid, id: remoteReview.id.value) else {
          //TODO: create
          RLMServiceV4.shared.createRLM(with: remoteReview)
          continue
        }
        //TODO: update
        RLMServiceV4.shared.update(localReview, with: remoteReview)
      }
      completion?(true)

    }
  }
}
