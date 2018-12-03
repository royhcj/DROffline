//
//  V4ReviewFlows-AddNewPhoto.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/3.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

extension V4ReviewFlows {
  class AddNewPhotoFlow: ReviewBaseFlow {
    override func execute() {
      flowController.showPhotoPicker(.addNewPhotos)
    }
  }
}
