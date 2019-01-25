//
//  V4ShareVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/26.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4ShareViewModel: V4ReviewViewModel {
  
  weak var output: V4ShareViewModelOutput?
  
  var sharedFriends: [FriendListViewController.Friend] = []
  
  override var restaurantState: V4ReviewVC.RestaurantNameCell.RestaurantState {
    return .canView
  }
  
  override init(output: Output?, reviewUUID: String?) {
    super.init(output: output, reviewUUID: reviewUUID)
    if let output = output as? V4ShareViewModelOutput {
      self.output = output
    }
  }
  
  // MARK: - ► Review Manipulation
  override func setReview(_ review: KVORestReviewV4) {
    super.setReview(review)
    fetchSharedFriends(review.allowedReaders) { [weak self] in
      self?.sharedFriends = $0
      self?.output?.refreshReview() // TODO: just refresh shared friend for optimization
    }
  }
  
  // MARK: - ► Friend Related
  func changeSharedFriends(_ friends: [FriendListViewController.Friend]) {
    sharedFriends = friends
    review?.allowedReaders = friends.compactMap { Int($0.id) }
    //review?.shareType = 2
    self.output?.refreshReview()
  }
  
  func fetchSharedFriends(_ friendIDs: [Int],
                          completion: @escaping (([FriendListViewController.Friend]) -> Void)) {
    guard let accessToken = LoggedInUser.sharedInstance().accessToken
    else { return }
    
    WebService.NoteV3FriendAPI.postFriends(accessToken: accessToken)
      .then { [weak self] json -> Void in
        guard json.statusCode == 0
        else {
          completion([])
          return
        }
        var resultFriends: [FriendListViewController.Friend] = []
        if let friends = json.friend {
          for friend in friends {
            if friendIDs.contains(where: { String($0) == friend.friendID }) {
              guard let resultFriend = Friend.transfer(friend: friend)
              else { continue }
              
              resultFriends.append(resultFriend)
            }
          }
        }
        completion(resultFriends)
      }
      .catch { (error) in
        print(error)
      }
  }
  
  // MARK: - ► Share Related
  func share() {
    updloadShare { [weak self] (success, error) in
      self?.output?.shareCompleted(successful: success,
                                   errorMessage: error?.localizedDescription)
    }
  }
  
  func updloadShare(completion: ((Bool, Error?) -> Void)?) {
    guard let accessToken = LoggedInUser.sharedInstance().accessToken,
          let review = review
    else { return print("Error! Invalid access token to share.") }
    
    let isNewShare = review.id == -1
    
    if isNewShare {
      WebService.NoteReviewAPI.postNewRestaurantShare(
        accessToken: accessToken,
        restaurantReview: review,
        latitude: nil, // TODO: Get latitude
        longitude: nil, // TODO: Get longitude
        phoneNumber: nil)
        .then { [unowned self] json -> Void in
          if json["statusCode"].int == 0 {
            // 註：其實不用回寫ID，因為分享完就跳出畫面了，但是為了安全起見還是回寫ID
            // 回寫評比ID
            if let restaurantReviewID = json["restauarntReviewID"].int {
              review.id = restaurantReviewID
            }
            // 回寫菜餚評比ID
            let dishReviewIDs = json["dishReviewID"].arrayValue.map {
              $0.intValue
            }
            for (index, dishReviewID) in dishReviewIDs.enumerated()
              where index < review.dishReviews.count {
              review.dishReviews[index].id = dishReviewID
            }

#if false // TODO: old logic. Do it later.
            if let shopID = json["shopID"].int {
              let restaurant = Restaurant(shopID: shopID,
                                          shopName: self.restReview.shop ?? "",
                                          address: self.restReview.address ?? "",
                                          addressSource: RLMRestReviewV3.AddressSource(rawValue: self.restReview.addressSource) ?? .manual,
                                          latitude: nil,
                                          longitude: nil,
                                          shopPhone: self.restReview.phoneNumber)
              
              self.getLocationInfo(restaurant: restaurant) { locationInfo in
                self.selectRest(restaurant: restaurant,
                                locationInfo: locationInfo)
                
                let dishReviews = Array(self.restReview.dishReviews)
                let dishReviewIDs = json["dishReviewID"].arrayValue.map {
                  $0.intValue
                }
                self.update(dishReviews: dishReviews, withReviewIDs: dishReviewIDs)
                completion?(true, nil)
              }
            }
#endif
            completion?(true, nil)
          } else {
            print(json["statusMsg"].stringValue)
//            completion?(false, json["statusMsg"].stringValue)
            completion?(false, json["statusMsg"].stringValue)
          }
        }.catch { error in
          print(error)
          completion?(false, error)
        }
    } else { // if !isNew
      WebService.NoteReviewAPI.postNewRestaurantShare(
        accessToken: accessToken,
        restaurantReview: review,
        latitude: nil, // TODO: Get latitude
        longitude: nil, // TODO: Get longitude
        phoneNumber: nil)
        .then { json -> Void in
          if json["statusCode"].int == 0 {
            completion?(true, nil)
          } else {
            print(json["statusMsg"].stringValue)
            completion?(false, json["statusMsg"].stringValue)
          }
        }.catch { error in
          print(error)
          completion?(false, error)
        }
    }
  }
}

protocol V4ShareViewModelOutput: class {
  func refreshReview()
  func shareCompleted(successful: Bool, errorMessage: String?)
}
