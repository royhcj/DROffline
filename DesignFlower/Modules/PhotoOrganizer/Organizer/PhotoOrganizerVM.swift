//
//  PhotoOrganizerVM.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/22.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoOrganizerVM {
  
  var disposeBag = DisposeBag()
  
  var dishItems = BehaviorRelay<[DishItem]?>(value: nil)
  
  let lastDeletedDishItem = BehaviorRelay<DishItem?>(value: nil)
  var dishDeleteRequests: [DishModificationRequest] = []
  
  var output: Output?
  
  struct Input {
    var deleteDishItem: Observable<DishItem>
    var undoLastDeletedDishItem: Observable<Void>
  }
  
  struct Output {
    var dishItems: Observable<[DishItem]?>
    var lastDeletedDishItem: Observable<DishItem?>
  }
  
  func bind(input: Input) -> Output {
    
    // Self binding
    lastDeletedDishItem
      .subscribe(onNext: { [weak self] dishItem in
        guard let itemIndex = dishItem?.itemIndex
        else { return }
        
        let request = DishModificationRequest()
        request.itemIndex = itemIndex
        request.modifications.append(.deleteDishReview)
        self?.dishDeleteRequests.append(request)
        print("Added Delete Request")
      }).disposed(by: disposeBag)
    
    //
    input.deleteDishItem
      .subscribe(onNext: { [weak self] dishItem in
        if var dishItems = self?.dishItems.value,
           let index = dishItems.firstIndex(where: {
             $0.itemIndex == dishItem.itemIndex
            }) {
          let deleted = dishItems[index]
          dishItems.remove(at: index)
          self?.dishItems.accept(dishItems)
          self?.lastDeletedDishItem.accept(deleted)
        }
      }).disposed(by: disposeBag)
    
    input.undoLastDeletedDishItem
      .subscribe(onNext: { [weak self] in
        guard let deletedDishItem = self?.lastDeletedDishItem.value,
              let dishItems = self?.dishItems.value else { return }
        
        var newDishItems: [DishItem] = dishItems
        newDishItems.append(deletedDishItem)
        newDishItems.sort(by: {
          $0.itemIndex ?? 0 < $1.itemIndex ?? 0
        })
        
        self?.dishItems.accept(newDishItems)
        
        // Remove from delete modification request
        self?.dishDeleteRequests.removeAll(where: {
          $0.itemIndex == deletedDishItem.itemIndex
        })
        
      }).disposed(by: disposeBag)
    
    //
    output = Output(dishItems: dishItems.asObservable(),
                    lastDeletedDishItem: lastDeletedDishItem.asObservable())
    
    return output!
  }
  
  // MARK: - Type Definitions
  typealias DishItem = PhotoOrganizer.DishItem
  typealias DishModificationRequest = PhotoOrganizer.DishModificationRequest
}
