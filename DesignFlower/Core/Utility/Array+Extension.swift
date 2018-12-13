//
//  Array+Extension.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/6/26.
//

import Foundation

extension Array {
  func at(_ index: Int) -> Element? {
    if index < count {
      return self[index]
    }
    return nil
  }
}
