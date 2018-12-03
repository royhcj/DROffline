//
//  V4ReviewFlows.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4ReviewFlows { // used as namespace

  class ReviewBaseFlow: Flow {
    var flowController: V4ReviewFlowController
    
    init(flowController: V4ReviewFlowController) {
      self.flowController = flowController
    }
  }
}
