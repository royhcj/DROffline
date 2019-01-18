//
//  NoteV3CameraViewController.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/5/29.
//

import UIKit
import CameraManager
import SDWebImage
import Photos
import CoreMotion
import RxSwift
import RxCocoa

protocol NoteV3CameraViewControllerDelegate: class {
  func showPhotoLibrary()
}

class NoteV3CameraViewController: UIViewController {

  typealias Scenario = NoteV3PhotoPickerViewController.Scenario
  
  let cameraManager = CameraManager()
  var scenario: Scenario = .addNewPhotos
  var photoCount: Int = 0
  var isFromChoose = false
  //weak var delegate: SelectorViewControllerDelegate?
  //var dishReview: PhotoDishReview?
  var indexPath: IndexPath?
  let motionManager = CMMotionManager()
  var orientationLast: UIImageOrientation = .right
  var photoLimit: Int = 10
  fileprivate var disposeBag = DisposeBag()
  weak var cameraDelegate: NoteV3CameraViewControllerDelegate?

  @IBOutlet var cameraView: UIView!
  @IBOutlet var cameraButton: UIButton!
  @IBOutlet var thumbnail: UIImageView!
  @IBOutlet var thumbnailButton: UIButton!
  @IBOutlet var photoCountLabel: UILabel!
  @IBOutlet var cameraDeviceButton: UIButton!
  

  // MARK: - Object lifecycle
  static func make(scenario: Scenario, photoLimit: Int) -> NoteV3CameraViewController? {
    let vc = UIStoryboard(name: "NoteV3Camera", bundle: nil)
              .instantiateViewController(withIdentifier: "NoteV3CameraViewController")
              as? NoteV3CameraViewController
    vc?.scenario = scenario
    vc?.photoLimit = photoLimit
    return vc
  }

  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // 要求權限
    let currentCameraState = cameraManager.currentCameraStatus()
    cameraManager.shouldKeepViewAtOrientationChanges = true
    cameraManager.shouldRespondToOrientationChanges = false
    if currentCameraState == .notDetermined {
      cameraManager.askUserForCameraPermission { [unowned self] in
        if $0 {
          self.addCameraToView()
        } else {
          self.navigationController?.popViewController(animated: true)
        }
      }
    } else if currentCameraState == .ready {
      addCameraToView()
    } else if currentCameraState == .accessDenied {
      alertPromptToAllowCameraAccessViaSetting()
    }

    PHPhotoLibrary.requestAuthorization { (status) in
      switch status {
      case .authorized:
        break
      case .denied, .notDetermined, .restricted:
        print("PhotoLibrary unauthorized")
      }
    }

    cameraManager.writeFilesToPhoneLibrary = false
    cameraManager.shouldUseLocationServices = false

    initializeMotionManager()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Customize Navigation Controller
    var titleText = "拍照"
    switch scenario {
    case .addNewPhotos:
      titleText = "拍照"
    case .addMorePhotos:
      titleText = "拍照"
    case .choosePhoto:
      titleText = "更換菜餚照片"
    }
    navigationController?.navigationBar.barTintColor = .black
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.isTranslucent = false
    navigationItem.title = titleText
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

    // Reload Thumbnail
    reloadThumbnail()
    
    // Setup location service
    setupLocationService()

    // Start Capture
    cameraManager.resumeCaptureSession()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Stop Capture
    cameraManager.stopCaptureSession()
  }

  deinit {
    motionManager.stopAccelerometerUpdates()
  }

  func alertPromptToAllowCameraAccessViaSetting() {
    let alert = UIAlertController(title: "無法取得相機使用權限", message: "您已經拒絕使用相機功能，請前往設定並開啟使用權限.", preferredStyle: UIAlertControllerStyle.alert)

    alert.addAction(UIAlertAction(title: "拒絕", style: .default))
    alert.addAction(UIAlertAction(title: "設定", style: .cancel) { _ in
      UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    })

    present(alert, animated: true)
  }

  func alertPromptToAllowPhotoAccessViaSetting() {
    let alert = UIAlertController(title: "無法取得相簿儲存權限", message: "您已經拒絕使用相簿功能，請前往設定並開啟使用權限.", preferredStyle: UIAlertControllerStyle.alert)

    alert.addAction(UIAlertAction(title: "拒絕", style: .default))
    alert.addAction(UIAlertAction(title: "設定", style: .cancel) { _ in
      UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    })

    present(alert, animated: true)
  }

  func addCameraToView() {

    _ = cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: .stillImage)
    cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in

      let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (_) -> Void in }))

      self?.present(alertController, animated: true, completion: nil)
    }
  }

  func initializeMotionManager() {
    motionManager.accelerometerUpdateInterval = 0.2
    motionManager.gyroUpdateInterval = 0.2
    motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
      if let error = error {
        print(error)
        return
      }
      if let data = data {
        self?.outputAccelerationData(data.acceleration)
      }
    }
  }

  func outputAccelerationData(_ acceleration: CMAcceleration) {
    var orientationNew: UIImageOrientation
    if acceleration.x >= 0.75 {
      orientationNew = .down
      //print("Landscape Left")
    } else if acceleration.x <= -0.75 {
      orientationNew = .up
      //print("Landscape Right")
    } else if acceleration.y <= -0.75 {
      orientationNew = .right
      //print("Portrait")
    } else if acceleration.y >= 0.75 {
      orientationNew = .left
      //print("Portrait UpsideDown")
    } else {
      // Consider same as last time
      return
    }
    let displayOrientation = orientationNew
    
    if cameraManager.cameraDevice == .front {
      if orientationNew == .up {
        orientationNew = .down
      } else if orientationNew == .down {
        orientationNew = .up
      }
    }

    if orientationNew == orientationLast {
      return
    }
    orientationLast = orientationNew
    
    var newAngle: CGFloat
    switch displayOrientation {
      case .up, .upMirrored:       newAngle = 0 + 90
      case .down, .downMirrored:   newAngle = 180 + 90
      case .left, .leftMirrored:   newAngle = 90 + 90
      case .right, .rightMirrored: newAngle = -90 + 90
    }
    print(newAngle)
    let newRadian = newAngle * CGFloat.pi / 180.0
    
    let viewsToRotate: [UIView] = [cameraDeviceButton, thumbnail, thumbnailButton, photoCountLabel]
    
    for subview in viewsToRotate {
      subview.transform = CGAffineTransform(rotationAngle: newRadian)
    }
  }

//  @objc func cancel() {
//    dismiss(animated: true, completion: {
//      self.delegate?.presentSelector(dishReview: self.dishReview, indexPath: self.indexPath)
//    })
//  }

  @objc func remove() {
    UIAlertController.show(on: self, title: "刪除此篇筆記？", message: nil, doneTitle: "確認", doneAction: {
      self.dismiss(animated: true, completion: nil)
    }, cancelTitle: "取消", cancelAction: nil)
  }

  @IBAction func changeCameraDevice(_: UIButton) {
    cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    switch cameraManager.cameraDevice {
    case .front:
      print("前鏡頭")
    case .back:
      print("後鏡頭")
    }
  }

  @IBAction func recordButtonTapped(sender: UIButton) {
    //    sender.isEnabled = false
    guard checkCameraPermit() else {
      self.alertPromptToAllowCameraAccessViaSetting()
      return
    }

    guard checkPhotoPermit() else {
      self.alertPromptToAllowPhotoAccessViaSetting()
      return
    }
    takePhoto()

  }

  func checkPhotoPermit() -> Bool {
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized, .notDetermined:
      return true
    case .denied, .restricted:
      return false
    }
  }

  func checkCameraPermit() -> Bool {
    let currentCameraState = cameraManager.currentCameraStatus()

    if currentCameraState == .notDetermined {
      return false
    } else if currentCameraState == .ready {
      return true
    } else {
      return false
    }
  }

  func takePhoto() {
    cameraButton.isEnabled = false

    if photoCount < photoLimit
      || photoLimit == 1 { // 單張模式則取代之前選取的項目
      cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
        if let errorOccured = error {
          self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
          self.cameraButton.isEnabled = true
        } else {
          guard var capturedImage = image else {
            self.cameraButton.isEnabled = true
            return
          }
          capturedImage = UIImage(cgImage: capturedImage.cgImage!, scale: capturedImage.scale, orientation: self.orientationLast)
          self.thumbnail.image = capturedImage
          self.thumbnailButton.setImage(nil, for: .normal)
          if self.photoLimit != 1 {
            self.photoCount += 1
          }
          self.photoCountLabel.text = "\(self.photoCount)"
          self.photoCountLabel.isHidden = false

          // 存入library
          let library = PHPhotoLibrary.shared()
          let creationDate = Date()
          let selectedDate = Date()
          library.performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: capturedImage)
            request.creationDate = creationDate
            if LocationService.shared.locationServiceAccessible(),
               LocationService.shared.coordinate?.isInvalid() == false,
               let location = LocationService.shared.coordinate {
              request.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
            }
          }, completionHandler: { (success, error) in
            DispatchQueue.main.async {
              if success {
                V4PhotoService.shared.getAssets(withCreationDates: [creationDate], completion: { result in
                  guard let asset = result?.firstObject
                  else { return }
                  
                  let selection = V4PhotoSelection(identifier: asset.localIdentifier, selectedDate: selectedDate)
                  V4PhotoService.shared.addPhotoSelection(selection, isSingle: self.photoLimit == 1)
                })


                self.reloadThumbnail()
                self.cameraButton.isEnabled = true
              } else {

                UIAlertController.show(on: self, title: nil, message: error?.localizedDescription, doneTitle: "確認", completion: { self.cameraButton.isEnabled = true })

              }
            }
          })
        }
        //        sender.isEnabled = true
      })} else {
        let alert = UIAlertController(title: "上限為１０張照片",
                                      message: "請先執行下一步辨識功能",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default,
                                      handler: { _ in self.cameraButton.isEnabled = true }))
        self.present(alert, animated: true, completion: {
        //        sender.isEnabled = true
      })
    }
  }

  func reloadThumbnail() {

    var photoSelections = Array(V4PhotoService.shared.getPhotoSelections())
    photoCount = photoSelections.count

    photoSelections = photoSelections.sorted {
      ($0.selectedDate ?? Date.date1970) > ($1.selectedDate ?? Date.date1970)
    }

    let localIdentifiers = photoSelections.compactMap { $0.identifier }

    V4PhotoService.shared.getAssets(withIdentifiers: localIdentifiers) { (result) in
      var assets: [PHAsset] = []
      result?.enumerateObjects({ (asset, _, _) in
        assets.append(asset)
      })

      // 清除照片已被刪除的selections
      var selectionAssets: [(V4PhotoSelection, PHAsset)] = []
      for selection in photoSelections {
        if let asset = assets.first(where: { $0.localIdentifier == selection.identifier }) {
          selectionAssets.append((selection, asset))
        } else if let localIdentifier = selection.identifier {
          V4PhotoService.shared.deleteNotePhotoSelection(with: localIdentifier)
        }
      }
      self.photoCount = selectionAssets.count
      guard let asset = selectionAssets.first?.1 else {
        self.thumbnail.image = nil
        self.thumbnailButton.setImage(UIImage(named: "photolibrary"), for: .normal)
        self.photoCountLabel.text = "0"
        self.photoCountLabel.isHidden = true
        return
      }
      
      //let image = NoteV3Service.shared.getImage(for: asset, targetSize: CGSize(width: 256, height: 256))
      // TODO: Target Size to (256x256)
      V4PhotoService.shared.getUIImage(for: asset, completion: { image in
        self.thumbnail.image = image
        self.thumbnailButton.setImage(image, for: .normal)
        self.photoCountLabel.text = "\(self.photoCount)"
        self.photoCountLabel.isHidden = self.photoCount == 0
      })
    }
  }

  @IBAction func clickedThumbnail(_ sender: Any) {
    guard self.checkPhotoPermit() else {
      let alert = UIAlertController(title: "無法取得相簿儲存權限", message: "您已經拒絕使用相簿功能，請前往設定並開啟使用權限.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "拒絕", style: .default))
      alert.addAction(UIAlertAction(title: "設定", style: .cancel) { _ in
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
      })

      present(alert, animated: true)
      return
    }
    cameraDelegate?.showPhotoLibrary()
  }

}

// MARK: - Location Service
extension NoteV3CameraViewController {
  
  func setupLocationService() {
    LocationService.shared.authorizationStatusSubject
      .subscribe {
        guard let status = $0.element else { return }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
          LocationService.shared.manager.startUpdatingLocation()
        case .notDetermined, .restricted, .denied:
          break
        }
      }.disposed(by: disposeBag)
    
    
    LocationService.shared.requestWhenInUseAuthorization()
    LocationService.shared.updateDistrictName()
  }
  
}


// MARK: - NoteV3PhotoSelectionUpdatable

extension NoteV3CameraViewController: NoteV3PhotoSelectionUpdatable {
  func updateNotePhotoSelections() {
    reloadThumbnail()
  }
}
