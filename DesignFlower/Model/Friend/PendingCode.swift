//
//  PendingCodes.swift
//
//  Created by 馮仰靚 on 23/02/2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class PendingCode: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let code = "code"
    static let createTime = "createTime"
    static let updatedTime = "updatedTime"
    static let name = "name"
  }

  // MARK: Properties

  public var code: String?
  public var createTime: String?
  public var updatedTime: String?
  public var name: String?

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
    code = json[SerializationKeys.code].string
    createTime = json[SerializationKeys.createTime].string
    updatedTime = json[SerializationKeys.updatedTime].string
     name = json[SerializationKeys.name].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = code { dictionary[SerializationKeys.code] = value }
    if let value = createTime { dictionary[SerializationKeys.createTime] = value }
    if let value = updatedTime { dictionary[SerializationKeys.updatedTime] = value }
       if let value = name { dictionary[SerializationKeys.name] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
    createTime = aDecoder.decodeObject(forKey: SerializationKeys.createTime) as? String
    updatedTime = aDecoder.decodeObject(forKey: SerializationKeys.updatedTime) as? String
        name = aDecoder.decodeObject(forKey: SerializationKeys.name) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(code, forKey: SerializationKeys.code)
    aCoder.encode(createTime, forKey: SerializationKeys.createTime)
    aCoder.encode(updatedTime, forKey: SerializationKeys.updatedTime)
        aCoder.encode(name, forKey: SerializationKeys.name)
  }
}
