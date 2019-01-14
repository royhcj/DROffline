//
//  AppDelegate.swift
//  DesignFlower
//
//  Created by Roy Hu on 2018/11/28.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

var dateStyle = "yyyy-MM-dd HH:mm:ss"

enum UserDefaultKey: String {
  case rdUtimeMax
  case rdUtimeMin // 餐廳列表上次更新的時間
  case token
  case updateDateMin // 筆記上次下載時間
  case updateDateMax
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var rootVC: UIViewController?
  var mainFlower: V4ReviewFlowController?
  var syncService = [SyncService]()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Setup Realm
    let config = Realm.Configuration(
      // Set the new schema version. This must be greater than the previously used
      // version (if you've never set a schema version before, the version is 0).
      schemaVersion: 0,
      
      // Set the block which will be called automatically when opening a Realm with
      // a schema version lower than the one set above
      migrationBlock: { migration, oldSchemaVersion in
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if oldSchemaVersion == 1 {
          // Nothing to do!
          // Realm will automatically detect new properties and removed properties
          // And will update the schema on disk automatically
          //migration.enumerateObjects(ofType: NoteImage.className()) { _, newObject in
          // combine name fields into a single field
          //newObject!["isCreate"] = false
          //}
        }
    })
    //    config.deleteRealmIfMigrationNeeded = true
    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config
    print("realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
    //start syncService
    syncService.append(SyncService.init(modelTypes: [RLMRestReviewV4.self]))
    syncService.append(SyncService.init(modelTypes: [RLMQueue.self], factory: .upload))
    if UserDefaults.standard.value(forKey: UserDefaultKey.token.rawValue) == nil {
      AutoLogin.login()
    } else {
      // 取得餐廳列表
      let min = UserDefaults.standard.value(forKey: UserDefaultKey.rdUtimeMin.rawValue) as? Date
      let max = UserDefaults.standard.value(forKey: UserDefaultKey.rdUtimeMax.rawValue) as? Date
      DishRankService.getRestList(strat: min, end: max, paramaters: nil)
      // 取得歷史筆記
      DishRankService.getRestaurantReview(updateDateMin: nil, updateDateMax: nil, url: nil)
    }
    
    IQKeyboardManager.shared.enable = true
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}


extension String: Error {
}
