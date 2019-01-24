//
//  DRDecoder.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/24.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import Moya

class DRDecoder {

  static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
  }

  static func encoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    return encoder
  }
}
