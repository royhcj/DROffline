//
//  FriendJSON.swift
//
//  Created by 馮仰靚 on 25/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class FriendJSON: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let statusCode = "statusCode"
    static let friend = "friend"
    static let statusMsg = "statusMsg"
  }

  // MARK: Properties

  public var statusCode: Int?
  public var friend: [Friend]?
  public var statusMsg: String?

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
    statusCode = json[SerializationKeys.statusCode].int
    if let items = json[SerializationKeys.friend].array { friend = items.map { Friend(json: $0) } }
    statusMsg = json[SerializationKeys.statusMsg].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = statusCode { dictionary[SerializationKeys.statusCode] = value }
    if let value = friend { dictionary[SerializationKeys.friend] = value.map { $0.dictionaryRepresentation() } }
    if let value = statusMsg { dictionary[SerializationKeys.statusMsg] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    statusCode = aDecoder.decodeObject(forKey: SerializationKeys.statusCode) as? Int
    friend = aDecoder.decodeObject(forKey: SerializationKeys.friend) as? [Friend]
    statusMsg = aDecoder.decodeObject(forKey: SerializationKeys.statusMsg) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(statusCode, forKey: SerializationKeys.statusCode)
    aCoder.encode(friend, forKey: SerializationKeys.friend)
    aCoder.encode(statusMsg, forKey: SerializationKeys.statusMsg)
  }
}
