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
      let uuid = UserDefaults.standard.string(forKey: "LastUnsavedReviewUUID")
      if let uuid = uuid {
        flowController.loadReview(uuid)
        flowController.showReviewVC()
      } else {
        let flow = AddNewPhotoFlow(flowController: flowController)
        flow.execute()
        flowController.showReviewVC()
      }
    }
  }
}
