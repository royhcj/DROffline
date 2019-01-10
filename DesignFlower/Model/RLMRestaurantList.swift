//
//  RLMRestaurantList.swift
//  DesignFlower
//
//  Created by 馮仰靚 on 2019/1/4.
//  Copyright © 2019 test. All rights reserved.
//

/*
 名稱    說明
 rd_anum 即id
 created_by    建立者
 md_anum    會員ID
 md_anum_recommend    DR推薦ID
 rd_name    名稱
 rd_ename    英文名稱
 rd_branch    分店名稱
 rd_full_address    完整地址
 apple_address    Apple地址
 rd_address_country    國家ID
 rd_address_code    郵遞區號
 rd_address_city    城市ID
 rd_address_area    區域ID
 rd_address_street    街道
 rd_address_english    英文地址
 rd_tel    電話
 rd_traffic    交通指南
 rd_seat    座位數
 rd_parking    停車位
 rd_consume_min    消費區間-最小值
 rd_consume_max    消費區間-最大值
 rd_url    餐廳官網
 rd_business_note
 rd_introduction    餐廳介紹
 rd_status    營業狀態
 rd_check    審核狀態
 rd_enabled    營運狀況：營業、停業
 rd_dr_recommend    是否為DR推薦
 recommended_at    DR推薦時間
 rd_utime    最後修改時間
 rd_uip    最後修改IP
 rd_btime    發布時間
 rd_note    備註
 rd_bip    發布IP
 rd_ctime    建立時間
 rd_cip    建立IP
 rd_etime    停用時間
 rd_eip    停用IP
 publish_status    發布狀態
 audit_reason    審核未通過原因
 deleted_at    軟刪除
 latitude    經度
 longitude    緯度
 rd_type    餐廳類型
 number    餐廳編號
 is_signed    是否為已簽約餐廳
 place_id
 views    瀏覽次數
 */

import Foundation
import RealmSwift

class RLMRestaurantList: Object {
  var id = RealmOptional<Int>()
  var rdAnum = RealmOptional<Int>()
  var createdBy = RealmOptional<Int>()
  var mdAnum = RealmOptional<Int>()
  var mdAnumRecommend = RealmOptional<Int>()
  @objc dynamic var rdName, rdEname, rdBranch: String?
  @objc dynamic var  rdFullAddress: String?
  @objc dynamic var  appleAddress: String?
  let rdAddressCountry = RealmOptional<Int>()
  @objc dynamic var  rdAddressCode: String?
  var rdAddressCity = RealmOptional<Int>()
  var rdAddressArea = RealmOptional<Int>()
  @objc dynamic var  rdAddressStreet, rdAddressEnglish, rdTel, rdTraffic: String?
  @objc dynamic var  rdSeat, rdParking: String?
  var rdConsumeMin = RealmOptional<Int>()
  var rdConsumeMax = RealmOptional<Int>()
  @objc dynamic var  rdURL: String?
  @objc dynamic var  rdBusinessNote: String?
  @objc dynamic var  rdIntroduction: String?
  var rdStatus = RealmOptional<Int>()
  var rdCheck = RealmOptional<Int>()
  var rdEnabled = RealmOptional<Int>()
  var rdDRRecommend = RealmOptional<Int>()
  @objc dynamic var  recommendedAt: String?
  @objc dynamic var  rdUtime: Date?
  @objc dynamic var  rdUip: String?
  @objc dynamic var  rdBtime: Date?
  @objc dynamic var  rdNote, rdBip, rdEip, rdCip: String?
  @objc dynamic var  rdEtime, rdCtime: Date?
  var publishStatus = RealmOptional<Int>()
  @objc dynamic var  auditReason: String?
  @objc dynamic var  deletedAt: String?
  var latitude = RealmOptional<Float>()
  var longitude = RealmOptional<Float>()
  @objc dynamic var  rdType: String?
  @objc dynamic var  number: String?
  var isSigned = RealmOptional<Int>()
  @objc dynamic var  placeID: String?
  var views = RealmOptional<Int>()

}

struct RestaurantList: Codable {
  let data: [Datum]?
  let links: Links?
  let meta: Meta?
}

struct Datum: Codable {
  let type: String?
  let id: Int?
  let attributes: Attributes?
}

struct Attributes: Codable {
  let rdAnum: Int?
  let createdBy: Int?
  let mdAnum: Int?
  let mdAnumRecommend: Int?
  let rdName, rdEname, rdBranch: String?
  let rdFullAddress: String?
  let appleAddress: String?
  let rdAddressCountry: Int?
  let rdAddressCode: String?
  let rdAddressCity, rdAddressArea: Int?
  let rdAddressStreet, rdAddressEnglish, rdTel, rdTraffic: String?
  let rdSeat, rdParking: String?
  let rdConsumeMin, rdConsumeMax: Int?
  let rdURL: String?
  let rdBusinessNote: String?
  let rdIntroduction: String?
  let rdStatus, rdCheck: Int?
  let rdEnabled: Int?
  let rdDRRecommend: Int?
  let recommendedAt: String?
  let rdUtime: Date?
  let rdUip: String?
  let rdBtime: Date?
  let rdNote, rdBip, rdEip, rdCip: String?
  let rdEtime, rdCtime: Date?
  let publishStatus: Int?
  let auditReason: String?
  let deletedAt: String?
  let latitude, longitude: Float?
  let rdType: String?
  let number: String?
  let isSigned: Int?
  let placeID: String?
  let views: Int?

  enum CodingKeys: String, CodingKey {
    case rdAnum = "rd_anum"
    case createdBy = "created_by"
    case mdAnum = "md_anum"
    case mdAnumRecommend = "md_anum_recommend"
    case rdName = "rd_name"
    case rdEname = "rd_ename"
    case rdBranch = "rd_branch"
    case rdFullAddress = "rd_full_address"
    case appleAddress = "apple_address"
    case rdAddressCountry = "rd_address_country"
    case rdAddressCode = "rd_address_code"
    case rdAddressCity = "rd_address_city"
    case rdAddressArea = "rd_address_area"
    case rdAddressStreet = "rd_address_street"
    case rdAddressEnglish = "rd_address_english"
    case rdTel = "rd_tel"
    case rdTraffic = "rd_traffic"
    case rdSeat = "rd_seat"
    case rdParking = "rd_parking"
    case rdConsumeMin = "rd_consume_min"
    case rdConsumeMax = "rd_consume_max"
    case rdURL = "rd_url"
    case rdBusinessNote = "rd_business_note"
    case rdIntroduction = "rd_introduction"
    case rdStatus = "rd_status"
    case rdCheck = "rd_check"
    case rdEnabled = "rd_enabled"
    case rdDRRecommend = "rd_dr_recommend"
    case recommendedAt = "recommended_at"
    case rdUtime = "rd_utime"
    case rdUip = "rd_uip"
    case rdBtime = "rd_btime"
    case rdNote = "rd_note"
    case rdBip = "rd_bip"
    case rdCtime = "rd_ctime"
    case rdCip = "rd_cip"
    case rdEtime = "rd_etime"
    case rdEip = "rd_eip"
    case publishStatus = "publish_status"
    case auditReason = "audit_reason"
    case deletedAt = "deleted_at"
    case latitude, longitude
    case rdType = "rd_type"
    case number
    case isSigned = "is_signed"
    case placeID = "place_id"
    case views
  }
}

struct Links: Codable {
  let first, last: String?
  let prev: String?
  let next: String?
}

struct Meta: Codable {
  let currentPage, from, lastPage: Int?
  let path: String?
  let perPage, to, total: Int?
  let rdUtimeMax: String?

  enum CodingKeys: String, CodingKey {
    case currentPage = "current_page"
    case from
    case lastPage = "last_page"
    case path
    case perPage = "per_page"
    case to, total
    case rdUtimeMax = "rd_utime_max"
  }
}
