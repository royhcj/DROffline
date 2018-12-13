//
//  CityModel.swift
//  DishRank
//
//  Created by 朱紹翔 on 2018/10/31.
//

import Foundation
class FBSearchCityModel: Codable {
  let data: Array<CityModel>
}
class CityModel: Codable {
  let key: String
  let name: String
  let type: String
  let countryCode: String
  let countryName: String
  let region: String?
  let regionId: Int?
  let supportsRegion: Bool
  let supportsCity: Bool
}
