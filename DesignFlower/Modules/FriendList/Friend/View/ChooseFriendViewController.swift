//
//  ChooseFriendViewController.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/6/15.
//

import Foundation
import UIKit

class ChooseFriendViewController: UIViewController {

  @IBOutlet weak var selectedFriendView: UIView!
  @IBOutlet weak var friendListView: UIView!
  @IBOutlet weak var segment: UISegmentedControl!
  @IBOutlet weak var searchView: UIView!
  @IBOutlet weak var limpidViewHeight: NSLayoutConstraint!
  @IBOutlet weak var underlineContainer: UIView!
  
  fileprivate var underlineView = UIView()
  var viewModel = ChooseFriendViewModel()
  var friendListVC: FriendListViewController?
  var selectedFriendListVC: FriendListViewController?
  var customSearch: CustomSearchBar?
  
  weak var flowDelegate: ChooseFriendViewControllerFlowDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setfriendListView()
    setSelectedFriendView()
    viewModel.delegate = self
    view.backgroundColor = .clear
    setSegment()
    setUnderline()
  }

  override func viewWillAppear(_ animated: Bool) {
    super .viewWillAppear(animated)

    setSearchControl()

  }
  
  func setUnderline(){
    let underlineSize = UIScreen.main.bounds.size
    underlineView = setupTheUnderlineView(size: underlineSize,
                                          positionX: 0,
                                          btnBgContentView: underlineContainer)
    underlineContainer.addSubview(underlineView)
  }

  private func setupTheUnderlineView(size: CGSize, positionX: CGFloat, btnBgContentView: UIView) -> UIView {
    self.view.layoutIfNeeded()
    //Prepare for setup the underlineView.
    let underlineWidth = size.width / 2
    let underlineHeight: CGFloat = 3
    let bgContentViewHeight = btnBgContentView.frame.size.height
    let underlinePostionY = bgContentViewHeight - underlineHeight
    let newUnderlineView = UIView(frame: CGRect(x: positionX,
                                                y: underlinePostionY,
                                                width: underlineWidth,
                                                height: underlineHeight))
    
    newUnderlineView.backgroundColor = UIColor.init(red: 186/255, green: 143/255, blue: 92/255, alpha: 1)
    
    return newUnderlineView
  }
  
  @IBAction func clearSelectedButton(_ sender: UIButton) {

    guard let vc = friendListVC else {
      return
    }
    vc.selectedFriends = []
    for index in vc.friends.indices {
      vc.friends[index].showSelected = false
    }
  }

  @IBAction func sureButton(_ sender: UIButton) {
// TODO:
//    NoteV3Service.shared.updateRestReview(restReview: viewModel.restReview, allowReaders: viewModel.selectedFriendIDs)
    flowDelegate?.choseFriends(viewModel.selectedFriends)
    
    viewModel.forSuperViewDelegate?.updateSelectedFriendList(friends: viewModel.selectedFriends)
//    self.dismiss(animated: true, completion: nil)

  }

  func setSearchControl() {
    let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.searchView.frame.height)
    let font = UIFont(name: ".PingFangTC-Light", size: 15.0)

    self.customSearch = CustomSearchBar(frame: frame,
                                        font: font!,
                                        textColor: .white,
                                        textFieldBackGroundColor: .white,
                                        keyboardButtonType: .done,
                                        keyboardButtonTitle: "Done")
    
    // Text field in search bar.
    if let textField = customSearch?.value(forKey: "searchField") as? UITextField {
       textField.leftViewMode = .never
    }
    self.customSearch?.delegate = self
    self.searchView.addSubview(self.customSearch!)

  }

  func setSegment() {
    segment.backgroundColor = .white
    segment.tintColor = .clear
    let lightGray = UIColor.init(red: 155/255,
                                 green: 155/255,
                                 blue: 155/255,
                                 alpha: 1)
    let unselectedAttributes = [NSAttributedStringKey.foregroundColor: lightGray,
                                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
    let selectedAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0 / 255,
                                                                             green: 0 / 255,
                                                                             blue: 0 / 255,
                                                                             alpha: 1.0),
                              NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)]
    
    segment.setTitleTextAttributes(unselectedAttributes, for: .normal)
    segment.setTitleTextAttributes(selectedAttributes, for: .selected)
    segment.addTarget(self, action: #selector(segMentValueChange), for: .valueChanged)

  }

  @IBAction func sort(_ sender: UIButton) {
    self.segment.selectedSegmentIndex = 0
    if sender.imageView?.image == #imageLiteral(resourceName: "S.sorting") {
      viewModel.getFriendList(sortBy: .ascending)
      sender.setImage(#imageLiteral(resourceName: "S.sorting Copy"), for: .normal)
    } else {
      viewModel.getFriendList(sortBy: .descending)
      sender.setImage(#imageLiteral(resourceName: "S.sorting"), for: .normal)
    }
    friendListVC?.friends = viewModel.friends
  }

  @objc func segMentValueChange(sender: UISegmentedControl) {
    viewModel.pickSelected()
    if sender.selectedSegmentIndex == 0 {
      friendListVC?.friends = viewModel.friends
      
      UIView.animate(withDuration: 0.1) {
        self.underlineView.transform = CGAffineTransform(translationX: 0, y: 0)
      }
    } else {
      friendListVC?.friends = viewModel.recentFriends
      
      UIView.animate(withDuration: 0.1) {
        self.underlineView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.size.width / 2, y: 0)
      }
    }
  }

  func setSelectedFriendView () {
    if let vc = FriendListViewController.make(style: .horizontal, allowsSelection: false) {
      self.addChildViewController(vc)
      self.view.addSubview(vc.view)
      vc.didMove(toParentViewController: self)
      vc.view.translatesAutoresizingMaskIntoConstraints = false
      vc.view.topAnchor.constraint(equalTo: selectedFriendView.topAnchor).isActive = true
      vc.view.bottomAnchor.constraint(equalTo: selectedFriendView.bottomAnchor).isActive = true
      vc.view.leftAnchor.constraint(equalTo: selectedFriendView.leftAnchor).isActive = true
      vc.view.rightAnchor.constraint(equalTo: selectedFriendView.rightAnchor).isActive = true
      selectedFriendListVC = vc
    }
  }

  func setfriendListView() {
    if let vc = FriendListViewController.make(style: .vertical, allowsSelection: true) {
      self.addChildViewController(vc)
      self.view.addSubview(vc.view)
      vc.didMove(toParentViewController: self)
      vc.view.translatesAutoresizingMaskIntoConstraints = false
      vc.view.topAnchor.constraint(equalTo: friendListView.topAnchor).isActive = true
      vc.view.bottomAnchor.constraint(equalTo: friendListView.bottomAnchor).isActive = true
      vc.view.leftAnchor.constraint(equalTo: friendListView.leftAnchor).isActive = true
      vc.view.rightAnchor.constraint(equalTo: friendListView.rightAnchor).isActive = true
      friendListVC = vc
      friendListVC?.listDelegate = viewModel
    }
  }

  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

}

extension ChooseFriendViewController: ChooseFriendViewModelDelegate {

  func updateFriendList(selectedList: [FriendListViewController.Friend]? = nil) {
    guard let vc = friendListVC else {
      return
    }
    vc.friends = viewModel.friends
    if let list = selectedList {
      vc.selectedFriends = list
    }
  }

  func updateSelectedFriendList(friends: [FriendListViewController.Friend]) {
    guard let vc = selectedFriendListVC else {
      return
    }
    vc.friends = friends
  }

}

extension ChooseFriendViewController: UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    UIView.animate(withDuration: 0.5) {
      self.limpidViewHeight.constant = 43
      self.view.layoutSubviews()
    }
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if let text = searchBar.text, text.count > 0 {
      viewModel.pickSelected()
      let filterFriends = viewModel.friends.filter { (friend) -> Bool in
        return friend.name.contains("\(text)")
      }
      guard let vc = friendListVC else {
        return
      }
      vc.friends = filterFriends
    } else {
      guard let vc = friendListVC else {
        return
      }
      viewModel.pickSelected()
      vc.friends = self.viewModel.friends
    }
  }

}


protocol ChooseFriendViewControllerFlowDelegate: class {
  func leave()
  func choseFriends(_ friends: [FriendListViewController.Friend])
}
