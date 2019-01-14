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

extension DishRankService {
  enum RestaurantReview {
    case get(updateDateMin: String?, updateDateMax: String?, url: String?)
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
  static func getRestaurantReview(updateDateMin: String?, updateDateMax: String?, url: String?) {
     let provider = DishRankService.RestaurantReview.provider
    provider.request(DishRankService.RestaurantReview.get(updateDateMin: updateDateMin, updateDateMax: updateDateMax, url: url)) { ( result) in
      switch result {
      case .success(let response):
        do {
          let json = try JSONSerialization.jsonObject(with: response.data, options: [])
          let decoder = JSONDecoder()
          let list = try decoder.decode(Restaurants.self, from: response.data)
          print(list)
        } catch {
          print(error.localizedDescription)
        }
      case .failure(let error):
        print("get restaurant review error: \(error.localizedDescription)")
      }
    }
  }
}
