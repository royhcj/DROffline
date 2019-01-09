//
//  ImageEditorViewController.swift
//  RHImageCropper
//
//  Created by roy on 11/22/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class ImageEditorViewController: UIViewController,
                                 BaseToolVCPresenter {

    internal var contentContainer: UIView = UIView()
    internal var toolbarContainer: UIView = UIView()
    private let toolbarHeight: CGFloat = 40
    
    private var doneButton = UIButton()
    private var cancelButton = UIButton()
    
    private var imageView: UIImageView = UIImageView()
    
    private var image: UIImage?
    internal var imageToEdit: UIImage {
        return image ?? UIImage()
    }
    
    private var xformButton: UIButton = UIButton()
    
    private var currentTool: BaseToolVC?
    
    var showsXformToolOnly = false // 直接顯示"裁切工具"
    
    weak var delegate: ImageEditorDelegate?
  
    override var prefersStatusBarHidden: Bool { return true }
    
    private let blueColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    private let goldColor = UIColor(red: 220.0/255, green: 190.0/255.0, blue: 30.0/255.0, alpha: 1)
    
    // MARK: - Object lifecycle
    static func make(image: UIImage, delegate: ImageEditorDelegate?) -> ImageEditorViewController {
        let vc = ImageEditorViewController()
        vc.showsXformToolOnly = true
        vc.delegate = delegate
        vc.setImage(image)
        return vc
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        setupContainerViews()
        setupToolButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showsXformToolOnly {
            beginTool(XformToolVC()) // 直接顯示Tool VC
        }
      
        UIApplication.shared.isStatusBarHidden = true
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func setupContainerViews() {
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.backgroundColor = .black
        view.addSubview(toolbarContainer)
        toolbarContainer.heightAnchor.constraint(equalToConstant: toolbarHeight).isActive = true
        toolbarContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolbarContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        toolbarContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
      
        let bottomFill = UIView()
        bottomFill.translatesAutoresizingMaskIntoConstraints = false
        bottomFill.backgroundColor = toolbarContainer.backgroundColor
        view.addSubview(bottomFill)
        view.sendSubview(toBack: bottomFill)
        bottomFill.topAnchor.constraint(equalTo: toolbarContainer.topAnchor).isActive = true
        bottomFill.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomFill.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor).isActive = true
        bottomFill.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor).isActive = true
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = UIColor(white: 0.05, alpha: 1)
        view.addSubview(contentContainer)
        contentContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentContainer.bottomAnchor.constraint(equalTo: toolbarContainer.topAnchor).isActive = true
        contentContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        contentContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        contentContainer.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive  = true
        imageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive  = true
        imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor).isActive  = true
        imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor).isActive  = true
    }
    
    func setupToolButtons() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(blueColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(tappedCancel(_:)), for: .touchUpInside)
        toolbarContainer.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: toolbarContainer.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor, constant: 16).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.isEnabled = false
        doneButton.setTitle("完成", for: .normal)
        doneButton.setTitleColor(goldColor, for: .normal)
        doneButton.setTitleColor(.gray, for: .disabled)
        doneButton.addTarget(self, action: #selector(tappedDone(_:)), for: .touchUpInside)
        toolbarContainer.addSubview(doneButton)
        doneButton.topAnchor.constraint(equalTo: toolbarContainer.topAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor, constant: -16).isActive = true
        
        xformButton.translatesAutoresizingMaskIntoConstraints = false
        xformButton.setImage(UIImage(named: "photoedit_cut"), for: .normal)
        xformButton.addTarget(self, action: #selector(tappedXfromButton(_:)), for: .touchUpInside)
        toolbarContainer.addSubview(xformButton)
        xformButton.topAnchor.constraint(equalTo: toolbarContainer.topAnchor).isActive = true
        xformButton.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor).isActive = true
        xformButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 40).isActive = true
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        print("Done!")
    }
    
    @IBAction func tappedXfromButton(_ sender: Any) {
        beginTool(XformToolVC())
    }
    
    func beginTool(_ tool: BaseToolVC) {
        removeCurrentTool()
        
        currentTool = tool
        
        tool.show(with: self)
    }
    
    func removeCurrentTool() {
        guard let tool = currentTool
        else { return }
        
        tool.contentView.removeFromSuperview()
        tool.toolbarView.removeFromSuperview()
        tool.removeFromParentViewController()
        tool.didMove(toParentViewController: nil)
    }
    
    // MARK: - Tool Delegate
    func toolCancel(_ sender: BaseToolVC) {
        if showsXformToolOnly {
            delegate?.imageEditorDidCancel(self)
        } else {
            removeCurrentTool()
        }
    }
    
    func tool(_ sender: BaseToolVC, commit image: UIImage) {
        setImage(image)
        doneButton.isEnabled = true
        
        if showsXformToolOnly {
            let resultImage: UIImage? = {
                UIGraphicsBeginImageContext(image.size)
                guard let context = UIGraphicsGetCurrentContext()
                else { return nil }
                let rect = CGRect(origin: .zero, size: image.size)
                context.setFillColor(UIColor.black.cgColor)
                UIRectFill(rect)
                image.draw(in: rect)
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return resultImage
            }()
            if let resultImage = resultImage {
                delegate?.imageEditor(self, commit: resultImage)
            }
        } else {
            removeCurrentTool()
        }
        
        
    }
    
    // MARK: - Image Manipulation
    public func setImage(_ image: UIImage) {
        self.image = image
        
        imageView.image = image
    }
    
    

}

protocol ImageEditorDelegate: class {
    func imageEditorDidCancel(_ sender: ImageEditorViewController)
    func imageEditor(_ sender: ImageEditorViewController, commit image: UIImage)
}

extension ImageEditorDelegate {
    func imageEditorDidCancel(_ sender: ImageEditorViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
