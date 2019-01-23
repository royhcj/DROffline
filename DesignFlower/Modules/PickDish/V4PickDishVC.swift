//
//  NoteV3DishSelectorViewController.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/6/5.
//

import Foundation
import UIKit

//protocol V4PickDishVCDelegate: class {
//  func reloadCollection()
//  func canAddDishReview()
//}

//protocol AddCellDelegate: class {
//}
//
//class AddCell: UITableViewCell {
//  @IBOutlet var nameLabel: UILabel!
//  @IBOutlet var addButton: UIButton!
//
//  weak var delegate: AddCellDelegate?
//}

class DishExist {
  var use = false
  var dishID: [Int] = []
}


protocol V4PickDish_AddCellDelegate: class {
}

class V4PickDish_AddCell: UITableViewCell {
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var addButton: UIButton!
  
  weak var delegate: V4PickDish_AddCellDelegate?
}

class V4PickDish_DishSelectCell: UITableViewCell {
  @IBOutlet var dishCNName: UILabel!
  @IBOutlet var dishENName: UILabel!
  @IBOutlet var dishImageView: UIImageView!
}

class V4PickDish_SearchCell: UITableViewCell {
  @IBOutlet var forSearchView: UIView!
}


class V4PickDishVC: UIViewController, V4PickDish_AddCellDelegate, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet var dishSearchTableView: UITableView!
  //var dishReview: RLMDishReviewV3!
  var cellIndexPath: IndexPath!
  var isSearch: Bool = false
  var shopID: Int!
  var searchController: UISearchController!
  var customSearchController: CustomSearchController!
  var shouldShowSearchResults = false
  var dishArray = [Dish]()
  var filterDishArray = [Dish]()
  var dishExist = DishExist()
  
  weak var flowDelegate: FlowDelegate?
  //weak var delegate: NoteV3DishSelectorViewControllerDelegate?
  
  // MARK: - Object lifecycle
  static func make(flowDelegate: FlowDelegate?, restaurantID: Int) -> V4PickDishVC {
    let vc = UIStoryboard(name: "V4PickDish", bundle: nil)
              .instantiateViewController(withIdentifier: "V4PickDishVC")
              as! V4PickDishVC
    vc.flowDelegate = flowDelegate
    vc.shopID = restaurantID
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    dishSearchTableView.delegate = self
    dishSearchTableView.dataSource = self
    getDishList()
    self.navigationController?.navigationBar.tintColor = DishRankColor.darkTan
    
  }
  
  func getDishList() {
    WebService.AddRating.getDishList(accessToken: LoggedInUser.sharedInstance().accessToken!, shopID: shopID).then { (json) -> Void in
      for dish in json["dishData"].arrayValue {
        let newDish = Dish()
        newDish.dishID = dish["dishID"].intValue
        newDish.title = dish["dishName"].stringValue
        newDish.subTitle = dish["dishEngName"].stringValue
        newDish.mainImgURL = dish["dishMainImgURL"].stringValue
        if self.dishExist.use == true {
          if self.dishExist.dishID.contains(dish["dishID"].intValue) {
          } else {
            self.dishArray.append(newDish)
          }
        } else {
          self.dishArray.append(newDish)
        }
      }
      self.filterDishArray = self.dishArray
    }.then { _ -> Void in
      self.dishSearchTableView.reloadData()
    }
  }
  
  func numberOfSections(in _: UITableView) -> Int {
    return isSearch ? 2 : 1
  }
  
  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    return configureCustomSearchController()
  }
  
  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0:
      return 60
    default:
      return 0
    }
  }
  
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return filterDishArray.count
    default:
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "DishSelectCell", for: indexPath)
      if let cell = cell as? DishSelectCell {
        cell.dishCNName.text = filterDishArray[indexPath.row].title
        cell.dishENName.text = filterDishArray[indexPath.row].subTitle
        if let urlString = filterDishArray[indexPath.row].mainImgURL {
          let url = URL(string: urlString)
          cell.dishImageView.sd_setImage(with: url, completed: nil)
        }
      }
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath)
      if let cell = cell as? AddCell {
        cell.nameLabel.text = "新增『\(customSearchController.customSearchBar.text ?? "")』"
        // 虛線
        let addButtonBorder = CAShapeLayer()
        addButtonBorder.strokeColor = DishRankColor.darkBrownColor.cgColor
        addButtonBorder.lineDashPattern = [2, 2]
        addButtonBorder.frame = cell.addButton.bounds
        addButtonBorder.fillColor = nil
        addButtonBorder.path = UIBezierPath(rect: cell.addButton.bounds).cgPath
        
        cell.addButton.layer.addSublayer(addButtonBorder)
        cell.addButton.isEnabled = false
        cell.delegate = self
      }
      return cell
    }
  }
  
  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      let dish = filterDishArray[indexPath.row]
//      NoteV3Service.shared.updateDishReview(dishReview: dishReview, name: dish.title, dishID: dish.dishID, type: 1)
//      delegate?.reloadCollection()
//      delegate?.canAddDishReview()
//      DispatchQueue.main.async {
//        self.navigationController?.popViewController(animated: true)
//      }
      
      flowDelegate?.pickDishVC(self, pickedDishName: dish.title, dishID: dish.dishID)
    default:
      let dish = Dish()
      dish.title = customSearchController.customSearchBar.text
//      NoteV3Service.shared.updateDishReview(dishReview: dishReview, name: dish.title, dishID: nil, type: 0)
//      delegate?.reloadCollection()
//      delegate?.canAddDishReview()
//      DispatchQueue.main.async {
//        self.navigationController?.popViewController(animated: true)
//      }
      
      flowDelegate?.pickDishVC(self, pickedDishName: dish.title, dishID: dish.dishID)
    }
  }
  
  func didChangeSearchText(searchText: String, customSearchBar: CustomSearchBar) {
    isSearch = true
    // Filter the data array and get only those countries that match the search text.
    filterDishArray = dishArray.filter({ (dish) -> Bool in
      let dishText: NSString = dish.getForSearchString() as NSString
      
      return (dishText.range(of: searchText, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
    })
    if searchText == "" {
      isSearch = false
      filterDishArray = dishArray
    } else {
      isSearch = true
    }
    // Reload the tableview.
    dishSearchTableView.reloadData()
  }
  
  // MARK: - Type Definition
  typealias AddCell = V4PickDish_AddCell
  typealias DishSelectCell = V4PickDish_DishSelectCell
  typealias FlowDelegate = V4PickDishVCFlowDelegate
}

extension V4PickDishVC: UISearchBarDelegate, CustomSearchControllerDelegate {
  // 回傳自製的View放到header
  func configureCustomSearchController() -> UIView {
    // add search bar
    customSearchController = CustomSearchController(searchBarFrame: CGRect(x: 0.0,
                                                                           y: 0.0,
                                                                           width: dishSearchTableView.frame.size.width - 30,
                                                                           height: 50),
                                                    searchBarFont: UIFont(name: ".PingFangTC-Light", size: 15.0)!,
                                                    searchBarTextColor: UIColor.white,
                                                    searchBarTintColor: UIColor.white,
                                                    textFieldBackGroundColor: UIColor.white,
                                                    keyboardButtonType: .done,
                                                    keyboardButtonTitle: "Done")
    customSearchController.customSearchBar.placeholder = "這道菜名是？"
    customSearchController.customSearchBar.translatesAutoresizingMaskIntoConstraints = false
    // add separate line
    let downLineView = UIView()
    downLineView.translatesAutoresizingMaskIntoConstraints = false
    downLineView.backgroundColor = DishRankColor.lightBrownColor
    // add container view
    let view = UIView()
    view.backgroundColor = .white
    view.addSubview(customSearchController.customSearchBar)
    view.addSubview(downLineView)
    // 設定constraint
    let views = [
      "customSearchBar": customSearchController.customSearchBar,
      "downLineView": downLineView
      ] as [String: Any]
    
    var allConstraints = [NSLayoutConstraint]()
    let customSearchBarVerticalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-[customSearchBar]",
      options: [.alignAllCenterY],
      metrics: nil,
      views: views)
    allConstraints += customSearchBarVerticalConstraints
    let lineVerticalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:[customSearchBar]-[downLineView(1)]-|",
      options: [],
      metrics: nil,
      views: views)
    allConstraints += lineVerticalConstraints
    let viewHorizontalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|-14-[customSearchBar]",
      options: [],
      metrics: nil,
      views: views)
    allConstraints += viewHorizontalConstraints
    let lineHorizontalConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|-15-[downLineView(==customSearchBar)]-14-|",
      options: [],
      metrics: nil,
      views: views)
    allConstraints += lineHorizontalConstraints
    NSLayoutConstraint.activate(allConstraints)
    customSearchController.customDelegate = self
    return view
  }
  
  // MARK: CustomSearchControllerDelegate functions
  
  func didStartSearching(customSearchBar: CustomSearchBar) {
    shouldShowSearchResults = true
    dishSearchTableView.reloadData()
  }
  
  func didTapOnSearchButton(searchText _: String, customSearchBar: CustomSearchBar) {
    if !shouldShowSearchResults {
      shouldShowSearchResults = true
      dishSearchTableView.reloadData()
    }
  }
  
  func didTapOnCancelButton(customSearchBar: CustomSearchBar) {
    shouldShowSearchResults = false
    dishSearchTableView.reloadData()
  }
  
}

protocol V4PickDishVCFlowDelegate: class {
  func pickDishVC(_ sender: V4PickDishVC, pickedDishName: String?, dishID: Int?)
}
