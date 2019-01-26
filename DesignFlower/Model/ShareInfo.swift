//
//  ShareInfo.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/6/20.
//

import Foundation

struct ShareInfo: Codable {
  let sharePeople: Int?
  let createdAt: String?
  let restaurantName: String?
  let city: String?
  let comment: String?
  let reviewCount: Int?
  let imageCount: Int?
  let imageUrl: String?
  let viewed: Int?
  let isDelete: Bool?
  let restaurantReviewID: Int?
  let title: String?

  enum CodingKeys: String, CodingKey {

    case sharePeople = "sharePeople"
    case createdAt = "createdAt"
    case restaurantName = "restaurantName"
    case city = "city"
    case comment = "comment"
    case reviewCount = "reviewCount"
    case imageCount = "imageCount"
    case imageUrl = "imageUrl"
    case viewed = "viewed"
    case isDelete = "isDelete"
    case restaurantReviewID = "restauarntReviewID" // api拼錯了，代修正
    case title = "title"
  }

}
