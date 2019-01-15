//
//  JSONable.swift
//  2017-dishrank-ios
//
//  Created by tony on 2017/9/7.
//
//

import SwiftyJSON

protocol JSONable {
  init(json: JSON)
}

extension JSON: JSONable {
  init(json: JSON) {
    self = json
  }
}
