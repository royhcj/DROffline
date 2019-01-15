//
//  Friend.swift
//
//  Created by 馮仰靚 on 25/10/2017
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

// 檢查是否為好友使用
class CheckFriend {
  var email: String!
  var username: String!
  var id: Int!
  var imgURL: String?
}

public class Friend: NSCoding, JSONable, ObjectToStringForSearch, Hashable {
  public var hashValue: Int { return Int(friendID ?? "0") ?? 0 }

  public static func == (lhs: Friend, rhs: Friend) -> Bool {
    return lhs.friendID == rhs.friendID && lhs.friendName == rhs.friendName
  }

  var image: UIImage = #imageLiteral(resourceName: "friend_avatar_large")

  func transfer(friend: Friend) -> FriendListViewController.Friend? {
    if let id = friend.friendID,
      let name = friend.friendName,
      let email = friend.friendEmail,
      let registerType = friend.friendRegisteredBy{
      var type = FriendListViewController.RegisterType.email
      switch registerType {
      case "email":
        type = .email
      case "google":
        type = .google
      case "fb":
        type = .facebook
      default:
        break
      }
      let avatarURL = friend.imgURL
      let myFriend = FriendListViewController.Friend(id: id,
                            type: .dishRankFriend,
                            name: name,
                            avatarURL: avatarURL,
                            showSelected: false,
                            email: email,
                            registerType: type)
      return myFriend
    }
    return nil
  }

  func getForSearchString() -> String {
    guard let friendName = self.friendName else {
      return ""
    }
    guard let nickname = self.nickname else {
      return friendName
    }
    return friendName + " " + nickname
  }

  public required init() {
  }

  // MARK: Declaration for string constants to be used to decode and also serialize.

  private struct SerializationKeys {
    static let isFollowing = "isFollowing"
    static let isMyInvite = "isMyInvite"
    static let friendID = "friendID"
    static let nickname = "nickname"
    static let allowFollowing = "allowFollowing"
    static let imgURL = "imgURL"
    static let isFriend = "isFriend"
    static let friendEmail = "friendEmail"
    static let friendName = "friendName"
    static let inviteDateTime = "inviteDateTime"
    static let reviewCount = "reviewCount"
    static let rejectMessage = "rejectMessage"
    static let friendRegisteredBy = "friendRegisteredBy"
  }

  // MARK: Properties

  public var isFollowing: Bool? = false
  public var isMyInvite: Bool? = false
  public var friendID: String?
  public var nickname: String?
  public var allowFollowing: Bool? = false
  public var imgURL: String?
  public var isFriend: Bool? = false
  public var friendEmail: String?
  public var friendName: String?
  public var inviteDateTime: String?
  public var reviewCount: Int?
  public var rejectMessage: String?
  public var friendRegisteredBy: String?

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
    isFollowing = json[SerializationKeys.isFollowing].boolValue
    isMyInvite = json[SerializationKeys.isMyInvite].boolValue
    friendID = json[SerializationKeys.friendID].string
    nickname = json[SerializationKeys.nickname].string
    allowFollowing = json[SerializationKeys.allowFollowing].boolValue
    imgURL = json[SerializationKeys.imgURL].string
    isFriend = json[SerializationKeys.isFriend].boolValue
    friendEmail = json[SerializationKeys.friendEmail].string
    friendName = json[SerializationKeys.friendName].string
    inviteDateTime = json[SerializationKeys.inviteDateTime].string
    reviewCount = json[SerializationKeys.reviewCount].int
    rejectMessage = json[SerializationKeys.rejectMessage].string
    friendRegisteredBy = json[SerializationKeys.friendRegisteredBy].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    dictionary[SerializationKeys.isFollowing] = isFollowing
    dictionary[SerializationKeys.isMyInvite] = isMyInvite
    if let value = friendID { dictionary[SerializationKeys.friendID] = value }
    if let value = nickname { dictionary[SerializationKeys.nickname] = value }
    dictionary[SerializationKeys.allowFollowing] = allowFollowing
    if let value = imgURL { dictionary[SerializationKeys.imgURL] = value }
    dictionary[SerializationKeys.isFriend] = isFriend
    if let value = friendEmail { dictionary[SerializationKeys.friendEmail] = value }
    if let value = friendName { dictionary[SerializationKeys.friendName] = value }
    if let value = inviteDateTime { dictionary[SerializationKeys.inviteDateTime] = value }
    if let value = reviewCount { dictionary[SerializationKeys.reviewCount] = value }
    if let value = friendRegisteredBy { dictionary[SerializationKeys.friendRegisteredBy] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol

  public required init(coder aDecoder: NSCoder) {
    isFollowing = aDecoder.decodeBool(forKey: SerializationKeys.isFollowing)
    isMyInvite = aDecoder.decodeBool(forKey: SerializationKeys.isMyInvite)
    friendID = aDecoder.decodeObject(forKey: SerializationKeys.friendID) as? String
    nickname = aDecoder.decodeObject(forKey: SerializationKeys.nickname) as? String
    allowFollowing = aDecoder.decodeBool(forKey: SerializationKeys.allowFollowing)
    imgURL = aDecoder.decodeObject(forKey: SerializationKeys.imgURL) as? String
    isFriend = aDecoder.decodeBool(forKey: SerializationKeys.isFriend)
    friendEmail = aDecoder.decodeObject(forKey: SerializationKeys.friendEmail) as? String
    friendName = aDecoder.decodeObject(forKey: SerializationKeys.friendName) as? String
    inviteDateTime = aDecoder.decodeObject(forKey: SerializationKeys.inviteDateTime) as? String
    reviewCount = aDecoder.decodeObject(forKey: SerializationKeys.reviewCount) as? Int
    friendRegisteredBy = aDecoder.decodeObject(forKey: SerializationKeys.friendRegisteredBy) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(isFollowing, forKey: SerializationKeys.isFollowing)
    aCoder.encode(isMyInvite, forKey: SerializationKeys.isMyInvite)
    aCoder.encode(friendID, forKey: SerializationKeys.friendID)
    aCoder.encode(nickname, forKey: SerializationKeys.nickname)
    aCoder.encode(allowFollowing, forKey: SerializationKeys.allowFollowing)
    aCoder.encode(imgURL, forKey: SerializationKeys.imgURL)
    aCoder.encode(isFriend, forKey: SerializationKeys.isFriend)
    aCoder.encode(friendEmail, forKey: SerializationKeys.friendEmail)
    aCoder.encode(friendName, forKey: SerializationKeys.friendName)
    aCoder.encode(inviteDateTime, forKey: SerializationKeys.inviteDateTime)
    aCoder.encode(reviewCount, forKey: SerializationKeys.reviewCount)
    aCoder.encode(friendRegisteredBy, forKey: SerializationKeys.friendRegisteredBy)
  }
}

class InvitingFriend: Friend {
  enum SourceType: Int {
    case phone
    case dishRank
    case all
  }

  var contactImage: UIImage?
  var friendSource: SourceType?

  public required init() {
    super.init()
  }

  public convenience init(_ friend: Friend) {
    self.init()

    isFollowing = friend.isFollowing
    isMyInvite = friend.isMyInvite
    friendID = friend.friendID
    nickname = friend.nickname
    allowFollowing = friend.allowFollowing
    imgURL = friend.imgURL
    isFriend = friend.isFriend
    friendEmail = friend.friendEmail
    friendName = friend.friendName
    inviteDateTime = friend.inviteDateTime
    reviewCount = friend.reviewCount
  }

  public required init(json: JSON) {
    super.init(json: json)

    friendSource = SourceType(rawValue: json["sourceType"].intValue)
  }

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
