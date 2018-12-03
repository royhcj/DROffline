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
  
  func display(_ viewController: UIViewController) {
    switch self {
    case .embed(let sourceVC, let view):
      viewController.view.frame = view.bounds
      view.addSubview(viewController.view)
      sourceVC.addChild(viewController)
      viewController.didMove(toParent: sourceVC)
    case .present(let sourceVC, let animated, let style):
      viewController.modalPresentationStyle = style
      sourceVC.present(viewController, animated: animated, completion: nil)
    case .push(let sourceVC, let animated):
      sourceVC.navigationController?.pushViewController(viewController, animated: animated)
    }
  }
  
  func undisplay(_ viewController: UIViewController?) {
    guard let viewController = viewController else { return }
    
    switch self {
    case .embed( _, _):
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
      viewController.didMove(toParent: nil)
    case .present( _, let animated, _):
      viewController.dismiss(animated: animated, completion: nil)
    case .push(let sourceVC, let animated):
      sourceVC.navigationController?.popViewController(animated: animated)
    }
  }
}
