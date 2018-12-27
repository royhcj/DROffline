//
//  V4ShareVM.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/26.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class V4ShareViewModel: V4ReviewViewModel {
  
  weak var output: V4ShareViewModelOutput?
  
  
  override init(output: Output?, reviewUUID: String?) {
    super.init(output: output, reviewUUID: reviewUUID)
    if let output = output as? V4ShareViewModelOutput {
      self.output = output
    }
  }
  
  
}

protocol V4ShareViewModelOutput: class {
  
}
