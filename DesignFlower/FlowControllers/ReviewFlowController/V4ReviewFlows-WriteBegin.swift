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
      // 先將新筆記設成Dirty
      flowController.makeReviewDirty(true)
      
      let flow = CheckLastUnsavedFlow(flowController: flowController)
      flow.execute()
    }
  }
}
