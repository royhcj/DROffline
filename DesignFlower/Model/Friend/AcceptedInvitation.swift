//
//  AcceptedInvitations.swift
//
//  Created by 馮仰靚 on 23/02/2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class AcceptedInvitation: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let avatar = "avatar"
    static let acceptTime = "acceptTime"
    static let email = "email"
  }

  // MARK: Properties

  public var avatar: String?
  public var acceptTime: String?
  public var email: String?

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
    avatar = json[SerializationKeys.avatar].string
    acceptTime = json[SerializationKeys.acceptTime].string
    email = json[SerializationKeys.email].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = avatar { dictionary[SerializationKeys.avatar] = value }
    if let value = acceptTime { dictionary[SerializationKeys.acceptTime] = value }
    if let value = email { dictionary[SerializationKeys.email] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    avatar = aDecoder.decodeObject(forKey: SerializationKeys.avatar) as? String
    acceptTime = aDecoder.decodeObject(forKey: SerializationKeys.acceptTime) as? String
    email = aDecoder.decodeObject(forKey: SerializationKeys.email) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(avatar, forKey: SerializationKeys.avatar)
    aCoder.encode(acceptTime, forKey: SerializationKeys.acceptTime)
    aCoder.encode(email, forKey: SerializationKeys.email)
  }
}
