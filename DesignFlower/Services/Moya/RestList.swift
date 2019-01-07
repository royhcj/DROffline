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

enum RestaurantListParamater: String {
  case name = "rd_name"
  case ename = "rd_ename"
}

extension DishRankService {
  enum RestList {
    case getList(start: Date?, end: Date? , paramaters: [RestaurantListParamater]?)
  }
}

extension DishRankService.RestList: MoyaProvidable {
  var baseURL: URL {
    return DishRankService.baseURL
  }

  var path: String {
    switch self {
    case .getList :
      return "/v2/restaurant"
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
    case .getList(let start, let end, let paramaters):
      let dateFormatter = DateFormatter.init()
      dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

      var dic: [String: String] = [:]

      if let startDate = start {
        dic["rd_utime_min"] = dateFormatter.string(from: startDate)
      }
      if let endF = end {
        dic["rd_utime_max"] = dateFormatter.string(from: endF)
      }

      if let para = paraToString(para: paramaters) {
        dic["fields[restaurant]"] = para
      }
      return .requestParameters(parameters: dic, encoding: URLEncoding.default)
//      return .requestJSONEncodable(dic)
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
    guard let token = UserDefaults.standard.value(forKey: "token") as? String else {
      return ["Content-Type": "application/json"]
    }
    return ["Content-Type": "application/json",
            "Authorization": "Bearer " + token]
  }
}


class RestList {
  static func getRestList(strat: Date? = nil, end: Date? = nil, paramaters: [RestaurantListParamater]? = nil) {
    let provider = DishRankService.RestList.provider
    provider.request(.getList(start: strat, end: end, paramaters: paramaters)) { (response) in
      switch response {
      case .success(let response):
        do {
          let json = try? JSON.init(data: response.data)
            print(json)
        } catch {
          print("transfer to json error")
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
