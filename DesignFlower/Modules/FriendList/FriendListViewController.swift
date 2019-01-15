//
//  FriendListViewController.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/6/11.
//

import UIKit
import SDWebImage
import AlignedCollectionViewFlowLayout

private let reuseIdentifier = "FriendCell"
private let friendHorizontalCell = "friendHorizontalCell"

protocol SendSelectedFriendsDelegate: class {
  func updateSelectedFriends(myFriends: [FriendListViewController.Friend])
}

class FriendListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  var friends: [Friend] = [] {
    didSet { 
      if let layout = self.collectionView?.collectionViewLayout
        as? AlignedCollectionViewFlowLayout {
        self.controlStyle(style: style, layout: layout)
      }
      collectionView?.reloadData()
    }
  }

  private var isShowName: Bool = true
  private var style: ListStyle = .horizontal
  private var horiZentalAlignment: HorizontalAlignment?
  var shouldShowName = true
  weak var delegate: Delegate?
  weak var listDelegate: SendSelectedFriendsDelegate?
  var selectedFriends: [Friend] = [] {
    didSet {
      listDelegate?.updateSelectedFriends(myFriends: selectedFriends)
    }
  }
  var allowSelection: Bool = false
  // MARK: - Object lifecycle

  static func make(style: ListStyle,
                   allowsSelection: Bool = false,
                   isShowName: Bool? = true,
                   horiZentalAlignment: HorizontalAlignment? = nil) -> FriendListViewController? {
    let vc = UIStoryboard(name: "FriendList", bundle: nil)
              .instantiateViewController(withIdentifier: "FriendListViewController")
              as? FriendListViewController
    vc?.style = style
    vc?.allowSelection = allowsSelection
    vc?.isShowName = isShowName!
    vc?.horiZentalAlignment = horiZentalAlignment

    return vc
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Register cell classes

    collectionView?.allowsMultipleSelection = allowSelection
    if let layout = self.collectionView?.collectionViewLayout
                      as? AlignedCollectionViewFlowLayout {
      self.controlStyle(style: style, layout: layout)
    }

    // Do any additional setup after loading the view.
  }

  func controlStyle(style: FriendListViewController.ListStyle, layout: AlignedCollectionViewFlowLayout) {
    switch style {
    case .horizontal:
      if let horiZentalAlignment = horiZentalAlignment {
        if friends.count < 4 {
          layout.horizontalAlignment = horiZentalAlignment
          collectionView?.isScrollEnabled = false
        } else {
          collectionView?.isScrollEnabled = true
          layout.scrollDirection = .horizontal
          layout.horizontalAlignment = .justified
        }
      } else {
        layout.scrollDirection = .horizontal
        collectionView?.isScrollEnabled = true
      }
    case .vertical:
      layout.scrollDirection = .vertical
      collectionView?.isScrollEnabled = true
      collectionView?.reloadData()
      delegate?.friendListViewControllerDidResize(self)
    }
  }

  // MARK: - CollectionView DataSource/Delegate

//  override func numberOfSections(in collectionView: UICollectionView) -> Int {
//    // #warning Incomplete implementation, return the number of sections
//    return 1
//    
//  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return friends.count
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch style {
    case .horizontal:
      var height = collectionView.frame.height > 60 ? 60 : collectionView.frame.height
      let width = ( collectionView.frame.width - 50 ) / 6
      height = height > width ? width : height
      if !isShowName {
        return CGSize.init(width: 60, height: 60 )
      }
      return CGSize.init(width: height, height: height + 25 )
    case .vertical:
      return CGSize.init(width: collectionView.frame.width, height: 60 )
    }
    
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let friend = friends[indexPath.item]
    
    switch style {
    case .horizontal:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
      
      if let cell = cell as? FriendCell {
        cell.configure(with: friend, isShowName: isShowName)
        cell.selectImageView.isHidden = !(self.collectionView?.allowsMultipleSelection)!
      }
      
      return cell
    case .vertical:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendHorizontalCell, for: indexPath)
      
      
      
      if let cell = cell as? FriendHorizontalCell {
        cell.configure(with: friend, isShowName: isShowName)
        cell.selectImageView.isHidden = !(self.collectionView?.allowsMultipleSelection)!
      }
      
      return cell
    }
    
    
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //控制all
    if friends[indexPath.row].id == "all" {
      if friends[indexPath.row].showSelected {
        for (index, friend) in friends.enumerated() where friend.id != "all" {
          if friends[index].showSelected {
            friends[index].showSelected = false
          }
        }
        selectedFriends.removeAll()
      } else {
        for (index, friend) in friends.enumerated() where friend.id != "all" {
          if !friends[index].showSelected {
            friends[index].showSelected = true
            selectedFriends.append(friend)
          }
        }
        if selectedFriends[0].id == "all" {
          selectedFriends.remove(at: 0)
        }
      }
      friends[indexPath.row].showSelected = !friends[indexPath.row].showSelected
      return
    }
    //控制除了all以外
    if selectedFriends.contains(where: { (friend) -> Bool in
      return friend.id == friends[indexPath.row].id
    }) {
      if let index = selectedFriends.index(where: { (friend) -> Bool in
        return friend.id == friends[indexPath.row].id
      }) {
         selectedFriends.remove(at: index)
      }
      friends[indexPath.row].showSelected = false
      if friends[0].id == "all" {
        friends[0].showSelected = false
      }
    } else {
      selectedFriends.append(friends[indexPath.row])
      friends[indexPath.row].showSelected = true
    }

    if let cell = collectionView.cellForItem(at: indexPath) as? FriendCell {
      cell.setSelectImageView(friend: friends[indexPath.row])
    }

  }

//  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//    selectedIndexPath = collectionView.indexPathsForSelectedItems
//    if let cell = collectionView.cellForItem(at: indexPath) as? FriendCell {
//      cell.setSelectImageView(friend: friends[indexPath.row])
//    }
//
//  }

  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */

  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */

  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }
   
   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
   
   }
   */

  // MARK: - Models

  struct Friend: Equatable, Comparable {
    var id: String
    var type: FriendType
    var name: String
    var avatarURL: String?
    var showSelected: Bool = false
    var email: String
    var registerType: RegisterType

    enum FriendType {
      case dishRankFriend     // 尋味好友
      case contactBookFriend  // 通訊錄好友
    }

    static func <(lhs: Friend, rhs: Friend) -> Bool {
      return lhs.name.lowercased() < rhs.name.lowercased()
    }

    static func >(lhs: Friend, rhs: Friend) -> Bool {
      return lhs.name.lowercased() > rhs.name.lowercased()
    }

  }

  // MARK: - Type Definitions

  enum ListStyle {
    case horizontal
    case vertical
  }
  
  enum RegisterType {
    case email
    case google
    case facebook
  }
}

// MARK: - Cell

class FriendHorizontalCollectionCell: UICollectionViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var selectImageView: UIImageView!
  @IBOutlet weak var registerTypeImageView: UIImageView!
  @IBOutlet weak var registerEmailTypeStackView: UIStackView!
  func setSelectImageView(friend: FriendListViewController.Friend) {
    selectImageView.image = friend.showSelected ? #imageLiteral(resourceName: "Sselectfriends") : #imageLiteral(resourceName: "S.unselect friends")
  }
  func configure(with friend: FriendListViewController.Friend, isShowName: Bool? = true) {
    registerEmailTypeStackView.isHidden = false
    
    if let url = friend.avatarURL, url != "" {
      self.avatarImageView.sd_setImage(with: URL(string: url), completed: nil)
    } else {
      if friend.id == "all" {
        self.avatarImageView.image = #imageLiteral(resourceName: "S.people allfriends")
      } else {
        self.avatarImageView.image = #imageLiteral(resourceName: "S.people big")
      }
      
      self.avatarImageView.backgroundColor = DishRankColor.darkTan
    }
    
    switch friend.registerType {
    case .email:
      registerTypeImageView.image = UIImage(named: "mailRegister")
    case .google:
      registerTypeImageView.image = UIImage(named: "googleRegister")
    case .facebook:
      registerTypeImageView.image = UIImage(named: "facebookRegister")
    }
    
    self.avatarImageView.clipsToBounds = true
    self.setSelectImageView(friend: friend)
    if isShowName! {
      self.avatarImageView.cornerRadius = self.avatarImageView.frame.width / 2
      nameLabel.text = friend.name
      let emailSplit = friend.email.split(separator: "@")
      if let emailFrontString = emailSplit.at(0) {
        if emailFrontString.description == "all" {
          registerEmailTypeStackView.isHidden = true
        } else {
          emailLabel.text = emailFrontString.description
        }
      } else {
        emailLabel.text = ""
      }
    } else {
      self.avatarImageView.cornerRadius = self.avatarImageView.frame.width / 2
      nameLabel.isHidden = true
      emailLabel.isHidden = true
    }
  }
}

class FriendListViewControllerCell: UICollectionViewCell {
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var selectImageView: UIImageView!

  func setSelectImageView(friend: FriendListViewController.Friend) {
    selectImageView.image = friend.showSelected ? #imageLiteral(resourceName: "Sselectfriends") : #imageLiteral(resourceName: "S.unselect friends")
  }

  func configure(with friend: FriendListViewController.Friend, isShowName: Bool? = true) {
    if let url = friend.avatarURL, url != "" {
      self.avatarImageView.sd_setImage(with: URL(string: url), completed: nil)
    } else {
      if friend.id == "all" {
          self.avatarImageView.image = #imageLiteral(resourceName: "S.people allfriends")
      } else {
          self.avatarImageView.image = #imageLiteral(resourceName: "S.people big")
      }

      self.avatarImageView.backgroundColor = DishRankColor.darkTan
    }

    self.avatarImageView.clipsToBounds = true
    self.setSelectImageView(friend: friend)
    if isShowName! {
      self.avatarImageView.cornerRadius = ( self.frame.width - 16 ) / 2
      nameLabel.text = friend.name
    } else {
      self.avatarImageView.cornerRadius = ( self.frame.width - 16 ) / 2
      nameLabel.isHidden = true
    }
  }
}

// MARK: - Protocol

protocol FriendListViewControllerDelegate: class {
  func friendListViewControllerDidResize(_ sender: FriendListViewController)
}
extension FriendListViewControllerDelegate {
  func friendListViewControllerDidResize(_ sender: FriendListViewController) { }
}

// MARK: - typealias

extension FriendListViewController {
  typealias FriendCell = FriendListViewControllerCell
  typealias FriendHorizontalCell = FriendHorizontalCollectionCell
  typealias Delegate = FriendListViewControllerDelegate
}
