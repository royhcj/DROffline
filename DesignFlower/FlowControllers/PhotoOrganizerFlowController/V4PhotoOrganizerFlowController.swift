//
//  V4PhotoOrganizerFlowController.swift
//  DesignFlower
//
//  Created by roy on 1/8/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

class V4PhotoOrganizerFlowController: ViewBasedFlowController,
V4PhotoOrganizerVCFlowDelegate {
  var photoOrganizerVC: PhotoOrganizerVC?
  var sourceDisplayContext: DisplayContext
  var initialDishItems: [PhotoOrganizerVC.DishItem] = []
  var initialDisplayIndex: Int?
  
  public var requestModifications: (([PhotoOrganizer.DishModificationRequest]) -> Void)?
  
  init(sourceDisplayContext: DisplayContext,
       initialDishItems: [PhotoOrganizerVC.DishItem],
       initialDisplayIndex: Int?) {
    self.sourceDisplayContext = sourceDisplayContext
    self.initialDishItems = initialDishItems
    self.initialDisplayIndex = initialDisplayIndex
  }
  
  deinit {
    print("V4PhotoOrganizerFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    photoOrganizerVC = PhotoOrganizerVC.make(flowDelegate: self,
                                             dishItems: initialDishItems,
                                             initialDisplayIndex: initialDisplayIndex)
    photoOrganizerVC?.loadViewIfNeeded()
  }
  
  override func start() {
    guard let photoOrganizerVC = photoOrganizerVC
    else { return }
    
    sourceDisplayContext.display(photoOrganizerVC)
  }
  
  // MARK: - Photo Organizer VC Flow Delegate
  func photoOrganizer(_ sender: PhotoOrganizerVC?, requestDishModifications: [PhotoOrganizer.DishModificationRequest]) {
    guard let photoOrganizerVC = photoOrganizerVC
    else { return }
    
    self.requestModifications?(requestDishModifications)
    
    sourceDisplayContext.undisplay(photoOrganizerVC)
  }

}

