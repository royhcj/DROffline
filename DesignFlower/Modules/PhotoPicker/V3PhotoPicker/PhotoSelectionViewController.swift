//
//  photoSelectionViewController.swift
//  2017-dishrank-ios
//
//  Created by tony on 2018/3/14.
//

import Photos
import UIKit

protocol HeaderCellDelegate: class {
  func selectAll(indexPath: IndexPath)
  func deSelectAll(indexPath: IndexPath)
}

class HeaderCell: UICollectionReusableView {
  @IBOutlet var selectAllButton: UIButton!
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var locationLabel: UILabel!
  @IBOutlet var photoCountsLabel: UILabel!
  @IBOutlet var fakeSelectAllButton: UIButton!
  var indexPath: IndexPath?
  weak var delegate: HeaderCellDelegate?

  @IBAction func clickSelectAllButton(_: UIButton) {
    if let indexPath = indexPath {
      if !selectAllButton.isSelected {
        delegate?.selectAll(indexPath: indexPath)
      } else {
        delegate?.deSelectAll(indexPath: indexPath)
      }
    }
  }

  override func awakeFromNib() {
    selectAllButton.isSelected = false
    let unSelectedImage = UIImage(named: "checkbox_none")
    let selectedImage = UIImage(named: "checkbox_check")
    selectAllButton.setImage(unSelectedImage, for: .normal)
    selectAllButton.setImage(selectedImage, for: .selected)
  }
}

class SelectionPhotoCell: UICollectionViewCell {
  var asset: PHAsset?
  @IBOutlet var selectedButton: UIButton!
  @IBAction func clickSelectedButton(_: UIButton) {
    selectedButton.isSelected = !selectedButton.isSelected

    if selectedButton.isSelected {
      selectedButton.alpha = 1
    } else {
      selectedButton.alpha = 0.4
    }
  }

  override func awakeFromNib() {
    let unSelectedImage = UIImage(named: "checkbox_none")
    let selectedImage = UIImage(named: "checkbox_check")
    selectedButton.setImage(unSelectedImage, for: .normal)
    selectedButton.setImage(selectedImage, for: .selected)
  }

  // override func state
  override var isSelected: Bool {
    didSet {
      selectedButton.isSelected = isSelected
      if isSelected {
        selectedButton.alpha = 1
      } else {
        selectedButton.alpha = 0.4
      }
    }
  }
}

class PhotoSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var restaurantTitle: UILabel!

  var assetsFetchResults: PHFetchResult<PHAsset>?
  var assetGridThumbnailSize: CGSize!
  var imageManager: PHCachingImageManager!
  var locationTitle: String?
  var assets: [[PHAsset]] = [] {
    didSet {
      refreshAssets()
    }
  }
  var resultAssets: [PHAsset] = []
  var limitCount = 10 // 複選最高上限

  override func viewDidLoad() {
    super.viewDidLoad()

    // 開啟多選
    collectionView.allowsSelection = true
    collectionView.allowsMultipleSelection = true
    // 申请权限
    PHPhotoLibrary.requestAuthorization({ status in
      if status != .authorized {
        return
      }

      // 则获取所有资源
      let allPhotosOptions = PHFetchOptions()
      // 按照创建时间倒序排列
      allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                           ascending: false)]
      // 只获取图片
      allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                               PHAssetMediaType.image.rawValue)
      self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                    options: allPhotosOptions)

      // 初始化和重置缓存
      self.imageManager = PHCachingImageManager()
      self.imageManager.stopCachingImagesForAllAssets()

      // 設定assets分類
      DispatchQueue.main.async {
        self.assets = self.makePhotoGroup()
      }

    })
#if false // TODO:
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "匯入",
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(importToNextVc))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "上一步",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(cancel))
#endif
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

//    if let nvc = navigationController as? CustomCameraNVC {
//      // 所在餐廳
//      restaurantTitle.text = nvc.restaurant?.shopName
//    }

#if false // TODO:
    // barUI設定
    navigationController?.navigationBar.barTintColor = .white
    navigationController?.navigationBar.tintColor = DishRankColor.darkBrownColor
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: DishRankColor.darkBrownColor]
#endif
    navigationItem.title = "選擇照片"
//    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "匯入",
//                                                        style: .plain,
//                                                        target: self,
//                                                        action: #selector(importToNextVc))
//    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "上一步",
//                                                       style: .plain,
//                                                       target: self,
//                                                       action: #selector(cancel))

    let scale = UIScreen.main.scale
    if let cellSize = (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize {
      assetGridThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
  }

  func makePhotoGroup() -> [[PHAsset]] {
    var allAssets: [PHAsset] = []
    for index in 0 ..< (assetsFetchResults?.count ?? 0) {
      if let asset = assetsFetchResults?.object(at: index) {
        allAssets.append(asset)
      }
    }

    var dictionary: [Date: [PHAsset]] = [:]
    for asset in allAssets {
      guard let date = asset.creationDate else { continue }
      let startOfDay = date.startOfDay()
      if dictionary[startOfDay] == nil {
        dictionary[startOfDay] = []
      }
      dictionary[startOfDay]?.append(asset)
    }

    let groups = dictionary.map { (_, assets) -> [PHAsset] in
      assets
    }

    let groupArray = groups.sorted { (assets1, assets2) -> Bool in
      if let date1 = assets1.first?.creationDate, let date2 = assets2.first?.creationDate {
        return date1 >= date2
      }
      return false
    }
    return groupArray
  }

  @discardableResult func isSectionAssetsAllSelected(assetIndex: IndexPath) -> Bool {
    var selectedBool = Bool()
    let sectionAssets = assets[assetIndex.section]

    let filterAssets = collectionView.indexPathsForSelectedItems?.filter({ (headerIndexPath) -> Bool in
      assetIndex.section == headerIndexPath.section
    })

    let firstIndexPath = IndexPath(item: 0, section: assetIndex.section)
    if let headerCell = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firstIndexPath) as? HeaderCell {
      if sectionAssets.count == filterAssets?.count {
        headerCell.selectAllButton.isSelected = true
        selectedBool = true
      } else {
        headerCell.selectAllButton.isSelected = false
        selectedBool = false
      }
    }
    return selectedBool
  }

  func locationConvertToPlaceName(location: CLLocation) {
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in

      // Place details
      var placeMark: CLPlacemark?
      placeMark = placemarks?[0]

      // Location name
      if let locationName = placeMark?.locality {
        self.locationTitle = locationName
      }
    })
  }

//  @objc func importToNextVc() {
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
//      nvc.savePHAsset()
//    }
//
//    UIView.animate(withDuration: 0.5, animations: {
//      guard let navView = self.navigationController?.view else { return }
//      var targetFrame = navView.bounds
//      targetFrame.origin.y = targetFrame.size.height
//      navView.frame = targetFrame
//    }, completion: { [weak self] _ in
//      self?.navigationController?.view.removeFromSuperview()
//      self?.navigationController?.removeFromParentViewController()
//
//    })
//  }

  @objc func cancel() {
    navigationController?.popViewController(animated: true)
  }

  func numberOfSections(in _: UICollectionView) -> Int {
    return assets.count
  }

  func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return assets[section].count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = (self.collectionView?.dequeueReusableCell(
      withReuseIdentifier: "SelectionPhotoCell", for: indexPath)) as? SelectionPhotoCell else {
      return UICollectionViewCell()
    }

    (cell.contentView.viewWithTag(1) as? UIImageView)?.image = nil

    let sectionAssets = assets[indexPath.section]
    let asset = sectionAssets[indexPath.row]

    cell.asset = asset
    cell.selectedButton.isUserInteractionEnabled = false
    // 获取缩略图
    imageManager.requestImage(for: asset,
                              targetSize: assetGridThumbnailSize,
                              contentMode: PHImageContentMode.aspectFill,
                              options: nil) { image, _ in
      (cell.contentView.viewWithTag(1) as? UIImageView)?.image = image
    }

    cell.isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
    return cell
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectAssets(at: [indexPath])
  }

  func collectionView(_: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    deselectAssets(at: [indexPath])
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt _: IndexPath) -> Bool {
    if let count = collectionView.indexPathsForSelectedItems?.count,
      count < limitCount || collectionView.allowsMultipleSelection == false {
      return true
    }
    let alert = UIAlertController(title: "注意！", message: "上限為\(limitCount)張照片", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
    return false
  }

  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionHeader {
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                    withReuseIdentifier: "header",
                                                    for: indexPath) as? HeaderCell {
        let sectionAssets = assets[indexPath.section]
        let asset = sectionAssets[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        headerView.timeLabel.text = dateFormatter.string(from: asset.creationDate ?? Date())

        headerView.selectAllButton.isSelected = false

        if let location = asset.location {
          locationConvertToPlaceName(location: location)
        }

        let filterAssets = collectionView.indexPathsForSelectedItems?.filter({ (headerIndexPath) -> Bool in
          indexPath.section == headerIndexPath.section
        })

        if sectionAssets.count == filterAssets?.count {
          headerView.selectAllButton.isSelected = true
        }

        let allowsMultipleSelection = collectionView.allowsMultipleSelection
        headerView.selectAllButton.isEnabled = allowsMultipleSelection
        headerView.fakeSelectAllButton.isEnabled = allowsMultipleSelection

        headerView.delegate = self
        headerView.indexPath = indexPath
        headerView.photoCountsLabel.text = String(sectionAssets.count)
        headerView.locationLabel.text = locationTitle
        return headerView
      }
    }
    return UICollectionReusableView()
  }

  // MARK: - Refresh Methods
  func refreshAssets() {
    collectionView.reloadData()
    reloadInitialAssetSelections()
  }

  // MARK: - Selection Manipulation
  open func selectAssets(at indexPaths: [IndexPath]) {
    indexPaths.forEach {
      self.collectionView.selectItem(at: $0, animated: false, scrollPosition: .centeredHorizontally)
    }
    Set(indexPaths).forEach {
      self.isSectionAssetsAllSelected(assetIndex: $0)
    }
  }

  open func deselectAssets(at indexPaths: [IndexPath]) {
    indexPaths.forEach {
      self.collectionView.deselectItem(at: $0, animated: false)
    }
    Set(indexPaths).forEach {
      self.isSectionAssetsAllSelected(assetIndex: $0)
    }
  }

  open func reloadInitialAssetSelections() {
  }
}

extension PhotoSelectionViewController: HeaderCellDelegate, UICollectionViewDelegateFlowLayout {
  func deSelectAll(indexPath: IndexPath) {
    let sectionAssets = assets[indexPath.section]

    var indexPaths: [IndexPath] = []
    for item in 0 ..< sectionAssets.count {
      let indexPath = IndexPath(item: item, section: indexPath.section)
      indexPaths.append(indexPath)
    }
    deselectAssets(at: indexPaths)
  }

  func selectAll(indexPath: IndexPath) {
    let sectionAssets = assets[indexPath.section]

    var indexPaths: [IndexPath] = []
    let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
    for item in 0 ..< sectionAssets.count {
      let indexPath = IndexPath(item: item, section: indexPath.section)
      if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
        continue
      }
      if selectedCount + indexPaths.count < limitCount {
        indexPaths.append(indexPath)
      } else {
        let alert = UIAlertController(title: "注意！", message: "上限為\(limitCount)張照片", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        break
      }
    }
    selectAssets(at: indexPaths)
  }

  func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    let width = (collectionView.contentSize.width - 30) / 3
    return CGSize(width: width, height: width)
  }
}
