//
//  extensionTextField.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 13/09/2017.
//
//

import UIKit

extension UITextField {
  @IBInspectable var doneAccessory: Bool {
    get {
      return doneAccessory
    }
    set(hasDone) {
      if hasDone {
        addDoneButtonOnKeyboard(keyboardButtonType: .done,
                                keyboardButtonTitle: "Done")
      }
    }
  }

  func addDoneButtonOnKeyboard(keyboardButtonType: KeyBoardButtonType,
                               keyboardButtonTitle: String,
                               keyboardButtonTarget: Any? = nil,
                               keyboardButtonSelector: Selector? = nil) {
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    doneToolbar.barStyle = .default

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
    
    let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(self.cancelButtonAction))

    var items = [cancel,flexSpace]

    switch keyboardButtonType {
    case .done:
      let done: UIBarButtonItem = UIBarButtonItem(title: keyboardButtonTitle,
                                                  style: .done,
                                                  target: self,
                                                  action: #selector(self.doneButtonAction))


      items.append(done)

    case .cancel:
      let cancel: UIBarButtonItem = UIBarButtonItem(title: keyboardButtonTitle,
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(self.cancelButtonAction))
      items.append(cancel)

    case .search:
      let search: UIBarButtonItem = UIBarButtonItem(title: keyboardButtonTitle,
                                                    style: .done,
                                                    target: keyboardButtonTarget,
                                                    action: keyboardButtonSelector)
      items.append(search)
    }

    doneToolbar.items = items
    doneToolbar.sizeToFit()

    inputAccessoryView = doneToolbar
  }

  @objc func doneButtonAction() {
    // DoneAction
    resignFirstResponder()
  }
  @objc func cancelButtonAction() {
    // CancelAction
    resignFirstResponder()
  }
}
