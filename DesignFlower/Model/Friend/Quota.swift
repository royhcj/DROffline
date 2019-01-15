//
//  Quota.swift
//
//  Created by 馮仰靚 on 24/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Quota: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let inviteQuota = "inviteQuota"
    static let statusMsg = "statusMsg"
    static let statusCode = "statusCode"
    static let waitAcceptCode = "waitAcceptCode"
    static let acceptedMember = "acceptedMember"
  }

  // MARK: Properties

  public var inviteQuota: Int?
  public var statusMsg: String?
  public var statusCode: Int?
  public var waitAcceptCode: [WaitAcceptCode]?
  public var acceptedMember: [AcceptedMember]?

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
    inviteQuota = json[SerializationKeys.inviteQuota].int
    statusMsg = json[SerializationKeys.statusMsg].string
    statusCode = json[SerializationKeys.statusCode].int
    if let items = json[SerializationKeys.waitAcceptCode].array { waitAcceptCode = items.map { WaitAcceptCode(json: $0) } }
    if let items = json[SerializationKeys.acceptedMember].array { acceptedMember = items.map { AcceptedMember(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = inviteQuota { dictionary[SerializationKeys.inviteQuota] = value }
    if let value = statusMsg { dictionary[SerializationKeys.statusMsg] = value }
    if let value = statusCode { dictionary[SerializationKeys.statusCode] = value }
    if let value = waitAcceptCode { dictionary[SerializationKeys.waitAcceptCode] = value.map { $0.dictionaryRepresentation() } }
    if let value = acceptedMember { dictionary[SerializationKeys.acceptedMember] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    inviteQuota = aDecoder.decodeObject(forKey: SerializationKeys.inviteQuota) as? Int
    statusMsg = aDecoder.decodeObject(forKey: SerializationKeys.statusMsg) as? String
    statusCode = aDecoder.decodeObject(forKey: SerializationKeys.statusCode) as? Int
    waitAcceptCode = aDecoder.decodeObject(forKey: SerializationKeys.waitAcceptCode) as? [WaitAcceptCode]
    acceptedMember = aDecoder.decodeObject(forKey: SerializationKeys.acceptedMember) as? [AcceptedMember]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(inviteQuota, forKey: SerializationKeys.inviteQuota)
    aCoder.encode(statusMsg, forKey: SerializationKeys.statusMsg)
    aCoder.encode(statusCode, forKey: SerializationKeys.statusCode)
    aCoder.encode(waitAcceptCode, forKey: SerializationKeys.waitAcceptCode)
    aCoder.encode(acceptedMember, forKey: SerializationKeys.acceptedMember)
  }
}
