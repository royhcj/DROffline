//
//  V4ReviewFlows-WriteBegin.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

extension V4ReviewFlows {
  class WriteBeginFlow: ReviewBaseFlow {
    override func execute() {
      let uuid = UserDefaults.standard.string(forKey: "LastUnsavedReviewUUID")
      
      if uuid == nil {
        //flowController.displayReviewVC()
      } else {
        let flow = CheckLastUnsavedFlow(flowController: flowController)
        flow.execute()
      }
    }
  }
}
