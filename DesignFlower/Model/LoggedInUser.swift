//
//  User.swift
//  2017-dishrank-ios
//
//  Created by tony on 2017/9/7.
//
//

//import FBSDKLoginKit
//import GoogleSignIn
import SwiftyJSON
import UIKit
import RxSwift
import RxCocoa
import Result
import Moya

enum LoginType {
  case facebook
  case google
  case email
}

protocol LoggedInUserDelegate: class {
  func tutorialShow()
}

class LoggedInUser: NSObject {
  public var accessToken: String?
  public private(set) var userID: String?
  public private(set) var userName: String?
  public private(set) var gender: Gender?
  public private(set) var phoneNumber: String?
  public private(set) var phoneCheck: Int?
  public private(set) var birthday: String?
  public private(set) var imgURL: String?
  public private(set) var deviceVersion: String?
  public private(set) var deviceID: String?
  public private(set) var account: String?
  @objc dynamic var updateTime: Date?
  public private(set) var accountCheck: Bool?
  public private(set) var refreshToken: String?
  public private(set) var loginType: String?
  public private(set) var hasGuide: Bool?
  public private(set) var views: Int?
  // 應該不需要的參數
  public private(set) var email: String?
  public private(set) var deviceToken: String?
  static var delegate: LoggedInUserDelegate?

  enum Gender: Int {
    case secret = -1
    case female = 0
    case male = 1
  }

  private static var mInstance: LoggedInUser?
  static func sharedInstance() -> LoggedInUser {
    if mInstance == nil {
      mInstance = LoggedInUser()
    }
    return mInstance!
  }

  override init() {
    accessToken = UserDefaults.standard.string(forKey: "token")//"accessToken")
    userID = UserDefaults.standard.string(forKey: "userID")
    userName = UserDefaults.standard.string(forKey: "userName")
    gender = Gender(rawValue: UserDefaults.standard.integer(forKey: "gender"))
    phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")
    phoneCheck = UserDefaults.standard.integer(forKey: "phoneCheck")
    birthday = UserDefaults.standard.string(forKey: "birthday")
    imgURL = UserDefaults.standard.string(forKey: "imgURL")
    email = UserDefaults.standard.string(forKey: "email")
    deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
    deviceVersion = UserDefaults.standard.string(forKey: "deviceVersion")
    deviceID = UserDefaults.standard.string(forKey: "deviceID")
    account = UserDefaults.standard.string(forKey: "account")
    accountCheck = UserDefaults.standard.bool(forKey: "accountCheck")
    refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
    loginType = UserDefaults.standard.string(forKey: "loginType")
    hasGuide = UserDefaults.standard.bool(forKey: "hasGuide")
    views = UserDefaults.standard.integer(forKey: "views")
    updateTime = Date.now
  }
}
/* TODO:
//  class func newLogin(operatingSystem: String,
//                      deviceVersion: String,
//                      deviceID: String,
//                      account: String,
//                      password: String,
//                      pushNotificationID: String,
//                      type: LoginType) {
//    mInstance?.account = account
//    mInstance?.deviceToken = pushNotificationID
//    mInstance?.deviceVersion = deviceVersion
//    mInstance?.deviceID = deviceID
//    LoginAPI.shared.login(os: operatingSystem,
//                          deviceVersion: deviceVersion,
//                          deviceID: deviceID,
//                          account: account,
//                          password: password,
//                          pushNotificationId: pushNotificationID)
//      .subscribe(onNext: { (json) in
//        print(json)
//        setParamater(json: json)
//        mInstance?.loginType = "信箱"
//        self.updateUserDefaults()
//      }, onError: {
//        print($0)
//      }).disposed(by: bag)
//  }

  class func newLogin(operatingSystem: String,
                      deviceVersion: String,
                      deviceID: String,
                      account: String,
                      password: String,
                      pushNotificationID: String,
                      type: LoginType) -> Observable<Result<Data, MoyaError>> {
    mInstance?.account = account
    mInstance?.deviceToken = pushNotificationID
    mInstance?.deviceVersion = deviceVersion
    mInstance?.deviceID = deviceID
    if type == .email {
      return LoginAPI.shared.post(os: operatingSystem,
                                  deviceVersion: deviceVersion,
                                  deviceID: deviceID,
                                  account: account,
                                  password: password,
                                  pushNotificationId: pushNotificationID)
        .do(onNext: { (result) in
          switch result {
          case .success(let data):
            let json = JSON(data)
            setParamater(json: json)
            mInstance?.loginType = "信箱"
            self.updateUserDefaults()
          case .failure(let e):
            break
          }
        })
    } else if type == .facebook {

      return LoginAPI.shared.fbPost(socialToken: account,
                                    pushNotificationId: pushNotificationID)
        .do(onNext: { (result) in
          switch result {
          case .success(let data):
            let json = JSON(data)
            setParamater(json: json)
            mInstance?.loginType = "Facebook"
            self.updateUserDefaults()
          case .failure(let error):
            break
          }
        })
    } else {

      return LoginAPI.shared.googlePost(socialToken: account,
                                        pushNotificationId: pushNotificationID)
        .do(onNext: { (result) in
          switch result {
          case .success(let data):
            let json = JSON(data)
            setParamater(json: json)
            mInstance?.loginType = "Google"
            self.updateUserDefaults()
          case .failure(let e):
            break
          }
        })
    }
  }
//  class func login(operatingSystem: String,
//                   deviceVersion: String,
//                   deviceID: String,
//                   account: String,
//                   password: String,
//                   pushNotificationID: String,
//                   type: LoginType) -> Promise<JSON> {
//    mInstance?.account = account
//    mInstance?.deviceToken = pushNotificationID
//    mInstance?.deviceVersion = deviceVersion
//    mInstance?.deviceID = deviceID
//
//    if type == .email {
//      return WebService.Login.post(os: operatingSystem,
//                                   deviceVersion: deviceVersion,
//                                   deviceID: deviceID,
//                                   account: account,
//                                   password: password,
//                                   pushNotificationId: pushNotificationID
//      ).then { json -> JSON in
//        setParamater(json: json)
//        mInstance?.loginType = "信箱"
//        self.updateUserDefaults()
//        return json
//      }
//    } else if type == .facebook {
//      return WebService.Login.fbPost(socialToken: account,
//                                     pushNotificationId: pushNotificationID
//      ).then(execute: { (json) -> JSON in
//        setParamater(json: json)
//        mInstance?.loginType = "Facebook"
//        self.updateUserDefaults()
//        return json
//      })
//    } else {
//      return WebService.Login.googlePost(socialToken: account,
//                                         pushNotificationId: pushNotificationID
//      ).then(execute: { (json) -> JSON in
//        setParamater(json: json)
//        mInstance?.loginType = "Google"
//        self.updateUserDefaults()
//        return json
//      })
//    }
//    // LoggedInUser.delegate?.tutorialShow()
//  }

  class func setParamater(json: JSON) {
    mInstance?.accessToken = json["accessToken"].stringValue
    mInstance?.userID = json["userId"].stringValue
    mInstance?.userName = json["username"].string ?? ""
    mInstance?.gender = Gender(rawValue: json["gender"].intValue)
    mInstance?.phoneNumber = json["phoneNumber"].string ?? ""
    mInstance?.phoneCheck = json["phoneCheck"].intValue
    mInstance?.birthday = json["birthday"].string ?? ""
    mInstance?.imgURL = json["imgURL"].string ?? ""
    mInstance?.email = json["email"].string ?? ""
    mInstance?.views = json["views"].intValue
    mInstance?.accountCheck = json["accountCheck"].bool ?? false
    mInstance?.refreshToken = json["refreshToken"].string ?? ""
    mInstance?.hasGuide = json["hasGuide"].bool ?? true
    if json["statusCode"].intValue == 0 && !(json["hasGuide"].bool ?? true) {
      LoggedInUser.delegate?.tutorialShow()
    }
  }

  class func logout(completion: (() -> ())?) {
    if FBSDKAccessToken.current() != nil {
      FBSDKLoginManager().logOut()
    }

    GIDSignIn.sharedInstance().signOut()

    if let deviceID = mInstance?.deviceToken,
      let userID = mInstance?.userID,
      let accessToken = mInstance?.accessToken {
      WebService.Logout.post(os: "iOS",
                             deviceVersion: "",
                             deviceID: deviceID,
                             userID: userID,
                             accessToken: accessToken
      ).catch(execute: { error in
        print(error.localizedDescription)
      })
      mInstance?.accessToken = nil
      mInstance?.userID = nil
      mInstance?.userName = nil
      mInstance?.gender = nil
      mInstance?.phoneNumber = nil
      mInstance?.phoneCheck = nil
      mInstance?.birthday = nil
      mInstance?.imgURL = nil
      mInstance?.email = nil
      mInstance?.deviceToken = nil
      mInstance?.deviceID = nil
      mInstance?.deviceVersion = nil
      mInstance?.accountCheck = nil
      mInstance?.refreshToken = nil
      mInstance?.loginType = nil
      mInstance?.hasGuide = nil
      updateUserDefaults()
      if let com = completion {
          com()
      }

    }
  }

  class func updateUserDefaults() {
    UserDefaults.standard.set(mInstance?.accessToken, forKey: "accessToken")
    UserDefaults.standard.set(mInstance?.userID, forKey: "userID")
    UserDefaults.standard.set(mInstance?.userName, forKey: "userName")
    UserDefaults.standard.set(mInstance?.gender?.rawValue, forKey: "gender")
    UserDefaults.standard.set(mInstance?.phoneNumber, forKey: "phoneNumber")
    UserDefaults.standard.set(mInstance?.phoneCheck, forKey: "phoneCheck")
    UserDefaults.standard.set(mInstance?.birthday, forKey: "birthday")
    UserDefaults.standard.set(mInstance?.imgURL, forKey: "imgURL")
    UserDefaults.standard.set(mInstance?.deviceVersion, forKey: "deviceVersion")
    UserDefaults.standard.set(mInstance?.deviceID, forKey: "deviceID")
    UserDefaults.standard.set(mInstance?.accountCheck, forKey: "accountCheck")
    UserDefaults.standard.set(mInstance?.refreshToken, forKey: "refreshToken")
    UserDefaults.standard.set(mInstance?.hasGuide, forKey: "hasGuide")

    UserDefaults.standard.set(mInstance?.email, forKey: "email")
    UserDefaults.standard.set(mInstance?.deviceToken, forKey: "deviceToken")
    UserDefaults.standard.set(mInstance?.loginType, forKey: "loginType")
    UserDefaults.standard.set(mInstance?.views, forKey: "views")
    // updateTime最後改，其他人會監聽這個數值有沒有改變進行重新整理
    mInstance?.updateTime = Date()
  }

  func setAccountCheck() {
    let loggedInUser = LoggedInUser.sharedInstance()
    loggedInUser.accountCheck = true
  }

  func updateToken(_ accessToken: String) {
    let loggedInUser = LoggedInUser.sharedInstance()
    if let refreshToken = self.refreshToken {
      self.refreshToken = nil
      guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
      WebService.UpdateToken.post(refreshToken: refreshToken)
        .then { [weak self] (json) -> Void in
          if json["statusCode"].intValue == 0 {
            loggedInUser.accessToken = json["accessToken"].string
            loggedInUser.refreshToken = json["refreshToken"].string
            LoggedInUser.updateUserDefaults()
          } else {
            if self?.refreshToken == nil {
              LoggedInUser.logout(completion: {
                LoggedInUser.delegate = nil
                //                let rootController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginRootViewController")
                appDel.window?.rootViewController = appDel.navigator.viewController(for: "myApp://Login")
              })
            }
          }
      }
    }
  }

  class func applyEditedUser(_ user: EditableUser) {
    let loggedInUser = LoggedInUser.sharedInstance()
    loggedInUser.userName = user.userName
    loggedInUser.gender = user.gender
    loggedInUser.phoneNumber = user.phoneNumber
    loggedInUser.phoneCheck = user.phoneCheck
    loggedInUser.birthday = user.birthday
    loggedInUser.imgURL = user.imageURL
    loggedInUser.accountCheck = user.accountCheck
    loggedInUser.views = user.views
  }

  class func setHasGuide(_ hasGuide: Bool) {
    let loggedInUser = LoggedInUser.sharedInstance()
    loggedInUser.hasGuide = hasGuide
    updateUserDefaults()
  }
}

class EditableUser {
  public private(set) var email: String?
  var userName: String?
  var gender: LoggedInUser.Gender?
  var phoneNumber: String?
  var phoneCheck: Int?
  var birthday: String?
  var imageURL: String?
  var accountCheck: Bool?
  var views: Int?

  func setFromLoggedInUser(_ loggedInUser: LoggedInUser) {
    email = loggedInUser.email
    userName = loggedInUser.userName
    gender = loggedInUser.gender
    phoneNumber = loggedInUser.phoneNumber
    phoneCheck = loggedInUser.phoneCheck
    birthday = loggedInUser.birthday
    imageURL = loggedInUser.imgURL
    accountCheck = loggedInUser.accountCheck
  }
}
*/
