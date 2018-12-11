//
//  UIAlertController+extension.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 31/10/2017.
//

import UIKit

extension UIAlertController {
  class func show(on viewController: UIViewController,
                  title: String?, message: String?, doneTitle: String?,
                  completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: doneTitle, style: .default, handler: { _ in
      completion?()
    }))
    viewController.present(alert, animated: true, completion: nil)
  }

  class func show(on viewController: UIViewController,
                  title: String?, message: String?,
                  doneTitle: String?, doneAction: (() -> Void)?,
                  cancelTitle: String?, cancelAction: (() -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: doneTitle, style: .default, handler: { _ in
      doneAction?()
    }))
    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
      cancelAction?()
    }))
    viewController.present(alert, animated: true, completion: nil)
  }
}
