//
//  WaitAcceptCode.swift
//
//  Created by 馮仰靚 on 24/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class WaitAcceptCode: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let code = "code"
    static let inviteDate = "inviteDate"
    static let isSend = "is_send"
  }

  // MARK: Properties

  public var code: String?
  public var inviteDate: String?
  public var isSend: Int?

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
    inviteDate = json[SerializationKeys.inviteDate].string
    isSend = json[SerializationKeys.isSend].int
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = code { dictionary[SerializationKeys.code] = value }
    if let value = inviteDate { dictionary[SerializationKeys.inviteDate] = value }
    if let value = isSend { dictionary[SerializationKeys.isSend] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    code = aDecoder.decodeObject(forKey: SerializationKeys.code) as? String
    inviteDate = aDecoder.decodeObject(forKey: SerializationKeys.inviteDate) as? String
    isSend = aDecoder.decodeObject(forKey: SerializationKeys.isSend) as? Int
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(code, forKey: SerializationKeys.code)
    aCoder.encode(inviteDate, forKey: SerializationKeys.inviteDate)
    aCoder.encode(isSend, forKey: SerializationKeys.isSend)
  }
}
