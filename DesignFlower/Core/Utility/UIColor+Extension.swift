//
//  extensionUIColor.swift
//  2017-dishrank-ios
//
//  Created by TonyHsu on 2017/11/29.
//

import UIKit

extension UIColor {
  convenience init(hex: String) {
    let scanner = Scanner(string: hex)
    scanner.scanLocation = 0

    var rgbValue: UInt64 = 0

    scanner.scanHexInt64(&rgbValue)

    let r = (rgbValue & 0xFF0000) >> 16
    let g = (rgbValue & 0xFF00) >> 8
    let b = rgbValue & 0xFF

    self.init(
      red: CGFloat(r) / 0xFF,
      green: CGFloat(g) / 0xFF,
      blue: CGFloat(b) / 0xFF, alpha: 1
    )
  }
}
