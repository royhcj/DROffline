//
//  CustomSearchController.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 13/09/2017.
//
//

import UIKit
import RxCocoa
import RxSwift

protocol ObjectToStringForSearch {
  func getForSearchString() -> String
}

protocol CustomSearchControllerDelegate: class {
  func didStartSearching(customSearchBar: CustomSearchBar)
  func didTapOnSearchButton(searchText: String,
                            customSearchBar: CustomSearchBar)
  func didTapOnCancelButton(customSearchBar: CustomSearchBar)
  func didChangeSearchText(searchText: String,
                           customSearchBar: CustomSearchBar)
  func didEndSearching(customSearchBar: CustomSearchBar)
}

extension CustomSearchControllerDelegate {
  func didEndSearching(customSearchBar: CustomSearchBar) {
  }
}

class CustomSearchController {
  var customSearchBar: CustomSearchBar!
  weak var customDelegate: CustomSearchControllerDelegate!
  private let disposeBag = DisposeBag()

  // MARK: Initialization

  init(searchBarFrame: CGRect,
       searchBarFont: UIFont,
       searchBarTextColor: UIColor,
       searchBarTintColor: UIColor,
       textFieldBackGroundColor: UIColor,
       keyboardButtonType: KeyBoardButtonType,
       keyboardButtonTitle: String,
       decorationStyle: CustomSearchBar.DecorationStyle = .underline) {

    var keyboardButtonTarget: Any? = nil
    var keyboardButtonSelector: Selector? = nil

    switch keyboardButtonType {
    case .search:
      keyboardButtonTarget = self
      keyboardButtonSelector = #selector(self.clickedSearch)
    default:
      break
    }

    configureSearchBar(searchBarFrame,
                       font: searchBarFont,
                       textColor: searchBarTextColor,
                       bgColor: searchBarTintColor,
                       textFieldBackGroundColor: textFieldBackGroundColor,
                       keyboardButtonType: keyboardButtonType,
                       keyboardButtonTitle: keyboardButtonTitle,
                       keyboardButtonTarget: keyboardButtonTarget,
                       keyboardButtonSelector: keyboardButtonSelector,
                       decorationStyle: decorationStyle)
  }
  // MARK: Custom functions

  func configureSearchBar(_ frame: CGRect,
                          font: UIFont,
                          textColor: UIColor,
                          bgColor _: UIColor,
                          textFieldBackGroundColor: UIColor,
                          keyboardButtonType: KeyBoardButtonType,
                          keyboardButtonTitle: String,
                          keyboardButtonTarget: Any? = nil,
                          keyboardButtonSelector: Selector? = nil,
                          decorationStyle: CustomSearchBar.DecorationStyle = .underline) {



    customSearchBar = CustomSearchBar(frame: frame,
                                      font: font,
                                      textColor: textColor,
                                      textFieldBackGroundColor: textFieldBackGroundColor,
                                      keyboardButtonType: keyboardButtonType,
                                      keyboardButtonTitle: keyboardButtonTitle,
                                      keyboardButtonTarget: keyboardButtonTarget,
                                      keyboardButtonSelector: keyboardButtonSelector,
                                      decorationStyle: decorationStyle)

    customSearchBar.barTintColor = UIColor.white
    customSearchBar.tintColor = UIColor.black
    customSearchBar.showsBookmarkButton = false
    customSearchBar.showsCancelButton = false
    customSearchBar.layer.borderWidth = 1
    customSearchBar.layer.borderColor = textFieldBackGroundColor.cgColor

    customSearchBar.rx
      .textDidBeginEditing
      .subscribe(onNext: { [weak self] _ in
        self?.customDelegate.didStartSearching(customSearchBar: (self?.customSearchBar)!)
      })
      .disposed(by: disposeBag)

    customSearchBar.rx
      .searchButtonClicked
      .subscribe(onNext: { [weak self] _ in
        self?.customSearchBar.resignFirstResponder()
        if let text = self?.customSearchBar.text {
          self?.customDelegate.didTapOnSearchButton(searchText: text,
                                                    customSearchBar: (self?.customSearchBar)!)
        }
      })
      .disposed(by: disposeBag)

    customSearchBar.rx
      .cancelButtonClicked
      .subscribe(onNext: { [weak self] _ in
        self?.customSearchBar.resignFirstResponder()
        self?.customDelegate.didTapOnCancelButton(customSearchBar: (self?.customSearchBar)!)
      })
      .disposed(by: disposeBag)

    customSearchBar.rx
      .text
      .skip(1)
      .debounce(0.3, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] searchText in
        if let searchText = searchText {
          self?.customDelegate.didChangeSearchText(searchText: searchText, customSearchBar: (self?.customSearchBar)!)
        }
      })
      .disposed(by: disposeBag)

    customSearchBar.rx
      .textDidEndEditing
      .subscribe(onNext: { [weak self] _ in
        self?.customDelegate.didEndSearching(customSearchBar: (self?.customSearchBar)!)
      })
      .disposed(by: disposeBag)
  }

  @IBAction func clickedSearch(_ sender: Any) {
    customSearchBar.endEditing(true)
    if let searchText = customSearchBar.text {
      self.customDelegate.didTapOnSearchButton(searchText: searchText,
                                               customSearchBar: self.customSearchBar)
    }
  }
}
