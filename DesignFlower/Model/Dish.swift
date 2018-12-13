//
//  DishCollection.swift
//
//  Created by 馮仰靚 on 06/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

class DishInfo {
  var dishArray = [Dish]()
}

class FriendInfo {
  var imgURL: String = ""
  var userId: String = ""
}

public class Dish: NSCoding, ObjectToStringForSearch/*, JSONable*/ {
  func getForSearchString() -> String {
    guard let title = self.title else {
      return ""
    }
    return title
  }

  public init() {
  }

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let content = "content"
    static let shopName = "shopName"
    static let address = "address"
    static let location = "location"
    static let dishtype = "dishtype"
    static let dishRank = "dishRank"
    static let title = "title"
    static let isFavorite = "isFavorite"
    static let price = "price"
    static let subTitle = "subTitle"
    static let mainImgURL = "mainImgURL"
    static let dishID = "dishID"
    static let reviewCount = "reviewCount"
    static let likeAt = "likeAt"

    static let media = "media"
    static let shopID = "shopID"
    static let isMyRating = "isMyRating"
  }

  // MARK: Properties

  public var content: String?
  public var shopName: String?
  public var address: String?
  public var location: String?
  public var dishtype: String?
  public var dishRank: String?
  public var title: String?
  public var isFavorite: Bool? = false
  public var price: String?
  public var subTitle: String?
  public var mainImgURL: String?
  public var dishID: Int?
  public var reviewCount: Int?
  public var likeAt: Int?

  public var media: [Media]?
  public var shopID: Int?
  public var isMyRating: Bool?

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
    content = json[SerializationKeys.content].string
    shopName = json[SerializationKeys.shopName].string
    address = json[SerializationKeys.address].string
    location = json[SerializationKeys.location].string
    dishtype = json[SerializationKeys.dishtype].string
    dishRank = json[SerializationKeys.dishRank].string
    title = json[SerializationKeys.title].string
    isFavorite = json[SerializationKeys.isFavorite].boolValue
    price = json[SerializationKeys.price].string
    subTitle = json[SerializationKeys.subTitle].string
    mainImgURL = json[SerializationKeys.mainImgURL].string
    dishID = json[SerializationKeys.dishID].intValue
    reviewCount = json[SerializationKeys.reviewCount].intValue
    likeAt = json[SerializationKeys.likeAt].intValue
    if let items = json[SerializationKeys.media].array { media = items.map { Media(json: $0) } }
    shopID = json[SerializationKeys.shopID].int
    isMyRating = json[SerializationKeys.isMyRating].bool
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = content { dictionary[SerializationKeys.content] = value }
    if let value = shopName { dictionary[SerializationKeys.shopName] = value }
    if let value = address { dictionary[SerializationKeys.address] = value }
    if let value = location { dictionary[SerializationKeys.location] = value }
    if let value = dishtype { dictionary[SerializationKeys.dishtype] = value }
    if let value = dishRank { dictionary[SerializationKeys.dishRank] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    dictionary[SerializationKeys.isFavorite] = isFavorite
    if let value = price { dictionary[SerializationKeys.price] = value }
    if let value = subTitle { dictionary[SerializationKeys.subTitle] = value }
    if let value = mainImgURL { dictionary[SerializationKeys.mainImgURL] = value }
    if let value = dishID { dictionary[SerializationKeys.dishID] = value }
    if let value = reviewCount { dictionary[SerializationKeys.reviewCount] = value }
    if let value = likeAt { dictionary[SerializationKeys.likeAt] = value }

    if let value = media { dictionary[SerializationKeys.media] = value.map { $0.dictionaryRepresentation() } }
    if let value = shopID { dictionary[SerializationKeys.shopID] = value }

    if let value = isMyRating { dictionary[SerializationKeys.isMyRating] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    content = aDecoder.decodeObject(forKey: SerializationKeys.content) as? String
    shopName = aDecoder.decodeObject(forKey: SerializationKeys.shopName) as? String
    address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
    location = aDecoder.decodeObject(forKey: SerializationKeys.location) as? String
    dishtype = aDecoder.decodeObject(forKey: SerializationKeys.dishtype) as? String
    dishRank = aDecoder.decodeObject(forKey: SerializationKeys.dishRank) as? String
    title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
    isFavorite = aDecoder.decodeBool(forKey: SerializationKeys.isFavorite)
    price = aDecoder.decodeObject(forKey: SerializationKeys.price) as? String
    subTitle = aDecoder.decodeObject(forKey: SerializationKeys.subTitle) as? String
    mainImgURL = aDecoder.decodeObject(forKey: SerializationKeys.mainImgURL) as? String
    dishID = aDecoder.decodeObject(forKey: SerializationKeys.dishID) as? Int
    reviewCount = aDecoder.decodeObject(forKey: SerializationKeys.reviewCount) as? Int
    likeAt = aDecoder.decodeObject(forKey: SerializationKeys.likeAt) as? Int

    media = aDecoder.decodeObject(forKey: SerializationKeys.media) as? [Media]
    shopID = aDecoder.decodeObject(forKey: SerializationKeys.shopID) as? Int

    isMyRating = aDecoder.decodeObject(forKey: SerializationKeys.isMyRating) as? Bool
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(content, forKey: SerializationKeys.content)
    aCoder.encode(shopName, forKey: SerializationKeys.shopName)
    aCoder.encode(address, forKey: SerializationKeys.address)
    aCoder.encode(location, forKey: SerializationKeys.location)
    aCoder.encode(dishtype, forKey: SerializationKeys.dishtype)
    aCoder.encode(dishRank, forKey: SerializationKeys.dishRank)
    aCoder.encode(title, forKey: SerializationKeys.title)
    aCoder.encode(isFavorite, forKey: SerializationKeys.isFavorite)
    aCoder.encode(price, forKey: SerializationKeys.price)
    aCoder.encode(subTitle, forKey: SerializationKeys.subTitle)
    aCoder.encode(mainImgURL, forKey: SerializationKeys.mainImgURL)
    aCoder.encode(dishID, forKey: SerializationKeys.dishID)
    aCoder.encode(reviewCount, forKey: SerializationKeys.reviewCount)
    aCoder.encode(likeAt, forKey: SerializationKeys.likeAt)

    aCoder.encode(media, forKey: SerializationKeys.media)
    aCoder.encode(shopID, forKey: SerializationKeys.shopID)
    aCoder.encode(isMyRating, forKey: SerializationKeys.isMyRating)
  }
}
