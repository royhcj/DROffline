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
import Alamofire
import Result

class DefaultAlamofireManager: Alamofire.SessionManager {
  static let sharedManager: DefaultAlamofireManager = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    configuration.timeoutIntervalForRequest = 10 // as seconds, you can set your request timeout
    configuration.timeoutIntervalForResource = 10 // as seconds, you can set your resource timeout
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return DefaultAlamofireManager(configuration: configuration)
  }()
}

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
    print(request)
    return request
  }
}


