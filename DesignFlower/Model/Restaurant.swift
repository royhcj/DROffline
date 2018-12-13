//
//  Restaurant.swift
//
//  Created by 馮仰靚 on 06/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

class PostDetail {
  var posterName: String = ""
  var posterPhotoURL: String = ""
  var postDate: String = ""
  var postTitle: String = ""
  var postId = Int()
  var postRank: String = ""
  var postShortDesc: String = ""
  var itemCP: String = ""
  var itemService: String = ""
  var itemEnvironment: String = ""
  var markAsLike = Bool()
  var isSigned = Bool()
  var isSelfCreated = Bool()
  var picURL: Array = [String]()
}

class MenuInfo {
  var name: String = ""
  var id = Int()
}

public class Restaurant: NSCoding, ObjectToStringForSearch/*, JSONable*/ {
  func getForSearchString() -> String {
    guard let shopName = self.shopName else {
      return ""
    }
    return shopName
  }

  public init() {
  }
  public init(shopID: Int?,
              shopName: String,
              address: String,
              addressSource: AddressSource,
              latitude: String?,
              longitude: String?,
              shopPhone: String?) {
    self.shopID = shopID
    self.shopName = shopName
    self.address = address
    self.addressSource = addressSource
    self.latitude = latitude
    self.longtitude = longitude
    self.shopPhone = shopPhone
  }
  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let shopName = "shopName"
    static let shopStyle = "shopStyle"
    static let itemService = "itemService"
    static let shopPhone = "shopPhone"
    static let markAsLike = "markAsLike"
    static let address = "address"
    static let country = "country"
    static let city = "city"
    static let itemCP = "itemCP"
    static let postFullText = "postFullText"
    static let latitude = "latitude"
    static let mainPicURL = "mainPicURL"
    static let menu = "menu"
    static let itemRank = "itemRank"
    static let picURL = "picURL"
    static let shopID = "shopID"
    static let dishPicURL = "dishPicURL"
    static let longtitude = "longtitude"
    static let openHour = "openHour"
    static let itemEnvironment = "itemEnvironment"
    static let subTitle = "subTitle"
    static let shopEnName = "shopEnglishName"
    static let content = "content"
    static let media = "media"
    static let recommandRank = "recommandRank"
    static let restaurantRank = "restaurantRank"
    static let serviceRank = "serviceRank"
    static let environmentRank = "environmentRank"
    static let reviewCount = "reviewCount"
    static let likeAt = "likeAt"
    static let distance = "distance"
    static let isSigned = "isSigned"
    static let placeID = "placeID"
    static let isMyRating = "isMyRating"
    static let isSelfCreated = "isSelfCreated"
    static let src = "src"
    static let itemEvaluation = "itemEvaluation"
  }

  // MARK: Properties

  public var shopName: String?
  public var shopStyle: String?
  public var shopPhone: String?
  public var markAsLike: Bool? = false
  public var address: String?
  public var addressSource: AddressSource = .manual
  public var country: String?
  public var city: String?
  public var itemCP: String?
  public var postFullText: String?
  public var latitude: String?
  public var mainPicURL: String?
  public var menu: [Dish]?
  public var itemRank: String?
  public var itemService: String?
  public var itemEnvironment: String?
  public var itemEvaluation: String?
  public var picURL: [String]?
  public var dishPicURL: [String]?
  public var longtitude: String?
  public var subTitle: String?
  public var shopEnName: String?
  public var content: String?
  public var media: [Media]?
  public var recommandRank: String?
  public var shopID: Int?
  public var restaurantRank: String?
  public var serviceRank: String?
  public var openHour: OpenHour?
  public var environmentRank: String?
  public var reviewCount: Int?
  public var likeAt: Int?
  public var isSigned: Bool?
  public var distance: Int = 0
  public var placeID: String?
  public var isMyRating: Bool?
  public var isSelfCreated: Bool?
  public var src: String?
  // MARK: SwiftyJSON Initializers
  
  public typealias AddressSource = KVORestReviewV4.AddressSource

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
    shopStyle = json[SerializationKeys.shopStyle].string
    shopName = json[SerializationKeys.shopName].string
    shopEnName = json[SerializationKeys.shopEnName].string
    itemService = json[SerializationKeys.itemService].string
    shopPhone = json[SerializationKeys.shopPhone].string
    markAsLike = json[SerializationKeys.markAsLike].boolValue
    address = json[SerializationKeys.address].string
    country = json[SerializationKeys.country].string
    city = json[SerializationKeys.city].string
    itemCP = json[SerializationKeys.itemCP].string
    postFullText = json[SerializationKeys.postFullText].string
    latitude = json[SerializationKeys.latitude].string
    mainPicURL = json[SerializationKeys.mainPicURL].string
    subTitle = json[SerializationKeys.subTitle].string
    if let items = json[SerializationKeys.menu].array { menu = items.map { Dish(json: $0) } }
    itemRank = json[SerializationKeys.itemRank].string
    if let items = json[SerializationKeys.picURL].array { picURL = items.map { $0.stringValue } }
    if let items = json[SerializationKeys.dishPicURL].array { dishPicURL = items.map { $0.stringValue } }
    longtitude = json[SerializationKeys.longtitude].string
    itemEnvironment = json[SerializationKeys.itemEnvironment].string
    placeID = json[SerializationKeys.placeID].string
    content = json[SerializationKeys.content].string
    if let items = json[SerializationKeys.media].array { media = items.map { Media(json: $0) } }
    recommandRank = json[SerializationKeys.recommandRank].string
    shopID = json[SerializationKeys.shopID].int
    reviewCount = json[SerializationKeys.reviewCount].int
    likeAt = json[SerializationKeys.likeAt].int
    restaurantRank = json[SerializationKeys.restaurantRank].string
    serviceRank = json[SerializationKeys.serviceRank].string
    openHour = OpenHour(json: json[SerializationKeys.openHour])
    environmentRank = json[SerializationKeys.environmentRank].string
    isSigned = json[SerializationKeys.isSigned].boolValue
    distance = json[SerializationKeys.distance].intValue
    isMyRating = json[SerializationKeys.isMyRating].bool
    isSelfCreated = json[SerializationKeys.isSelfCreated].bool
    src = json[SerializationKeys.src].string
    itemEvaluation = json[SerializationKeys.itemEvaluation].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  // swiftlint:disable cyclomatic_complexity
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = shopStyle { dictionary[SerializationKeys.shopStyle] = value }
    if let value = shopEnName { dictionary[SerializationKeys.shopEnName] = value }
    if let value = shopName { dictionary[SerializationKeys.shopName] = value }
    if let value = itemService { dictionary[SerializationKeys.itemService] = value }
    if let value = shopPhone { dictionary[SerializationKeys.shopPhone] = value }
    dictionary[SerializationKeys.markAsLike] = markAsLike
    if let value = address { dictionary[SerializationKeys.address] = value }
    if let value = country { dictionary[SerializationKeys.country] = value }
    if let value = city { dictionary[SerializationKeys.city] = city }
    if let value = itemCP { dictionary[SerializationKeys.itemCP] = value }
    if let value = postFullText { dictionary[SerializationKeys.postFullText] = value }
    if let value = latitude { dictionary[SerializationKeys.latitude] = value }
    if let value = mainPicURL { dictionary[SerializationKeys.mainPicURL] = value }
    if let value = menu { dictionary[SerializationKeys.menu] = value.map { $0.dictionaryRepresentation() } }
    if let value = itemRank { dictionary[SerializationKeys.itemRank] = value }
    if let value = picURL { dictionary[SerializationKeys.picURL] = value }
    if let value = dishPicURL { dictionary[SerializationKeys.dishPicURL] = value }
    if let value = longtitude { dictionary[SerializationKeys.longtitude] = value }
    if let value = openHour { dictionary[SerializationKeys.openHour] = value }
    if let value = itemEnvironment { dictionary[SerializationKeys.itemEnvironment] = value }
    if let value = subTitle { dictionary[SerializationKeys.itemEnvironment] = value }
    if let value = placeID { dictionary[SerializationKeys.placeID] = value }
    if let value = content { dictionary[SerializationKeys.content] = value }
    if let value = media { dictionary[SerializationKeys.media] = value.map { $0.dictionaryRepresentation() } }
    if let value = recommandRank { dictionary[SerializationKeys.recommandRank] = value }
    if let value = shopID { dictionary[SerializationKeys.shopID] = value }
    if let value = likeAt { dictionary[SerializationKeys.likeAt] = value }
    if let value = reviewCount { dictionary[SerializationKeys.reviewCount] = value }
    if let value = restaurantRank { dictionary[SerializationKeys.restaurantRank] = value }
    if let value = serviceRank { dictionary[SerializationKeys.serviceRank] = value }
    if let value = openHour { dictionary[SerializationKeys.openHour] = value.dictionaryRepresentation() }
    if let value = environmentRank { dictionary[SerializationKeys.environmentRank] = value }
    if let value = isMyRating { dictionary[SerializationKeys.isMyRating] = value }
    if let value = isSelfCreated { dictionary[SerializationKeys.isSelfCreated] = value }
    if let value = src { dictionary[SerializationKeys.src] = value }
    if let value = itemEvaluation { dictionary[SerializationKeys.itemEvaluation] = value }
    return dictionary
  }

  // swiftlint:enable cyclomatic_complexity

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    shopStyle = aDecoder.decodeObject(forKey: SerializationKeys.shopStyle) as? String
    shopName = aDecoder.decodeObject(forKey: SerializationKeys.shopName) as? String
    shopEnName = aDecoder.decodeObject(forKey: SerializationKeys.shopEnName) as? String
    itemService = aDecoder.decodeObject(forKey: SerializationKeys.itemService) as? String
    shopPhone = aDecoder.decodeObject(forKey: SerializationKeys.shopPhone) as? String
    markAsLike = aDecoder.decodeBool(forKey: SerializationKeys.markAsLike)
    address = aDecoder.decodeObject(forKey: SerializationKeys.address) as? String
    country = aDecoder.decodeObject(forKey: SerializationKeys.country) as? String
    city = aDecoder.decodeObject(forKey: SerializationKeys.city) as? String
    itemCP = aDecoder.decodeObject(forKey: SerializationKeys.itemCP) as? String
    postFullText = aDecoder.decodeObject(forKey: SerializationKeys.postFullText) as? String
    latitude = aDecoder.decodeObject(forKey: SerializationKeys.latitude) as? String
    mainPicURL = aDecoder.decodeObject(forKey: SerializationKeys.mainPicURL) as? String
    menu = aDecoder.decodeObject(forKey: SerializationKeys.menu) as? [Dish]
    itemRank = aDecoder.decodeObject(forKey: SerializationKeys.itemRank) as? String
    picURL = aDecoder.decodeObject(forKey: SerializationKeys.picURL) as? [String]
    dishPicURL = aDecoder.decodeObject(forKey: SerializationKeys.dishPicURL) as? [String]
    longtitude = aDecoder.decodeObject(forKey: SerializationKeys.longtitude) as? String
    itemEnvironment = aDecoder.decodeObject(forKey: SerializationKeys.itemEnvironment) as? String
    subTitle = aDecoder.decodeObject(forKey: SerializationKeys.subTitle) as? String
    placeID = aDecoder.decodeObject(forKey: SerializationKeys.placeID) as? String
    content = aDecoder.decodeObject(forKey: SerializationKeys.content) as? String
    media = aDecoder.decodeObject(forKey: SerializationKeys.media) as? [Media]
    recommandRank = aDecoder.decodeObject(forKey: SerializationKeys.recommandRank) as? String
    shopID = aDecoder.decodeObject(forKey: SerializationKeys.shopID) as? Int
    likeAt = aDecoder.decodeObject(forKey: SerializationKeys.likeAt) as? Int
    reviewCount = aDecoder.decodeObject(forKey: SerializationKeys.reviewCount) as? Int
    restaurantRank = aDecoder.decodeObject(forKey: SerializationKeys.restaurantRank) as? String
    serviceRank = aDecoder.decodeObject(forKey: SerializationKeys.serviceRank) as? String
    openHour = aDecoder.decodeObject(forKey: SerializationKeys.openHour) as? OpenHour
    environmentRank = aDecoder.decodeObject(forKey: SerializationKeys.environmentRank) as? String
    isMyRating = aDecoder.decodeObject(forKey: SerializationKeys.isMyRating) as? Bool
    isSelfCreated = aDecoder.decodeObject(forKey: SerializationKeys.isMyRating) as? Bool
    src = aDecoder.decodeObject(forKey: SerializationKeys.src) as? String
    itemEvaluation = aDecoder.decodeObject(forKey: SerializationKeys.itemEvaluation) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(shopEnName, forKey: SerializationKeys.shopEnName)
    aCoder.encode(shopName, forKey: SerializationKeys.shopName)
    aCoder.encode(itemService, forKey: SerializationKeys.itemService)
    aCoder.encode(shopPhone, forKey: SerializationKeys.shopPhone)
    aCoder.encode(markAsLike, forKey: SerializationKeys.markAsLike)
    aCoder.encode(address, forKey: SerializationKeys.address)
    aCoder.encode(country, forKey: SerializationKeys.country)
    aCoder.encode(city, forKey: SerializationKeys.city)
    aCoder.encode(itemCP, forKey: SerializationKeys.itemCP)
    aCoder.encode(postFullText, forKey: SerializationKeys.postFullText)
    aCoder.encode(latitude, forKey: SerializationKeys.latitude)
    aCoder.encode(mainPicURL, forKey: SerializationKeys.mainPicURL)
    aCoder.encode(menu, forKey: SerializationKeys.menu)
    aCoder.encode(itemRank, forKey: SerializationKeys.itemRank)
    aCoder.encode(picURL, forKey: SerializationKeys.picURL)
    aCoder.encode(dishPicURL, forKey: SerializationKeys.dishPicURL)
    aCoder.encode(longtitude, forKey: SerializationKeys.longtitude)
    aCoder.encode(openHour, forKey: SerializationKeys.openHour)
    aCoder.encode(itemEnvironment, forKey: SerializationKeys.itemEnvironment)
    aCoder.encode(subTitle, forKey: SerializationKeys.subTitle)
    aCoder.encode(placeID, forKey: SerializationKeys.placeID)
    aCoder.encode(shopStyle, forKey: SerializationKeys.shopStyle)
    aCoder.encode(content, forKey: SerializationKeys.content)
    aCoder.encode(media, forKey: SerializationKeys.media)
    aCoder.encode(recommandRank, forKey: SerializationKeys.recommandRank)
    aCoder.encode(shopID, forKey: SerializationKeys.shopID)
    aCoder.encode(likeAt, forKey: SerializationKeys.likeAt)
    aCoder.encode(reviewCount, forKey: SerializationKeys.reviewCount)
    aCoder.encode(restaurantRank, forKey: SerializationKeys.restaurantRank)
    aCoder.encode(serviceRank, forKey: SerializationKeys.serviceRank)
    aCoder.encode(openHour, forKey: SerializationKeys.openHour)
    aCoder.encode(environmentRank, forKey: SerializationKeys.environmentRank)
    aCoder.encode(isMyRating, forKey: SerializationKeys.isMyRating)
    aCoder.encode(isSelfCreated, forKey: SerializationKeys.isSelfCreated)
    aCoder.encode(src, forKey: SerializationKeys.src)
    aCoder.encode(itemEvaluation, forKey: SerializationKeys.itemEvaluation)
  }
}
