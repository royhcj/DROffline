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
    let vc =  UIStoryboard(name: "PhotoPicker", bundle: nil)
                .instantiateViewController(withIdentifier: "PhotoPickerVC")
                as! V4PhotoPickerVC
    vc.flowDelegate = flowDelegate
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  typealias FlowDelegate = V4PhotoPickerVCFlowDelegate
}

protocol V4PhotoPickerVCFlowDelegate: class {
  func photoPickerVCPicked(assets: [PHAsset])
  func photoPickerVCDidCancel()
}
