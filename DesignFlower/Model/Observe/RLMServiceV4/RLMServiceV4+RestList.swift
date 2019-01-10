//
//  RLMServiceV4+RestList.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/9.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import RealmSwift

extension RLMServiceV4 {
  // no.1
  internal func restListToRLMRestList(copyBy attributes: Attributes) {
    do {
      try realm.write {
        let restList = realm.create(RLMRestaurantList.self)
        restList.rdAnum.value = attributes.rdAnum
        restList.createdBy.value = attributes.createdBy
        restList.mdAnum.value = attributes.mdAnum
        restList.mdAnumRecommend.value = attributes.mdAnumRecommend
        restList.rdName = attributes.rdName
        restList.rdEname = attributes.rdEname
        restList.rdBranch = attributes.rdBranch
        restList.rdFullAddress = attributes.rdFullAddress
        restList.appleAddress = attributes.appleAddress
        restList.rdAddressCountry.value = attributes.rdAddressCountry
        restList.rdAddressCode = attributes.rdAddressCode
        restList.rdAddressCity.value = attributes.rdAddressCity
        restList.rdAddressArea.value = attributes.rdAddressArea
        restList.rdAddressStreet = attributes.rdAddressStreet
        restList.rdAddressEnglish = attributes.rdAddressEnglish
        restList.rdTel = attributes.rdTel
        restList.rdTraffic = attributes.rdTraffic
        restList.rdSeat = attributes.rdSeat
        restList.rdParking = attributes.rdParking
        restList.rdConsumeMin.value = attributes.rdConsumeMin
        restList.rdConsumeMax.value = attributes.rdConsumeMax
        restList.rdURL = attributes.rdURL
        restList.rdBusinessNote = attributes.rdBusinessNote
        restList.rdIntroduction = attributes.rdIntroduction
        restList.rdStatus.value = attributes.rdStatus
        restList.rdCheck.value = attributes.rdCheck
        restList.rdEnabled.value = attributes.rdEnabled
        restList.rdDRRecommend.value = attributes.rdDRRecommend
        restList.recommendedAt = attributes.recommendedAt
        restList.rdUtime = attributes.rdUtime
        restList.rdUip = attributes.rdUip
        restList.rdBtime = attributes.rdBtime
        restList.rdNote = attributes.rdNote
        restList.rdBip = attributes.rdBip
        restList.rdEip = attributes.rdEip
        restList.rdCip = attributes.rdCip
        restList.rdEtime = attributes.rdEtime
        restList.rdCtime = attributes.rdCtime
        restList.publishStatus.value = attributes.publishStatus
        restList.auditReason = attributes.auditReason
        restList.deletedAt = attributes.deletedAt
        restList.latitude.value = attributes.latitude
        restList.longitude.value = attributes.longitude
        restList.rdType = attributes.rdType
        restList.number = attributes.number
        restList.isSigned.value = attributes.isSigned
        restList.placeID = attributes.placeID
        restList.views.value = attributes.views

      }
    } catch {
      print("RLMServiceV4+RestList file's no.1 func error")
    }
  }

  internal func getRestaurantList(id: Int? = nil) -> Results<RLMRestaurantList> {
    if let id = id {
      let predicate = NSPredicate(format: "rdAnum == \(id)")
      return realm.objects(RLMRestaurantList.self).filter(predicate)
    } else {
      return realm.objects(RLMRestaurantList.self)
    }
  }

  internal func updateList(attributes: Attributes, to restList: RLMRestaurantList) {
    do {
      try realm.write {
        restList.rdAnum.value = attributes.rdAnum
        restList.createdBy.value = attributes.createdBy
        restList.mdAnum.value = attributes.mdAnum
        restList.mdAnumRecommend.value = attributes.mdAnumRecommend
        restList.rdName = attributes.rdName
        restList.rdEname = attributes.rdEname
        restList.rdBranch = attributes.rdBranch
        restList.rdFullAddress = attributes.rdFullAddress
        restList.appleAddress = attributes.appleAddress
        restList.rdAddressCountry.value = attributes.rdAddressCountry
        restList.rdAddressCode = attributes.rdAddressCode
        restList.rdAddressCity.value = attributes.rdAddressCity
        restList.rdAddressArea.value = attributes.rdAddressArea
        restList.rdAddressStreet = attributes.rdAddressStreet
        restList.rdAddressEnglish = attributes.rdAddressEnglish
        restList.rdTel = attributes.rdTel
        restList.rdTraffic = attributes.rdTraffic
        restList.rdSeat = attributes.rdSeat
        restList.rdParking = attributes.rdParking
        restList.rdConsumeMin.value = attributes.rdConsumeMin
        restList.rdConsumeMax.value = attributes.rdConsumeMax
        restList.rdURL = attributes.rdURL
        restList.rdBusinessNote = attributes.rdBusinessNote
        restList.rdIntroduction = attributes.rdIntroduction
        restList.rdStatus.value = attributes.rdStatus
        restList.rdCheck.value = attributes.rdCheck
        restList.rdEnabled.value = attributes.rdEnabled
        restList.rdDRRecommend.value = attributes.rdDRRecommend
        restList.recommendedAt = attributes.recommendedAt
        restList.rdUtime = attributes.rdUtime
        restList.rdUip = attributes.rdUip
        restList.rdBtime = attributes.rdBtime
        restList.rdNote = attributes.rdNote
        restList.rdBip = attributes.rdBip
        restList.rdEip = attributes.rdEip
        restList.rdCip = attributes.rdCip
        restList.rdEtime = attributes.rdEtime
        restList.rdCtime = attributes.rdCtime
        restList.publishStatus.value = attributes.publishStatus
        restList.auditReason = attributes.auditReason
        restList.deletedAt = attributes.deletedAt
        restList.latitude.value = attributes.latitude
        restList.longitude.value = attributes.longitude
        restList.rdType = attributes.rdType
        restList.number = attributes.number
        restList.isSigned.value = attributes.isSigned
        restList.placeID = attributes.placeID
        restList.views.value = attributes.views
      }
    } catch {

    }
  }
}
