//
//  RestaurantListViewController.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/6/1.
//

import Foundation

import CoreLocation
import UIKit
import Alamofire
import RxSwift
import SVProgressHUD
import SwiftyJSON
import SnapKit
import MapKit

//protocol RestaurantListViewControllerDelegate: class {
//  func selectRest(restaurant: Restaurant,
//                  locationInfo: V4RestaurantPickerVC.LocationInfo?)
//  func restaurantListDismissed(locationInfo: V4RestaurantPickerVC.LocationInfo?)
//}

protocol V4RestaurantPickerVCFlowDelegate: class {
  func selectRest(restaurant: Restaurant,
                  locationInfo: V4RestaurantPickerVC.LocationInfo?)
  func restaurantListDismissed(locationInfo: V4RestaurantPickerVC.LocationInfo?)
}

class CreateRestaurantCell: UITableViewCell {
  @IBOutlet weak var newRestaurantLabel: UILabel!
  @IBOutlet weak var addButton: UIButton!
  var newRestaurantName: String?
  //weak var delegate: AddRestaurantCellDelegate?
  
  //  @IBAction func clickConfirmButton(_: UIButton) {
  //    if let restaurantName = newRestaurantName {
  //      delegate?.addNewRestaurant(restaurantName: restaurantName)
  //    }
  //  }
}

class V4RestaurantPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {
  typealias NewRestaurantCell = CreateRestaurantCell
  typealias FlowDelegate = V4RestaurantPickerVCFlowDelegate
  @IBOutlet weak var restaurantTableView: UITableView!
  @IBOutlet weak var cityTableView: UITableView!
  @IBOutlet var timeoutView: UIView!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var titleViewLayout: NSLayoutConstraint!
  @IBOutlet weak var limpidView: UIView!
  @IBOutlet weak var searchHeaderView: UIView!
  @IBOutlet weak var searchBarContainer: UIView!
  @IBOutlet weak var searchCityBarContainer: UIView!
  
  var customSearchController: CustomSearchController!
  var customSearchCityController: CustomSearchController!
  
  @IBOutlet weak var locationLabel: UILabel?
  var restaurantArray = [Restaurant]()
  var filterRestaurantArray = [Restaurant]()
  var failedGettingRestaurantArray = false
  var restaurantInHere: Restaurant?
  var lastReloadedCoordinate: CLLocationCoordinate2D? // 儲存最上次reload的座標
  public var fixedCoordinate: CLLocationCoordinate2D? // 強制指定定位位置
  private var cityCoordinate: CLLocationCoordinate2D?
  public var initialLocation: Location? // V4 初始位址
  fileprivate var fixedDistrictName: String? // 強制指定定位地區名稱 (沒使用到，還是保留，以免以後要用)
  var waitLoadingTimer: Timer?
//  var restReview: RLMRestReviewV3!
  private var fbSearchCitys = Array<CityModel>()
  weak var flowDelegate: V4RestaurantPickerVCFlowDelegate?
//  weak var dismissDelegate: ChooseRestaurantViewControllerDismissDelegate?
  private let searchCompleter = MKLocalSearchCompleter()
  private let secondSearchCompleter = MKLocalSearchCompleter()
  private var localSearch: MKLocalSearch?
  private var searchDistance: Double = 500
  static var searchDisplacementDistances: Double = 0.025
  static var searchPlaceholder: String = "Restaurant"
  static var displayDRRestaurant: Bool = false
  static var displayPrivateRestaurant: Bool = false
  
  internal var disposeBag = DisposeBag()
  
  @IBOutlet var locationServiceView: UIView!
  
  // MARK: - Object lifecyce
  static func make(flowDelegate: FlowDelegate, initialLocation: Location?) -> V4RestaurantPickerVC {
    let vc = UIStoryboard(name: "V4RestaurantPicker", bundle: nil)
              .instantiateViewController(withIdentifier: "V4RestaurantPickerVC")
              as! V4RestaurantPickerVC
    vc.flowDelegate = flowDelegate
    vc.initialLocation = initialLocation
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    restaurantTableView.delegate = self
    restaurantTableView.dataSource = self
    cityTableView.delegate = self
    cityTableView.dataSource = self
    searchCompleter.delegate = self
    secondSearchCompleter.delegate = self
    filterRestaurantArray = restaurantArray
    view.backgroundColor = .clear
    customSearchController = CustomSearchController(searchBarFrame: CGRect(x: 0.0,
                                                                           y: 0.0,
                                                                           width: restaurantTableView.frame.size.width - 30,
                                                                           height: 40),
                                                    searchBarFont: UIFont(name: ".PingFangTC-Light", size: 15.0)!,
                                                    searchBarTextColor: UIColor.white,
                                                    searchBarTintColor: UIColor.white,
                                                    textFieldBackGroundColor: UIColor.white,
                                                    keyboardButtonType: .search,
                                                    keyboardButtonTitle: "Search",
                                                    decorationStyle: .bordered(color: UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0),
                                                    inset: UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)))
    
    customSearchController.customSearchBar.placeholder = "請輸入餐廳名稱"
    customSearchController.customSearchBar.translatesAutoresizingMaskIntoConstraints = false
    
    customSearchCityController = CustomSearchController(searchBarFrame: CGRect(x: 0.0,
                                                                     y: 0.0,
                                                                     width: restaurantTableView.frame.size.width - 30,
                                                                     height: 40),
                                              searchBarFont: UIFont(name: ".PingFangTC-Light", size: 15.0)!,
                                              searchBarTextColor: UIColor.white,
                                              searchBarTintColor: UIColor.white,
                                              textFieldBackGroundColor: UIColor.white,
                                              keyboardButtonType: .search,
                                              keyboardButtonTitle: "Search",
                                              decorationStyle: .bordered(color: UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0),
                                              inset: UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)))
    customSearchCityController.customSearchBar.placeholder = "請輸入城市，地區或是國家"
    customSearchCityController.customSearchBar.translatesAutoresizingMaskIntoConstraints = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    automaticallyAdjustsScrollViewInsets = false
    
    // barUI設定
    navigationController?.navigationBar.barTintColor = .white
    navigationController?.navigationBar.tintColor = DishRankColor.darkBrownColor
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: DishRankColor.darkBrownColor]
    navigationItem.title = "選擇餐廳"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "刪除",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(cancel))
    
    // Timeout View
    timeoutView.removeFromSuperview()
    
    // Setup Location Service
    setupLocationService()
    
    if CLLocationManager.locationServicesEnabled() {
      //locationServiceView.isHidden = true
      //tableViewTopConstant.constant = 0
    } else {
      onGetLocationFailed()
    }
    
    LocationService.shared.registerStatusMessage(self,
                                                 on: nil,
                                                 font: UIFont.systemFont(ofSize: 15),
                                                 height: 60)
    
  }
  
  @IBAction func clickedReload(_ sender: Any) {
    autoCompleterSearch(at: lastReloadedCoordinate)
  }
  
  @IBAction func closeButton(_ sender: UIButton) {
    self.dismiss(animated: true, completion: {
      self.getLocationInfo(restaurant: nil, completion: { (locationInfo) in
        self.flowDelegate?.restaurantListDismissed(locationInfo: locationInfo)
      })
    })
  }
  
  @objc func cancel() {
    // 取消後刪除建立的review
    UIAlertController.show(on: self, title: "刪除此篇筆記？", message: nil, doneTitle: "確認", doneAction: {
#if false // TODO:
      NoteService.shared.deleteReview()
#endif
      self.dismiss(animated: true, completion: nil)
    }, cancelTitle: "取消", cancelAction: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    LocationService.shared.unregisterStatusMessage(self)
  }
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//    guard let coordinate = lastReloadedCoordinate else {
//      return
//    }
    let coordinate = completer.region.center
    var latitude: String? = String(coordinate.latitude)
    var longitude: String? = String(coordinate.longitude)
    if coordinate.isInvalid() {
      latitude = nil
      longitude = nil
    }
    
    failedGettingRestaurantArray = false
    
    if completer == searchCompleter {
      filterRestaurantArray.removeAll()
      
      let searchText = customSearchController.customSearchBar.text
      
#if false // TODO:
      WebService.AddRating.getRestaurants(accessToken: LoggedInUser.sharedInstance().accessToken!,
                                          latitude: latitude,
                                          longitude: longitude,
                                          filter: searchText
        ).then { [weak self] restaurants -> Void in
          
          restaurants.forEach({ (appleRestaurant) in
            if self?.filterRestaurantArray.filter({ (filterRest) -> Bool in
              appleRestaurant.address == filterRest.address
            }).count == 0 && !(appleRestaurant.address?.contains("搜索附近") ?? false) {
              self?.filterRestaurantArray.append(appleRestaurant)
            }
          })
          
          var appleRestaurants = [Restaurant]()
          
          for result in completer.results {
            let rest = Restaurant(shopID: nil,
                                  shopName: result.title,
                                  address: result.subtitle,
                                  addressSource: .apple,
                                  latitude: nil,
                                  longitude: nil,
                                  shopPhone: nil)
            appleRestaurants.append(rest)
          }
          
          
          appleRestaurants.forEach({ (appleRestaurant) in
            if self?.filterRestaurantArray.filter({ (filterRest) -> Bool in
              appleRestaurant.address == filterRest.address && appleRestaurant.shopName == filterRest.shopName
            }).count == 0 && !(appleRestaurant.address?.contains("搜索附近") ?? false) {
              self?.filterRestaurantArray.append(appleRestaurant)
            }
          })
          
          
          self?.restaurantTableView.reloadData()
        }.catch { [weak self] error in
          self?.failedGettingRestaurantArray = true
          self?.filterRestaurantArray.removeAll()
          self?.restaurantTableView.reloadData()
          
        }.always {
          let secondCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + RestaurantListViewController.searchDisplacementDistances,
                                                        longitude: coordinate.longitude)
          self.secondSearchCompleter.region = MKCoordinateRegionMakeWithDistance(secondCoordinate,
                                                                                 self.searchDistance,
                                                                                 self.searchDistance)
          
          
          self.secondSearchCompleter.queryFragment = completer.queryFragment
          
          
          SVProgressHUD.dismiss()
          self.waitLoadingTimer?.invalidate();
          self.waitLoadingTimer = nil
          self.timeoutView.removeFromSuperview()
      }
#endif
    } else {
      var appleRestaurants = [Restaurant]()
      for result in completer.results {
        let rest = Restaurant(shopID: nil,
                              shopName: result.title,
                              address: result.subtitle,
                              addressSource: .apple,
                              latitude: nil,
                              longitude: nil,
                              shopPhone: nil)
        appleRestaurants.append(rest)
      }
      
      appleRestaurants.forEach({ (appleRestaurant) in
        if self.filterRestaurantArray.filter({ (filterRest) -> Bool in
          appleRestaurant.address == filterRest.address && appleRestaurant.shopName == filterRest.shopName
        }).count == 0 && !(appleRestaurant.address?.contains("搜索附近") ?? false) {
          self.filterRestaurantArray.append(appleRestaurant)
        }
      })
      self.restaurantTableView.reloadData()
    }
  }
  
  func onGetLocationFailed() {
    /* MARK OFF: 不顯示issue #54668
     let alert = UIAlertController(title: "地點未被啟用", message: "請確保你已經准許dishrank使用你的地點，你可以前往設定檢查。", preferredStyle: .alert)
     alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
     //self.locationServiceView.isHidden = false
     //self.tableViewTopConstant.constant = 30
     }))
     alert.addAction(UIAlertAction(title: "設定", style: .default, handler: { _ in
     if let appSettings = URL(string: "app-settings:com.dishrank.ranking") {
     UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
     }
     }))
     present(alert, animated: true, completion: nil)
     */
  }
  
  func nextStep() {
    if restaurantInHere?.shopName == nil {
      let alert = UIAlertController(title: "尚未選擇餐廳", message: "請重新選擇", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
    } else {
      if let restaurant = restaurantInHere {
        getLocationInfo(restaurant: restaurant) { locationInfo in
          self.flowDelegate?.selectRest(restaurant: restaurant,
                                    locationInfo: locationInfo)
          self.dismiss(animated: true, completion: nil)
        }
      }
      
    }
  }
  
  func shouldHideAddRestaurant() -> Bool {
    let isSearchTextEmpty = customSearchController.customSearchBar.text?.isEmpty ?? true;
    
    if isSearchTextEmpty {
      return true
    }
    if failedGettingRestaurantArray {
      return false
    }
    /* MARK OFF: 改成無論有無結果都顯示
     let isSearchResultEmpty = filterRestaurantArray.isEmpty
     if !isSearchResultEmpty {
     return true
     }
     */
    return false
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
    switch tableView {
    case restaurantTableView:
      return filterRestaurantArray.count + (shouldHideAddRestaurant() ? 0 : 1)
    case cityTableView:
      return fbSearchCitys.count + 1
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch tableView {
    case restaurantTableView:
      let index = indexPath.row - (shouldHideAddRestaurant() ? 0 : 1)
      if shouldHideAddRestaurant() || indexPath.row != 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantListCell", for: indexPath)
        if let cell = cell as? RestaurantListCell,
          let restaurant = filterRestaurantArray.at(index) {
          cell.restaurantNameLabel.text = restaurant.shopName
          if let address = restaurant.address {
            if address == "" {
              cell.restaurantLocationLabel.text = "\(address)"
            } else {
              cell.restaurantLocationLabel.text = "．\(address)"
            }
          }
          
          // 判斷私房, DR餐廳icon是否要顯示
          cell.dishRankImageView.isHidden = true
          cell.drImageView.isHidden = true
          
          if restaurant.src == "dr" && V4RestaurantPickerVC.displayDRRestaurant {
            cell.dishRankImageView.isHidden = false
            cell.drImageView.isHidden = false
            cell.privateOrDRLabel.text = "尋味推薦"
          } else if restaurant.src != "apple"  {
            if let isSelfCreated = restaurant.isSelfCreated {
              if isSelfCreated && V4RestaurantPickerVC.displayPrivateRestaurant {
                // 是私房顯示icon
                cell.dishRankImageView.isHidden = false
                cell.privateOrDRLabel.text = "私房餐廳"
              }
            }
          }
          
          // 顯示公里數
          let distance = restaurant.distance
          if distance > 1000 {
            cell.distanceLabel.text = String(format: "%.1f公里", Float(distance) / 1000)
          } else {
            cell.distanceLabel.text = "\(distance)公尺"
          }
        }
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateRestaurantCell", for: indexPath)
        
        if let cell = cell as? NewRestaurantCell {
          //        cell.addButton.cornerRadius = cell.addButton.frame.width / 2
          
          // 虛線
          //        let addButtonBorder = CAShapeLayer()
          //        addButtonBorder.strokeColor = DishRankColor.darkBrownColor.cgColor
          //        addButtonBorder.lineDashPattern = [2, 2]
          //        addButtonBorder.frame = cell.addButton.bounds
          //        addButtonBorder.fillColor = nil
          //        addButtonBorder.path = UIBezierPath(rect: cell.addButton.bounds).cgPath
          //        cell.addButton.layer.addSublayer(addButtonBorder)
          
          //cell.delegate = self
          
          if customSearchController != nil,
            let searchText = customSearchController.customSearchBar.text {
            
            let message = filterRestaurantArray.isEmpty ? "找不到相關的搜尋結果?"
              : "找不到相關的搜尋結果?"
            cell.newRestaurantLabel.text = message
            cell.newRestaurantName = searchText
          }
        }
        return cell
      }
    case cityTableView:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentLocationCell", for: indexPath)
        return cell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityLocationCell", for: indexPath) as! RestaurantListCityTableViewCell
        let row = indexPath.row - 1
        let fbSearchCity = fbSearchCitys[row]
        cell.cityNameLabel.text = fbSearchCity.name + ", " + fbSearchCity.countryName
        return cell
      }
      
    default:
      return UITableViewCell()
    }

  }
  
  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return 60
  }
  func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
    if tableView == restaurantTableView {
      return configureCustomSearchController()
    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
    /* MARK OFF: for new style
     if (LocationService.shared.authorizationStatus != .authorizedAlways
     && LocationService.shared.authorizationStatus != .authorizedWhenInUse)
     || !CLLocationManager.locationServicesEnabled() {
     return 90
     } else {
     return 100
     }
     */
    if tableView == restaurantTableView {
      return 100
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch tableView {
    case restaurantTableView:
      let index = indexPath.row - (shouldHideAddRestaurant() ? 0 : 1)
      if shouldHideAddRestaurant() || indexPath.row != 0 {
        restaurantInHere = filterRestaurantArray.at(index)
        nextStep()
      } else {
        let vc = AddRestaurantVC.make(delegate: self,
                                      initialName: customSearchController.customSearchBar.text)
        present(vc, animated: true, completion: nil)
      }
    case cityTableView:
      customSearchCityController.customSearchBar.layer.sublayers?
        .forEach{
          if let shape = $0 as? CAShapeLayer {
            shape.strokeColor = UIColor(red: 186/255,
                                        green: 143/255,
                                        blue: 92/255,
                                        alpha: 1.0).cgColor
          }
      }
      if indexPath.row == 0 {
        customSearchCityController.customSearchBar.text = "使用目前所在位置"
        cityCoordinate = LocationService.shared.coordinate
        customSearchCityController.customSearchBar.resignFirstResponder()
        
        cityTableView.isHidden = true
      } else {
        let row = indexPath.row - 1
        let fbSearchCity = fbSearchCitys[row]
        
        do {
          let jsonEncoder = JSONEncoder()
          let jsonData = try jsonEncoder.encode(fbSearchCity)
          let json = String(data: jsonData, encoding: String.Encoding.utf8)
          let currentCitysHistory = UserDefaults.standard.string(forKey: "citysHistory")
          if let cityJson = json {
            if currentCitysHistory?.range(of: cityJson) == nil { //判斷object是否有存過
              if currentCitysHistory == nil {
                UserDefaults.standard.set("\(cityJson)", forKey: "citysHistory")
              } else {
                UserDefaults.standard.set("\(cityJson), \(currentCitysHistory ?? "")", forKey: "citysHistory")
              }
            }
          }
        } catch let e {
          print(e)
        }
      
        customSearchCityController.customSearchBar.text = fbSearchCity.name + ", " + fbSearchCity.countryName
        
        searchCityCoordinate(cityName: fbSearchCity.name + ", " + fbSearchCity.countryName)
      }
    default:
      break
    }
  }
  
  func addRestaurant(restaurantName: String?) {
    if let shopName = restaurantName {
      self.restaurantInHere = Restaurant()
      self.restaurantInHere?.shopName = shopName
      self.nextStep()
      /* MARK OFF: 不再由呼叫建立餐廳的API
       WebService.AddRating.createRestaurant(accessToken: accessToken,
       shopName: shopName).then(execute: { (json) -> Void in
       if json["statusCode"].intValue == 0 {
       self.restaurantInHere = Restaurant()
       self.restaurantInHere?.shopID = json["shopID"].intValue
       self.restaurantInHere?.shopName = shopName
       self.nextStep()
       }
       }).catch(execute: { error in
       self.restaurantInHere = Restaurant()
       self.restaurantInHere?.shopName = shopName
       self.nextStep()
       print(error.localizedDescription)
       })
       */
    }
  }
  
  func getRestaurantList(at coordinate: CLLocationCoordinate2D? = nil) {
    // lastReloadedCoordinate == nil 是因為 getCoordinate會執行很多次, 但我們只要執行一次
    guard let coordinate = cityCoordinate ?? fixedCoordinate ?? coordinate ?? LocationService.shared.coordinate, lastReloadedCoordinate == nil
      else { restaurantTableView.reloadData(); return }
    lastReloadedCoordinate = coordinate
    autoCompleterSearch(at: coordinate)
  }
  
  private func autoCompleterSearch(at coordinate: CLLocationCoordinate2D? = nil) {
    guard let coordinate = cityCoordinate ?? fixedCoordinate ?? coordinate ?? LocationService.shared.coordinate
      else { restaurantTableView.reloadData(); return }
    
    SVProgressHUD.show(withStatus: "正在探索周邊餐廳")
    timeoutView.removeFromSuperview()
    
    waitLoadingTimer?.invalidate(); waitLoadingTimer = nil
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.testConnection(url: "http://www.google.com", threshold: 2, completion: { (connectionGood) in
        if !connectionGood,
          self.waitLoadingTimer?.isValid == true {
          SVProgressHUD.setBackgroundColor(.white)
          SVProgressHUD.dismiss()
#if false // TODO:
          SVProgressHUD.show(UIImage(named: "warn_internet")!, status: nil)
#endif
          SVProgressHUD.setImageViewSize(CGSize(width: 150, height: 150))
        }
      })
    }
    
    waitLoadingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (_) in
      SVProgressHUD.dismiss()
      self.waitLoadingTimer?.invalidate(); self.waitLoadingTimer = nil
      
      self.showTimeoutView()
    })
    
    self.lastReloadedCoordinate = coordinate
    
    searchCompleter.region = MKCoordinateRegionMakeWithDistance(coordinate, searchDistance, searchDistance)
    searchCompleter.queryFragment = V4RestaurantPickerVC.searchPlaceholder
  }
  
  private func showTimeoutView() {
    timeoutView.removeFromSuperview()
    
    timeoutView.frame = view.bounds
    view.addSubview(timeoutView)
  }
  /*
   @IBAction func clickOpenPositioningButton(_: UIButton) {
   locationServiceView.isHidden = true
   tableViewTopConstant.constant = 0
   
   if let appSettings = URL(string: "app-settings:com.dishrank.ranking") {
   UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
   }
   }
   
   @IBAction func clickCloseLocationPromptButton(_: UIButton) {
   locationServiceView.isHidden = true
   tableViewTopConstant.constant = 0
   }
   */
  func evaluateConnectionTime(url: String, threshold: TimeInterval, completion: @escaping ((TimeInterval?) -> Void)) {
    guard let url = URL(string: url)
      else {
        completion(nil)
        return
    }
    
    let timer = Timer.scheduledTimer(withTimeInterval: threshold, repeats: false, block: { _ in
      completion(threshold)
    })
    
    let startDate = Date()
#if false // TODO:
    Alamofire.request(url, method: .get).responseData().then { _ -> Void in
      let endDate = Date()
      let timeInterval = endDate.timeIntervalSince(startDate)
      if timer.isValid {
        completion(timeInterval)
      }
      timer.invalidate()
      
      }.catch { _ in
        if timer.isValid {
          completion(nil)
        }
        timer.invalidate()
    }
#endif
  }
  
  func testConnection(url: String, threshold: TimeInterval, completion: @escaping ((Bool) -> Void)) {
    evaluateConnectionTime(url: url, threshold: threshold) { (timeInterval) in
      if let timeInterval = timeInterval {
        completion(timeInterval < threshold)
      } else {
        completion(false)
      }
    }
  }
  
}

@objc extension V4RestaurantPickerVC: UISearchBarDelegate, CustomSearchControllerDelegate {
  
  func configureCustomSearchController() -> UIView {
    
    customSearchController.customDelegate = self
    customSearchCityController.customDelegate = self
    
    let iconView = UIImageView.init(image: UIImage(named: "search"))
    customSearchController.customSearchBar.setLeftView(iconView)
    customSearchController.customSearchBar.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
    
    let searchCityIcon = UIImageView.init(image: UIImage(named: "locationSearchbar"))
    customSearchCityController.customSearchBar.setLeftView(searchCityIcon)
    customSearchCityController.customSearchBar.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
    
    
    if customSearchController.customSearchBar.superview == nil {
      searchBarContainer.addSubview(customSearchController.customSearchBar)
      customSearchController.customSearchBar.snp.makeConstraints {
        $0.edges.equalToSuperview()
      }
    }
    
    if customSearchCityController.customSearchBar.superview == nil {
      searchCityBarContainer.addSubview(customSearchCityController.customSearchBar)
      customSearchCityController.customSearchBar.snp.makeConstraints {
        $0.edges.equalToSuperview()
      }
    }
    
    
    
    return searchHeaderView
  }
  
  /* MARK OFF: 改用storyboard
   // 回傳自製的View放到header
   func configureCustomSearchController() -> UIView {
   // add separate line
   let middleLineView = UIView()
   middleLineView.translatesAutoresizingMaskIntoConstraints = false
   middleLineView.backgroundColor = DishRankColor.lightBrownColor
   middleLineView.isHidden = true // 不顯示分隔線
   // add location label
   if locationLabel == nil {
   locationLabel = UILabel()
   locationLabel?.text = "目前以---進行搜尋"
   locationLabel?.textColor = DishRankColor.lightBrownColor
   locationLabel?.font = UIFont.systemFont(ofSize: 14)
   locationLabel?.translatesAutoresizingMaskIntoConstraints = false
   }
   updateLocationLabel()
   
   // add separate line
   let bottomLineView = UIView()
   bottomLineView.translatesAutoresizingMaskIntoConstraints = false
   bottomLineView.backgroundColor = .lightGray
   // add container view
   let view = UIView()
   view.backgroundColor = .white
   view.addSubview(customSearchController.customSearchBar)
   view.addSubview(middleLineView)
   if let locationLabel = locationLabel {
   view.addSubview(locationLabel)
   }
   view.addSubview(bottomLineView)
   
   guard let locationLabel = locationLabel else { return view }
   
   // 設定constraint
   let views = [
   "customSearchBar": customSearchController.customSearchBar,
   "middleLineView": middleLineView,
   "locationLabel": locationLabel,
   "bottomLineView": bottomLineView
   ] as [String: Any]
   
   var allConstraints = [NSLayoutConstraint]()
   let lineVerticalConstraints = NSLayoutConstraint.constraints(
   withVisualFormat: "V:|-[customSearchBar(40)]-[middleLineView(1)]-[locationLabel]-[bottomLineView(1)]-|",
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
   withVisualFormat: "H:|-15-[middleLineView(==customSearchBar)]-15-|",
   options: [],
   metrics: nil,
   views: views)
   allConstraints += lineHorizontalConstraints
   let locationLabelHorizontalConstraints = NSLayoutConstraint.constraints(
   withVisualFormat: "H:|-15-[locationLabel]-15-|",
   options: [],
   metrics: nil,
   views: views)
   allConstraints += locationLabelHorizontalConstraints
   let bottomLineHorizontalConstraints = NSLayoutConstraint.constraints(
   withVisualFormat: "H:|[bottomLineView]|",
   options: [],
   metrics: nil,
   views: views)
   allConstraints += bottomLineHorizontalConstraints
   NSLayoutConstraint.activate(allConstraints)
   customSearchController.customDelegate = self
   return view
   }
   */
  
  // MARK: CustomSearchControllerDelegate functions
  
  func didStartSearching(customSearchBar: CustomSearchBar) {
    switch customSearchBar {
    case customSearchController.customSearchBar:
      customSearchController.customSearchBar
        .setLeftViewMode(.never)
      cityTableView.isHidden = true
    case customSearchCityController.customSearchBar:
      customSearchCityController.customSearchBar
        .setLeftViewMode(.never)
      getSearchCitysHistory()
      cityTableView.isHidden = false
    default:
      break
    }
    
    if self.titleViewLayout.multiplier >= 252.5/333.5 {
      UIView.animate(withDuration: 0.5) {
        self.titleViewLayout.constant -= self.limpidView.frame.size.height - 31
        self.view.layoutSubviews()
      }
    }
  }
  
  func didEndSearching(customSearchBar: CustomSearchBar) {
    switch customSearchBar {
    case customSearchController.customSearchBar:
      customSearchController.customSearchBar
        .setLeftViewMode(.always)
    case customSearchCityController.customSearchBar:
      customSearchCityController.customSearchBar
        .setLeftViewMode(.always)
      guard
        let coordinate = cityCoordinate ?? fixedCoordinate ?? LocationService.shared.coordinate
        else {
          filterRestaurantArray = restaurantArray
          restaurantTableView.reloadData()
          return
      }
      
      var appleSearchText = ""
      appleSearchText = (customSearchController.customSearchBar.text ?? V4RestaurantPickerVC.searchPlaceholder) == "" ? V4RestaurantPickerVC.searchPlaceholder : appleSearchText
      
      
      searchCompleter.region = MKCoordinateRegionMakeWithDistance(coordinate, searchDistance, searchDistance)
      searchCompleter.queryFragment = appleSearchText
//      searchRestaurants(appleSearchText: appleSearchText,
//                        drSearchText: customSearchController.customSearchBar.text ?? "",
//                        center: coordinate)
    default:
      break
    }
  }
  
  func didTapOnCancelButton(customSearchBar: CustomSearchBar) {
    switch customSearchBar {
    case customSearchController.customSearchBar:
      restaurantTableView.reloadData()
    case customSearchCityController.customSearchBar:
      getSearchCitysHistory()
      restaurantTableView.reloadData()
    default:
      break
    }
  }
  
  func didTapOnSearchButton(searchText: String,
                            customSearchBar: CustomSearchBar) {
    switch customSearchBar {
    case customSearchController.customSearchBar:
      guard
        let coordinate = cityCoordinate ?? fixedCoordinate ?? LocationService.shared.coordinate
        else {
          filterRestaurantArray = restaurantArray
          restaurantTableView.reloadData()
          return
      }
      
      lastReloadedCoordinate = coordinate
      
      if searchText != "" {
        searchRestaurants(appleSearchText: searchText,
                          drSearchText: searchText,
                          center: coordinate)
      }
    case customSearchCityController.customSearchBar:
      break
    default:
      break
    }
  }
  
  func didChangeSearchText(searchText: String,
                           customSearchBar: CustomSearchBar) {
    
    if customSearchBar.text != "" {
      customSearchBar.layer.sublayers?
        .forEach{
          if let shape = $0 as? CAShapeLayer {
            shape.strokeColor = UIColor(red: 186/255,
                                        green: 143/255,
                                        blue: 92/255,
                                        alpha: 1.0).cgColor
          }
      }
    } else {
      customSearchBar.layer.sublayers?
        .forEach{
          if let shape = $0 as? CAShapeLayer {
            shape.strokeColor = UIColor(red: 155/255,
                                        green: 155/255,
                                        blue: 155/255,
                                        alpha: 1.0).cgColor
          }
      }
    }
    
    
    switch customSearchBar {
    case customSearchController.customSearchBar:
      guard
        let coordinate = cityCoordinate ?? fixedCoordinate ?? LocationService.shared.coordinate
        else {
          filterRestaurantArray = restaurantArray
          restaurantTableView.reloadData()
          return
      }
      
      
      lastReloadedCoordinate = coordinate
      searchCompleter.region = MKCoordinateRegionMakeWithDistance(coordinate, searchDistance, searchDistance)
      
      if searchText.count > 0 {
        searchCompleter.queryFragment = searchText
      } else{
        searchCompleter.queryFragment = V4RestaurantPickerVC.searchPlaceholder

      }
    case customSearchCityController.customSearchBar:
      cityCoordinate = nil
      if searchText == "" {
        getSearchCitysHistory()
      } else {
        searchCitys(citySearchText: searchText)
      }
    default:
      break
    }
  }
  
  func searchCityCoordinate(cityName: String) {
    SVProgressHUD.show()
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = cityName
    
    let completionHandler: MKLocalSearchCompletionHandler = { [weak self] response, error in
      guard let this = self else {
        return
      }
      if let response = response {
        if response.mapItems.count != 0 {
          self?.cityCoordinate = response.mapItems[0].placemark.coordinate
          
          self?.customSearchCityController.customSearchBar.resignFirstResponder()
          self?.cityTableView.isHidden = true
        }
      }
      SVProgressHUD.dismiss()
      this.waitLoadingTimer?.invalidate();
      this.waitLoadingTimer = nil
      this.timeoutView.removeFromSuperview()
    }
    
    if self.localSearch != nil {
      localSearch = nil
    }
    
    localSearch = MKLocalSearch(request: request)
    if let localSearch = self.localSearch {
      localSearch.start(completionHandler: completionHandler)
    }
  }
  
  func searchRestaurants(appleSearchText: String,
                         drSearchText: String,
                         center: CLLocationCoordinate2D) {
    let newRegion = MKCoordinateRegionMakeWithDistance(center, searchDistance, searchDistance)
    let request = MKLocalSearchRequest()
    request.naturalLanguageQuery = appleSearchText
    request.region = newRegion
    
    let completionHandler: MKLocalSearchCompletionHandler = { [weak self] response, error in
#if false // TODO:
      WebService.AddRating.getRestaurants(accessToken: LoggedInUser.sharedInstance().accessToken!,
                                          latitude: center.latitude.description,
                                          longitude: center.longitude.description,
                                          filter: drSearchText
        ).then { [weak self] restaurants -> Void in

          self?.filterRestaurantArray.removeAll()
          self?.filterRestaurantArray.append(contentsOf: restaurants)
          
          if let actualError = error as NSError? {

          } else {
            var appleRestaurants = [Restaurant]()
            for result in response!.mapItems {
              let rest = Restaurant(shopID: nil,
                                    shopName: result.name ?? "",
                                    address: result.placemark.title ?? "",
                                    addressSource: .apple,
                                    latitude: result.placemark.coordinate.latitude.description,
                                    longitude: result.placemark.coordinate.longitude.description,
                                    shopPhone: result.phoneNumber)
              appleRestaurants.append(rest)
            }
            
            appleRestaurants.forEach({ (appleRest) in
              if self?.filterRestaurantArray.filter({ (filterRest) -> Bool in
                appleRest.address == filterRest.address
              }).count == 0 && !(appleRest.address?.contains("搜索附近") ?? false) {
                self?.filterRestaurantArray.append(appleRest)
              }
            })
            
          }
          self?.restaurantTableView.reloadData()
        }.catch { [weak self] error in
          self?.failedGettingRestaurantArray = true
          self?.filterRestaurantArray.removeAll()
          self?.restaurantTableView.reloadData()
          /* 不顯示失敗提示
           let alert = UIAlertController(title: "餐廳列表讀取失敗", message: "\(error.localizedDescription)",
           preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (_: UIAlertAction!) in
           self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
           }))
           self?.present(alert, animated: true, completion: nil)
           */
        }.always {
          SVProgressHUD.dismiss()
          self?.waitLoadingTimer?.invalidate();
          self?.waitLoadingTimer = nil
          self?.timeoutView.removeFromSuperview()
      }
#endif
    }
    
    if self.localSearch != nil {
      localSearch = nil
    }
    
    self.filterRestaurantArray.removeAll()
    localSearch = MKLocalSearch(request: request)
    if let localSearch = self.localSearch {
      localSearch.start(completionHandler: completionHandler)
    }
  }
  
  func getSearchCitysHistory() {
    do {
      let currentCitysHistory = "[" + (UserDefaults.standard.string(forKey: "citysHistory") ?? "") + "]"
      let currentCitysHistoryData = currentCitysHistory.data(using: String.Encoding.utf8)
      let jsonDecoder = JSONDecoder()
      fbSearchCitys = try jsonDecoder.decode([CityModel].self, from: currentCitysHistoryData ?? Data())
      cityTableView.reloadData()
    } catch let e {
      print(e)
    }
  }
  
  func searchCitys(citySearchText: String) {
#if false // TODO:
    WebService.AddRating.getCitys(type: "adgeolocation",
                                  limit: 1000,
                                  accessToken: "EAAEOwkE6TeQBAC1SPNz0kYVKCUdjP9eJGUOXFzPQCwZB7b0t0tZCkwAeJpzwxCO0XW0ijLRrs90ZCDJsxEJ5qKJstKGZAwPha08zKemwID8inwtlRcb7G73k1ne4YHmiZB4dpVLIsp8TDmT0BMsLQX50NMR71vXiGXBzfBsAXwvCw4JcQYurt5LedU6slSRAZD",
                                  locale: "zh_TW",
                                  q: citySearchText).then { [unowned self] (json) -> Void in
                                    let jsonDecoder = JSONDecoder()
                                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                                    do{
                                      let cityArray = try jsonDecoder.decode(FBSearchCityModel.self,
                                                                             from: json.rawData())
                                      self.fbSearchCitys = cityArray.data
                                      DispatchQueue.main.async { [unowned self] in
                                        self.cityTableView.reloadData()
                                      }
                                    } catch let e {
                                      print(e)
                                    }
                                    
                                    
                                    
    }
#endif
  }
}

//@objc extension RestaurantListViewController: NewRestaurantCellDelegate, AddRestaurantCellDelegate {
//
//  func addNewRestaurant(restaurantName: String) {
//    restaurantInHere = Restaurant()
//    restaurantInHere?.shopName = restaurantName
//    addRestaurant(restaurantName: restaurantName)
//  }
//
//  func changeCell() {
//    restaurantTableView.reloadData()
//  }
//
//}

// MARK: - Location Service
extension V4RestaurantPickerVC {
  
  struct LocationInfo {
    var districtName: String?
    var coordinate: CLLocationCoordinate2D?
  }
  
  func setupLocationService() {
    LocationService.shared.authorizationStatusSubject
      .subscribe { [weak self] in
        guard let status = $0.element else { return }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
          self?.lastReloadedCoordinate = nil // clear last coordinate so we can reload when GPS enabled
          LocationService.shared.manager.startUpdatingLocation()
        case .notDetermined, .restricted, .denied:
          self?.onGetLocationFailed()
        }
      }.disposed(by: disposeBag)
    
    LocationService.shared.coordinateSubject
      .subscribe { [weak self] in
        self?.getRestaurantList(at: $0.element)
      }.disposed(by: disposeBag)
    
    LocationService.shared.districtNameSubject
      .subscribe { [weak self] _ in
        guard self?.isViewLoaded == true else { return }
        self?.updateLocationLabel()
      }.disposed(by: disposeBag)
    
    LocationService.shared.requestWhenInUseAuthorization()
    
    LocationService.shared.updateDistrictName()
    
    updateLocationLabel()
    
    if let fixedCoordinate = fixedCoordinate {
      LocationService.shared.getDistrictName(for: fixedCoordinate) { [weak self] districtName in
        self?.fixedDistrictName = districtName
        //self?.locationLabel?.text = "目前以\(self?.fixedDistrictName ?? "---")進行搜尋"
      }
    }
    
  }
  
  func updateLocationLabel() {
    if let fixedCoordinate = fixedCoordinate,
      LocationService.shared.isDefaultCoordinate(fixedCoordinate) == false {
      customSearchCityController.customSearchBar.placeholder = "目前以照片位置為中心"
      locationLabel?.text = "目前以照片位置為中心"
    } else if LocationService.shared.isDefaultCoordinate() {
      customSearchCityController.customSearchBar.placeholder = "目前以台北市為中心"
      locationLabel?.text = "目前以台北市為中心"
    } else if LocationService.shared.coordinate?.isInvalid() == false {
      if LocationService.shared.locationServiceAccessible() == false {
        if LocationService.shared.districtName?.isEmpty != true {
          customSearchCityController.customSearchBar.placeholder = "目前以\(LocationService.shared.districtName ?? "---")進行搜尋"
          locationLabel?.text = "目前以\(LocationService.shared.districtName ?? "---")進行搜尋"
        } else {
          customSearchCityController.customSearchBar.placeholder = "目前以上次位置進行搜尋"
          locationLabel?.text = "目前以上次位置進行搜尋"
        }
      } else {
        customSearchCityController.customSearchBar.placeholder = "目前以GPS位置為中心"
        locationLabel?.text = "目前以GPS位置為中心"
      }
    } else {
      customSearchCityController.customSearchBar.placeholder = "目前以台北市為中心"
      locationLabel?.text = "目前以台北市為中心"
    }
  }
  
  func getLocationInfo(restaurant: Restaurant?,
                       completion: @escaping ((LocationInfo?) -> Void)) {
    
    
    var coordinate: CLLocationCoordinate2D?
    
    if let latitudeString = restaurant?.latitude,
      let longitudeString = restaurant?.longtitude,
      let latitude = Double(latitudeString),
      let longitude = Double(longitudeString) {
      coordinate = CLLocationCoordinate2D(latitude: latitude,
                                          longitude: longitude)
    } else if let fixedCoordinage = fixedCoordinate {
      coordinate = fixedCoordinage
    } else if LocationService.shared.coordinate?.isInvalid() == false,
      let gpsCoordinate = LocationService.shared.coordinate {
      coordinate = gpsCoordinate
    }
    
    if let coordinate = coordinate {
      LocationService.shared.getDistrictName(for: coordinate) { (districtName) in
        if let districtName = districtName {
          let info = LocationInfo(districtName: districtName,
                                  coordinate: coordinate)
          completion(info)
        } else {
          completion(nil)
        }
      }
    } else {
      completion(nil)
    }
  }
  
}

// MARK: - AddRestaurantVC Delegate
extension V4RestaurantPickerVC: AddRestaurantVC.Delegate {
  func addRestaurantVC(sender: AddRestaurantVC, addedRestaurntWith info: AddRestaurantVM.RestaurantInfo) {
    restaurantInHere = Restaurant()
    restaurantInHere?.shopName = info.name
    restaurantInHere?.country = info.country
    restaurantInHere?.city = info.city
    restaurantInHere?.address = info.address
    restaurantInHere?.addressSource = .manual
    restaurantInHere?.shopPhone = info.phoneNumber
    nextStep()
  }
}


