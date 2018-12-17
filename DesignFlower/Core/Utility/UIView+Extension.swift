//
//  extensionUIView.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 11/09/2017.
//
//

import UIKit

class ShadowView: UIView {
  override var bounds: CGRect {
    didSet {
      setupShadow()
    }
  }

  private func setupShadow() {
    layer.cornerRadius = 8
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowRadius = 3
    layer.shadowOpacity = 0.3
    layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }
}

extension UIView {
  class func instanceFromNib(nibName: String) -> UIView? {
    return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView
  }

  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }

  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }

  @IBInspectable
  var borderColor: UIColor? {
    get {
      if let color = layer.borderColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.borderColor = color.cgColor
      } else {
        layer.borderColor = nil
      }
    }
  }

  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }

  @IBInspectable
  var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }

  @IBInspectable
  var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }

  @IBInspectable
  var shadowColor: UIColor? {
    get {
      if let color = layer.shadowColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.shadowColor = color.cgColor
      } else {
        layer.shadowColor = nil
      }
    }
  }
}
