//
//  RestList.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/4.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import Result
import SVProgressHUD

enum RestaurantListParamater: String {
  case name = "rd_name"
  case ename = "rd_ename"
}

extension DishRankService {
  enum RestList {
    case getList(start: Date?, end: Date?, paramaters: [RestaurantListParamater]?, next: String?)
  }
}

extension DishRankService.RestList: MoyaProvidable {
  var baseURL: URL {
    switch self {
    case .getList(_, _, _, let url):
      if let urlString = url, let url = URL(string: urlString) {
        return url
      } else {
        return DishRankService.baseURL
      }
    }
  }

  var path: String {
    switch self {
    case .getList(_, _, _, let url) :
      if url != nil {
        return ""
      } else {
        return "/v2/restaurant"
      }
    }
  }

  var method: Moya.Method {
    switch self {
    case .getList:
      return .get
    }
  }

  var sampleData: Data {
    @objc class TestClass: NSObject { }
    switch self {
    case .getList:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
    }

  }

  var task: Task {
    switch self {
    case .getList(let start, let end, let paramaters, _):

      var dic: [String: String] = [:]

      if let startDate = start {
        dic["rd_utime_min"] = Date.getString(any: startDate)
      }
      if let endF = end {
        dic["rd_utime_max"] = Date.getString(any: endF)
      }

      if let para = paraToString(para: paramaters) {
        dic["fields[restaurant]"] = para
      }
      return .requestParameters(parameters: dic, encoding: URLEncoding.default)
    }
  }

  func paraToString(para: [RestaurantListParamater]?) -> String? {
    guard let para = para, para.count > 0 else {
      return "*"
    }
    var paramaterString: String = ""
    for p in para {
      paramaterString += p.rawValue + ","
    }
    return paramaterString
  }

  var headers: [String : String]? {
    guard let token = UserDefaults.standard.value(forKey: UserDefaultKey.token.rawValue) as? String else {
      return ["Content-Type": "application/json"]
    }
    return ["Content-Type": "application/json",
            "Authorization": "Bearer " + token]
  }
}


