//
//  WebService.swift
//  2017-dishrank-ios
//
//  Created by tony on 2017/9/7.
//
//

import Alamofire
import HTTPStatusCodes
import PromiseKit
import SwiftyJSON
import UIKit

class WebService {
  static var isShowTimeoutAlert = true
  class ServiceBase {
    static var configuration = Configuration()
    static func response<T: JSONable>(
      url: String,
      method: HTTPMethod,
      parameters: () throws -> Parameters? = { nil }
      ) -> Promise<T> {
      return responseJSON(url: url, method: method, parameters: parameters).then { json in
        Promise(value: T(json: json))
      }
    }
    
    static func response<T: JSONable>(
      url: String,
      method: HTTPMethod,
      parameters: () throws -> Parameters? = { nil }
      ) -> Promise<[T]> {
      return responseJSON(url: url, method: method, parameters: parameters).then { json in
        Promise { resolve, _ in
          var elements = [T]()
          for jsonElement in json {
            elements.append(T(json: jsonElement.1))
          }
          resolve(elements)
        }
      }
    }
    
    private static func responseJSON(
      url: String,
      method: HTTPMethod,
      parameters: () throws -> Parameters? = { nil }
      ) -> Promise<JSON> {
      do {
        let accessToken = LoggedInUser.sharedInstance().accessToken
        
        return DefaultAlamofireManager.sharedManager.request(url, method: method, parameters: try parameters()).response().then { (a, response, data) -> Promise<JSON> in
          let json = JSON(data)
            return Promise { resolve, reject in
              guard let statusCode = HTTPStatusCode(rawValue: response.statusCode) else {
                throw String(response.statusCode)
              }
              
              
              if statusCode.isSuccess {
                if json["statusCode"].intValue == 401,
                  LoggedInUser.sharedInstance().accessToken == accessToken {
/* TODO:
                  LoggedInUser
                    .sharedInstance()
                    .updateToken(accessToken ?? "")
*/
                  let customJSON = JSON(["statusCode": 401, "statusMsg": "讀取失敗，麻煩重新讀取"])
                  resolve(customJSON)
                } else {
                  resolve(json)
                }
              } else if let message = json["message"].string, statusCode != .unauthorized {
                reject(message)
              } else {
                reject(statusCode)
              }
            }
          }.catch(execute: { (_) in
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
/* TODO: later
            appdelegate?.navigator.open("navigator://alert?title=請檢查網路問題&message=網路不穩請重新整理畫面&isShowTimeoutAlert=\(WebService.isShowTimeoutAlert)")
 */
          })
      } catch {
        return Promise(error: error)
      }
    }
    
    static func response<T: JSONable>(
      url: String,
      method: HTTPMethod,
      timeout: TimeInterval = 20,
      headerParameters: Parameters?,
      bodyParameters: () throws -> Parameters? = { nil }
      ) -> Promise<T> {
      return responseJSON(url: url, method: method,
                          timeout: timeout,
                          headerParameters: headerParameters,
                          bodyParameters: bodyParameters).then { json in
                            Promise(value: T(json: json))
      }
    }
    
    static func response<T: JSONable>(
      url: String,
      method: HTTPMethod,
      timeout: TimeInterval = 20,
      headerParameters: Parameters?,
      bodyParameters: () throws -> Parameters? = { nil }
      ) -> Promise<[T]> {
      return responseJSON(url: url, method: method,
                          timeout: timeout,
                          headerParameters: headerParameters,
                          bodyParameters: bodyParameters).then { json in
                            Promise { resolve, _ in
                              var elements = [T]()
                              for jsonElement in json {
                                elements.append(T(json: jsonElement.1))
                              }
                              resolve(elements)
                            }
      }
    }
    
    private static func responseJSON(
      url: String,
      method: HTTPMethod,
      timeout: TimeInterval,
      headerParameters _: Parameters?, // TODO: 沒真的用到，以後再修
      bodyParameters: () throws -> Parameters? = { nil }
      ) -> Promise<JSON> {
      do {
        guard let url = URL(string: url) else { throw ("Invalid url.") }
        
        guard let parameters = try bodyParameters() else { throw ("Invalid parameters.") }
        
        var request = URLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        
        request.timeoutInterval = timeout
        
        print("❤️ \(String(data: request.httpBody!, encoding: .utf8)!) ❤️")
        
        let accessToken = LoggedInUser.sharedInstance().accessToken
        
        return DefaultAlamofireManager.sharedManager.request(request).response()
          .then { (_, response, data) -> Promise<JSON> in
            let json = JSON(data)
            return Promise { resolve, reject in
              guard let statusCode = HTTPStatusCode(rawValue: response.statusCode) else {
                throw String(response.statusCode)
              }
              
              if statusCode.isSuccess {
                if json["statusCode"].intValue == 401,
                  LoggedInUser.sharedInstance().accessToken == accessToken {
/* TODO:
                  LoggedInUser
                    .sharedInstance()
                    .updateToken(accessToken ?? "")
 */
                  let customJSON = JSON(["statusCode": 401, "statusMsg": "讀取失敗，麻煩重新讀取"])
                  resolve(customJSON)
                } else {
                  resolve(json)
                }
              } else if let message = json["message"].string, statusCode != .unauthorized {
                reject(message)
              } else {
                reject(statusCode)
              }
            }
        }
      } catch {
        return Promise(error: error)
      }
    }
    
    // MARK: Utility Methods
    
    func dateToDateTimeString(date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = DateFormatter.Style.medium
      dateFormatter.timeStyle = DateFormatter.Style.none
      dateFormatter.dateFormat = "yyyy-MM-dd"
      let dateString = dateFormatter.string(from: date)
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "HH:mm:ss.SSSxxx"
      let timeString = timeFormatter.string(from: date)
      let resultString = dateString + "T" + timeString
      return resultString
    }
  } // end ServiceBase
  
  static func dateStringToDate(_ dateString: String?) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    if let dateString = dateString {
      return dateFormatter.date(from: dateString)
    }
    return nil
  }
  
  static func isServiceUnavailable(_ error: Error) -> Bool {
    if let httpStatusCode = error as? HTTPStatusCode,
      httpStatusCode == .notFound {
      return true
    } else if error is URLError {
      return true
    }
    return false
  }
} // end WebService

extension HTTPStatusCode: Error {}

extension HTTPStatusCode: LocalizedError {
  public var errorDescription: String? { return description }
}

extension WebService.ServiceBase {
  struct CommonResponse<T: Codable>: Decodable, JSONable {
    var statusCode: Int?
    var statusMsg: String?
    var data: T?
    
    init() {
      statusCode = nil
      statusMsg = nil
      data = nil
    }
    
    init(json: JSON) {
      do {
        let data = try json.rawData()
        let decoder = DRDecoder.decoder()
        decoder.dateDecodingStrategy = .formatted({
          let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"
          formatter.calendar = Calendar(identifier: .iso8601)
          formatter.timeZone = TimeZone(secondsFromGMT: 0)
          formatter.locale = Locale(identifier: "en_US_POSIX")
          return formatter
          }())
        let response = try decoder.decode(CommonResponse<T>.self, from: data)
        self.statusCode = response.statusCode
        self.statusMsg = response.statusMsg
        self.data = response.data
      } catch {
        print(error)
        self.statusCode = nil
        self.statusMsg = nil
        self.data = nil
      }
    }
    
    //    init(json: JSON, dataArrayElementGenerator: ((JSON) -> Any) ) {
    //      statusCode = json["statusCode"].int
    //      statusMsg = json["statusMsg"].string
    //      if let array = json["data"].array {
    //
    //      }
    //    }
  }
}
