//
//  NewPhotoSelectionViewController.swift
//  2017-dishrank-ios
//
//  Created by tony on 2018/5/10.
//

import Photos
import UIKit

class NewPhotoSelectionViewController: PhotoSelectionViewController {
  //var dishReview: PhotoDishReview?
  var cellIndexPath: IndexPath?
  //weak var delegate: SelectorViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

//  @objc override func importToNextVc() {
//    guard let selectedItems = collectionView.indexPathsForSelectedItems else {
//      return
//    }
//    resultAssets = [PHAsset]()
//    for indexPath in selectedItems {
//      let sectionAssets = assets[indexPath.section]
//      let asset = sectionAssets[indexPath.row]
//      resultAssets.append(asset)
//    }
//
//    if let nvc = self.navigationController as? CustomCameraNVC {
//      nvc.assets = resultAssets
//      if
//        let dishReview = dishReview,
//        let cellIndexPath = cellIndexPath {
//        nvc.dishReview = dishReview
//        nvc.cellIndexPath = cellIndexPath
//      }
//      nvc.savePHAsset()
//    }
//
//    dismiss(animated: true, completion: nil)
//  }

//  @objc override func cancel() {
//    dismiss(animated: true, completion: {
//       self.delegate?.presentSelector(dishReview: self.dishReview, indexPath: self.cellIndexPath)
//    })
//  }

  @IBAction func clickCancelButton(_: UIBarButtonItem) {
    //cancel()
  }

  @IBAction func clickImportButton(_: UIBarButtonItem) {
    //importToNextVc()
  }
}
