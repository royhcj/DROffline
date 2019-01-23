//
//  DishRankService.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/4.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Result


class DishRankService {

  static var baseURL: URL { return URL(string: "http://api.larvatadish.work")! }
  enum Note {
    case uploadIMG(image: UIImage)
  }
}

protocol MoyaProvidable: TargetType {
  static var provider: MoyaProvider<Self> { get }

}

extension MoyaProvidable {
  static var provider: MoyaProvider<Self> {
    var provider = MoyaProvider<Self>.init()
    provider = MoyaProvider<Self>(manager: DefaultAlamofireManager.sharedManager,
                                  plugins: [CustomPlugin()])

    return provider
  }
}

final class CustomPlugin: PluginType {
  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
    print("prepare request: \(request)")
    return request
  }

  func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
    guard target.headers != nil else {
      // 下載圖片會進來這
      return result
    }
    switch result {
    case .success(let response):
    do {
      let json = try JSON.init(data: response.data)
      if json["errors"] == nil {
        return result
      } else {
        print("moya process error: \(json["errors"].stringValue)")
        return Result<Response, MoyaError>.init(nil, failWith: .jsonMapping(response))
      }
    } catch {
      return Result<Response, MoyaError>.init(nil, failWith: .requestMapping("parse json error"))
    }
    case .failure:
    return result
  }
  }
}


