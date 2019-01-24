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
    case post(queueReview: RLMQueue)
    case uploadIMG(fileData: Data)
    case put(queueReview: RLMQueue)
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
    case .post, .put:
      return DishRankService.baseURL
    case .uploadIMG:
      return DishRankService.baseURL
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
    case .post:
      return "/v2/restaurant-review"
    case .uploadIMG:
      return "/media/upload"
    case .put:
      return "/v2/restaurant-review"
    }
  }

  var method: Moya.Method {
    switch self {
    case .get:
      return .get
    case .download:
      return .get
    case .post:
      return .post
    case .uploadIMG:
      return .post
    case .put:
      return .put
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
    case .post:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
    case .uploadIMG, .put:
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
    case .post(let restReview):
      let customData: MyData = MyData.init(data: restReview)
      return .requestJSONEncodable(customData)
    case .put(let restReview):
      let customData: MyData = MyData.init(data: restReview)
      print(customData)
      do {
        let json = try JSONEncoder().encode(customData)
        print(json)
      } catch {
        print(error.localizedDescription)
      }
      return .requestJSONEncodable(customData)
    case .uploadIMG(let fileData):
      // any additional body data or body parms
      let imageMultipartFormData = MultipartFormData(provider: .data(fileData), name: "file", fileName: "avatar.jpg", mimeType: "image/jpeg")
      return .uploadMultipart([imageMultipartFormData])
    }
  }

  var headers: [String : String]? {
    switch self {
    case .get, .post, .uploadIMG, .put:
      guard let token = UserDefaults.standard.value(forKey: UserDefaultKey.token.rawValue) as? String else {
        return ["Content-Type": "application/json"]
      } 
      return ["Content-Type": "application/json",
              "Authorization": "Bearer " + token]
    case .download :
      return nil
    }
    // TODO: 需要更改取得Token
  }
}

