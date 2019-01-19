//
//  DishRankService+Review.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/14.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import Result
import SVProgressHUD

extension DishRankService {
  enum RestaurantReview {
    case get(updateDateMin: Date?, updateDateMax: Date?, url: String?)
    case download(url: URL, fileName: String)
  }
}

extension DishRankService.RestaurantReview: MoyaProvidable {

  
  var baseURL: URL {
    switch self {
    case .get(_, _, let url):
      if let urlString = url, let url = URL(string: urlString) {
        return url
      } else {
        return DishRankService.baseURL
      }
    case .download(let url, _):
      return url
    }
  }

  var path: String {
    switch self {
    case .get(_, _, let url) :
      if url != nil {
        return ""
      } else {
        return "/v2/restaurant-review"
      }
    case .download:
      return ""
    }
  }

  var method: Moya.Method {
    switch self {
    case .get:
      return .get
    case .download:
      return .get
    }
  }

  var sampleData: Data {
    @objc class TestClass: NSObject { }
    switch self {
    case .get:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
    case .download:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
    }
  }

  var task: Task {
    switch self {
    case .get(let start, let end, _):

      var dic: [String: String] = [:]

      if let startDate = start {
        dic["update_date_min"] = Date.getString(any: startDate)
      }
      if let endF = end {
        dic["update_date_max"] = Date.getString(any: endF)
      }

      return .requestParameters(parameters: dic, encoding: URLEncoding.default)
    case .download(_, let fileName):

      //下载儲存位置
      let defaultDownloadDir: URL = KVOImageV4.localFolder

      let localLocation: URL = defaultDownloadDir.appendingPathComponent(fileName)
      let downloadDestination: DownloadDestination = { _, _ in
        return (localLocation, .removePreviousFile) }
      return .downloadDestination(downloadDestination)
    }
  }

  var headers: [String : String]? {
    switch self {
    case .get:
      guard let token = UserDefaults.standard.value(forKey: UserDefaultKey.token.rawValue) as? String else {
        return ["Content-Type": "application/json"]
      }
      return ["Content-Type": "application/json",
              "Authorization": "Bearer " + token]
    case .download:
      return nil
    }
    // TODO: 需要更改取得Token

  }


}

extension DishRankService.RestaurantReview {

  static internal func downloadImgs(url: URL, imageName: String, count: Int, total: Int,completion: ((Bool) -> ())? = nil ) {
    let privoder = DishRankService.RestaurantReview.provider
    privoder.request(.download(url: url, fileName: imageName),
                     callbackQueue: nil,
                     progress: { (progressResponse) in
                      // progress

                SVProgressHUD.showProgress(Float(count)/Float(total), status: "\(count)/\(total)")
    }) { (result) in
      // finish
      switch result {
      case .success:
        completion?(true)
        print("下載完成")
      case .failure:
        completion?(false)
        print("error")
      }


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
                DishRankService.RestaurantReview.getRestaurantReview(updateDateMin: nil, updateDateMax: nil, url: restaurants.links?.next)
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
               DishRankService.RestaurantReview.download(imgs: imgs)
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

    DishRankService.RestaurantReview.downloadImgs(url: url, imageName: imgName, count: count, total: total) {
      if $0 {
        RLMServiceV4.shared.image.update(imgs[count], localName: imgName)
      } else {
        RLMServiceV4.shared.image.update(imgs[count], imageID: nil)
      }
      downloadImgQueue(count: count + 1, total: total, imgs: imgs)
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
