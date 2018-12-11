//
//  Location.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/12/11.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import MapKit

struct Location {
  var coordinate: CLLocationCoordinate2D
  var sourceType: SourceType
  
  enum SourceType {
    case defaultLocation  // 預設位置
    case GPS              // GPS位置
    case previousGPS      // 上次GPS位置
  }
}

