//
//  AcceptedMember.swift
//
//  Created by 馮仰靚 on 24/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class AcceptedMember: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let method = "method"
    static let inviteDate = "inviteDate"
    static let code = "code"
    static let imgURL = "imgURL"
    static let userNickname = "userNickname"
    static let friendEmail = "friendEmail"
    static let friendName = "friendName"
    static let merberId = "merberId"
  }

  // MARK: Properties

  public var method: String?
  public var inviteDate: String?
  public var code: String?
  public var imgURL: String?
  public var userNickname: String?
  public var friendEmail: String?
  public var friendName: String?
  public var merberId: Int?

  // MARK: SwiftyJSON Initializers

  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    method = json[SerializationKeys.method].string
    inviteDate = json[SerializationKeys.inviteDate].string
    code = json[SerializationKeys.code].string
    imgURL = json[SerializationKeys.imgURL].string
    userNickname = json[SerializationKeys.userNickname].string
    friendEmail = json[SerializationKeys.friendEmail].string
    friendName = json[SerializationKeys.friendName].string
    merberId = json[SerializationKeys.merberId].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = method { dictionary[SerializationKeys.method] = value }
    if let value = inviteDate { dictionary[SerializationKeys.inviteDate] = value }
    if let value = code { dictionary[SerializationKeys.code] = value }
    if let value = imgURL { dictionary[SerializationKeys.imgURL] = value }
    if let value = userNickname { dictionary[SerializationKeys.userNickname] = value }
    if let value = friendEmail { dictionary[SerializationKeys.friendEmail] = value }
    if let value = friendName { dictionary[SerializationKeys.friendName] = value }
    if let value = merberId { dictionary[SerializationKeys.merberId] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    method = aDecoder.decodeObject(forKey: SerializationKeys.method) as? String
    inviteDate = aDecoder.decodeObject(forKey: SerializationKeys.inviteDate) as? String
    code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
    imgURL = aDecoder.decodeObject(forKey: SerializationKeys.imgURL) as? String
    userNickname = aDecoder.decodeObject(forKey: SerializationKeys.userNickname) as? String
    friendEmail = aDecoder.decodeObject(forKey: SerializationKeys.friendEmail) as? String
    friendName = aDecoder.decodeObject(forKey: SerializationKeys.friendName) as? String
    merberId = aDecoder.decodeObject(forKey: SerializationKeys.merberId) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(method, forKey: SerializationKeys.method)
    aCoder.encode(inviteDate, forKey: SerializationKeys.inviteDate)
    aCoder.encode(code, forKey: SerializationKeys.code)
    aCoder.encode(imgURL, forKey: SerializationKeys.imgURL)
    aCoder.encode(userNickname, forKey: SerializationKeys.userNickname)
    aCoder.encode(friendEmail, forKey: SerializationKeys.friendEmail)
    aCoder.encode(friendName, forKey: SerializationKeys.friendName)
    aCoder.encode(merberId, forKey: SerializationKeys.merberId)
  }
}
