//
//  Double+Extension.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/14.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

extension Float {
  func toString(format: String? = nil) -> String {
    return String(format: format ?? "%.1f", self)
  }
  func format(float: Float?) -> String? {
    guard let float = float else {
      return nil
    }
    return String(format: "%.1f", float)
  }
}
