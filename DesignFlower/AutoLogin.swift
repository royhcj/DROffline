//
//  AutoLogin.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/3.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import SwiftyJSON



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
        if let json = try? JSON.init(data: response.data) {
          let token = json["accessToken"].stringValue
          let userDefault = UserDefaults.standard
          userDefault.set(token, forKey: "token")

          // 測試用
          LoggedInUser.sharedInstance().accessToken = token
        } else {
          print("transfer to json error")
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }

  }
}

