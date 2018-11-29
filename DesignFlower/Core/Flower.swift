//
//  Flower.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation

class Flower {
  
  var children: [Flower] = []
  
  func prepare() {
    
  }
  
  func start() {
    
  }
  
  func addChild(_ flower: Flower) {
    children.append(flower)
  }
}


class ViewFlower: Flower {
  func handle(viewLifecycle: ViewLifecycle) {
    
  }
}

enum ViewLifecycle {
  case viewDidLoad
  case viewWillAppear(_ isFirstTimeAppear: Bool)
  case viewDidAppear(_ isFirstTimeAppear: Bool)
  case viewWillDisappear
  case viewDidDisappear
}
