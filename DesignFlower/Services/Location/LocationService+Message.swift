//
//  LocationService+Message.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/5/21.
//

import UIKit
import CoreLocation

extension LocationService {
  /**
   * param viewController - Owner of status message observer.
   * param view - view to put message on. If nil, shows on window.
   */
  public func registerStatusMessage(_ viewController: UIViewController, on view: UIView?, font: UIFont = UIFont.systemFont(ofSize: 13),  height: CGFloat = 30) {
    let observer = StatusMessageObserver(viewController: viewController, view: view, font: font, height: height)
    statusMessageObservers.append(observer)
    updateStatusMessage()
  }

  public func unregisterStatusMessage(_ viewController: UIViewController) {
    if let observer = statusMessageObservers.filter({ $0.viewController === viewController }).first {
      clearStatusMessage(for: observer)
    }
    statusMessageObservers = statusMessageObservers.filter { !($0.viewController === viewController) }
  }

  private func postStatusMessage(_ message: String) {
    for observer in statusMessageObservers {
      guard let viewController = observer.viewController
      else { continue }
      
      let view = observer.view ?? ((UIApplication.shared.delegate?.window)!)!

      TipBar.showTip(for: viewController,
                     on: view,
                     message: message,
                     font: observer.font,
                     iconName: "icon_location_w",
                     height: observer.height,
                     duration: 4,
                     isMakeConstrains: observer.view != nil) {
        if CLLocationManager.locationServicesEnabled() && false {
          if let authorizeSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(authorizeSettingsURL, options: [:], completionHandler: nil)
          }
        } else {
          //if let locationSettingsURL = URL(string: "App-Prefs:root=Privacy&path=LOCATION") { // this path not working on iOS 11
          if let locationSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(locationSettingsURL, options: [:], completionHandler: nil)
          }
        }

      }
    }
  }

  private func clearStatusMessage(for observer: StatusMessageObserver) {
    if let viewController = observer.viewController {
      TipBar.clearTip(for: viewController)
    }
  }

  internal func updateStatusMessage() {
    if authorizationStatus == .notDetermined
       || authorizationStatus == .restricted
       || authorizationStatus == .denied
       || !CLLocationManager.locationServicesEnabled() {
      postStatusMessage("選擇開啟定位服務")
    } else {
      for observer in statusMessageObservers {
        clearStatusMessage(for: observer)
      }
    }
  }

  internal class StatusMessageObserver {
    weak var viewController: UIViewController?
    weak var view: UIView?
    let font: UIFont
    let height: CGFloat

    init(viewController: UIViewController, view: UIView?, font: UIFont, height: CGFloat) {
      self.viewController = viewController
      self.view = view
      self.font = font
      self.height = height
    }
  }
}
