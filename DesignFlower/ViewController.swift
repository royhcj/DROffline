//
//  ViewController.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                      V4ReviewFlowController.Delegate {
  
  var reviewFlowController: V4ReviewFlowController?
  @IBOutlet weak var tableView: UITableView!
  var list : [RLMRestReviewV4] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }
  
  @IBAction func clickedWriteReview(_ sender: Any) {
    reviewFlowController = V4ReviewFlowController(scenario: .writeBegin)
    reviewFlowController?.delegate = self
    reviewFlowController?.prepare()
    reviewFlowController?.start()
  }
  
  
  
  func getDisplayContext(for sender: V4ReviewFlowController) -> DisplayContext {
    return .present(vc: self, animated: true, style: .fullScreen)
  }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    list = RLMServiceV4.shared.getRestReviewList() ?? []
    return list.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
    if let cell = cell as? ReviewCell {
      cell.title.text = list[indexPath.row].title
    }
    return cell
  }
}

class ReviewCell: UITableViewCell {

  @IBOutlet weak var title: UILabel!
}


