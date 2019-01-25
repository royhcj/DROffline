//
//  NetworkStateService.swift
//  2017-dishrank-ios
//
//  Created by 馮仰靚 on 2018/9/19.
//

import Reachability

public class NetworkStateService {

  static let shared = CustomReachability()

  public class CustomReachability {
    let reachability = Reachability()!

    init() {
      NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
      do {
        try reachability.startNotifier()
      } catch {
        print("could not start reachability notifier")
      }
    }

    @objc func reachabilityChanged(note: Notification) {
      let reachability = note.object as! Reachability
      switch reachability.connection {
      case .wifi:
        print("Reachable via WiFi")
      case .cellular:
        print("Reachable via Cellular")
      case .none:
        print("Network not reachable")
      }
    }
  }

}
