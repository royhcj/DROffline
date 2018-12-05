//
//  V4ReviewVC+Cells.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/4.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit

class V4ReviewVC_RestaurantNameCell: UITableViewCell {
  
  @IBOutlet var restaurantNameButton: UIButton!
  
  func configure(with review: KVORestReviewV4?) {
    let title = "\(review?.restaurant?.name ?? "") >"
    restaurantNameButton.setTitle(title, for: .normal)
  }
}

class V4ReviewVC_DiningTimeCell: UITableViewCell {
  
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

class V4ReviewVC_ReviewTitleCell: UITableViewCell {
  
  @IBOutlet var reviewTitleTextField: UITextField!
  
  func configure(with review: KVORestReviewV4?) {
    reviewTitleTextField.text = review?.title
  }
}

class V4ReviewVC_DishReviewHeaderCell: UITableViewCell {
  
}

class V4ReviewVC_DishReviewCell: UITableViewCell {
  
}

class V4ReviewVC_RestaurantRatingCell: UITableViewCell {
  
  @IBOutlet var commentTextView: UITextView!
  @IBOutlet var priceRatingView: UIView!
  @IBOutlet var serviceRatingView: UIView!
  @IBOutlet var environmentRatingView: UIView!
  
  func configure(with review: KVORestReviewV4?) {
    commentTextView.text = review?.comment
  }
}

class V4ReviewVC_DeleteCell: UITableViewCell {

}

extension V4ReviewVC {
  typealias RestaurantNameCell = V4ReviewVC_RestaurantNameCell
  typealias DiningTimeCell = V4ReviewVC_DiningTimeCell
  typealias ReviewTitleCell = V4ReviewVC_ReviewTitleCell
  typealias DishReviewHeaderCell = V4ReviewVC_DishReviewHeaderCell
  typealias DishReviewCell = V4ReviewVC_DishReviewCell
  typealias RestaurantRatingCell = V4ReviewVC_RestaurantRatingCell
  typealias DeleteCell = V4ReviewVC_DeleteCell
}
