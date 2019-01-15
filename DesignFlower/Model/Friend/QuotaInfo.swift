//
//  QuotaInfo.swift
//
//  Created by 馮仰靚 on 23/02/2018
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class QuotaInfo: NSCoding, JSONable {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let inactiveCodes = "inactiveCodes"
    static let inviteQuota = "inviteQuota"
    static let statusMsg = "statusMsg"
    static let statusCode = "statusCode"
    static let acceptedInvitations = "acceptedInvitations"
    static let pendingCodes = "pendingCodes"
  }

  // MARK: Properties

  public var inactiveCodes: [InactiveCode]?
  public var inviteQuota: Int?
  public var statusMsg: String?
  public var statusCode: Int?
  public var acceptedInvitations: [AcceptedInvitation]?
  public var pendingCodes: [PendingCode]?

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
    if let items = json[SerializationKeys.inactiveCodes].array { inactiveCodes = items.map { InactiveCode(json: $0) } }
    inviteQuota = json[SerializationKeys.inviteQuota].int
    statusMsg = json[SerializationKeys.statusMsg].string
    statusCode = json[SerializationKeys.statusCode].int
    if let items = json[SerializationKeys.acceptedInvitations].array {
      acceptedInvitations = items.map { AcceptedInvitation(json: $0) }
                                 .filter {
                                   $0.email != ""
                                 }
    }
    if let items = json[SerializationKeys.pendingCodes].array { pendingCodes = items.map { PendingCode(json: $0) } }
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = inactiveCodes { dictionary[SerializationKeys.inactiveCodes] = value.map { $0.dictionaryRepresentation() } }
    if let value = inviteQuota { dictionary[SerializationKeys.inviteQuota] = value }
    if let value = statusMsg { dictionary[SerializationKeys.statusMsg] = value }
    if let value = statusCode { dictionary[SerializationKeys.statusCode] = value }
    if let value = acceptedInvitations { dictionary[SerializationKeys.acceptedInvitations] = value.map { $0.dictionaryRepresentation() } }
    if let value = pendingCodes { dictionary[SerializationKeys.pendingCodes] = value.map { $0.dictionaryRepresentation() } }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    inactiveCodes = aDecoder.decodeObject(forKey: SerializationKeys.inactiveCodes) as? [InactiveCode]
    inviteQuota = aDecoder.decodeObject(forKey: SerializationKeys.inviteQuota) as? Int
    statusMsg = aDecoder.decodeObject(forKey: SerializationKeys.statusMsg) as? String
    statusCode = aDecoder.decodeObject(forKey: SerializationKeys.statusCode) as? Int
    acceptedInvitations = aDecoder.decodeObject(forKey: SerializationKeys.acceptedInvitations) as? [AcceptedInvitation]
    pendingCodes = aDecoder.decodeObject(forKey: SerializationKeys.pendingCodes) as? [PendingCode]
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(inactiveCodes, forKey: SerializationKeys.inactiveCodes)
    aCoder.encode(inviteQuota, forKey: SerializationKeys.inviteQuota)
    aCoder.encode(statusMsg, forKey: SerializationKeys.statusMsg)
    aCoder.encode(statusCode, forKey: SerializationKeys.statusCode)
    aCoder.encode(acceptedInvitations, forKey: SerializationKeys.acceptedInvitations)
    aCoder.encode(pendingCodes, forKey: SerializationKeys.pendingCodes)
  }
}
