//
//  Login.swift
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
      return "/app/login"
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
