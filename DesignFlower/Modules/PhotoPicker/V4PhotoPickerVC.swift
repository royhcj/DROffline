//
//  V4PhotoPickerVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit
import Photos

class V4PhotoPickerVC: FlowedViewController {
  
  weak var flowDelegate: FlowDelegate?
  
  // MARK: - Object lifecycle
  static func make(flowDelegate: FlowDelegate) -> V4PhotoPickerVC {
    let vc =  UIStoryboard(name: "V4PhotoPicker", bundle: nil)
                .instantiateViewController(withIdentifier: "V4PhotoPickerVC")
                as! V4PhotoPickerVC
    vc.flowDelegate = flowDelegate
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - IB Actions
  @IBAction func clickedDone(_ sender: Any) {
    flowDelegate?.photoPickerVCPicked(assets: [])
  }
  
  @IBAction func clickedCancel(_ sender: Any) {
    flowDelegate?.photoPickerVCDidCancel()
  }
  
  // MARK: - Type Definitions
  typealias FlowDelegate = V4PhotoPickerVCFlowDelegate
}

protocol V4PhotoPickerVCFlowDelegate: class {
  func photoPickerVCPicked(assets: [PHAsset])
  func photoPickerVCDidCancel()
}
