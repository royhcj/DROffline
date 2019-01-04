//
//  AutoLogin.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/3.
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

  static var baseURL: URL { return URL(string: "http://api.larvatadish.work/app")! }

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
    provider = MoyaProvider<Self>(manager: DefaultAlamofireManager.sharedManager)

    return provider
  }
}

extension DishRankService {
  enum Login {
    case login(email: String, password: String)
    case post(os: String,
      deviceVersion: String,
      deviceID: String,
      account: String,
      password: String,
      pushNotificationId: String)
    case fbPost(socialToken: String,
      pushNotificationId: String)
    case googlePost(socialToken: String,
      pushNotificationId: String)
  }
}

extension DishRankService.Login: MoyaProvidable {
  var baseURL: URL {
    return DishRankService.baseURL
  }

  var path: String {
    switch self {
    case .login :
      return "/login"
    case .post:
      return "/login"
    case .fbPost, .googlePost:
      return "/login/social-platform"
    }
  }

  var method: Moya.Method {
    switch self {
    case .login:
      return .post
    case .post:
      return .post
    case .fbPost, .googlePost:
      return .post
    }
  }

  var sampleData: Data {
    @objc class TestClass: NSObject { }
    switch self {
    case .login:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
    //      return Data()
    case .post:
      let bundle = Bundle(for: TestClass.self)
      let path = bundle.path(forResource: "Login", ofType: "json")
      return try! Data(contentsOf: URL(fileURLWithPath: path!))
      //      return .data(using: String.Encoding.utf8)!

    //      return Data()
    case .fbPost:
      return Data()
    case .googlePost:
      return Data()
    }

  }

  var task: Task {
    switch self {
    case .login(let email, let password):
      return .requestJSONEncodable(["email" : email,
                                    "password" : password])
    case .post(let os,
               let deviceVersion,
               let deviceID,
               let account,
               let password,
               let pushNotificationId):

      return .requestJSONEncodable(["OS": os,
                                    "deviceversion": deviceVersion,
                                    "DeviceID": deviceID,
                                    "account": account,
                                    "password": password,
                                    "pushNotificationId": pushNotificationId])

    case .fbPost(let socialToken,
                 let pushNotificationId):

      return .requestJSONEncodable(["socialToken": socialToken,
                                    "type": "facebook",
                                    "pushNotificationId": pushNotificationId])

    case .googlePost(let socialToken, let pushNotificationId):

      return .requestJSONEncodable(["socialToken": socialToken,
                                    "type": "google",
                                    "pushNotificationId": pushNotificationId])

    }
  }

  var headers: [String : String]? {
    return ["Content-Type": "application/json"]
  }
}


struct AfterLogin: Codable {
  let statusCode: Int
  let statusMsg: String
  let accessToken: String
}

class AutoLogin {

  static func login() {
    let account = "pei@qqq.com"
    let password = "1234567890"

    let provider = DishRankService.Login.provider
    provider.request(.login(email: account, password: password)) { (result) in
      switch result {
      case .success(let response):
        do {
          if let json = try? JSON.init(data: response.data) {
             let token = json["accessToken"].stringValue
            let userDefault = UserDefaults.standard
            userDefault.set(token, forKey: "token")
          }

        } catch {
          print("transfer to json error")
        }




      case .failure(let error):
        print(error.localizedDescription)
      }
    }

  }
}
