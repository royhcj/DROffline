//
//  V4ReviewVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/29.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import Photos

class V4ReviewViewModel {
  
  private weak var output: Output?
  private var realmService: RLMServiceV4 = RLMScratchServiceV4.scratchShared
  
  var review: KVORestReviewV4? {
                didSet {
                  // 清除observer
                  if observe != nil {
                    observe?.cancelObserve()
                    observe = nil
                  }
                  // 製造observer
                  if let review = review {
                    observe = RestReviewObserve(object: review,
                                                service: realmService)
                  }
                }
              }
  var observe: RestReviewObserve?
  var dirty: Bool = false
  var restaurantHasDishMenu: Bool = false // 餐廳有沒有菜單
  var reviewHasShareRecords: Bool = false // 該評比有沒有分享紀錄（分身）
  
  var lastBlankDishReviewUUID: String?
  
  var wasReviewSavedSuccessfully: Bool {
    guard let uuid = review?.uuid,
          let rlmReview = RLMServiceV4.shared.getRestReview(uuid: uuid)
    else { return false }
    
    if rlmReview.id.value == nil || rlmReview.id.value == -1 {
      return false
    }
    return true
  }
  
  open var restaurantState: V4ReviewVC.RestaurantNameCell.RestaurantState {
    guard let reviewUUID = review?.uuid
    else { return .noAction }
    
    if RLMServiceV4.shared.isExist(reviewUUID: reviewUUID, reviewID: nil) {
      return .canView // 如果存在原稿既表示已儲存過，引此不能改餐廳
    }
    return .canChange
  }

  init(output: Output?, reviewUUID: String?) {
    review = {
      let review = ScratchManager.shared.getScratch(originalUUID: reviewUUID)
      self.observe = RestReviewObserve(object: review,
                                       service: self.realmService)
      print("new review: \(review.uuid))")
      return review
    }()
    
    self.output = output
  }
  
  func setReview(_ review: KVORestReviewV4) {
    clearScratch()
    
    self.review = review
    
    updateRestaurantHasDishMenu()
    updateReviewHasShareRecords()
    
    output?.refreshReview()
  }
  
  // MARK: - DishReview Manipulation
  func addDishReview() {
    guard let review = review else { return }
    
    // 如果有空白的dish review, 捲動至該dish review即可
    if let blankDishReviewUUID = lastBlankDishReviewUUID,
       let index = review.dishReviews.firstIndex(where: { $0.uuid == blankDishReviewUUID }) {
      output?.scrollToDishReviewAtIndex(index)
      return
    }
    
    // 加入新的空白dish review
    let dishReview = KVODishReviewV4(uuid: nil)
    review.dishReviews.append(dishReview)
    lastBlankDishReviewUUID = dishReview.uuid
    
    setDirty(true)
    output?.refreshReview()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      self?.output?.scrollToDishReviewAtIndex(review.dishReviews.count - 1)
    }
  }
  
  func addDishReviews(with assets: [PHAsset]) {
    guard let review = review else { return }
    
    for asset in assets {
      let dishReview = KVODishReviewV4(uuid: nil)
      
      review.dishReviews.append(dishReview)
      
      V4PhotoService.shared.createKVOImage(with: asset) { [weak self] image in
        guard let image = image
        else { return }
        
        dishReview.images.append(image)

        self?.output?.refreshReview()
        
        if asset == assets.last {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.output?.scrollToDishReviewAtIndex(review.dishReviews.count - 1)
          }
        }
      }
    }
    if !assets.isEmpty {
      setDirty(true)
    }
    
    output?.refreshReview()
  }
  
  func getDishReview(_ dishReviewUUID: String) -> KVODishReviewV4? {
    return review?.dishReviews.first(where: {
      $0.uuid == dishReviewUUID
    })
  }
  
  // MARK: - Save Review
  func saveReview() {
    guard let review = review else { return }
    review.updateDate = Date.now
    ScratchManager.shared.commitScratch(review, needSync: true) {
      self.setDirty(false)
      self.output?.refreshReview() // TODO: Just refresh restaurantState for optimization
    }
  }
  
  // MARK: - Dirty Manipulation
  func setDirty(_ dirty: Bool) {
    self.dirty = dirty
    
    output?.refreshDirty()
  }
  
  func setDirty(_ dirty: Bool, forDishReview dishReview: KVODishReviewV4) {
    if dishReview.uuid == lastBlankDishReviewUUID {
      lastBlankDishReviewUUID = nil
    }
    setDirty(dirty)
  }
  
  // MARK: - Review Change Methods
  func changeReviewTitle(_ title: String?) {
    review?.title = title
    setDirty(true)
  }
  
  func changeReviewComment(_ comment: String?) {
    review?.comment = comment
    setDirty(true)
  }
  
  func changePriceRank(_ rank: Float) {
    review?.priceRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func changeServiceRank(_ rank: Float) {
    review?.serviceRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func changeEnvironmentRank(_ rank: Float) {
    review?.environmentRank = String(format: "%.1f", rank)
    setDirty(true)
  }
  
  func changeDiningTime(_ date: Date?) {
    review?.eatingDate = date
    setDirty(true)
    output?.refreshReview()
  }
  
  func changeRestaurant(_ restaurant: KVORestaurantV4?) {
    review?.restaurant = restaurant
    
    updateRestaurantHasDishMenu()
    
    setDirty(true)
    output?.refreshReview()
  }
  
  func deleteReview() {
    if let reviewUUID = self.review?.uuid {
      print("deleting review \(reviewUUID)")
      RLMServiceV4.shared.delete(reviewUUID: reviewUUID)
    }
    clearScratch()
  }
  
  func clearScratch() {
    if let reviewUUID = self.review?.uuid {
      print("deleting scratch \(reviewUUID)")
      DispatchQueue.main.asyncAfter(deadline: .now()) {
        self.realmService.delete(reviewUUID: reviewUUID)
      }
    }
    review = nil
  }
  
  // MARK: - Dish Review Change Methods
  func changeDishReviewDish(for dishReviewUUID: String, name: String, dishID: Int?) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    if dishReview.dish == nil {
      dishReview.dish = KVODishV4(uuid: nil)
    }
    
    dishReview.dish?.name = name
    if let dishID = dishID {
      dishReview.dish?.id = dishID
    }
    setDirty(true, forDishReview: dishReview)
  }
  
  func changeDishReviewComment(for dishReviewUUID: String, comment: String) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.comment = comment
    setDirty(true, forDishReview: dishReview)
  }
  
  func changeDishReviewRank(for dishReviewUUID: String, rank: Float) {
    guard let dishReview = getDishReview(dishReviewUUID) else { return }
    
    dishReview.rank = String(format: "%.1f", rank)
    setDirty(true, forDishReview: dishReview)
  }
  
  func mergeDishReview(from sourceDishReviewUUID: String, to targetDishReviewUUID: String) {
    guard sourceDishReviewUUID != targetDishReviewUUID,
          let source = getDishReview(sourceDishReviewUUID),
          let target = getDishReview(targetDishReviewUUID)
    else { return }
    
    // merge photos
    target.images.append(contentsOf: source.images)

    deleteDishReview(for: sourceDishReviewUUID)
    setDirty(true, forDishReview: target)
  }
  
  func reorderDishReview(from indexA: Int, to indexB: Int) -> Bool {
    guard let review = review,
          UInt(indexA) < review.dishReviews.count,
          UInt(indexB) < review.dishReviews.count
    else { return false}
    
    let orderA = review.dishReviews[indexA].order
    review.dishReviews[indexA].order = review.dishReviews[indexB].order
    review.dishReviews[indexB].order = orderA
    review.dishReviews.sort {
      $0.order < $1.order
    }
    setDirty(true)
    
    return true
  }
  
  func deleteDishReview(for dishReviewUUID: String) {
    guard let dishReview = getDishReview(dishReviewUUID),
          let index = review?.dishReviews.firstIndex(where: {
            $0 == dishReview
          })
    else { return }
    
    review?.dishReviews.remove(at: index)
    setDirty(true, forDishReview: dishReview)
    output?.refreshReview()
  }
  
  
  // MARK: - Restaurant Manipulation
  func updateRestaurantHasDishMenu() {
    guard let restaurantID = review?.restaurant?.id
    else {
      restaurantHasDishMenu = false
      output?.refreshReview()
      return
    }
    
    WebService.AddRating.getDishList(accessToken: LoggedInUser.sharedInstance().accessToken!,
                                     shopID: restaurantID)
      .then { [weak self] json -> Void in
        self?.restaurantHasDishMenu = json["dishData"].arrayValue.isEmpty == false
      }.catch { [weak self] error in
        print(error)
        self?.restaurantHasDishMenu = false
      }.always { [weak self] in
        self?.output?.refreshReview() // TODO: Just refresh dish menu only for optimization
      }
  }
  
  // MAKR: - Share History Manipulation
  func updateReviewHasShareRecords() {
    
    // 取得原稿的id
    guard let review = review,
          let rlmReview = RLMServiceV4.shared
                            .getRestReview(uuid: review.uuid),
          let reviewID = rlmReview.id.value,
          reviewID != -1
    else {
      return
    }
    
    guard let accessToken = LoggedInUser.sharedInstance().accessToken,
          review.parentID == -1 // 本尊才有分身
    else { return }
    
    WebService.NoteReviewAPI.getShareRecords(
      accessToken: accessToken,
      restaurantReviewID: reviewID)
      .then { response -> Void in
        var hasRecords = false
        if let shareInfos = response.data, shareInfos.count > 0 {
          hasRecords = true
        }
        if hasRecords != self.reviewHasShareRecords {
          self.reviewHasShareRecords = hasRecords
          self.output?.refreshReview()
        }
      }.catch { error in
        print(error)
      }
  }
  
  // MARK: - Type Definitions
  typealias Output = V4ReviewViewModelOutput
}


protocol V4ReviewViewModelOutput: class {
  func refreshReview()
  func refreshDirty()
  func scrollToDishReviewAtIndex(_ index: Int)
}
