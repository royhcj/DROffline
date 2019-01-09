//
//  V4ReviewVC+Cells.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/4.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit
import YCRateView
import SnapKit

class V4Review_RestaurantNameCell: V4ReviewVC.CommonCell {
  
  @IBOutlet var restaurantNameButton: UIButton!
  
  func configure(with review: KVORestReviewV4?) {
    let title = "\(review?.restaurant?.name ?? "") >"
    restaurantNameButton.setTitle(title, for: .normal)
  }
}

class V4Review_DiningTimeCell: V4ReviewVC.CommonCell {
  
  @IBOutlet var diningTimeButton: UIButton!
  @IBOutlet var diningTimeArrowButton: UIButton!
  @IBOutlet var deleteTimeButton: UIButton!

  func configure(with review: KVORestReviewV4?) {
    var title: String
    var textColor: UIColor
    
    if let date = review?.eatingDate {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy/MM/dd HH:mm"
      title = formatter.string(from: date)
      textColor = UIColor.lightGray
      diningTimeArrowButton.isHidden = true
      deleteTimeButton.isHidden = false
    } else {
      title = "不顯示"
      textColor = UIColor(hex: "333333")
      diningTimeArrowButton.isHidden = false
      deleteTimeButton.isHidden = true
    }
    
    diningTimeButton.setTitle(title, for: .normal)
    diningTimeButton.tintColor = textColor
  }

  @IBAction func clickedDiningTime(_ sender: Any) {
    delegate?.pickDiningTime()
  }
  
  @IBAction func clickedDeleteTime(_ sender: Any) {
    delegate?.changeDiningTime(nil)
  }
  
}

class V4Review_ReviewTitleCell: V4ReviewVC.CommonCell, UITextFieldDelegate {
  
  @IBOutlet var reviewTitleTextField: UITextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    reviewTitleTextField.delegate = self
  }
  
  func configure(with review: KVORestReviewV4?) {
    reviewTitleTextField.text = review?.title
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.changeReviewTitle(textField.text)
  }
}

class V4Review_DishReviewHeaderCell: V4ReviewVC.CommonCell {
  @IBOutlet weak var addDishReviewButton: UIButton!
  
  @IBAction func clickedAddDishReview(_ sender: Any) {
    delegate?.addDishReview()
  }
}

class V4Review_DishReviewCell: V4ReviewVC.SelectableCommonCell, UITextFieldDelegate, UITextViewDelegate {
  
  var dishReviewUUID: String?
  @IBOutlet var dishNameTextField: UITextField!
  @IBOutlet var dishRateView: YCRateView!
  @IBOutlet var commentTextView: UITextView!
  @IBOutlet var photoImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    dishRateView.sliderAddTarget(target: self, selector: #selector(dishRankValueChanged), event: .touchUpInside)
    dishRateView.yc_IsSliderEnabled = true
    dishRateView.yc_IsTextHidden = false
    dishRateView.setNeedsDisplay()
    
    dishNameTextField.delegate = self
    
    commentTextView.delegate = self
  }
  
  func configure(with dishReview: KVODishReviewV4?) {
    dishReviewUUID = dishReview?.uuid
    dishRateView.yc_InitValue = Float(dishReview?.rank ?? "0.0") ?? 0
    dishRateView.setNeedsDisplay()
    
    if let image = dishReview?.images.first {
      image.fetchUIImage { [weak self] uiImage in
        self?.photoImageView.image = uiImage ?? UIImage(named: "菜餚預設圖片")
      }
    } else {
      photoImageView.image = UIImage(named: "菜餚預設圖片")
    }
  }
  
  @objc func dishRankValueChanged(sender: UISlider, value: Float) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.changeDishReviewRank(for: uuid, rank: sender.value)
  }
  
  @IBAction func clickedMore(_ sender: Any) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.showMoreForDishReview(uuid)
  }
  
  @IBAction func clickedDelete(_ sender: Any) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.deleteDishReview(for: uuid)
  }
  
  @IBAction func clickedImage(_ sender: Any) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.showPhotoOrganizer(for: uuid)
  }
  
  
  override func clickedSelectionButton(_ sender: Any) {
    guard let dishReviewUUID = dishReviewUUID else { return }
    delegate?.toggleDishReviewSelection(dishReviewUUID: dishReviewUUID)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.changeDishReviewComment(for: uuid, comment: commentTextView.text)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.changeDishReviewDish(for: uuid, name: dishNameTextField.text ?? "", dishID: nil)
  }
  
}

class V4Review_RestaurantRatingCell: V4ReviewVC.SelectableCommonCell, UITextViewDelegate {
  
  @IBOutlet var commentTextView: UITextView!
  @IBOutlet var priceRatingView: YCRateView!
  @IBOutlet var serviceRatingView: YCRateView!
  @IBOutlet var environmentRatingView: YCRateView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    commentTextView.delegate = self
    priceRatingView.sliderAddTarget(target: self, selector: #selector(priceRankValueChanged), event: .valueChanged)
    serviceRatingView.sliderAddTarget(target: self, selector: #selector(serviceRankValueChanged), event: .valueChanged)
    environmentRatingView.sliderAddTarget(target: self, selector: #selector(environmentRankValueChanged), event: .valueChanged)
  }
  
  func configure(with review: KVORestReviewV4?) {
    commentTextView.text = review?.comment
    
    priceRatingView.yc_IsSliderEnabled = true
    priceRatingView.yc_IsTextHidden = false
    priceRatingView.yc_InitValue = Float(review?.priceRank ?? "0.0") ?? 0
    priceRatingView.setNeedsDisplay()
    
    serviceRatingView.yc_IsSliderEnabled = true
    serviceRatingView.yc_IsTextHidden = false
    serviceRatingView.yc_InitValue = Float(review?.serviceRank ?? "0.0") ?? 0
    serviceRatingView.setNeedsDisplay()
    
    environmentRatingView.yc_IsSliderEnabled = true
    environmentRatingView.yc_IsTextHidden = false
    environmentRatingView.yc_InitValue = Float(review?.environmentRank ?? "0.0") ?? 0
    environmentRatingView.setNeedsDisplay()
  }
  
  @objc func priceRankValueChanged(sender: UISlider, value: Float) {
    delegate?.changePriceRank(value)
  }
  
  @objc func serviceRankValueChanged(sender: UISlider, value: Float) {
    delegate?.changeServiceRank(value)
  }
  
  @objc func environmentRankValueChanged(sender: UISlider, value: Float) {
    delegate?.changeEnvironmentRank(value)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    delegate?.changeReviewComment(textView.text)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    delegate?.changeReviewComment(textView.text)
  }
  
  override func clickedSelectionButton(_ sender: Any) {
    delegate?.toggleRestaurantRatingSelection()
  }
}

class V4Review_DeleteCell: V4ReviewVC.CommonCell {

  
  @IBOutlet weak var findShareContainer: UIView!
  
  @IBOutlet weak var deleteReviewContainer: UIView!
  
  @IBAction func clickedFindShare(_ sender: Any) {
    delegate?.findShare()
  }
  
  @IBAction func clickedDeleteReview(_ sender: Any) {
    delegate?.deleteReview()
  }
}

class V4Review_CommonCell: UITableViewCell {
  weak var delegate: V4ReviewVCCommonCellDelegate?
}

class V4Review_SelectableCommonCell: V4Review_CommonCell {
  var selectionStatus: SelectionStatus = .unselected
  
  @IBOutlet weak var selectionContainer: UIView?

  var selectionView: UIView?
  var selectionButton: UIButton?
  var selectionCircle: UIView?
  var selectionLabel: UILabel?
  var selectionImage: UIImageView?
  
  func createSelectionViews() {
    guard let container = selectionContainer
    else { return }
    
    if selectionView != nil {
      return
    }
    
    selectionView = {
      let selectionView = UIView(frame: container.bounds)
      selectionView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
      selectionView.translatesAutoresizingMaskIntoConstraints = true
      container.addSubview(selectionView)
      container.bringSubview(toFront: selectionView)
      return selectionView
    }()

    selectionButton = {
      guard let selectionView = self.selectionView else { return nil }
      let button: UIButton = UIButton(frame: selectionView.bounds)
      button.translatesAutoresizingMaskIntoConstraints = true
      selectionView.addSubview(button)
      
      button.addTarget(self, action: #selector(clickedSelectionButton(_:)), for: .touchUpInside)
      
      return button
    }()
    
    selectionCircle = {
      guard let selectionView = self.selectionView else { return nil }
      let circle = UIView(frame: CGRect(x: selectionView.bounds.width - 5 - 24, y: 5, width: 24, height: 24))
      circle.translatesAutoresizingMaskIntoConstraints = true
      circle.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
      circle.backgroundColor = .white
      circle.borderColor = DishRankColor.darkTan
      circle.borderWidth = 1
      circle.layer.cornerRadius = circle.bounds.width * 0.5
      circle.clipsToBounds = true
      selectionView.addSubview(circle)
      return circle
    }()
    
    selectionLabel = {
      guard let circle = self.selectionCircle else { return nil }
      let label = UILabel(frame: circle.bounds)
      label.textColor = .white
      label.textAlignment = .center
      label.backgroundColor = DishRankColor.darkTan
      label.layer.cornerRadius = circle.bounds.width * 0.5
      label.layer.masksToBounds = true
      label.translatesAutoresizingMaskIntoConstraints = true
      circle.addSubview(label)
      return label
    }()
    
    selectionImage = {
      guard let circle = self.selectionCircle else { return nil }
      let image = UIImageView(frame: circle.bounds)
      image.image = UIImage(named: "Susccess")
      image.backgroundColor = DishRankColor.darkTan
      image.translatesAutoresizingMaskIntoConstraints = true
      circle.addSubview(image)
      return image
    }()
  }
  
  func setSelectionStatus(_ selectionStatus: SelectionStatus) {
    self.selectionStatus = selectionStatus
    
    switch selectionStatus {
    case .unselected:
      selectionView?.backgroundColor = .clear
      selectionLabel?.isHidden = true
      selectionImage?.isHidden = true
    case .selected:
      selectionView?.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
      selectionLabel?.isHidden = true
      //selectionLabel?.text = "✓"
      selectionImage?.isHidden = false
    case .selectedWithNumber(let number):
      selectionView?.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
      selectionLabel?.isHidden = false
      selectionLabel?.text = "\(number + 1)"
      selectionImage?.isHidden = true
    }
  }
  
  @objc func clickedSelectionButton(_ sender: Any) {
    
  }
  
  
  
  enum SelectionStatus {
    case unselected
    case selected
    case selectedWithNumber(_ number: Int)
  }
}

extension V4ReviewVC {
  typealias CommonCell = V4Review_CommonCell
  typealias SelectableCommonCell = V4Review_SelectableCommonCell
  typealias RestaurantNameCell = V4Review_RestaurantNameCell
  typealias DiningTimeCell = V4Review_DiningTimeCell
  typealias ReviewTitleCell = V4Review_ReviewTitleCell
  typealias DishReviewHeaderCell = V4Review_DishReviewHeaderCell
  typealias DishReviewCell = V4Review_DishReviewCell
  typealias RestaurantRatingCell = V4Review_RestaurantRatingCell
  typealias DeleteCell = V4Review_DeleteCell
}


protocol V4ReviewVCCommonCellDelegate: class {
  func changeReviewTitle(_ title: String?)
  func changeReviewComment(_ comment: String?)
  func changePriceRank(_ rank: Float)
  func changeServiceRank(_ rank: Float)
  func changeEnvironmentRank(_ rank: Float)
  func changeDiningTime(_ date: Date?)
  func pickDiningTime()
  func findShare()
  func deleteReview()
  
  // Dish Review Related
  func changeDishReviewDish(for dishReviewUUID: String, name: String, dishID: Int?)
  func changeDishReviewComment(for dishReviewUUID: String, comment: String)
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float)
  func showMoreForDishReview(_ dishReviewUUID: String)
  func deleteDishReview(for dishReviewUUID: String)
  func addDishReview()
  func showPhotoOrganizer(for dishReviewUUID: String)
  
  // Selection Related
  func toggleDishReviewSelection(dishReviewUUID: String)
  func toggleRestaurantRatingSelection()
}
