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


class RestList {
  static func getRestList(strat: Date? = nil, end: Date? = nil, paramaters: [RestaurantListParamater]? = nil, next url: String? = nil) {

    if !SVProgressHUD.isVisible() {
       SVProgressHUD.show(withStatus: "檢查資料是否需要更新...")
    }

    let provider = DishRankService.RestList.provider
    provider.request(.getList(start: strat, end: end, paramaters: paramaters, next: url)) { (response) in
      switch response {
      case .success(let response):
        do {
          let decoder = JSONDecoder()
          let list = try decoder.decode(RestaurantList.self, from: response.data)
           SVProgressHUD.show(withStatus: "更新中...\(list.meta?.currentPage ?? 0)/\(list.meta?.lastPage ?? 0)")
          if let next = list.links?.next, next != "" {
            updateRestaurantList(list: list, completion: { (finish) in
              if finish {
                RestList.getRestList(strat: nil, end: nil, paramaters: nil, next: list.links?.next)
              }
            })
          } else {
            // 最後一筆進來這
            updateRestaurantList(list: list, completion: nil)
            let min = Date.getDate(any: list.meta?.rdUtimeMax)
            UserDefaults.standard.set(min, forKey: UserDefaultKey.rdUtimeMin.rawValue)
            UserDefaults.standard.set(nil, forKey: UserDefaultKey.rdUtimeMax.rawValue)
            SVProgressHUD.show(withStatus: "更新完成")
            SVProgressHUD.dismiss(withDelay: 1)
          }

        } catch {
          SVProgressHUD.show(withStatus: "更新失敗")
          SVProgressHUD.dismiss(withDelay: 1)
          print("transfer to json error")
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  private static func update(RdUtimeMax: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = dateStyle
    if let date = formatter.date(from: RdUtimeMax) {
      UserDefaults.standard.set(date, forKey: "rdUtimeMax")
    }
  }
  static func updateRestaurantList(list: RestaurantList, completion: ((Bool) -> ())?) {

    guard let restlist = list.data else {
      return
    }

    for rest in restlist {
      guard let attributes = rest.attributes else {
        break
      }
     if let existRest = RLMServiceV4.shared.getRestaurantList(id: rest.id).first {
      // 有就更新
      RLMServiceV4.shared.updateList(attributes: attributes, to: existRest)
     } else {
      // 沒有就新增
      RLMServiceV4.shared.restListToRLMRestList(copyBy: attributes)
     }
    }
    completion?(true)

  }

}
