//
//  UIViewController+Alert.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/10/4.
//

import UIKit

extension UIViewController {
  func showAlert(title: String?, message: String?, buttonTitle: String?, buttonAction: (()->())?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let button = UIAlertAction(title: buttonTitle, style: .default) { (_) in
      buttonAction?()
    }
    alert.addAction(button)
    present(alert, animated: true, completion: nil)
  }
  
  func showAlert(title: String?, message: String?,
                 confirmTitle: String?, confirmAction: (()->())?,
                 cancelTitle: String?, cancelAction: (()->())?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let confirm = UIAlertAction(title: confirmTitle, style: .default) { (_) in
      confirmAction?()
    }
    let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { (_) in
      cancelAction?()
    }
    alert.addAction(confirm)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
  }
}
