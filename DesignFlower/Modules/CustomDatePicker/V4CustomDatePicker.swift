//
//  CustomDatePicker.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/5/31.
//

import Foundation
import UIKit

class V4CustomDatePickerVC: UIViewController {

  var callBack: ((Date?) -> ())?
  var initDate: Date?

  @IBOutlet weak var datePicker: UIDatePicker!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .clear
    if let date = initDate {
      datePicker.date = date
    }
  }

  override func didReceiveMemoryWarning() {
    print("memory warninig")
  }

  static func make(initDate: Date? ,callBack: ((Date?) -> ())?) -> V4CustomDatePickerVC {
    let vc = V4CustomDatePickerVC.init(nibName: "V4CustomDatePicker", bundle: nil)
    vc.callBack = callBack
    vc.initDate = initDate
    return vc
  }

  //取消
  @IBAction func down(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  //初始時間
  @IBAction func originDate(_ sender: Any) {
    update(date: Date(timeIntervalSince1970: 0))
    self.dismiss(animated: true, completion: nil)
  }

  //完成
  @IBAction func finish(_ sender: Any) {
     update(date: datePicker.date)
    self.dismiss(animated: true, completion: nil)
  }

  func update(date: Date?) {
    if let callBack = callBack {
      callBack(date)
    }
  }
}

