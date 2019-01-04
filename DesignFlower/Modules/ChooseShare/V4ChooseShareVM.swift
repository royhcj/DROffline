//
//  V4ChooseShareVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2019/1/3.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class V4ChooseShareViewModel: V4ReviewViewModel {
 
  weak var output: V4ChooseShareViewModelOutput?
  
  var selectedDishReviewUUIDs: [String] = []
  var selectedRestaurantReview: Bool = false
  
  override init(output: Output?, reviewUUID: String?) {
    super.init(output: output, reviewUUID: reviewUUID)
    if let output = output as? V4ChooseShareViewModelOutput {
      self.output = output
    }
  }
  
  // MARK: - Selection Management
  func getSelectionStatus(forDishReviewIndex index: Int) -> SelectionStatus {
    guard let dishReview = review?.dishReviews.at(index)
    else { return .unselected }
    
    if let selectedIndex = selectedDishReviewUUIDs.firstIndex(where: {
      $0 == dishReview.uuid
    }) {
      return .selectedWithNumber(selectedIndex)
    }
    return .unselected
  }
  
  func toggleDishReviewSelection(dishReviewUUID: String) {
    if let index = selectedDishReviewUUIDs.firstIndex(of: dishReviewUUID) {
      selectedDishReviewUUIDs.remove(at: index)
    } else {
      selectedDishReviewUUIDs.append(dishReviewUUID)
    }
    output?.refreshReview()
  }
  
  func toggleRestaurantRatingSelection() {
    selectedRestaurantReview = !selectedRestaurantReview
    output?.refreshReview()
  }
  
  // MARK: - Type definitions
  typealias SelectionStatus = V4Review_SelectableCommonCell.SelectionStatus
}

protocol V4ChooseShareViewModelOutput: class {
  func refreshReview()
}
