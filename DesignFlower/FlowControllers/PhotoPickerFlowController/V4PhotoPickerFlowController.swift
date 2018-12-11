//
//  PhotoPickerFlowController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import UIKit
import Photos

class V4PhotoPickerFlowController: ViewBasedFlowController,
                                   V4PhotoPickerVC.FlowDelegate {
  
  weak var delegate: Delegate?
  
  //var photoPickerVC: V4PhotoPickerVC?
  var photoPickerVC: NoteV3PhotoPickerViewController?
  var scenario: Scenario
  var sourceDisplayContext: DisplayContext
  
  init(delegate: Delegate, scenario: Scenario, sourceDisplayContext: DisplayContext) {
    self.delegate = delegate
    self.scenario = scenario
    self.sourceDisplayContext = sourceDisplayContext
  }
  
  deinit {
    print("V4PhotoPickerFlowController.deinit")
  }
  
  // MARK: - Flow Execution
  override func prepare() {
    //photoPickerVC = V4PhotoPickerVC.make(flowDelegate: self)
    //photoPickerVC?.view.backgroundColor = .purple
    photoPickerVC = NoteV3PhotoPickerViewController.make(scenario: .addNewPhotos, isPresented: true, photoLimit: 10)
    photoPickerVC?.flowDelegate = self
  }
  
  override func start() {
    showPhotoPickerVC()
  }
  
  // MARK: - PhotoPicker VC Manipulation
  func showPhotoPickerVC() {
    guard let photoPickerVC = photoPickerVC else { return }
    
    sourceDisplayContext.display(photoPickerVC)
  }
  
  // MARK: - PhotoPicker VC Flow Delegate
  func photoPickerVCPicked(assets: [PHAsset]) {
    delegate?.photoPicker(self, picked: assets, scenario: scenario)
    sourceDisplayContext.undisplay(photoPickerVC)
  }
  
  func photoPickerVCDidCancel() {
    delegate?.photoPickerDidCancel(self)
    sourceDisplayContext.undisplay(photoPickerVC)
  }
  
  // MARK: - Type Definitions
  typealias Delegate = V4PhotoPickerFlowControllerDelegate
  typealias Scenario = V4PhotoPickerModule.Scenario
}

protocol V4PhotoPickerFlowControllerDelegate: class {
  func photoPicker(_ sender: V4PhotoPickerFlowController, picked assets: [PHAsset], scenario: V4PhotoPickerModule.Scenario)
  func photoPickerDidCancel(_ sender: V4PhotoPickerFlowController)
}
