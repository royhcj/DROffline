//
//  CustomSearchBar.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 13/09/2017.
//
//

import UIKit
enum KeyBoardButtonType {
  case done
  case cancel
  case search
}

class CustomSearchBar: UISearchBar {
  var preferredFont: UIFont!
  var preferredTextColor: UIColor!
  var textFieldBackGroundColor: UIColor!
  var keyboardButtonType: KeyBoardButtonType!
  var keyboardButtonTitle: String!
  var keyboardButtonTarget: Any? = nil
  var keyboardButtonSelector: Selector? = nil
  var decorationStyle: DecorationStyle = .underline
  private var isExistShapeLayer = false
    
  enum DecorationStyle {
    case underline
    case bordered(color: UIColor?, inset: UIEdgeInsets?)
  }

  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    // Drawing code
    // Find the index of the search field in the search bar subviews.
    if let index = indexOfSearchFieldInSubviews() {
      // Access the search field
      guard let searchField = (subviews[0]).subviews[index] as? UITextField else {
        return
      }
      // Set its frame.
      searchField.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
//      searchField.leftView = nil

      searchField.addDoneButtonOnKeyboard(keyboardButtonType: keyboardButtonType,
                                          keyboardButtonTitle: keyboardButtonTitle,
                                          keyboardButtonTarget: keyboardButtonTarget,
                                          keyboardButtonSelector: keyboardButtonSelector)
      // Set the font and text color of the search field.
      searchField.font = preferredFont
      searchField.textColor = UIColor.black
      // Set the background color of the search field.
      searchField.backgroundColor = textFieldBackGroundColor
      searchField.textAlignment = .left

    }

    switch decorationStyle {
    case .underline:
      let startPoint = CGPoint(x: 0.0, y: frame.size.height)
      let endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
      let path = UIBezierPath()
      path.move(to: startPoint)
      path.addLine(to: endPoint)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.cgPath
      shapeLayer.strokeColor = UIColor.white.cgColor
      shapeLayer.lineWidth = 1
      layer.addSublayer(shapeLayer)
    case .bordered(let color, let inset):
      let inset = inset ?? UIEdgeInsets.zero
      let tlPoint = CGPoint(x: 0 + inset.left, y: 0 + inset.top)
      let trPoint = CGPoint(x: frame.size.width - inset.right, y: 0 + inset.top)
      let blPoint = CGPoint(x: 0 + inset.left, y: frame.size.height - inset.bottom)
      let brPoint = CGPoint(x: frame.size.width - inset.right, y: frame.size.height - inset.bottom)
      let path = UIBezierPath()
      path.move(to: tlPoint)
      path.addLine(to: trPoint)
      path.addLine(to: brPoint)
      path.addLine(to: blPoint)
      path.addLine(to: tlPoint)
      let shapeLayer = CAShapeLayer()
      self.layer.sublayers?
        .forEach{
          if $0 is CAShapeLayer {
            isExistShapeLayer = true
          }
      }
      if !isExistShapeLayer {
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color?.cgColor ?? UIColor.lightGray.cgColor
        layer.addSublayer(shapeLayer)
      }
    }
    
    super.draw(rect)
  }
  init(frame: CGRect,
       font: UIFont,
       textColor: UIColor,
       textFieldBackGroundColor: UIColor,
       keyboardButtonType: KeyBoardButtonType,
       keyboardButtonTitle: String,
       keyboardButtonTarget: Any? = nil,
       keyboardButtonSelector: Selector? = nil,
       decorationStyle: DecorationStyle = .underline) {
    super.init(frame: frame)
    self.frame = frame
    preferredFont = font
    preferredTextColor = textColor
    self.textFieldBackGroundColor = textFieldBackGroundColor
    backgroundImage = UIImage.from(color: textFieldBackGroundColor)
    searchBarStyle = UISearchBarStyle.prominent
    isTranslucent = true
    self.keyboardButtonType = keyboardButtonType
    self.keyboardButtonTitle = keyboardButtonTitle
    self.keyboardButtonTarget = keyboardButtonTarget
    self.keyboardButtonSelector = keyboardButtonSelector
    self.decorationStyle = decorationStyle
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func indexOfSearchFieldInSubviews() -> Int! {
    // Uncomment the next line to see the search bar subviews.
    // println(subviews[0].subviews)
    var index: Int!
    let searchBarView = subviews[0]
    for i in 0 ..< searchBarView.subviews.count {
      if searchBarView.subviews[i].isKind(of: UITextField.self) {
        index = i
        break
      }
    }
    return index
  }
  
  func setLeftViewMode(_ mode:  UITextFieldViewMode) {
    let subview = self.subviews.first?.subviews.first {
      $0 is UITextField
    }
    
    if let textField  = subview as? UITextField {
      textField.leftViewMode = mode
    }
  }
  
  func setLeftView(_ leftView: UIView) {
    let subview = self.subviews.first?.subviews.first {
      $0 is UITextField
    }
    
    if let textField  = subview as? UITextField {
      textField.leftView = leftView
    }
  }
}
