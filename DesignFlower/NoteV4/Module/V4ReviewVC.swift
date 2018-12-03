//
//  V4ReviewVC.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class V4ReviewVC: FlowedViewController,
                  UITableViewDataSource,
                  UITableViewDelegate {
  
  var flowDelegate: FlowDelegate?
  
  var viewModel: V4ReviewViewModel?
  
  @IBOutlet var tableView: UITableView!
 
  // MARK: - ► Object lifecycle
  
  static func make(flowDelegate: FlowDelegate?, viewModel: V4ReviewViewModel) -> V4ReviewVC {
    let vc = UIStoryboard(name: "V4Review", bundle: nil)
              .instantiateViewController(withIdentifier: "V4ReviewVC")
              as! V4ReviewVC
    return vc
  }
  
  // MARK: - ► View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - ► Table DataSource/Delegate
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  
  typealias FlowDelegate = V4ReviewVCFlowDelegate
}


protocol V4ReviewVCFlowDelegate {
  
}
