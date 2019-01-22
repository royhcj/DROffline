//
//  DishRankService+Alamofire.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/22.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import Alamofire

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
