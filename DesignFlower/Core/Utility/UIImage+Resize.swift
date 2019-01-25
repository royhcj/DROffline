//
//  UIImage+Resize.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/9/17.
//

import UIKit

extension UIImage {
  
  enum ResizeResolution {
    case original
    case fullHD
    case custom(width: Int, height: Int)
  }
  
  enum ResizeError: Error {
    case invalidOriginalSize
    case invalidTargetSize
    case failedGettingImageContext
  }
  
  static func resize(image: UIImage,
                     to resolution: ResizeResolution,
                     keepAspectRatio: Bool = true,
                     scaleDownOnly: Bool = false) throws -> UIImage {
    guard image.size.width > 0,
          image.size.height > 0 else {
      throw ResizeError.invalidOriginalSize
    }
    
    var size = image.size
    switch resolution {
      case .original:
        return image
      case .fullHD:
        size = CGSize(width: 1920, height: 1080)
      case .custom(let width, let height):
        size = CGSize(width: width, height: height)
    }
    
    var scaleX = size.width / image.size.width
    var scaleY = size.height / image.size.height
    
    if keepAspectRatio {
      scaleX = min(scaleX, scaleY)
      scaleY = scaleX
    }
    
    if scaleDownOnly, scaleX >= 1.0 && scaleY >= 1.0 {
      return image
    }
    
    size = CGSize(width: image.size.width * scaleX,
                  height: image.size.height * scaleY)
    
    
    guard size.width > 0,
          size.height > 0 else {
        throw ResizeError.invalidTargetSize
    }
    
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: size))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let newImage = resizedImage else {
      throw ResizeError.failedGettingImageContext
    }
    
    return newImage
  }
  
}
