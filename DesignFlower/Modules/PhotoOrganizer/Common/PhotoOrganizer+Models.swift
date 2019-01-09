//
//  PhotoOrganizerModels.swift
//  DishRank
//
//  Created by Roy Hu on 2018/10/22.
//

import UIKit
import Photos
import Kingfisher

class PhotoOrganizer {
  
  struct DishItem {
    var dishReview: KVODishReviewV4?
    var itemIndex: Int?
  }
  
  enum DishModification {
    case changeDishName(_ name: String?)
    case changeComment(_ comment: String?)
    case changePhoto(_ photo: ImageRepresentation?)
    case changeRating(_ rating: Float?)
    case deleteDishReview
  }
  
  enum ImageRepresentation {
    case image(_ image: UIImage?)
    case url(_ url: String?)
    case localFile(_ path: String?)
    case phAsset(_ asset: PHAsset?)
  }
}


extension PhotoOrganizer.ImageRepresentation {
  func fetchImage(completion: @escaping (UIImage?) -> Void) {
    switch self {
    case .image(let image):
      completion(image)
    case .phAsset(let asset):
      guard let asset = asset
      else { completion(nil); break }
      
      let manager = PHImageManager.default()
      let options = PHImageRequestOptions()
      options.isSynchronous = false
      manager.requestImage(for: asset,
                           targetSize: PHImageManagerMaximumSize,
                           contentMode: .aspectFit,
                           options: options) { (image, info) in
        completion(image)
      }
      
    case .url(let url):
      guard let url = URL(string: url ?? "")
      else { completion(nil); break }
      
      KingfisherManager.shared.retrieveImage(with: url,
                                             options: nil,
                                             progressBlock: nil) {
          (image, error, cacheType, url) in
        completion(image)
      }
    case .localFile(let path):
      guard let url = URL(string: path ?? "")
      else { completion(nil); break }

      do {
        let data = try Data.init(contentsOf: url)
        let image = UIImage.init(data: data, scale: 1)
        completion(image)
      } catch(let error) {
        print(error)
        completion(nil)
      }
    }
  }
}
