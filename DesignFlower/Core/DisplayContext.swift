//
//  DisplayContext.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit

enum DisplayContext {
  case embed(vc: UIViewController, on: UIView)
  case present(vc: UIViewController, animated: Bool,
               style: UIModalPresentationStyle)
  case push(vc: UIViewController, animated: Bool)
  
  func display(_ viewController: UIViewController,
               completion: (() -> ())? = nil) {
    switch self {
    case .embed(let sourceVC, let view):
      viewController.view.frame = view.bounds
      view.addSubview(viewController.view)
      sourceVC.addChildViewController(viewController)
      viewController.didMove(toParentViewController: sourceVC)
      completion?()
    case .present(let sourceVC, let animated, let style):
      viewController.modalPresentationStyle = style
      sourceVC.present(viewController, animated: animated) {
        completion?()
      }
    case .push(let sourceVC, let animated):
      sourceVC.navigationController?.pushViewController(viewController, animated: animated)
      completion?()
    }
  }
  
  func undisplay(_ viewController: UIViewController?,
                 completion: (() -> ())? = nil) {
    guard let viewController = viewController else { return }
    
    switch self {
    case .embed( _, _):
      viewController.view.removeFromSuperview()
      viewController.removeFromParentViewController()
      viewController.didMove(toParentViewController: nil)
      completion?()
    case .present( _, let animated, _):
      viewController.dismiss(animated: animated) {
        completion?()
      }
    case .push(let sourceVC, let animated):
      sourceVC.navigationController?.popViewController(animated: animated)
      completion?()
    }
  }
}
