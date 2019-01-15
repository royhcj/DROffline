//
//  Configuration.swift
//  2017-dishrank-ios
//
//  Created by tony on 2017/9/7.
//
//

import Foundation

enum Environment: String {
  case staging = "Staging"
  case production = "Production"
  case qa = "QA"
  case beta = "Beta"

  var apiURL: String {
    switch self {
    case .staging:
      return "http://api-dev-v11.dishrank.com/app"
    case .production:
      return "http://api-v11.dishrank.com/app"
    case .qa:
      // old http://api-qa-v11.dishrank.com/app
      return "http://api.larvatadish.work/app"
    case .beta:
      return "http://api.larvatadish.services/app"
    }
  }
}

struct Configuration {
  lazy var environment: Environment = {
    return .qa
    /*
    if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
      if configuration.range(of: "Staging") != nil {
        return Environment.staging
      } else if configuration.range(of: "QA") != nil {
        return Environment.qa
      } else if configuration.range(of: "Beta") != nil {
        return Environment.beta
      }
    }
    return Environment.production
 */
  }()
}
