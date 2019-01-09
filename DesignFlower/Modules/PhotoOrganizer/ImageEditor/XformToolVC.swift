//
//  XformToolVC.swift
//  RHImageCropper
//
//  Created by roy on 11/22/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class ProtractorView: UIView {
    
    private var rotation: CGFloat = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setRotation(_ rotation: CGFloat) {
        self.rotation = rotation
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        
        let radius: CGFloat = (frame.width / 2) * 1.2
        let center = CGPoint(x: frame.width / 2,
                             y: frame.height - radius - 30)
        context.translateBy(x: center.x, y: center.y)
        
        // Draw triangle
        let shouldDrawTriangle = true
        if shouldDrawTriangle {
            context.translateBy(x: 0, y: radius + 7)
            
            let label = "▲" as NSString
            let attributes: [NSAttributedString.Key: Any]
                = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                   NSAttributedString.Key.foregroundColor : UIColor(white: 0.65, alpha: 1)]
            let size = label.size(withAttributes: attributes)
            context.translateBy(x: -size.width * 0.5, y: 0)
            label.draw(at: .zero, withAttributes: attributes)
            context.translateBy(x: size.width * 0.5, y: 0)
            
            context.translateBy(x: 0, y: -(radius + 7))
        }
        
        context.rotate(by: rotation)
        
        let dot = dotImage(of: 2, color: UIColor(white: 0.65, alpha: 1))
        let bigDot = dotImage(of: 3, color: UIColor(white: 0.65, alpha: 1))
        
        let stepDegree: CGFloat = 2
        let stepRadian: CGFloat = -stepDegree * .pi / 180.0
        let steps = Int(360.0/stepDegree)
        let stepsPerLabel = 5

        for i in 0...steps {
            context.translateBy(x: 0, y: radius)
            context.setTextDrawingMode(CGTextDrawingMode.fill)
            
            if i % stepsPerLabel == 0 {
                context.translateBy(x: 0, y: -25)
                
                let degree = i * Int(stepDegree) <= 180 ? i * Int(stepDegree) : i * Int(stepDegree) - 360
                let label = NSString(format: "%d" as NSString, degree)
                let attributes: [NSAttributedString.Key: Any]
                    = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                       NSAttributedString.Key.foregroundColor : UIColor(white: 0.65, alpha: 1)]
                let size = label.size(withAttributes: attributes)
                context.translateBy(x: -size.width * 0.5, y: 0)
                label.draw(at: .zero, withAttributes: attributes)
                context.translateBy(x: size.width * 0.5, y: 0)
                
                context.translateBy(x: 0, y: 25)
            }

            let dot = i % stepsPerLabel == 0 ? bigDot : dot
            dot.draw(at: CGPoint(x: -dot.size.width * 0.5, y: -dot.size.height * 0.5))
            
            context.translateBy(x: 0, y: -radius)
            
            context.rotate(by: stepRadian)
        }
    }
    
    private func dotImage(of radius: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 2*radius, height: 2*radius))
        guard let context = UIGraphicsGetCurrentContext()
        else { return UIImage() }
        context.addEllipse(in: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius))
        context.setFillColor(color.cgColor)
        context.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}

class CornerView: UIView {
    var cornerType: CornerType = .topLeft
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return }
        
        let width = frame.width
        let height = frame.height
        
        var point0: CGPoint
        let point1: CGPoint = CGPoint(x: width * 0.5, y: height * 0.5)
        var point2: CGPoint
        
        switch cornerType {
        case .topLeft:
            point0 = CGPoint(x: width * 0.5, y: height)
            point2 = CGPoint(x: width, y: height * 0.5)
        case .topRight:
            point0 = CGPoint(x: 0, y: height * 0.5 )
            point2 = CGPoint(x: width * 0.5, y: height)
        case .bottomLeft:
            point0 = CGPoint(x: width * 0.5, y: 0)
            point2 = CGPoint(x: width, y: height * 0.5)
        case .bottomRight:
            point0 = CGPoint(x: 0, y: height * 0.5)
            point2 = CGPoint(x: width * 0.5, y: 0 )
        }
        
        context.setLineWidth(3)
        context.setStrokeColor(UIColor.white.cgColor)
        context.move(to: point0)
        context.addLine(to: point1)
        context.addLine(to: point2)
        context.strokePath()
    }


    typealias CornerType = XformToolVC.CornerType
}

class XformToolVC: BaseToolVC {

    private var originalImage = UIImage()
    private var image = UIImage()
    private var rotation: CGFloat = 0 // in radians
    private var fixedRatio: CGFloat?
    
    private var holderView  = UIView()
    private var imageView   = UIImageView()
    private var cropView    = UIView()
    private var cornerViews = [CornerView]()
    private var rotationView = ProtractorView()

    private var panelView   = UIView()
    private var orientationButton = UIButton()
    private var resetButton = UIButton()
    private var ratioButton = UIButton()
    
    private var horizontalFlipButton = UIButton()
    private var verticalFlipButton = UIButton()
    private var doneButton  = UIButton()
    private var cancelButton = UIButton()
    
    private let cornerSize  = CGSize(width: 50, height: 50)
    private let rotationHeight = CGFloat(90)
    
    private let blueColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1)
    private let goldColor = UIColor(red: 220.0/255, green: 190.0/255.0, blue: 30.0/255.0, alpha: 1)
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageSize(image.size)
    }
    
    override func show(with presenter: BaseToolVC.Presenter) {
        super.show(with: presenter)
        
        setupImageView()
        setupCropView()
        setupRotationView()
        
        setImage(presenter.imageToEdit)
        
        setupPanel()
        setupToolbar()
    }
    
    private func setupImageView() {
        holderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(holderView)
        
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        holderView.addSubview(imageView)
    }
    
    private func setupCropView() {
        
        cropView.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(cropView)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleCropPan(_:)))
        cropView.addGestureRecognizer(gesture)
        cropView.layer.borderWidth = 1
        cropView.layer.borderColor = UIColor.white.cgColor
        
        for corner in 0...3 {
            guard let cornerType = CornerType(rawValue: corner)
            else { continue }
            
            let cornerView = CornerView(frame: CGRect(origin: .zero, size: cornerSize))
            cornerView.cornerType = cornerType
            cornerView.translatesAutoresizingMaskIntoConstraints = false
            holderView.addSubview(cornerView)
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
            cornerView.addGestureRecognizer(gesture)
            
            cornerViews.append(cornerView)
        }
    }
    
    private func setupRotationView() {
        rotationView.backgroundColor = .clear
        rotationView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rotationView)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleRotationPan(_:)))
        rotationView.addGestureRecognizer(gesture)
    }
    
    // MARK: - Panel Manipulation
    private func setupPanel() {
        panelView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(panelView)
        panelView.backgroundColor = .clear
        panelView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        panelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        panelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        panelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        orientationButton.translatesAutoresizingMaskIntoConstraints = false
        orientationButton.setTitleColor(.white, for: .normal)
        orientationButton.setImage(UIImage(named: "photoedit_rotate 90"), for: .normal)
        orientationButton.addTarget(self, action: #selector(tappedOrientation(_:)), for: .touchUpInside)
        panelView.addSubview(orientationButton)
        orientationButton.topAnchor.constraint(equalTo: panelView.topAnchor).isActive = true
        orientationButton.bottomAnchor.constraint(equalTo: panelView.bottomAnchor).isActive = true
        orientationButton.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 16).isActive = true
        
        ratioButton.translatesAutoresizingMaskIntoConstraints = false
        ratioButton.setImage(UIImage(named: "crop image_default"), for: .normal)
        ratioButton.setImage(UIImage(named: "crop image_active"), for: .selected)
        ratioButton.addTarget(self, action: #selector(tappedRatio(_:)), for: .touchUpInside)
        panelView.addSubview(ratioButton)
        ratioButton.topAnchor.constraint(equalTo: panelView.topAnchor).isActive = true
        ratioButton.bottomAnchor.constraint(equalTo: panelView.bottomAnchor).isActive = true
        ratioButton.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -16).isActive = true
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitleColor(blueColor, for: .normal)
        resetButton.setTitle("重置", for: .normal)
        resetButton.addTarget(self, action: #selector(tappedReset(_:)), for: .touchUpInside)
        panelView.addSubview(resetButton)
        resetButton.centerXAnchor.constraint(equalTo: panelView.centerXAnchor).isActive = true
        resetButton.centerYAnchor.constraint(equalTo: panelView.centerYAnchor).isActive = true
    }
    
    @IBAction func tappedOrientation(_ sender: Any) {
        rotateOrientationBy90()
        doneButton.isEnabled = true
    }
    
    @IBAction func tappedRatio(_ sender: Any) {
        if ratioButton.isSelected == false {
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if image.size.width > 0 && image.size.height > 0 {
                let ratio = image.size.width / image.size.height
                sheet.addAction(UIAlertAction(title: "原圖", style: .default, handler: { [weak self] _ in self?.setFixedRatio(ratio) }))
            }
            
            sheet.addAction(UIAlertAction(title: "正方形", style: .default, handler: { [weak self] _ in self?.setFixedRatio(1.0) }))
            if cropView.bounds.width >= cropView.bounds.height {
                sheet.addAction(UIAlertAction(title: "3:2", style: .default, handler: { [weak self] _ in self?.setFixedRatio(3.0/2.0)}))
                sheet.addAction(UIAlertAction(title: "5:3", style: .default, handler: { [weak self] _ in self?.setFixedRatio(5.0/3.0)}))
                sheet.addAction(UIAlertAction(title: "4:3", style: .default, handler: { [weak self] _ in self?.setFixedRatio(4.0/3.0)}))
                sheet.addAction(UIAlertAction(title: "5:4", style: .default, handler: { [weak self] _ in self?.setFixedRatio(5.0/4.0)}))
                sheet.addAction(UIAlertAction(title: "7:5", style: .default, handler: { [weak self] _ in self?.setFixedRatio(7.0/5.0)}))
                sheet.addAction(UIAlertAction(title: "16:9", style: .default, handler: { [weak self] _ in self?.setFixedRatio(16.0/9.0)}))
            } else {
                sheet.addAction(UIAlertAction(title: "2:3", style: .default, handler: { [weak self] _ in self?.setFixedRatio(2.0/3.0)}))
                sheet.addAction(UIAlertAction(title: "3:5", style: .default, handler: { [weak self] _ in self?.setFixedRatio(3.0/5.0)}))
                sheet.addAction(UIAlertAction(title: "3:4", style: .default, handler: { [weak self] _ in self?.setFixedRatio(3.0/4.0)}))
                sheet.addAction(UIAlertAction(title: "4:5", style: .default, handler: { [weak self] _ in self?.setFixedRatio(4.0/5.0)}))
                sheet.addAction(UIAlertAction(title: "5:7", style: .default, handler: { [weak self] _ in self?.setFixedRatio(5.0/7.0)}))
                sheet.addAction(UIAlertAction(title: "9:16", style: .default, handler: { [weak self] _ in self?.setFixedRatio(9.0/16.0)}))
            }
            sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
            
            doneButton.isEnabled = true
        } else {
            setFixedRatio(nil)
        }
    }
    
    @IBAction func tappedReset(_ sender: Any) {
        setFixedRatio(nil)
        setEditingImage(originalImage)
        setRotation(0)
        
        doneButton.isEnabled = false
    }
    
    // MARK: - Toolbar Manipulation
    private func setupToolbar() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(blueColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(tappedCancel(_:)), for: .touchUpInside)
        toolbarView.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 16).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("完成", for: .normal)
        doneButton.setTitleColor(goldColor, for: .normal)
        doneButton.setTitleColor(.gray, for: .disabled)
        doneButton.isEnabled = false
        doneButton.addTarget(self, action: #selector(tappedDone(_:)), for: .touchUpInside)
        toolbarView.addSubview(doneButton)
        doneButton.topAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -16).isActive = true
        
        horizontalFlipButton.translatesAutoresizingMaskIntoConstraints = false
        horizontalFlipButton.setImage(UIImage(named: "photoedit_mirror"), for: .normal)
        horizontalFlipButton.addTarget(self, action: #selector(tappedHorizontalFlip(_:)), for: .touchUpInside)
        toolbarView.addSubview(horizontalFlipButton)
        horizontalFlipButton.topAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        horizontalFlipButton.bottomAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        horizontalFlipButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 40).isActive = true
        
        verticalFlipButton.translatesAutoresizingMaskIntoConstraints = false
        verticalFlipButton.setImage(UIImage(named: "photoedit_mirror02"), for: .normal)
        verticalFlipButton.addTarget(self, action: #selector(tappedVerticalFlip(_:)), for: .touchUpInside)
        toolbarView.addSubview(verticalFlipButton)
        verticalFlipButton.topAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        verticalFlipButton.bottomAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        verticalFlipButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -40).isActive = true
    
        horizontalFlipButton.widthAnchor.constraint(equalTo: verticalFlipButton.widthAnchor).isActive = true
        horizontalFlipButton.trailingAnchor.constraint(equalTo: verticalFlipButton.leadingAnchor).isActive = true
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        presenter?.toolCancel(self)
    }
    
    @IBAction func tappedDone(_ sender: Any) {
        if let result = cropImage() {
            presenter?.tool(self, commit: result)
        }
    }
    
    @IBAction func tappedHorizontalFlip(_ sender: Any) {
        horizontalFlip()
        doneButton.isEnabled = true
    }
    
    @IBAction func tappedVerticalFlip(_ sender: Any) {
        verticalFlip()
        doneButton.isEnabled = true
    }
    
    // MARK: - Image Manipulation
    func setImage(_ image: UIImage) {
        self.originalImage = image
        setEditingImage(image)
        
        resetCropArea()
    }
    
    func setEditingImage(_ image: UIImage) {
        self.image = image
        imageView.image = image
        imageView.layoutIfNeeded() // call immediately to avoid image causing imageView resize
        
        self.updateImageSize(image.size)
    }
    
    func updateImageSize(_ size: CGSize) {
        guard size.width > 0 else { return }
        
        let topMargin: CGFloat = 20
        let bottomMargin: CGFloat = 200
        let sideMargin: CGFloat = 10
        
        let outerBounds = view.bounds
        let bounds = CGRect(x: sideMargin,
                            y: topMargin,
                            width: outerBounds.width - 2 * sideMargin,
                            height: outerBounds.height - topMargin - bottomMargin)
        let xscale = bounds.width / size.width
        let yscale = bounds.height / size.height
        let scale = min(xscale, yscale)
        let targetSize = CGSize(width: size.width * scale,
                                height: size.height * scale)
        
        let area = CGRect(x: (bounds.width - targetSize.width) * 0.5 + bounds.origin.x,
                          y: (bounds.height - targetSize.height) * 0.5 + bounds.origin.y,
                          width: targetSize.width, height: targetSize.height)
        holderView.frame = area
        imageView.frame = CGRect(origin: .zero, size: targetSize)
        
        setCropArea(cropView.frame)
        
        let rotationFrame = CGRect(x: 0, y: area.origin.y + area.height,
                                   width: view.frame.width,
                                   height: rotationHeight)
                                   //height: rotationHeight)
        rotationView.frame = rotationFrame
    }
    
    // MARK: - Crop Manipulation
    func resetCropArea() {
        setCropArea(holderView.bounds)
    }
    
    func setCropArea(_ area: CGRect) {
        if let ratio = fixedRatio {
            setCropArea(area, ratio: ratio)
            return
        }
        
        var area = area
        let bounds = holderView.bounds
        area.origin.x = max(area.origin.x, 0)
        area.origin.y = max(area.origin.y, 0)
        area.size.width = max(area.size.width, cornerSize.width)
        area.size.height = max(area.size.height, cornerSize.height)
        if area.size.width + area.origin.x > bounds.width {
            area.size.width = bounds.width - area.origin.x
        }
        if area.size.height + area.origin.y > bounds.height {
            area.size.height = bounds.height - area.origin.y
        }
        cropView.frame = area
        
        for cornerView in cornerViews {
            switch cornerView.cornerType {
            case .topLeft:
                cornerView.center = CGPoint(x: area.origin.x, y: area.origin.y)
            case .topRight:
                cornerView.center = CGPoint(x: area.origin.x + area.width, y: area.origin.y)
            case .bottomLeft:
                cornerView.center = CGPoint(x: area.origin.x, y: area.origin.y + area.height)
            case .bottomRight:
                cornerView.center = CGPoint(x: area.origin.x + area.width, y: area.origin.y + area.height)
            }
        }
    }
    
    func setCropArea(_ area: CGRect, ratio: CGFloat) {
        let minLength: CGFloat = 50
        
        var area = area
        let bounds = holderView.bounds
        
        if area.origin.x < 0 {
            area.origin.x = 0
        }
        if area.origin.y < 0 {
            area.origin.y = 0
        }
        area.origin.x = max(0, area.origin.x)
        area.origin.y = max(0, area.origin.y)
        area.size.width = max(minLength, area.size.width)
        area.size.height = max(minLength, area.size.height)
        
        if area.origin.x + area.width > bounds.width {
            area.size.width = bounds.width - area.origin.x
        }
        
        area.size.height = area.width / ratio
        if area.origin.y + area.height > bounds.height {
            area.size.height = bounds.height - area.origin.y
            area.size.width = area.size.height * ratio
        }
        
        cropView.frame = area
        for cornerView in cornerViews {
            switch cornerView.cornerType {
            case .topLeft:
                cornerView.center = CGPoint(x: area.origin.x, y: area.origin.y)
            case .topRight:
                cornerView.center = CGPoint(x: area.origin.x + area.width, y: area.origin.y)
            case .bottomLeft:
                cornerView.center = CGPoint(x: area.origin.x, y: area.origin.y + area.height)
            case .bottomRight:
                cornerView.center = CGPoint(x: area.origin.x + area.width, y: area.origin.y + area.height)
            }
        }
    }
    
    func setFixedRatio(_ ratio: CGFloat?) {
        ratioButton.isSelected = ratio != nil
        fixedRatio = ratio
        setCropArea(cropView.frame)
    }
    
    @objc func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
              let cornerType = (gestureView as? CornerView)?.cornerType
        else { return }
        
        let bounds = holderView.bounds
        var translation = gesture.translation(in: holderView)
        gesture.setTranslation(.zero, in: holderView)
        
        if let ratio = fixedRatio {
            var area = cropView.frame
            
            switch cornerType {
            case .topLeft:
                break
            case .topRight:
                translation.x *= -1
            case .bottomLeft:
                translation.y *= -1
            case .bottomRight:
                translation.x *= -1
                translation.y *= -1
            }
            
            var deltaX: CGFloat
            if abs(translation.x) > abs(translation.y) {
                deltaX = translation.x
            } else {
                deltaX = translation.y
            }
            
            let minLength: CGFloat = 50
            
            switch cornerType {
                
            case .topLeft:
                if area.origin.x + deltaX < 0 {
                    deltaX = -area.origin.x
                }
                if area.width - deltaX < minLength {
                    deltaX = area.width - minLength
                }
                var deltaY = deltaX / ratio
                if area.origin.y + deltaY < 0 {
                    deltaY = -area.origin.y
                    deltaX = deltaY * ratio
                }
                area.origin.x += deltaX; area.size.width -= deltaX
                area.origin.y += deltaY; area.size.height -= deltaY
            case .topRight:
                if area.origin.x + area.width - deltaX > bounds.width {
                    deltaX = area.origin.x + area.width - bounds.width
                }
                if area.width - deltaX < minLength {
                    deltaX = area.width - minLength
                }
                var deltaY = deltaX / ratio
                if area.origin.y + deltaY < 0 {
                    deltaY = -area.origin.y
                    deltaX = deltaY * ratio
                }
                area.size.width -= deltaX
                area.origin.y += deltaY; area.size.height -= deltaY
            case .bottomLeft:
                if area.origin.x + deltaX < 0 {
                    deltaX = -area.origin.x
                }
                if area.width - deltaX < minLength {
                    deltaX = area.width - minLength
                }
                var deltaY = deltaX / ratio
                if area.origin.y + area.height - deltaY > bounds.height {
                    deltaY = area.origin.y + area.height - bounds.height
                    deltaX = deltaY * ratio
                }
                area.origin.x += deltaX; area.size.width -= deltaX
                area.size.height -= deltaY
            case .bottomRight:
                if area.origin.x + area.width - deltaX > bounds.width {
                    deltaX = area.origin.x + area.width - bounds.width
                }
                if area.width - deltaX < minLength {
                    deltaX = area.width - minLength
                }
                var deltaY = deltaX / ratio
                if area.origin.y + area.height - deltaY > bounds.height {
                    deltaY = area.origin.y + area.height - bounds.height
                    deltaX = deltaY * ratio
                }
                area.size.width -= deltaX
                area.size.height -= deltaY
            }
            
            setCropArea(area)
        } else {
            if gestureView.center.x + translation.x < 0 {
                translation.x = 0
            }
            if gestureView.center.y + translation.y < 0 {
                translation.y = 0
            }
            
            var area = cropView.frame
            
            switch cornerType {
            case .topLeft:
                area.origin.x += translation.x
                area.size.width -= translation.x
                area.origin.y += translation.y
                area.size.height -= translation.y
            case .topRight:
                area.size.width += translation.x
                area.origin.y += translation.y
                area.size.height -= translation.y
            case .bottomLeft:
                area.origin.x += translation.x
                area.size.width -= translation.x
                area.size.height += translation.y
            case .bottomRight:
                area.size.width += translation.x
                area.size.height += translation.y
            }
            
            setCropArea(area)
        }
        doneButton.isEnabled = true
    }
    
    @objc func handleCropPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: holderView)
        gesture.setTranslation(.zero, in: holderView)
        var area = cropView.frame
        area.origin.x += translation.x
        area.origin.y += translation.y
        
        let bounds = holderView.bounds
        
        if area.origin.x + area.width > bounds.width {
            area.origin.x = bounds.width - area.width
        }
        if area.origin.y + area.height > bounds.height {
            area.origin.y = bounds.height - area.height
        }
        
        setCropArea(area)
        
        doneButton.isEnabled = true
    }
    
    // MAKR: - Rotation Manipulation
    @objc func handleRotationPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: holderView)
        gesture.setTranslation(.zero, in: holderView)

        let rotation = self.rotation + -translation.x * CGFloat.pi / 1000
        print("rotation \(rotation)")
        
        setRotation(rotation)
        
        doneButton.isEnabled = true
    }
    
    func setRotation(_ rotation: CGFloat) {
        self.rotation = rotation
        rotationView.setRotation(rotation)
        
        let originalSize = originalImage.size
        let center = CGPoint(x: originalSize.width * 0.5,
                             y: originalSize.height * 0.5)
        var points = [CGPoint]()
        for corner in 0...3 {
            guard let cornerType = CornerType(rawValue: corner)
            else { return }
            
            switch cornerType {
            case .topLeft:
                points.append(CGPoint(x: -center.x, y: -center.y))
            case .topRight:
                points.append(CGPoint(x:  center.x, y: -center.y))
            case .bottomLeft:
                points.append(CGPoint(x: -center.x, y:  center.y))
            case .bottomRight:
                points.append(CGPoint(x:  center.x, y:  center.y))
            }
        }
        let transform = CGAffineTransform(rotationAngle: rotation)
        let newPoints = points.map { $0.applying(transform) }
        let minX = newPoints.reduce(CGFloat.greatestFiniteMagnitude) { (result, point) -> CGFloat in
            min(point.x, result)
        }
        let maxX = newPoints.reduce(-CGFloat.greatestFiniteMagnitude) { (result, point) -> CGFloat in
            max(point.x, result)
        }
        let minY = newPoints.reduce(CGFloat.greatestFiniteMagnitude) { (result, point) -> CGFloat in
            min(point.y, result)
        }
        let maxY = newPoints.reduce(-CGFloat.greatestFiniteMagnitude) { (result, point) -> CGFloat in
            max(point.y, result)
        }
        let newSize = CGSize(width: maxX - minX, height: maxY - minY)
        
        print("rotation new sze \(newSize)")
        guard newSize.width > 0 && newSize.height > 0
        else { return }
        
        UIGraphicsBeginImageContext(newSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: newSize.width / 2.0,
                                 y: newSize.height / 2.0)
            context.translateBy(x: -origin.x, y: -origin.y)
            context.rotate(by: rotation)
            let transform = CGAffineTransform(rotationAngle: -rotation)
            let vector = origin.applying(transform)
            context.translateBy(x: vector.x * 2, y: vector.y * 2)
            originalImage.draw(at: points[CornerType.topLeft.rawValue])
            
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
            if let rotatedImage = rotatedImage {
                setEditingImage(rotatedImage)
            }
            resetCropArea() // 先預設重制裁切
        }
    }
    
    func rotateOrientationBy90() {
        var degree = rotation * 180.0 / .pi
        while degree < 0 {
            degree += 360
        }
        var newDegree: CGFloat
        switch degree {
            case 0..<45, 315...360:
                newDegree = 90
            case 45..<135:
                newDegree = 180
            case 135..<225:
                newDegree = 270
            case 225..<315:
                newDegree = 0
            default:
                newDegree = 0
        }
        print("\(degree) -> \(newDegree)")
        
        setRotation(newDegree * .pi / 180)
        resetCropArea()
    }
    
    // MARK: - Image Flipping
    func horizontalFlip() {
        guard let cgImage = image.cgImage
        else { return }
        
        var orientation: UIImage.Orientation = image.imageOrientation
        switch image.imageOrientation {
        case .up:
            orientation = .upMirrored
        case .down:
            orientation = .downMirrored
        case .left:
            break
        case .right:
            break
        case .upMirrored:
            orientation = .up
        case .downMirrored:
            orientation = .down
        case .leftMirrored:
            break
        case .rightMirrored:
            break
        }
        
        let flippedImage = UIImage.init(cgImage: cgImage, scale: image.scale, orientation: orientation)
        setEditingImage(flippedImage)
    }
    
    func verticalFlip() {
        guard let cgImage = image.cgImage
        else { return }
        
        var orientation: UIImage.Orientation = image.imageOrientation
        switch image.imageOrientation {
        case .up:
            orientation = .downMirrored
        case .down:
            orientation = .upMirrored
        case .left:
            break
        case .right:
            break
        case .upMirrored:
            orientation = .down
        case .downMirrored:
            orientation = .up
        case .leftMirrored:
            break
        case .rightMirrored:
            break
        }
        
        let flippedImage = UIImage.init(cgImage: cgImage, scale: image.scale, orientation: orientation)
        setEditingImage(flippedImage)
    }
    
    // MARK: - Image Cropping
    func cropImage() -> UIImage? {
        
        let cropArea = cropView.frame
        let bounds = holderView.bounds
        let xscale = image.size.width / bounds.width
        let yscale = image.size.height / bounds.height
        let cropFrame = CGRect(x: cropArea.origin.x * xscale,
                               y: cropArea.origin.y * yscale,
                               width: cropArea.width * xscale,
                               height: cropArea.height * yscale)
        
        UIGraphicsBeginImageContext(cropFrame.size)
        image.draw(at: CGPoint(x: -cropFrame.origin.x, y: -cropFrame.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}


extension XformToolVC {
    enum CornerType: Int {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
}
