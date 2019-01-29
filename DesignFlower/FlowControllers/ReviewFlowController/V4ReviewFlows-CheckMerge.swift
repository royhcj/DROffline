//
//  V4ReviewFlows-CheckMerge.swift
//  DesignFlower
//
//  Created by Roy Hu on 2019/1/28.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import CoreLocation

extension V4ReviewFlows {
  class CheckMergeFlow: ReviewBaseFlow {
    override func execute() {
      fetchMergeableReview() { mergeableReviewUUID in
        if let uuid = mergeableReviewUUID {
          self.flowController.loadReview(uuid)
          self.flowController.showReviewVC()
        } else {
          let flow = AddNewPhotoFlow(flowController: self.flowController)
          flow.execute()
          self.flowController.showReviewVC()
        }
      }

    }
    
    func fetchMergeableReview(completion: ((String?) ->())?) {
      guard let latitude = LocationService.shared.coordinate?.latitude,
            let longitude = LocationService.shared.coordinate?.longitude,
            let accessToken = LoggedInUser.sharedInstance().accessToken
      else {
        completion?(nil)
        return
      }
      
      WebService.NoteReviewAPI.checkLastReview(accessToken: accessToken, latitude: latitude.description, longitude: longitude.description).then { json -> Void in
        if json["statusCode"].int == 0,
          let restaurantReviewID = json["restaurantReviewID"].int {
          //completion?(restaurantReviewID)
          if let rlmReview = RLMServiceV4.shared.getRestReview(uuid: nil, id: restaurantReviewID) {
            completion?(rlmReview.uuid)
          } else {
            completion?(nil)
          }
        } else {
          completion?(nil)
        }
      }.catch { error in
        print(error)
        completion?(nil)
      }
      
#if false
      let currentLocation = CLLocation(latitude: CLLocationDegrees(latitude),
                                       longitude: CLLocationDegrees(longitude))
      
      let date = Date.now.added(.minute, by: -30)
      
      //let predicate = NSPredicate(format: "updateDate >= %@", date.description)
      let rlmReviews = RLMServiceV4.shared.getRestReviews().filter { (review) -> Bool in
        if let updateDate = review.updateDate {
          return updateDate > date
        } else {
          return false
        }
      }
      let mergeable = rlmReviews.first(where: { (review) -> Bool in
        guard let latitude = review.restaurant?.latitude.value,
              let longitude = review.restaurant?.longitude.value
        else {
          return false
        }
        let location = CLLocation(latitude: CLLocationDegrees(latitude),
                                  longitude: CLLocationDegrees(longitude))
        let distance = location.distance(from: currentLocation)
        print("distance \(distance)")
        return distance < 50
      })
      
      if let mergeable = mergeable {
        completion?(mergeable.uuid)
      } else {
        completion?(nil)
      }
#endif
      
    }
  }
  
  
}
