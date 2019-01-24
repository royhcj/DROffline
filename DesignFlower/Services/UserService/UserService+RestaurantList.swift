//
//  UserService.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/21.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import SVProgressHUD

extension UserService {
  class RestaurantList {
    static func getRestList(strat: Date? = nil, end: Date? = nil, paramaters: [RestaurantListParamater]? = nil, next url: String? = nil, completion: ((Bool) -> ())? = nil ) {

      if !SVProgressHUD.isVisible() {
        UserDefaults.standard.set(Date(), forKey: UserDefaultKey.rdUtimeMax.rawValue)
        SVProgressHUD.show(withStatus: "檢查資料是否需要更新...")
      }

      let provider = DishRankService.RestList.provider
      provider.request(.getList(start: strat, end: end, paramaters: paramaters, next: url)) { (response) in
        switch response {
        case .success(let response):
          do {
            let decoder = DRDecoder.decoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let list = try decoder.decode(APIResponse.self, from: response.data)
            SVProgressHUD.show(withStatus: "餐廳列表更新中...\(list.meta?.currentPage ?? 0)/\(list.meta?.lastPage ?? 0)")
            if let next = list.links?.next, next != "" {
              updateRestaurantList(list: list, completion: { (finish) in
                if finish {
                  let max = Date.getDate(any: list.meta?.rdUtimeMax)
                  UserDefaults.standard.set(max, forKey: UserDefaultKey.rdUtimeMax.rawValue)
                  self.getRestList(strat: nil, end: nil, paramaters: nil, next: list.links?.next)
                }
              })
            } else {
              // 最後一筆進來這
              updateRestaurantList(list: list) {
                guard $0 else {
                  SVProgressHUD.show(withStatus: "更新失敗")
                  SVProgressHUD.dismiss(withDelay: 1)
                  return
                }
                let min = Date.getDate(any: list.meta?.rdUtimeMax)
                UserDefaults.standard.set(min, forKey: UserDefaultKey.rdUtimeMin.rawValue)
                UserDefaults.standard.set(nil, forKey: UserDefaultKey.rdUtimeMax.rawValue)
                SVProgressHUD.show(withStatus: "餐廳列表更新完成")
                // 取得歷史筆記
                SVProgressHUD.show(withStatus: "開始下載舊有筆記")
                let upMin = UserDefaults.standard.value(forKey: UserDefaultKey.updateDateMin.rawValue) as? Date
                let upMax = UserDefaults.standard.value(forKey: UserDefaultKey.updateDateMax.rawValue) as? Date
                UserService.RestReview.getRestaurantReview(updateDateMin: upMin, updateDateMax: upMax, url: nil)
              }
              completion?(true)
            }

          } catch {
            SVProgressHUD.show(withStatus: "更新失敗")
            SVProgressHUD.dismiss(withDelay: 1)
            print("transfer to json error")
          }
        case .failure(let error):
          print(error)
        }
      }
    }
    private static func update(RdUtimeMax: String) {
      let formatter = DateFormatter()
      formatter.dateFormat = dateStyle
      if let date = formatter.date(from: RdUtimeMax) {
        UserDefaults.standard.set(date, forKey: "rdUtimeMax")
      }
    }
    private static func updateRestaurantList(list: APIResponse, completion: ((Bool) -> ())?) {

      guard let restlist = list.data else {
        completion?(false)
        return
      }

      for rest in restlist {
        guard let attributes = rest.attributes else {
          continue
        }
        if let existRest = RLMServiceV4.shared.getRestaurantList(id: rest.id).first {
          // 有就更新
          RLMServiceV4.shared.updateList(attributes: attributes, to: existRest)
        } else {
          // 沒有就新增
          RLMServiceV4.shared.restListToRLMRestList(copyBy: attributes)
        }
      }
      completion?(true)

    }
  }
}
