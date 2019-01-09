//
//  PhotoOrganizerGroupVM.swift
//  DishRank
//
//  Created by roy on 10/23/18.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class DishPhotoOrganizerVM: NSObject {

  // Rx Members
  var disposeBag = DisposeBag()
  
  var dishItem = BehaviorRelay<DishItem?>(value: nil)
  
  // Modification Members
  var dishModificationRequest = DishModificationRequest()
  
  var output: Output?
  
  struct Input {
    let changeDishName: Observable<String?>
    let changeComment: Observable<String?>
    let changePhoto: Observable<ImageRepresentation?>
    let changeRating: Observable<Float?>
    let deleteDishReview: Observable<Void>
    let savePhoto: Observable<Void>
  }
  
  struct Output {
    let dishItem: Observable<DishItem?>
    let changedPhoto: PublishSubject<ImageRepresentation?>
    let savedPhoto: PublishSubject<Bool>
  }
  
  func bind(input: Input) -> Output {
    
    // Self binding
    dishItem.subscribe(onNext: { [weak self] (dishItem) in
      self?.dishModificationRequest.itemIndex = dishItem?.itemIndex
    }).disposed(by: disposeBag)
    
    //
    let output = Output(dishItem: dishItem.asObservable(),
                        changedPhoto: PublishSubject<ImageRepresentation?>(),
                        savedPhoto: PublishSubject<Bool>())
    self.output = output
    
    // Bind Input
    input.changePhoto
      .subscribe(onNext: { [weak self] imageRepresentation in
        let modification = DishModification.changePhoto(imageRepresentation)
        self?.dishModificationRequest.append(modification: modification)
        
        self?.output?.changedPhoto.onNext(imageRepresentation)
      }).disposed(by: disposeBag)
    
    input.changeDishName
      .skipUntil(dishItem.skip(1))
      .subscribe(onNext: { [weak self] name in
        print("Adding changeDishName(\(name ?? ""))")
        let modification = DishModification.changeDishName(name)
        self?.dishModificationRequest.append(modification: modification)
      }).disposed(by: disposeBag)
    
    input.changeComment
      .skipUntil(dishItem.skip(1))
      .subscribe(onNext: { [weak self] comment in
        let modification = DishModification.changeComment(comment)
        self?.dishModificationRequest.append(modification: modification)
      }).disposed(by: disposeBag)
    
    input.changeRating
      .skipUntil(dishItem.skip(1))
      .subscribe(onNext: { [weak self] rating in
        let modification = DishModification.changeRating(rating)
        self?.dishModificationRequest.append(modification: modification)
      }).disposed(by: disposeBag)
    
    input.deleteDishReview
      .skipUntil(dishItem.skip(1))
      .subscribe(onNext: { [weak self] _ in
        let modification = DishModification.deleteDishReview
        self?.dishModificationRequest.append(modification: modification)
      }).disposed(by: disposeBag)
    
    input.savePhoto
      .subscribe(onNext: { [weak self] _ in
        self?.saveImageToPhotoAlbum()
      }).disposed(by: disposeBag)
    
    return output
  }
  
  // MARK: - Dish Image
  func getCurrentDishImageRepresentation() -> ImageRepresentation? {
    for modification in dishModificationRequest.modifications.reversed() {
      if case .changePhoto(let imageRepresentation) = modification {
        return imageRepresentation
      }
    }

//    if let urlString = dishItem.value?.dishReview?.url {
    
    if let localName = dishItem.value?.dishReview?.images.first?.localName {
      let url = KVOImageV4.localFolder.appendingPathComponent(localName)
      return .localFile(url.absoluteString)
    } else if let urlString = dishItem.value?.dishReview?.images.first?.url {
      return .url(urlString)
    }
    
    return nil
  }
  
  // MARK: - Save Image
  func saveImageToPhotoAlbum() {
    guard let imageRepresentation = getCurrentDishImageRepresentation()
      else { return }
    
    imageRepresentation.fetchImage(completion: { [weak self] image in
      if let image = image {
        UIImageWriteToSavedPhotosAlbum(image, self,
          #selector(self?.saveImageCompletion(_:
                            didFinishSavingWithError:
                            contextInfo:)), nil)
      }
    })
  }
  
  @objc func saveImageCompletion(_ image: UIImage,
                                 didFinishSavingWithError error: NSError?,
                                 contextInfo: UnsafeRawPointer) {
    output?.savedPhoto.onNext(error == nil)
  }
  
  // MARK: - Type Definitions
  typealias DishItem = PhotoOrganizer.DishItem
  typealias DishModification = PhotoOrganizer.DishModification
  typealias DishModificationRequest = PhotoOrganizer.DishModificationRequest
  typealias ImageRepresentation = PhotoOrganizer.ImageRepresentation
}
