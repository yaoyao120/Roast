//
//  RoastDrawViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-21.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol RoastDrawViewControllerDelegate: class {
    func roastDrawViewControllerDidFinishEditing(newImage: UIImage)
}

class RoastDrawViewController: UIViewController {
    
    weak var delegate: RoastDrawViewControllerDelegate?
    
    var prevDraggingPosition: CGPoint = .zero
    
    lazy var drawingView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var drawPanRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(drawWithPan(sender:)))
        recognizer.maximumNumberOfTouches = 1
        return recognizer
    }()
    
    fileprivate let titleAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: TextColor.textBlack]
    
    var image = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupImageView()
        setupDrawView()
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = titleAttribute
        navigationItem.title = "Draw"
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = closeButton
        
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_check"), style: .plain, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func setupImageView() {
        view.addSubview(imageView)
        let ratio = CustomImageView.ratioOfImageViewWith(image: image, isRatioLimited: true)
        let height = view.frame.width / ratio
        imageView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
    }
    
    fileprivate func setupDrawView() {
        imageView.addSubview(drawingView)
        drawingView.anchor(top: imageView.topAnchor, left: imageView.leftAnchor, bottom: imageView.bottomAnchor, right: imageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        drawingView.addGestureRecognizer(drawPanRecognizer)
    }
    
    func handleClose() {
        dismiss(animated: false, completion: nil)
    }
    
    func handleDone() {
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        delegate?.roastDrawViewControllerDidFinishEditing(newImage: img)
        dismiss(animated: false, completion: nil)
    }
    
    func drawWithPan(sender: UIPanGestureRecognizer) {
        let currentDragginPosition = sender.location(in: drawingView)
        
        if sender.state == .began {
            prevDraggingPosition = currentDragginPosition
        }
        
        if sender.state != .ended {
            drawLine(from: prevDraggingPosition, to: currentDragginPosition)
        }
        
        prevDraggingPosition = currentDragginPosition
    }
    
    func drawLine(from start: CGPoint, to end: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(drawingView.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        drawingView.image?.draw(at: .zero)
        let strokeWidth = max(1, 5)
        let strokeColor = UIColor.black
        context?.setLineWidth(CGFloat(strokeWidth))
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setLineCap(CGLineCap.round)
        
        if false {
            context?.setBlendMode(CGBlendMode.clear)
        }
        
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
        
        drawingView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
