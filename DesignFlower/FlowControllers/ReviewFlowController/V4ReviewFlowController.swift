//
//  V4ReviewFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit
import Photos

class V4ReviewFlowController: ViewBasedFlowController {
  
  weak var delegate: Delegate?
  
  var scenario: Scenario = .writeBegin
  
  var reviewVC: V4ReviewVC?
  var navigationVC: UINavigationController?
  
  init(scenario: Scenario) {
    self.scenario = scenario
  }
  
  deinit {
    print("V4ReviewFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    createReviewVC()
  }
  
  override func start() {
    switch scenario {
    case .writeBegin:
      let flow = V4ReviewFlows.WriteBeginFlow(flowController: self)
      flow.execute()
    }
  }
  
  // MARK: - Review VC Manipulation
  func createReviewVC() {
    reviewVC = V4ReviewVC.make(flowDelegate: self)
    reviewVC?.viewBasedFlowController = self
    
    if let reviewVC = reviewVC {
      navigationVC = UINavigationController(rootViewController: reviewVC)
    }
  }
  
  func showReviewVC() {
    guard let navigationVC = navigationVC else { return }
    
    delegate?.getDisplayContext(for: self).display(navigationVC)
  }
  
  func askContinueUnsavedReview() {
    reviewVC?.askContinueUnsavedReview()
  }
  
  // MARK: - Review Manipulation
  func loadReview(_ reviewUUID: String) {
    let review = KVORestReviewV4(uuid: reviewUUID)
    reviewVC?.setReview(review)
  }
  
  func createNewReview() {
    let review = KVORestReviewV4(uuid: nil)
    reviewVC?.setReview(review)
  }
  
  // MARK: - Type Definitions
  typealias Delegate = V4ReviewFlowControllerDelegate
  
  enum Scenario {
    case writeBegin // 點羽毛寫筆記
  }
}

protocol V4ReviewFlowControllerDelegate: class {
  func getDisplayContext(for sender: V4ReviewFlowController) -> DisplayContext
}

// MARK: - Photo Picker Manipulation
extension V4ReviewFlowController: V4PhotoPickerFlowControllerDelegate {
  
  func showPhotoPicker(_ scenario: V4PhotoPickerModule.Scenario) {
    guard let reviewVC = reviewVC else { return }
    
    let displayContext: DisplayContext = {
      switch scenario {
      case .addNewPhotos:
        //return .embed(vc: reviewVC, on: reviewVC.view)
        return .embedEx(vc: reviewVC, on: reviewVC.view, hidesNavigationBar: true)
      default:
        return .present(vc: reviewVC, animated: true, style: .fullScreen)
      }
    }()
    
    let photoPickerFlowController = V4PhotoPickerFlowController(delegate: self, scenario: scenario, sourceDisplayContext: displayContext)
    addChild(flowController: photoPickerFlowController)
    photoPickerFlowController.prepare()
    photoPickerFlowController.start()
  }
  
  func photoPicker(_ sender: V4PhotoPickerFlowController,
                   picked assets: [PHAsset],
                   scenario: V4PhotoPickerModule.Scenario) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    
    // TODO: 不好的方法，稍後修正
    sender.sourceDisplayContext.undisplay(sender.photoPickerVC,
                                          completion: {
      if sender.scenario == .addNewPhotos {
        self.showRestaurantPicker()
      }
    })
    
    addDishReviews(with: assets)
  }
  
  func photoPickerDidCancel(_ sender: V4PhotoPickerFlowController) {
    if let index = childFlowControllers.firstIndex(where: { $0 === sender}) {
      childFlowControllers.remove(at: index)
    }
    delegate?.getDisplayContext(for: self).undisplay(reviewVC)
  }
}

// MARK: - DishReview Manipulation
extension V4ReviewFlowController {
  func addDishReviews(with assets: [PHAsset]) {
    reviewVC?.addDishReviews(with: assets)
  }
}

// MARK: - Restaurant List Manipulation
extension V4ReviewFlowController: V4RestaurantPickerFlowController.Delegate {
  func showRestaurantPicker() {
    guard let reviewVC = reviewVC else { return }
    
    let restaurantPickerFlowController = V4RestaurantPickerFlowController(delegate: self, sourceDisplayContext: .present(vc: reviewVC, animated: true, style: .overFullScreen), initialLocation: nil)
    addChild(flowController: restaurantPickerFlowController)
    restaurantPickerFlowController.prepare()
    restaurantPickerFlowController.start()
  }

  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        selected: Restaurant,
                        locationInfo: V4RestaurantPickerVC.LocationInfo?) {
    
  }
  
  func restaurantPicker(_ sender: V4RestaurantPickerFlowController,
                        dismissedWithLocationInfo: V4RestaurantPickerVC.LocationInfo?) {
    
  }
  
}

//
extension V4ReviewFlowController: V4ReviewVC.FlowDelegate {
  
  func answerContinueLastUnsavedReview(_ yesOrNo: Bool) {
    if yesOrNo == false {
      let oldReviewVC = reviewVC
      delegate?.getDisplayContext(for: self).undisplay(oldReviewVC,
                                                       completion: {
        self.createReviewVC()
        self.showReviewVC()
      })
    }
  }
  
  func leave() {
    delegate?.getDisplayContext(for: self).undisplay(reviewVC,
                                                     completion: {
      
    })
  }
  
  func showShare(originalReviewUUID: String) {
    guard let reviewVC = reviewVC else { return }
    
    let shareFlowController = V4ShareFlowController(sourceDisplayContext: .present(vc: reviewVC, animated: true, style: .fullScreen),
                              originalReviewUUID: originalReviewUUID)
    
    addChild(flowController: shareFlowController)
    
    shareFlowController.prepare()
    shareFlowController.start()
  }
  
  func showChooseShare(originalReviewUUID: String) {
    guard let reviewVC = reviewVC else { return }
    
    let chooseShareFlowController
          = V4ChooseShareFlowController(sourceDisplayContext: .present(vc: reviewVC,
                                                                       animated: true,
                                                                       style: .fullScreen),
                                        originalReviewUUID: originalReviewUUID)
    
    addChild(flowController: chooseShareFlowController)
    
    chooseShareFlowController.prepare()
    chooseShareFlowController.start()
  }
  
  func showAddDishReviewWithPhoto() {
    showPhotoPicker(.addMorePhotos)
  }
  
  func showPhotoOrganizer(dishReviewUUID: String,
                          dishReviews: [KVODishReviewV4],
                          initialDisplayIndex: Int?) {
    guard let reviewVC = reviewVC else { return }
    
    let displayContext = DisplayContext.present(vc: reviewVC,
                                                animated: true,
                                                style: .fullScreen)
    let dishItems: [PhotoOrganizerVC.DishItem] = {
      var items: [PhotoOrganizerVC.DishItem] = []
      for (index, dishReview) in dishReviews.enumerated() {
        let item = PhotoOrganizerVC.DishItem.init(dishReview: dishReview, itemIndex: index)
        items.append(item)
      }
      return items
    }()
    
    
    let photoOrganizerFlowController
          = V4PhotoOrganizerFlowController(sourceDisplayContext: displayContext,
                                           initialDishItems: dishItems,
                                           initialDisplayIndex: initialDisplayIndex)
    addChild(flowController: photoOrganizerFlowController)
    photoOrganizerFlowController.prepare()
    photoOrganizerFlowController.start()
  }

}
