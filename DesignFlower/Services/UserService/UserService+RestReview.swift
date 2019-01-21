//
//  UserService+RestReview.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/21.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import SVProgressHUD

class UserService {

}

extension UserService {
  class RestReview {
    static func update(restReview: RLMRestReviewV4) {
      let provider = DishRankService.RestaurantReview.provider
      provider.request(.post(restReview: restReview)) { (result) in
        switch result {
        case .success(let response):
          print(response.data)
        case .failure(let error):
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
        case .failure:
          completion?(false)
          print("download img error")
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
