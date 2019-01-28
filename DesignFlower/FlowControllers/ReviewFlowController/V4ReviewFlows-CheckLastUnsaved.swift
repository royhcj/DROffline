//
//  CheckLastUnsaved.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

extension V4ReviewFlows {
  class CheckLastUnsavedFlow: ReviewBaseFlow {
    override func execute() {
      if let uuid = ScratchManager.shared.lastUnsavedScratchUUID {
        flowController.loadReview(uuid)
        flowController.showReviewVC()
        flowController.askContinueUnsavedReview()
      } else {
        // 先將新筆記設成Dirty
        flowController.makeReviewDirty(true)
        
        let flow = AddNewPhotoFlow(flowController: flowController)
        flow.execute()
        flowController.showReviewVC()
      }
    }
  }
}
