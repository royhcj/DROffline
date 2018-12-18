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

class V4ReviewVC_RestaurantNameCell: V4ReviewVC.CommonCell {
  
  @IBOutlet var restaurantNameButton: UIButton!
  
  func configure(with review: KVORestReviewV4?) {
    let title = "\(review?.restaurant?.name ?? "") >"
    restaurantNameButton.setTitle(title, for: .normal)
  }
}

class V4ReviewVC_DiningTimeCell: V4ReviewVC.CommonCell {
  
  @IBOutlet var diningTimeButton: UIButton!
  
  func configure(with review: KVORestReviewV4?) {
    var title: String
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm >"
    if let date = review?.eatingDate {
      title = formatter.string(from: date)
    } else {
      title = "選擇用餐時間 >"
    }
    
    diningTimeButton.setTitle(title, for: .normal)
  }
}

class V4ReviewVC_ReviewTitleCell: V4ReviewVC.CommonCell, UITextFieldDelegate {
  
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

class V4ReviewVC_DishReviewHeaderCell: V4ReviewVC.CommonCell {
  
}

class V4ReviewVC_DishReviewCell: V4ReviewVC.CommonCell, UITextFieldDelegate, UITextViewDelegate {
  
  var dishReviewUUID: String?
  @IBOutlet var dishNameTextField: UITextField!
  @IBOutlet var dishRateView: YCRateView!
  @IBOutlet var commentTextView: UITextView!
  
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
  
  func textViewDidChange(_ textView: UITextView) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.changeDishReviewComment(for: uuid, comment: commentTextView.text)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let uuid = dishReviewUUID else { return }
    delegate?.changeDishReviewDish(for: uuid, name: dishNameTextField.text ?? "", dishID: nil)
  }
  
}

class V4ReviewVC_RestaurantRatingCell: V4ReviewVC.CommonCell, UITextViewDelegate {
  
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
}

class V4ReviewVC_DeleteCell: V4ReviewVC.CommonCell {

}

class V4ReviewVC_CommonCell: UITableViewCell {
  weak var delegate: V4ReviewVCCommonCellDelegate?
}

extension V4ReviewVC {
  typealias CommonCell = V4ReviewVC_CommonCell
  typealias RestaurantNameCell = V4ReviewVC_RestaurantNameCell
  typealias DiningTimeCell = V4ReviewVC_DiningTimeCell
  typealias ReviewTitleCell = V4ReviewVC_ReviewTitleCell
  typealias DishReviewHeaderCell = V4ReviewVC_DishReviewHeaderCell
  typealias DishReviewCell = V4ReviewVC_DishReviewCell
  typealias RestaurantRatingCell = V4ReviewVC_RestaurantRatingCell
  typealias DeleteCell = V4ReviewVC_DeleteCell
}


protocol V4ReviewVCCommonCellDelegate: class {
  func changeReviewTitle(_ title: String?)
  func changeReviewComment(_ comment: String?)
  func changePriceRank(_ rank: Float)
  func changeServiceRank(_ rank: Float)
  func changeEnvironmentRank(_ rank: Float)
  
  // Dish Review Related
  func changeDishReviewDish(for dishReviewUUID: String, name: String, dishID: Int?)
  func changeDishReviewComment(for dishReviewUUID: String, comment: String)
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float)
  func showMoreForDishReview(_ dishReviewUUID: String)
  func deleteDishReview(for dishReviewUUID: String)
}
