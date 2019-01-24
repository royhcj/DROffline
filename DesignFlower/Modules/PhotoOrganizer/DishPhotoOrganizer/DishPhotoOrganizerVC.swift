//
//  PhotoOrganizerGroupVC.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/22.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import YCRateView
import Photos

class DishPhotoOrganizerVC: UIViewController,
                            V4PhotoPickerVC.FlowDelegate,
                            ImageEditorDelegate {
  
  @IBOutlet var dishNameTextField: UITextField!
  @IBOutlet var photoImageView: UIImageView!
  @IBOutlet var dishRateView: YCRateView!
  @IBOutlet var dishCommentTextField: UITextField!
  @IBOutlet var trashButton: UIButton!
  @IBOutlet var downloadButton: UIButton!
  @IBOutlet var editButton: UIButton!
  @IBOutlet var changeButton: UIButton!
  @IBOutlet weak var photosCollectionView: UICollectionView!
  
  var vm: DishPhotoOrganizerVM?
  
  // Photo Picker Related
  var photoPickerVC: NoteV3PhotoPickerViewController?
  
  // Rx Members
  var disposeBag = DisposeBag()
  
  var dishRating = PublishSubject<Float?>()
  var changePhoto = PublishSubject<ImageReplacement?>()
  var addPhoto = PublishSubject<ImageRepresentation?>()
  var selectImageAtIndex = PublishSubject<Int?>() // Image Index
  
  // Delegate
  weak var delegate: Delegate?
  
  // MARK: - Object lifecycle
  static func make(dishItem: DishItem?) -> DishPhotoOrganizerVC {
    let vc = UIStoryboard(name: "DishPhotoOrganizer", bundle: nil)
              .instantiateViewController(withIdentifier: "DishPhotoOrganizerVC")
              as! DishPhotoOrganizerVC
    vc.loadViewIfNeeded()
    vc.setDishItem(dishItem)
    return vc
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize
    photoImageView.image = nil
    
    // Setup Photo Collection View
    setupPhotoCollectionView()
    
    // Setup Dish Rate View
    setupDishRateView()
    
    //
    bindViewModel()
  }
  
  // MARK: -
  func setDishItem(_ dishItem: DishItem?) {
    vm?.dishItem.accept(dishItem)
    
    if dishItem?.dishReview?.images.isEmpty == false {
      selectImageAtIndex.onNext(0)
    }
  }
  
  // MARK: - MVVM Bindings
  func bindViewModel() {
    // Create View Model
    vm = DishPhotoOrganizerVM()
    
    // Generate Input
    let deleteDishReview = PublishSubject<Void>()
    
    let input = DishPhotoOrganizerVM.Input(
      changeDishName: dishNameTextField.rx
        .controlEvent(.editingDidEnd)
        .map { [weak self] in self?.dishNameTextField.text }
        .asObservable(),
      changeComment: dishCommentTextField.rx
        .controlEvent(.editingDidEnd)
        .map { [weak self] in self?.dishCommentTextField.text }
        .asObservable(),
      changePhoto: changePhoto,
      addPhoto: addPhoto,
      changeRating: dishRating,
      deleteDishReview: deleteDishReview.asObservable(),
      savePhoto: downloadButton.rx.tap.asObservable(),
      selectImageAtIndex: selectImageAtIndex)

    // Bind Output
    let output = vm?.bind(input: input)
    
    output?.dishItem
      .subscribe(onNext: { [weak self] dishItem in
        guard let dishReview = dishItem?.dishReview
        else { return }
        
        if self?.vm?.dishReview?.images.isEmpty == true {
          self?.selectImageAtIndex.onNext(0)
        }
        
        self?.dishNameTextField.text = dishReview.dish?.name
        self?.dishCommentTextField.text = dishReview.comment
        self?.dishRateView.yc_InitValue = Float(dishReview.rank ?? "0.0")!
      }).disposed(by: disposeBag)

    output?.changedPhoto
      .subscribe(onNext: { [weak self] imageReplacement in
        guard let imageReplacement = imageReplacement
        else { self?.photoImageView.image = nil; return }
        
// TODO: update current image
//        imageReplacement.imageRepresentation.fetchImage(completion: { [weak self] (image) in
//          self?.photoImageView.image = image
//        })
        self?.photosCollectionView.reloadData()
        
        switch imageReplacement.imageRepresentation {
        case .image, .url, .localFile:
          self?.downloadButton.isEnabled = true
        case .phAsset:
          self?.downloadButton.isEnabled = false
        }
      }).disposed(by: disposeBag)
    
    output?.addedPhoto
      .subscribe(onNext: { [weak self] imageRepresentation in
        self?.photosCollectionView.reloadData()
      }).disposed(by: disposeBag)
    
    output?.savedPhoto
      .subscribe(onNext: { [weak self] successful in
        if successful {
          self?.downloadButton.isEnabled = false
        }
        
        self?.showPhotoSavedMessage(successful: successful)
      }).disposed(by: disposeBag)
    
    output?.selectedImage
      .subscribe(onNext: { [weak self] imageUUID in
        if let imageRepresentation = self?.vm?.getCurrentDishImageRepresentation() {
          imageRepresentation.fetchImage { image in
            self?.photoImageView.image = image
          }
          
          switch imageRepresentation {
          case .image, .url, .localFile:
            self?.downloadButton.isEnabled = true
          case .phAsset:
            self?.downloadButton.isEnabled = false
          }
        } else {
          self?.photoImageView.image = nil
        }
      }).disposed(by: disposeBag)
    
    // Self binding
    trashButton.rx.tap
      .map { _ -> Void in return }
      .subscribe(onNext: { [weak self] () in
        self?.showAlert(title: "是否刪除此菜餚？", message: nil,
                        confirmTitle: "確認", confirmAction: {
          guard let strongSelf = self,
                let dishItem = strongSelf.vm?.dishItem.value
          else { return }

          self?.delegate?.dishPhotoOrganizer(strongSelf,
                                deleteWithDishItem: dishItem)
        }, cancelTitle: "取消", cancelAction: nil)
      }).disposed(by: disposeBag)
    
    changeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showPhotoPicker()
      }).disposed(by: disposeBag)
    
    editButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.showPhotoEditor()
      }).disposed(by: disposeBag)
  }
  
  // MARK: - RateView Manipulaiton
  func setupDishRateView() {
    dishRateView.yc_IsSliderEnabled = true
    dishRateView.yc_IsTextHidden = false
    dishRateView.sliderAddTarget(target: self,
                                 selector: #selector(dishRateViewValueChanged),
                                 event: .valueChanged)
  }
  
  @objc func dishRateViewValueChanged(sender: UISlider, value: Float) {
    dishRating.onNext(sender.value)
  }
  
  // MARK: - Photo Picker Manipulation
  func showPhotoPicker() {
    photoPickerVC = NoteV3PhotoPickerViewController.make(scenario: .addNewPhotos, isPresented: true, photoLimit: 10)
    photoPickerVC?.flowDelegate = self
    photoPickerVC?.modalPresentationStyle = .overFullScreen
    if let vc = photoPickerVC {
      present(vc, animated: true, completion: nil)
    }
  }
  
  func photoPickerVCPicked(assets: [PHAsset]) {
    for asset in assets {
      addPhoto.onNext(.phAsset(asset))
    }
    photoPickerVC?.dismiss(animated: true, completion: nil)
    V4PhotoService.shared.deleteAllPhotoSelections()
  }
  
  func photoPickerVCDidCancel() {
    photoPickerVC?.dismiss(animated: true, completion: nil)
    V4PhotoService.shared.deleteAllPhotoSelections()
  }
  
  // MARK: - Download-related methods
  func showPhotoSavedMessage(successful: Bool) {
    let message = successful ? "已從雲端下載圖片" : "儲存相片失敗"
    TipBar.showTip(
      for: self,
      on: ((UIApplication.shared.delegate?.window)!)!,
      message: message,
      font: UIFont.systemFont(ofSize: 15),
      //backgroundColor: tipBackgroundColor,
      iconName: "S.select friends",
      height: 60,
      animationDirection: .downward,
      duration: 3,
      showCloseButton: false,
      isMakeConstrains: false) {
        TipBar.clearTip(for: self)
    }
  }
  
  // MARK: - Photo Editor Related
  func showPhotoEditor() {
    guard let imageRepresentation = vm?.getCurrentDishImageRepresentation()
    else { return }
    
    imageRepresentation.fetchImage { [weak self] in
      guard let image = $0
      else { return }
      
      let vc = ImageEditorViewController.make(image: image, delegate: self)
      vc.modalPresentationStyle = .overFullScreen
      vc.modalPresentationCapturesStatusBarAppearance = false
      self?.present(vc, animated: true, completion: nil)
    }
  }
  
  func imageEditor(_ sender: ImageEditorViewController, commit image: UIImage) {
    // 存入library
    guard let imageUUID = vm?.selectedImageUUID.value
    else { return print("Error! Failed getting selected image UUID") }
    let library = PHPhotoLibrary.shared()
    let creationDate = Date.now
    library.performChanges({
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      request.creationDate = creationDate
      
      // 填入位置資訊
      if LocationService.shared.locationServiceAccessible(),
         LocationService.shared.coordinate?.isInvalid() == false,
        let location = LocationService.shared.coordinate {
        request.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
      }
    }, completionHandler: { [weak self] (success, error) in
      if !success || error != nil {
        DispatchQueue.main.async { [weak self] in
          self?.showAlert(title: "無法儲存相片",
                          message: "\(error?.localizedDescription ?? "")",
                          buttonTitle: "確認", buttonAction: nil)
          return
        }
      }
      
      V4PhotoService.shared.getAssets(withCreationDates: [creationDate], completion: { [weak self] assets in
        guard let asset = assets?.firstObject else { return }
        
        self?.changePhoto.onNext(ImageReplacement(imageRepresentation: .phAsset(asset), sourceImageUUID: imageUUID))
      })
      
/* TODO: later
      NoteV3Service.shared.getAssets(creationDates: [creationDate], completion: { [weak self] assets in
        guard let asset = assets?.firstObject else { return }
        
        let imageRepresentation = ImageRepresentation.phAsset(asset)
        self?.changePhoto.onNext(imageRepresentation)
      })
 */
    })
    
    sender.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Type Definitions
  typealias DishItem = PhotoOrganizer.DishItem
  typealias ImageRepresentation = PhotoOrganizer.ImageRepresentation
  typealias ImageReplacement = PhotoOrganizer.ImageReplacement
  typealias Delegate = DishPhotoOrganizerVCDelegate
}

// MARK: - Photo Collection View Extension
extension DishPhotoOrganizerVC: UICollectionViewDataSource,
                                UICollectionViewDelegate {
  
  func setupPhotoCollectionView() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoCollectionViewLongPress(gesture:)))
    gesture.minimumPressDuration = 0.2
    
    photosCollectionView.addGestureRecognizer(gesture)
    
    if let flowLayout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.scrollDirection = .horizontal
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let dishReview = vm?.dishItem.value?.dishReview
    else { return 0 }
    
    return dishReview.images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
    
    if let cell = cell as? PhotoCell,
       let dishReview = vm?.dishItem.value?.dishReview,
       let image = dishReview.images.at(indexPath.item) {
      image.fetchUIImage {
        cell.photoImageView.image = $0
      }
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectImageAtIndex.onNext(indexPath.item)
  }
  
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard let dishReview = vm?.dishItem.value?.dishReview
    else { return }
    
    let kvoImage = dishReview.images[sourceIndexPath.item]
    dishReview.images.remove(at: sourceIndexPath.item)
    dishReview.images.insert(kvoImage, at: destinationIndexPath.item)
  }
  
  @objc func handlePhotoCollectionViewLongPress(gesture: UILongPressGestureRecognizer) {
    switch(gesture.state) {
      
    case .began:
      guard let selectedIndexPath = photosCollectionView.indexPathForItem(at: gesture.location(in: photosCollectionView))
        else {
          break
      }
      photosCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case .changed:
      photosCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
    case .ended:
      photosCollectionView.endInteractiveMovement()
    default:
      photosCollectionView.cancelInteractiveMovement()
    }
  }
  
}


protocol DishPhotoOrganizerVCDelegate: class {
  func dishPhotoOrganizer(_ sender: DishPhotoOrganizerVC,
                          deleteWithDishItem: PhotoOrganizer.DishItem)
}
