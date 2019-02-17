//
//  SingleAssetViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-22.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit
import Photos
import QuartzCore

protocol SingleAssetViewControllerDelegate: class {
    func singleAssetViewControllerDidTapCheckButton(with asset: PHAsset, in viewer: SingleAssetViewController)
    func singleAssetViewControllerDidClosed(with asset: PHAsset)
}

protocol SingleAssetViewControllerDoneDelegate: class {
    func singleAssetViewControllerDidTapDoneButton(_ viewController: SingleAssetViewController)
}

class SingleAssetViewController: UIViewController {

    weak var delegate: SingleAssetViewControllerDelegate?
    weak var doneDelegate: SingleAssetViewControllerDoneDelegate?
    fileprivate var ymAsset: YMAsset!
    fileprivate var asset: PHAsset!
    fileprivate var mediaType: PickerMediaType!
    fileprivate var imageView: UIImageView!
    fileprivate var image: UIImage?
    fileprivate var scrollView: UIScrollView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isAssetSelected: Bool = false {
        didSet {
            toggleCheckedView(isAssetSelected)
        }
    }
    
    fileprivate var shouldHideBar = false {
        didSet {
            if shouldHideBar {
                hideBar()
            } else {
                showBar()
            }
        }
    }
    
    fileprivate let checkImage = UIImage(named: "ic_check")
    fileprivate let cancelImage = UIImage(named: "nav_close")
    
    // MARK: - SingleAssetViewController LifeCycle
    func initialize(with asset: PHAsset) {
        
        self.asset = asset
        YMAsset.initialize(with: asset, highQuality: true, completion: {
            ymAsset in
            
            self.ymAsset = ymAsset
            self.mediaType = ymAsset.mediaType
        })
        loadViewIfNeeded() // load view here, or selectionButton will be nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.mediaType! {
        case PickerMediaType.image:
            loadImageViewer()
        case PickerMediaType.video:
            loadVideoViewer()
        }
        setupBarView()
        setupCancelButton()
        setupSelectionButton()
        
        print("*** SingleAssetViewController did loaded")
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateZoomScaleForSize(size: scrollView.bounds.size)
        recenterImageView()
    }
    
    deinit {
        print("*** SingleAssetViewController did removed")
    }
    
    fileprivate func loadImageViewer() {
        
        self.image = self.ymAsset.image
        
        //Setup Image View
        imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit
        //Setup Background View
        self.view.backgroundColor = UIColor.white
        
        //Setup Scroll View
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentSize = imageView.bounds.size
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        updateZoomScaleForSize(size: scrollView.bounds.size)
        recenterImageView()
        
        
        //Setup Gesture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTaped(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTaped(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        //let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        //pan.delegate = self
        scrollView.addGestureRecognizer(singleTap)
        scrollView.addGestureRecognizer(doubleTap)
        //scrollView.addGestureRecognizer(pan)
        
    }
    
    fileprivate func loadVideoViewer() {
        
    }
    
    fileprivate func setupCancelButton() {
        backButton.setImage(cancelImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = TextColor.textBlack
    }
    
    fileprivate func setupSelectionButton() {
        
        selectionButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        selectionButton.layer.cornerRadius = selectionButton.bounds.width / 2
        toggleCheckedView(false)
    }
    
    fileprivate func setupBarView() {
        view.bringSubview(toFront: topBarView)
        view.bringSubview(toFront: bottomBarView)
        topBarView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        topBarView.addBottomBorder(ymLightTintColor, width: 0.5)
        bottomBarView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        bottomBarView.addTopBorder(ymLightTintColor, width: 0.5)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
    }
    
    
    //MARK: - User Interaction Method
    func didTapDoneButton() {
        doneButton.isHidden = true
        activityIndicator.startAnimating()
        doneDelegate?.singleAssetViewControllerDidTapDoneButton(self)
        
    }
    
    func didSingleTaped(_ tap: UITapGestureRecognizer) {
        shouldHideBar = !shouldHideBar
    }
    
    func didDoubleTaped(_ tap: UITapGestureRecognizer) {
        
        let point = tap.location(in: imageView)
        let widthScale = scrollView.bounds.width / imageView.bounds.width
        let heightScale = scrollView.bounds.height / imageView.bounds.height
        let maxScale = max(widthScale, heightScale)
        let minScale = min(widthScale, heightScale)
        if scrollView.zoomScale != minScale {
            scrollView.setZoomScale(minScale, animated: true)
            
            if shouldHideBar {
                shouldHideBar = false
            }
        } else if maxScale / minScale < 1.6 {
            let zoomSize = CGSize(width: imageView.frame.width / scrollView.maximumZoomScale * 1.5, height: imageView.frame.height / scrollView.maximumZoomScale * 1.5)
            let zoomCenterPoint = CGPoint(x: point.x - zoomSize.width / 2, y: point.y - zoomSize.height / 2)
            let zoomRect = CGRect(origin: zoomCenterPoint, size: zoomSize)
            scrollView.zoom(to: zoomRect, animated: true)
            
            if !shouldHideBar {
                shouldHideBar = true
            }
        } else {
            let zoomSize = CGSize(width: imageView.frame.width / maxScale, height: imageView.frame.height / maxScale)
            let zoomCenterPoint = CGPoint(x: point.x - zoomSize.width / 2, y: point.y - zoomSize.height / 2)
            let zoomRect = CGRect(origin: zoomCenterPoint, size: zoomSize)
            scrollView.zoom(to: zoomRect, animated: true)
            
            if !shouldHideBar {
                shouldHideBar = true
            }
        }
    }

    func didPan(_ pan: UIPanGestureRecognizer) {
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.singleAssetViewControllerDidClosed(with: self.asset)
    }
    
    @IBAction func checked(_ sender: UIButton) {
        delegate?.singleAssetViewControllerDidTapCheckButton(with: asset, in: self)    }
    
    //MARK: - User Interface Design Methods
    func toggleCheckedView(_ isSelected: Bool) {
        
        self.selectionButton.layer.borderColor = isSelected ? ymCheckedColor.cgColor : ymLightTintColor.cgColor
        self.selectionButton.layer.borderWidth = isSelected ? 0 : 1.5
        self.selectionButton.tintColor = isSelected ? UIColor.white : ymLightTintColor
        self.selectionButton.backgroundColor = isSelected ? ymCheckedColor : UIColor.clear
        
    }
    
    fileprivate func hideBar() {
        
        let topBarMover = CABasicAnimation(keyPath: "position.y")
        topBarMover.fromValue = topBarView.center.y
        topBarMover.toValue = -topBarView.center.y
        topBarMover.duration = 0.2
        topBarMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let bottomBarMover = CABasicAnimation(keyPath: "position.y")
        bottomBarMover.fromValue = bottomBarView.center.y
        bottomBarMover.toValue = bottomBarView.center.y + bottomBarView.frame.height
        bottomBarMover.duration = 0.2
        bottomBarMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        topBarView.layer.add(topBarMover, forKey: "hideTopBar")
        topBarView.layer.position.y = -topBarView.center.y
        bottomBarView.layer.add(bottomBarMover, forKey: "hideBottomBar")
        bottomBarView.layer.position.y = bottomBarView.center.y + bottomBarView.frame.height
        
        topBarView.isUserInteractionEnabled = false
        bottomBarView.isUserInteractionEnabled = false
    }
    
    fileprivate func showBar() {
        
        let topBarMover = CABasicAnimation(keyPath: "position.y")
        topBarMover.fromValue = topBarView.center.y
        topBarMover.toValue = -topBarView.center.y
        topBarMover.duration = 0.2
        topBarMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let bottomBarMover = CABasicAnimation(keyPath: "position.y")
        bottomBarMover.fromValue = bottomBarView.center.y
        bottomBarMover.toValue = bottomBarView.center.y - bottomBarView.frame.height
        bottomBarMover.duration = 0.2
        bottomBarMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        topBarView.layer.add(topBarMover, forKey: "showTopBar")
        topBarView.layer.position.y = -topBarView.center.y
        bottomBarView.layer.add(bottomBarMover, forKey: "showBottomBar")
        bottomBarView.layer.position.y = bottomBarView.center.y - bottomBarView.frame.height
        
        topBarView.isUserInteractionEnabled = true
        bottomBarView.isUserInteractionEnabled = true
        
    }


}

extension SingleAssetViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImageView()
    }
    
    fileprivate func recenterImageView() {
        
        let scrollViewSize = scrollView.bounds.size
        // Must use imageView frame. When zooming, bounds of imageView is not changing, the frame is!
        let imageViewSize = imageView.frame.size
        let horiSpace = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let vertSpace = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: vertSpace, left: horiSpace, bottom: vertSpace, right: horiSpace)
    }
    
    fileprivate func updateZoomScaleForSize(size: CGSize) {
        
        //A zoom scale below one shows the content zoomed out, while a zoom scale of greater than one shows the content zoomed in
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        let maxScale = max(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale * 2 * 1.5
        scrollView.zoomScale = minScale
    }
    
    
    
}
