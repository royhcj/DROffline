//
//  NoteV3PhotoLibrarySelectionViewController.swift
//  2017-dishrank-ios
//
//  Created by Roy Hu on 2018/5/30.
//

import UIKit

protocol NoteV3PhotoLibrarySelectionViewControllerDelegate: class {
  func confirmSelections()
}

class NoteV3PhotoLibrarySelectionViewController: NewPhotoSelectionViewController {

  typealias Scenario = NoteV3PhotoPickerViewController.Scenario
  
  weak var selectionDelegate: NoteV3PhotoLibrarySelectionViewControllerDelegate?
  
  var scenario: Scenario = .addNewPhotos

  // MARK: - Object lifecycle
  static func make(scenario: Scenario, photoLimit: Int) -> NoteV3PhotoLibrarySelectionViewController? {
    let vc = UIStoryboard(name: "NoteV3PhotoLibrarySelection", bundle: nil)
              .instantiateViewController(withIdentifier: "NoteV3PhotoLibrarySelectionViewController")
              as? NoteV3PhotoLibrarySelectionViewController
    vc?.scenario = scenario
    vc?.limitCount = photoLimit
    return vc
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.allowsMultipleSelection = limitCount > 1
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    var titleText = "選擇照片"
    var backText = "返回"
    var doneText = "寫筆記"
    switch scenario {
    case .addNewPhotos, .addMorePhotos:
      titleText = "選擇照片"
      backText = "返回"
      doneText = "寫筆記"
    case .choosePhoto:
      titleText = "更改照片"
      backText = "取消"
      doneText = "確認"
    }
    
    navigationItem.title = titleText
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: doneText,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(clickedConfirm(_:)))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: backText,//image: UIImage(named: "6.Camara"),
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(clickedBack(_:)))
  }

  // MARK: - IB Actions

  @objc func clickedConfirm(_ sender: Any) {
    selectionDelegate?.confirmSelections()
  }

  @objc func clickedBack(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func clickedCamera(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  // MARK: - Selection Manipulation

  override func selectAssets(at indexPaths: [IndexPath]) {
    // Add selections to database
    indexPaths.forEach {
      let asset = assets[$0.section][$0.item]
      
      let selection = V4PhotoSelection(identifier: asset.localIdentifier,
                                       selectedDate: Date())
      V4PhotoService.shared.addPhotoSelection(selection,
                                              isSingle: limitCount == 1)
    }

    super.selectAssets(at: indexPaths)
  }

  override func deselectAssets(at indexPaths: [IndexPath]) {
    // Remove selections from database
    indexPaths.forEach {
      let asset = assets[$0.section][$0.item]
      V4PhotoService.shared.deleteNotePhotoSelection(with: asset.localIdentifier)
    }
    super.deselectAssets(at: indexPaths)
  }

  override func reloadInitialAssetSelections() {
    guard isViewLoaded else { return }

    // 取得之前選取的indexPaths
    let selectedIndexPaths: [IndexPath] = {
      var indexPaths: [IndexPath] = []
      
      let selections = V4PhotoService.shared.getPhotoSelections()
      for (section, assetGroup) in assets.enumerated() {
        for (item, asset) in assetGroup.enumerated() {
          if selections.contains(where: {
            $0.identifier == asset.localIdentifier
          }) {
            indexPaths.append(IndexPath(item: item, section: section))
          }
        }
      }
      return indexPaths
    }()

    selectedIndexPaths.forEach {
      self.collectionView.selectItem(at: $0, animated: false, scrollPosition: .centeredHorizontally)
    }

    // 更新section是否全選的勾勾
    Set(selectedIndexPaths.map { $0.section }).forEach {
      self.isSectionAssetsAllSelected(assetIndex: IndexPath(item: 0, section: $0))
    }
  }
}

// MARK: - NoteV3PhotoSelectionUpdatable

extension NoteV3PhotoLibrarySelectionViewController: NoteV3PhotoSelectionUpdatable {
  func updateNotePhotoSelections() {
    reloadInitialAssetSelections()
  }
}
