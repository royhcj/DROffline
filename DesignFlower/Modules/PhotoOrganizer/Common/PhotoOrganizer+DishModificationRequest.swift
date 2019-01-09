//
//  PhotoOrganizerDishModificationSet.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/29.
//

import Foundation

extension PhotoOrganizer {
  
  class DishModificationRequest {
    
    var itemIndex: Int?
    var modifications: [DishModification] = []
    
    func append(modification: DishModification) {
      // TODO: should merge. later
      modifications.append(modification)
    }
  }
  
}
