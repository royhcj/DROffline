//
//  NoteV3PhotoPickerViewController.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/6/4.
//

import UIKit
import Photos

protocol NoteV3PhotoPickerViewControllerDelegate: class {
  func notePhotoPickerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     picked assets: [PHAsset])
  func notePhotoPickerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     dismissWithAbort: Bool, wasPresented: Bool)
  func notePhotoPikcerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     choosed asset: PHAsset, for indexPath: IndexPath)
}
extension NoteV3PhotoPickerViewControllerDelegate {
  func notePhotoPickerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     picked assets: [PHAsset]) { }
  func notePhotoPickerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     dismissWithAbort: Bool, wasPresented: Bool) { }
  func notePhotoPikcerViewController(_ sender: NoteV3PhotoPickerViewController,
                                     choosed asset: PHAsset, for indexPath: IndexPath) { }
}

protocol NoteV3PhotoSelectionUpdatable {
  func updateNotePhotoSelections()
}

class NoteV3PhotoPickerViewController: UINavigationController {

  enum Scenario {
    case addNewPhotos
    case addMorePhotos
    case choosePhoto(indexPath: IndexPath)
  }
  
  weak var flowDelegate: V4PhotoPickerVCFlowDelegate?

  //weak var pickerDelegate: NoteV3PhotoPickerViewControllerDelegate?
  var scenario: Scenario = .addNewPhotos
  var isPresented = true // 記錄此vc是被present還是embed
  var photoLimit = 10

  // MARK: - Object lifecycle
  static func make(scenario: Scenario,
                   isPresented: Bool,
                   photoLimit: Int) -> NoteV3PhotoPickerViewController? {
    let vc = UIStoryboard(name: "NoteV3PhotoPicker", bundle: nil)
              .instantiateViewController(withIdentifier: "NoteV3PhotoPickerViewController")
              as? NoteV3PhotoPickerViewController
    vc?.scenario = scenario
    vc?.isPresented = isPresented
    vc?.photoLimit = photoLimit
    return vc
  }

  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if let cameraVC = NoteV3CameraViewController.make(scenario: scenario, photoLimit: photoLimit) {
      cameraVC.cameraDelegate = self
      self.pushViewController(cameraVC, animated: false)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Setup Navigation Bar
    var backText = "返回"
    var doneText = "寫筆記"
    switch scenario {
    case .addNewPhotos, .addMorePhotos:
      backText = "返回"
      doneText = "寫筆記"
    case .choosePhoto:
      backText = "取消"
      doneText = "確認"
    }
    navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: backText,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(clickedClose(_:)))
    navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: doneText,
                                                                style: .plain,
                                                                target: self, action: #selector(clickedNext(_:)))
    
    // Ask for re-using previous selections
#if false // TODO:
    let selectedCount = NoteV3Service.shared.getNotePhotoSelections().count
    if selectedCount > 0 {
      let alert = UIAlertController(title: "是否繼續使用上次照片", message: "程式裡有\(selectedCount)張暫存未使用的照片，請問是否要繼續使用", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "放棄", style: .default, handler: { _ in
        NoteV3Service.shared.deleteAllNotePhotoSelections()
        for vc in self.viewControllers {
          if let vc = vc as? NoteV3PhotoSelectionUpdatable {
            vc.updateNotePhotoSelections()
          }
        }
      }))
      alert.addAction(UIAlertAction(title: "使用", style: .default, handler: { _ in
      }))
      present(alert, animated: true, completion: nil)
    }
#endif
  }

  // MARK: - IB Actions
  @objc func clickedClose(_ sender: Any) {
    var shouldAbort = false
    if case .addNewPhotos = self.scenario {
      shouldAbort = true
    }

#if false // TODO:
    let selectedCount = NoteV3Service.shared.getNotePhotoSelections().count
#endif
    let selectedCount = 0
    if selectedCount > 0 {
      UIAlertController.show(on: self, title: nil, message: "已有\(selectedCount)張照片，確認離開？",
        doneTitle: "離開", doneAction: {
#if false // TODO:
          NoteV3Service.shared.deleteAllNotePhotoSelections()
#endif
          self.dismiss(abort: shouldAbort)
        }, cancelTitle: "取消", cancelAction: nil)
    } else {
      self.dismiss(abort: shouldAbort)
    }
  }

//  func getRestReview() -> RLMRestReviewV3? {
//    if let vc = self.viewControllers.filter({ (vc) -> Bool in
//      return ((vc as? NoteV3ViewController) != nil)
//    }).first as? NoteV3ViewController{
//      return vc.viewModel.restReview
//    } else {
//      return nil
//    }
//  }

  @objc func clickedNext(_ sender: Any) {
    if let vc = self.viewControllers.filter({ (vc) -> Bool in
      return ((vc as? NoteV3CameraViewController) != nil)
    }).first as? NoteV3CameraViewController {
      if vc.cameraButton.isEnabled {
        print("cameraButton is show")
      } else {
        return
      }
    }
    confirmSelections()
  }

  func confirmSelections() {

    self.flowDelegate?.photoPickerVCPicked(assets: [])
    return
    
    var creationDates: [Date] = []
#if false // TODO:
    let selections = NoteV3Service.shared.getNotePhotoSelections().sorted {
      ($0.selectedDate ?? Date(timeIntervalSince1970: 0))
        >= ($1.selectedDate ?? Date(timeIntervalSince1970: 0))
    }
    selections.forEach {
      if let creationDate = $0.creationDate {
        creationDates.append(creationDate)
      }
    }
    NoteV3Service.shared.getAssets(creationDates: creationDates) { result in

      var assets: [PHAsset] = []
      result?.enumerateObjects({ (asset, _, _) in
        assets.append(asset)
      })

      let confirm = { () -> Void in
        switch self.scenario {
        case .addNewPhotos, .addMorePhotos:
          //self.pickerDelegate?.notePhotoPickerViewController(self, picked: assets)
          self.flowDelegate?.photoPickerVCPicked(assets: assets)
        case .choosePhoto(let indexPath):
          if let asset = assets.first {
            //self.pickerDelegate?.notePhotoPikcerViewController(self, choosed: asset, for: indexPath)
            self.flowDelegate?.photoPickerVCPicked(assets: [asset])
          }
        }
      }

      if self.isPresented {
        confirm()
      } else {
        self.startDisappearAnimation(completion: {
          confirm()
        })
      }
    }
#endif
  }

  func dismiss(abort: Bool) {
    switch scenario {
      case .addMorePhotos, .choosePhoto:
#if false // TODO:
        NoteV3Service.shared.deleteAllNotePhotoSelections
#endif
      case .addNewPhotos:
        break
    }

//    self.pickerDelegate?.notePhotoPickerViewController(self, dismissWithAbort: abort, wasPresented: isPresented)
    flowDelegate?.photoPickerVCDidCancel()
  }

  func startDisappearAnimation(completion: @escaping (() -> Void)) {
    UIView.animate(withDuration: 0.5, animations: {
      var frame = self.view.frame
      frame.origin.y = frame.size.height
      self.view.frame = frame
    }, completion: { _ in
      completion()
    })
  }
}

extension NoteV3PhotoPickerViewController: NoteV3CameraViewControllerDelegate {
  func showPhotoLibrary() {
    if let vc = NoteV3PhotoLibrarySelectionViewController.make(scenario: scenario, photoLimit: photoLimit) {
      vc.selectionDelegate = self
      vc.loadViewIfNeeded()
      pushViewController(vc, animated: true)
    }
  }
}

extension NoteV3PhotoPickerViewController: NoteV3PhotoLibrarySelectionViewControllerDelegate {
}
