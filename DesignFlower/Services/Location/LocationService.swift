//
//  LocationService.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/5/18.
//

import Foundation
import CoreLocation
import SwiftLocation
import RxSwift

open class LocationService: NSObject {

  private static let lastCoordinateLatitudeKey = "LocationService.lastCoordinateLatitude"
  private static let lastCoordinateLongitudeKey = "LocationService.lastCoordinateLongitude"

  public static let shared = LocationService()

  public var manager = CLLocationManager()

  public var coordinate: CLLocationCoordinate2D?
  public var coordinateSubject = BehaviorSubject<CLLocationCoordinate2D>(value: CLLocationCoordinate2D.init(latitude: 0, longitude: 0))

  public var districtName: String?
  public var districtNameSubject = BehaviorSubject<String>(value: "")

  public var authorizationStatus: CLAuthorizationStatus?
  public var authorizationStatusSubject = BehaviorSubject<CLAuthorizationStatus>(value: .notDetermined)

  public var locationError: Error?
  public var locationErrorSubject = PublishSubject<Error>()

  private var disposeBag = DisposeBag()

  public var defaultCoordinate: CLLocationCoordinate2D?

  static public let coordinateTaipei = CLLocationCoordinate2D(latitude: 25.032997, longitude: 121.563993)

  internal var statusMessageObservers: [StatusMessageObserver] = []

  // MARK: - Initializations

  override init() {
    super.init()
    manager.delegate = self
    manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
    manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

    coordinateSubject
      .bind {
        self.coordinate = $0
      }.disposed(by: disposeBag)

    districtNameSubject
      .bind {
        self.districtName = $0
      }.disposed(by: disposeBag)

    authorizationStatusSubject
      .bind {
        self.authorizationStatus = $0
      }.disposed(by: disposeBag)

    locationErrorSubject
      .bind {
        self.locationError = $0
      }.disposed(by: disposeBag)

    // location -> districtName
    coordinateSubject
      .subscribe { (_) in
        self.updateDistrictName()
      }.disposed(by: disposeBag)
  }

  // MARK: - Authorization

  public func requestWhenInUseAuthorization() {
    manager.requestWhenInUseAuthorization()
  }

  // MARK: - District Name

  public func updateDistrictName() {
    guard let coordinate = coordinate else { return }

    getDistrictName(for: coordinate) { districtName in
      self.districtNameSubject.onNext(districtName ?? "")
    }
  }
  
  public func getDistrictName(for coordinate: CLLocationCoordinate2D,
                              completion: @escaping ((String?) -> ())) {
    Locator.location(fromCoordinates: coordinate, onSuccess: { (places) -> (Void) in
      if let place = places.first,
         let districtName = place.administrativeArea {
        completion(districtName)
      } else {
        completion(nil)
      }
    }) { (error) -> (Void) in
      completion(nil)
    }
  }

  // MARK: - UserDefault Storage

  func getLastStoredCoordinate() -> CLLocationCoordinate2D {
    if UserDefaults.standard.object(forKey: LocationService.lastCoordinateLatitudeKey) != nil
      && UserDefaults.standard.object(forKey: LocationService.lastCoordinateLongitudeKey) != nil {
      let latitude = UserDefaults.standard.double(forKey: LocationService.lastCoordinateLatitudeKey)
      let longitude = UserDefaults.standard.double(forKey: LocationService.lastCoordinateLongitudeKey)
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else if let defaultCoordinate = defaultCoordinate {
      return defaultCoordinate
    } else {
      return LocationService.coordinateTaipei
    }
  }

  func storeCoordinate(_ coordinate: CLLocationCoordinate2D) {
    UserDefaults.standard.set(coordinate.latitude, forKey: LocationService.lastCoordinateLatitudeKey)
    UserDefaults.standard.set(coordinate.longitude, forKey: LocationService.lastCoordinateLongitudeKey)
  }

}

// MARK: - CLLocation Manager Delegate

extension LocationService: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager,
                              didChangeAuthorization status: CLAuthorizationStatus) {
    authorizationStatusSubject.onNext(status)

    if !CLLocationManager.locationServicesEnabled() {
      coordinateSubject.onNext(getLastStoredCoordinate()) // case 1: 定位沒開，使用上次(或預設)位置
    } else {
      switch status {
      case .notDetermined, .restricted, .denied:
        coordinateSubject.onNext(getLastStoredCoordinate()) // case 2: 定位沒有授權，使用上次(或預設)位置
      case .authorizedAlways, .authorizedWhenInUse:
        break
      }
    }

    updateStatusMessage()
  }

  public func locationManager(_ manager: CLLocationManager,
                              didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      coordinateSubject.onNext(location.coordinate)
      storeCoordinate(location.coordinate)
    }
  }

  public func locationManager(_ manager: CLLocationManager,
                              didFailWithError error: Error) {
    locationErrorSubject.onNext(error)
  }

  public func locationManager(_ manager: CLLocationManager,
                              didFinishDeferredUpdatesWithError error: Error?) {
    if let error = error {
      locationErrorSubject.onNext(error)
    }
  }
  
  func locationServiceAccessible() -> Bool {
    if CLLocationManager.locationServicesEnabled() == false
       || (LocationService.shared.authorizationStatus != .authorizedAlways
           && LocationService.shared.authorizationStatus != .authorizedWhenInUse) {
      return false
    }
    return true
  }
  
  func isDefaultCoordinate() -> Bool {
    guard let coordinate = coordinate else { return false }
    return LocationService.shared.isDefaultCoordinate(coordinate)
  }
  
  func isDefaultCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
    guard let defaultCoordinate = defaultCoordinate else { return false }
    
    return coordinate.latitude == defaultCoordinate.latitude
          && coordinate.longitude == defaultCoordinate.longitude
  }
}

extension CLLocationCoordinate2D {
  func isInvalid() -> Bool {
    return latitude == 0 && longitude == 0
  }
}
