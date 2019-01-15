//
//  FriendAPI.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2017/10/24.
//

import Foundation
import PromiseKit
import SwiftyJSON

extension WebService {
  class Friend: ServiceBase {
    // 取得Quota資訊
    class func quotaInfo(accessToken: String
    ) -> Promise<QuotaInfo> {
      let url = "\(configuration.environment.apiURL)/invite-code/quota"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 收回邀請碼
    class func revokeQuota(accessToken: String, code: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/invite-code/revoke/\(code)"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 送出邀請碼
    class func sendQuota(accessToken: String, code: String, name: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/invite-code/send/\(code)"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken,
                          "name": name]
        return parameters
      }
    }

    // 取得邀請碼
    class func createQuota(accessToken: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/invite-code/create"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 取得Quota資訊
    class func quotaPost(accessToken: String
    ) -> Promise<Quota> {
      let url = "\(configuration.environment.apiURL)/friends/quota"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 更新Quota資訊
    class func quotaUpdate(accessToken: String, code: String, status: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/friends/quota/update"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "code": code,
          "status": status
        ] // 0 > 更新邀請碼 1 > 已使用寄出邀請碼
        return parameters
      }
    }

    // 邀請朋友
    class func invite(accessToken: String, member: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/friends/invite"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "friendAccount": member
        ]
        return parameters
      }
    }

    // 取得朋友列表
    class func postFriends(accessToken: String
    ) -> Promise<FriendJSON> {
      let url = "\(configuration.environment.apiURL)/me/friends"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 編輯好友
    class func edit(accessToken: String, friendID: String, nickname: String?, isFollowing: Bool, allowFollowing: Bool
    ) -> Promise<FriendJSON> {
      let url = "\(configuration.environment.apiURL)/friends/update"
      return response(url: url, method: .put) {
        let parameters = [
          "accessToken": accessToken,
          "friendID": friendID,
          "nickname": nickname ?? "",
          "isFollowing": isFollowing,
          "allowFollowing": allowFollowing
        ] as [String: Any]
        return parameters
      }
    }

    // 查詢好友
    class func find(accessToken: String, userAccount: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/users"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "userAccount": userAccount
        ]
        return parameters
      }
    }

    // 寄送認證信
    class func sendCheckEmail(accessToken: String
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/email/verify"
      return response(url: url, method: .post) {
        let parameters = ["accessToken": accessToken]
        return parameters
      }
    }

    // 86 回覆好友邀請
    class func reply(accessToken: String, userID: Int, accept: Bool
    ) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/friends/reply"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "userID": userID,
          "accept": accept
        ] as [String: Any]
        return parameters
      }
    }
    
    // 取消好友邀請
    class func cancel(accessToken: String, userID: Int) -> Promise<JSON> {
      let url = "\(configuration.environment.apiURL)/friends/cancel"
      return response(url: url, method: .post) {
        let parameters = [
          "accessToken": accessToken,
          "userID": userID
          ] as [String: Any]
        return parameters
      }
    }
    
    
  }
}
