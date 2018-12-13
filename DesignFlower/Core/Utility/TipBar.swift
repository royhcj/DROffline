//
//  TipBar.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/5/22.
//

import UIKit

open class TipBar {
  private static var tipItems: [TipItem] = []
  private static var defaultBackgroundColor: UIColor = UIColor(red: 132.0/255.0, green: 31.0/255.0, blue: 66.0/255.0, alpha: 1)

  public enum AnimationDirection {
    case downward
    case upward
  }

  private static var clearTimers: [Timer] = []

  public static func showTip(for owner: AnyObject,
                             on view: UIView,
                             message: String,
                             font: UIFont = UIFont.systemFont(ofSize: 13),
                             textColor: UIColor = .white,
                             backgroundColor: UIColor = UIColor(red: 132.0/255.0, green: 31.0/255.0, blue: 66.0/255.0, alpha: 1),
                             iconName: String? = nil,
                             height: CGFloat = 30,
                             animationDirection: AnimationDirection = .downward,
                             duration: TimeInterval? = nil,
                             showCloseButton: Bool = true,
                             isMakeConstrains: Bool = true,
                             resetButtonAction: ((UIButton) -> ())? = nil,
                             action: (() -> Void)?) {
    clearTip(for: owner)

    var topSpacing: CGFloat = 0
    if view.safeAreaInsets.top >= 20 && animationDirection == .downward {
      topSpacing = view.safeAreaInsets.top - 20.0
    }
    
    var tipFrame = view.bounds; tipFrame.size.height = height + topSpacing
    let tipView = UIView(frame: tipFrame)
    tipView.backgroundColor = backgroundColor
    tipView.translatesAutoresizingMaskIntoConstraints = false
    tipView.isUserInteractionEnabled = true
    view.addSubview(tipView)

      tipView.snp.makeConstraints {
        $0.height.equalTo(tipFrame.height)
        $0.left.equalToSuperview()
        $0.right.equalToSuperview()
        if isMakeConstrains {
          $0.top.equalToSuperview()
          $0.bottom.equalToSuperview()
        }else{
          $0.top.equalToSuperview()
        }
      }
    
    let contentFrame = CGRect(x: 0, y: topSpacing,
                              width: view.frame.width, height: height)

    var currentX: CGFloat = 10.0
    if let iconName = iconName {
      let icon = UIImageView(image: UIImage(named: iconName))
      icon.frame = CGRect(x: currentX, y: contentFrame.origin.y,
                          width: icon.image?.size.width ?? height,
                          height: contentFrame.height)
      icon.contentMode = .center
      tipView.addSubview(icon)
      currentX += icon.frame.width + 10.0
    }

    let label = UILabel(frame: CGRect(x: currentX, y: contentFrame.origin.y,
                                      width: tipFrame.width - 10.0,
                                      height: contentFrame.height))
    label.text = message
    label.textColor = textColor
    label.font = font
    tipView.addSubview(label)

    let button = TipItemButton(frame: tipView.bounds)
    button.action = action
    tipView.addSubview(button)

    if let resetButtonAction = resetButtonAction {
      let resetButton = TipItemButton(frame:
        CGRect(x: tipFrame.width - 100, y: contentFrame.origin.y,
               width: 90, height: contentFrame.height))
      resetButton.titleLabel?.font = .systemFont(ofSize: 14)
      resetButton.setTitle("復原資料", for: .normal)
      resetButton.setImage(UIImage(named: "undo"), for: .normal)
      resetButton.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
      resetButton.resetAction = resetButtonAction
      if showCloseButton {
        tipView.addSubview(resetButton)
      }
    } else {
      let closeButton = TipItemButton(frame:
        CGRect(x: tipFrame.width - tipFrame.height, y: contentFrame.origin.y,
               width: tipFrame.height, height: contentFrame.height))
      closeButton.setImage(UIImage(named: "btn_icon_not_attend"), for: .normal)
      closeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
      closeButton.action = {
        TipBar.clearTip(for: owner)
      }
      if showCloseButton {
        tipView.addSubview(closeButton)
      }
    }

    var sourceFrame = tipFrame
    if animationDirection == .downward {
      sourceFrame.origin.y = -tipFrame.height
    } else {
      sourceFrame.origin.y = tipFrame.height
    }
    tipView.frame = sourceFrame
    UIView.animate(withDuration: 0.5) {
      tipView.frame = tipFrame
    }

    let tipItem = TipItem(owner: owner, tipView: tipView, action: action)
    tipItem.animationDirection = animationDirection
    tipItems.append(tipItem)

    if let duration = duration {
      createClearTimer(for: tipItem, duration: duration)
    }
  }

  public static func clearTip(for owner: AnyObject) {
    guard let tipItem = tipItem(for: owner) else { return }
    tipItem.tipView.removeFromSuperview()

    tipItems = tipItems.filter { !($0.owner === owner) }
  }

  private static func createClearTimer(for tipItem: TipItem,
                                       duration: TimeInterval) {
    let timer = Timer.scheduledTimer(withTimeInterval: duration,
                                     repeats: false) { (timer) in
      UIView.animate(withDuration: 0.3, animations: {
        var frame = tipItem.tipView.frame
        frame.origin.y = tipItem.animationDirection == .downward ?
                           -frame.height: frame.height
        tipItem.tipView.frame = frame
      }, completion: { _ in
        // 清除tipItem
        if let index = tipItems.index(where: { $0 === tipItem }) {
          tipItem.tipView.removeFromSuperview()
          tipItems.remove(at: index)
        }

        // 清除timer
        timer.invalidate()
        if let index = clearTimers.index(where: { $0 === timer }) {
          clearTimers.remove(at: index)
        }
      })
    }
    clearTimers.append(timer)
  }

  private static func tipItem(for owner: AnyObject) -> TipItem? {
    return tipItems.filter { $0.owner === owner }.first
  }

  private class TipItem {
    weak var owner: AnyObject?
    var tipView: UIView
    var animationDirection: AnimationDirection = .downward
    var action: (() -> Void)?

    init(owner: AnyObject, tipView: UIView, action: (() -> Void)?) {
      self.owner = owner
      self.tipView = tipView
      self.action = action
    }
  }

  private class TipItemButton: UIButton {
    var action: (() -> Void)?
    var resetAction: ((UIButton) -> Void)?

    override init(frame: CGRect) {
      super.init(frame: frame)
      addTarget(self, action: #selector(onClicked(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    @objc func onClicked(_ sender: Any) {
      action?()
      resetAction?(self)
    }
  }
}
