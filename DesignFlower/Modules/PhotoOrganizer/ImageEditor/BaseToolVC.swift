//
//  BaseToolVC.swift
//  RHImageCropper
//
//  Created by roy on 11/22/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class BaseToolVC: UIViewController {

    var contentView: UIView { return view }
    var toolbarView: UIView = UIView()
    
    var presenter: Presenter?
  
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func show(with presenter: Presenter) {
        presenter.toolPresenter.addChildViewController(self)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor(white: 0.05, alpha: 1)
        presenter.contentContainer.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: presenter.contentContainer.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: presenter.contentContainer.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: presenter.contentContainer.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: presenter.contentContainer.trailingAnchor).isActive = true
        
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.backgroundColor = .black
        presenter.toolbarContainer.addSubview(toolbarView)
        toolbarView.topAnchor.constraint(equalTo: presenter.toolbarContainer.topAnchor).isActive = true
        toolbarView.bottomAnchor.constraint(equalTo: presenter.toolbarContainer.bottomAnchor).isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: presenter.toolbarContainer.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: presenter.toolbarContainer.trailingAnchor).isActive = true
        
        didMove(toParentViewController: presenter.toolPresenter)
        
        self.presenter = presenter
    }
    

    typealias Presenter = BaseToolVCPresenter
}


protocol BaseToolVCPresenter {
    var toolPresenter: UIViewController { get }
    var contentContainer: UIView { get }
    var toolbarContainer: UIView { get }
    var imageToEdit: UIImage { get }
    func toolCancel(_ sender: BaseToolVC)
    func tool(_ sender: BaseToolVC, commit image: UIImage)
}

extension BaseToolVCPresenter where Self: UIViewController {
    var toolPresenter: UIViewController { get {
        return self
    } }
}
