//
//  ViewController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                      V4ReviewFlowController.Delegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Start Main Flower
    let reviewFlowController = V4ReviewFlowController.init()
    reviewFlowController.delegate = self
    reviewFlowController.prepare()
    reviewFlowController.start()
  }
  
  
  func getDisplayContext(for sender: V4ReviewFlowController) -> DisplayContext {
    return .present(vc: self, animated: false, style: .fullScreen)
  }
  
}


