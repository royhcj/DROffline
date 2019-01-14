//
//  DishPhotoOrganizer+Cells.swift
//  DesignFlower
//
//  Created by roy on 1/14/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit


class DishPhotoOrganizer_PhotoCell: UICollectionViewCell {
  
  @IBOutlet weak var photoImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectedBackgroundView = {
      let view = UIView()
      view.backgroundColor = DishRankColor.darkTan
      return view
    }()
  }
}

extension DishPhotoOrganizerVC {
  typealias PhotoCell = DishPhotoOrganizer_PhotoCell
}
