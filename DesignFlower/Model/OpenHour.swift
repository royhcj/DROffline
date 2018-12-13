//
//  OpenHour.swift
//
//  Created by 馮仰靚 on 31/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class OpenHour: NSCoding/*, JSONable*/ {

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let wednesday = "wednesday"
    static let saturday = "saturday"
    static let thursday = "thursday"
    static let monday = "monday"
    static let friday = "friday"
    static let sunday = "sunday"
    static let tuesday = "tuesday"
  }

  // MARK: Properties

  public var wednesday: String?
  public var saturday: String?
  public var thursday: String?
  public var monday: String?
  public var friday: String?
  public var sunday: String?
  public var tuesday: String?

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
    wednesday = json[SerializationKeys.wednesday].string
    saturday = json[SerializationKeys.saturday].string
    thursday = json[SerializationKeys.thursday].string
    monday = json[SerializationKeys.monday].string
    friday = json[SerializationKeys.friday].string
    sunday = json[SerializationKeys.sunday].string
    tuesday = json[SerializationKeys.tuesday].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = wednesday { dictionary[SerializationKeys.wednesday] = value }
    if let value = saturday { dictionary[SerializationKeys.saturday] = value }
    if let value = thursday { dictionary[SerializationKeys.thursday] = value }
    if let value = monday { dictionary[SerializationKeys.monday] = value }
    if let value = friday { dictionary[SerializationKeys.friday] = value }
    if let value = sunday { dictionary[SerializationKeys.sunday] = value }
    if let value = tuesday { dictionary[SerializationKeys.tuesday] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    wednesday = aDecoder.decodeObject(forKey: SerializationKeys.wednesday) as? String
    saturday = aDecoder.decodeObject(forKey: SerializationKeys.saturday) as? String
    thursday = aDecoder.decodeObject(forKey: SerializationKeys.thursday) as? String
    monday = aDecoder.decodeObject(forKey: SerializationKeys.monday) as? String
    friday = aDecoder.decodeObject(forKey: SerializationKeys.friday) as? String
    sunday = aDecoder.decodeObject(forKey: SerializationKeys.sunday) as? String
    tuesday = aDecoder.decodeObject(forKey: SerializationKeys.tuesday) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(wednesday, forKey: SerializationKeys.wednesday)
    aCoder.encode(saturday, forKey: SerializationKeys.saturday)
    aCoder.encode(thursday, forKey: SerializationKeys.thursday)
    aCoder.encode(monday, forKey: SerializationKeys.monday)
    aCoder.encode(friday, forKey: SerializationKeys.friday)
    aCoder.encode(sunday, forKey: SerializationKeys.sunday)
    aCoder.encode(tuesday, forKey: SerializationKeys.tuesday)
  }
}
