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
    }
  }

  var method: Moya.Method {
    switch self {
    case .get:
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
    }
  }

  var headers: [String : String]? {
    // TODO: 需要更改取得Token
    guard let token = UserDefaults.standard.value(forKey: UserDefaultKey.token.rawValue) as? String else {
      return ["Content-Type": "application/json"]
    }
    return ["Content-Type": "application/json",
            "Authorization": "Bearer " + token]
  }
}

extension DishRankService {
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
                DishRankService.getRestaurantReview(updateDateMin: nil, updateDateMax: nil, url: restaurants.links?.next)
              }
            }
          } else {
            let min = Date.getDate(any: restaurants.meta.updateDateMax)
            UserDefaults.standard.set(min, forKey: UserDefaultKey.updateDateMin.rawValue)
            UserDefaults.standard.set(nil, forKey: UserDefaultKey.updateDateMax.rawValue)
            update(restaurants: restaurants)
            SVProgressHUD.show(withStatus: "下載完成")
            SVProgressHUD.dismiss(withDelay: 1)
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
