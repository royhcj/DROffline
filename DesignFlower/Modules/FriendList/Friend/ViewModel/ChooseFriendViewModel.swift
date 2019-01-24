//
//  ChooseFriendViewModel.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/6/15.
//

import Foundation

protocol ChooseFriendViewModelDelegate: class {
  func updateFriendList(selectedList: [FriendListViewController.Friend]?)
  func updateSelectedFriendList(friends: [FriendListViewController.Friend])
}

protocol ChooseFriendViewModelForSuperViewDelegate: class {
   func updateSelectedFriendList(friends: [FriendListViewController.Friend])
}

class ChooseFriendViewModel: NSObject {

  //var restReview: RLMRestReviewV3!

  var friends: [FriendListViewController.Friend] = [] {
    didSet {
      delegate?.updateFriendList(selectedList: nil)
    }
  }

  var recentFriends: [FriendListViewController.Friend] = [] {
    didSet {
      delegate?.updateFriendList(selectedList: nil)
    }
  }

  var selectedFriends: [FriendListViewController.Friend] = [] {
    didSet {
      delegate?.updateSelectedFriendList(friends: selectedFriends)
      var ids = [String]()
      for friend in selectedFriends {
        ids.append(friend.id)
      }
      selectedFriendIDs = ids
    }
  }

  var selectedFriendIDs: [String] = []

  weak var delegate: ChooseFriendViewModelDelegate?
  weak var forSuperViewDelegate: ChooseFriendViewModelForSuperViewDelegate?
  override init() {
    super.init()
    getFriendList()
    getRecentList()
  }

  enum Arrange {
    case ascending
    case descending
  }

  func getFriendList(sortBy: Arrange = .ascending) {

    guard let accessToken = LoggedInUser.sharedInstance().accessToken
    else {
        return
    }
    
    guard friends.count < 1 else {
      self.sortFriends(sortBy: sortBy)
      self.pickSelected()
      return
    }

    WebService.NoteV3FriendAPI.postFriends(accessToken: accessToken)
      .then { friend -> Void in
        if let friends = friend.friend {
          let firstFriend = FriendListViewController.Friend(id: "all",
                                                            type: .dishRankFriend,
                                                            name: "全部好友",
                                                            avatarURL: nil,
                                                            showSelected: false,
                                                            email: "all",
                                                            registerType: .email)

          for friend in friends {
            guard let myFriend = Friend.transfer(friend: friend) else { continue }
            if friend.isFriend ?? false {
              self.friends.append(myFriend)
            }
            
          }
          self.sortFriends(sortBy: sortBy)
          self.friends.insert(firstFriend, at: 0)
          self.pickSelected()
        }
      }
      .catch { error in
        print(error)
      }
   }

  func sortFriends(sortBy: Arrange = .ascending) {
    switch sortBy {
    case .ascending:
      self.friends = self.friends.sorted { (first, second) -> Bool in
        if first.id != "all", second.id != "all" {
          return first < second
        }
        return false
      }
    case .descending:
      self.friends = self.friends.sorted { (first, second) -> Bool in
        if first.id != "all", second.id != "all" {
          return first > second
        }
        return false
      }
    }
  }

  func pickSelected() {
    var indexs = [Int]()
    for (index, friend) in self.friends.enumerated() {
      if self.selectedFriendIDs.contains(where: { id -> Bool in
        return id == "\(friend.id)"
      }) {
        self.friends[index].showSelected = true
        indexs.append(index)
      } else {
        self.friends[index].showSelected = false
      }
    }
    for index in indexs {
      if selectedFriends.contains(where: { (friend) -> Bool in
        return friend.id == self.friends[index].id
      }) { continue }
      self.selectedFriends.append(self.friends[index])
    }
    //
    indexs.removeAll()
    for (index, recentFriend) in self.recentFriends.enumerated() {
      if self.selectedFriendIDs.contains(where: { id -> Bool in
        return id == "\(recentFriend.id)"
      }) {
        self.recentFriends[index].showSelected = true
        indexs.append(index)
      } else {
        self.recentFriends[index].showSelected = false
      }
    }
    for index in indexs {
      if selectedFriends.contains(where: { (friend) -> Bool in
        return friend.id == self.recentFriends[index].id
      }) { continue }
      self.selectedFriends.append(self.recentFriends[index])
    }

    delegate?.updateFriendList(selectedList: selectedFriends)
  }

  func getRecentList() {
    guard let accessToken = LoggedInUser.sharedInstance().accessToken
    else { return }
    
    WebService.NoteV3FriendAPI.getRecentFriends(accessToken: accessToken)
      .then { (friendJSON) -> Void in
        if let recentFriends = friendJSON.friend {
          for recentFriend in recentFriends {
            guard var myFriend = Friend.transfer(friend: recentFriend) else { continue }
            self.recentFriends.append(myFriend)
          }
          self.recentFriends = self.recentFriends.sorted { $0 < $1 }
          self.pickSelected()
        }
      }
      .catch { error in
        print(error)
      }
  }

}

extension ChooseFriendViewModel: SendSelectedFriendsDelegate {
  func updateSelectedFriends(myFriends: [FriendListViewController.Friend]) {
    selectedFriends = myFriends
  }

}
