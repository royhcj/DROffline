//
//  V4ReviewFlower.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit

class V4ReviewFlower: ViewFlower {
  
  var reviewVC: V4ReviewVC?
  weak var delegate: V4ReviewFlowerDelegate?
  
  init(delegate: V4ReviewFlowerDelegate?) {
    self.delegate = delegate
  }
  
  override func prepare() {
    reviewVC = V4ReviewVC.make(viewModel: V4ReviewViewModel())
    reviewVC?.viewFlower = self
    reviewVC?.flower = self
  }
  
  override func start() {
    guard let displayContext = delegate?.reviewFlowerDisplayContext(self),
          let reviewVC = reviewVC
    else { return }
    
    displayContext.present(reviewVC, animated: true, completion: nil)
  }
  
}


protocol V4ReviewFlowerDelegate: class {
  func reviewFlowerDisplayContext(_ sender: V4ReviewFlower) -> UIViewController
}
