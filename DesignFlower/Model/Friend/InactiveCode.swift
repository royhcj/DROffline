//
//  InactiveCodes.swift
//
//  Created by 馮仰靚 on 23/02/2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class InactiveCode: NSCoding, JSONable {
  init() {
  }

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let createTime = "createTime"
    static let code = "code"
  }

  // MARK: Properties

  public var createTime: String?
  public var code: String?

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
    createTime = json[SerializationKeys.createTime].string
    code = json[SerializationKeys.code].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = createTime { dictionary[SerializationKeys.createTime] = value }
    if let value = code { dictionary[SerializationKeys.code] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    createTime = aDecoder.decodeObject(forKey: SerializationKeys.createTime) as? String
    code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(createTime, forKey: SerializationKeys.createTime)
    aCoder.encode(code, forKey: SerializationKeys.code)
  }
}
