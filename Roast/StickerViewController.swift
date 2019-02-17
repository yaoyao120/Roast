//
//  StickerViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-13.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Photos

protocol StickerViewControllerDelegate: class {
    func stickerViewControllerDidFinishEditing(newImage: UIImage)
}

class StickerViewController: UIViewController {
    
    weak var delegate: StickerViewControllerDelegate?
    
    fileprivate let titleAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: TextColor.textBlack]
    
    var image = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    var activeSticker: RoastStickerView?
    
    let imageView: CustomImageView = {
        
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var stickerMenu: StickerMenu = {
        let sm = StickerMenu()
        sm.delegate = self
        return sm
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapImageView))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupImageView()
        setupStickerMenu()
    }
    
    
    fileprivate func setupImageView() {
        view.addSubview(imageView)
        let ratio = CustomImageView.ratioOfImageViewWith(image: image, isRatioLimited: true)
        let height = view.frame.width / ratio
        imageView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = titleAttribute
        navigationItem.title = "Sticker"
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = closeButton
        
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_check"), style: .plain, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func setupStickerMenu() {
        view.addSubview(stickerMenu)
        stickerMenu.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 88)
    }
    
    func handleTapImageView() {
        if let activeSticker = activeSticker {
            setActive(sticker: activeSticker, active: false)
        }
        
    }
    
    
    func handleClose() {
        
        dismiss(animated: false, completion: nil)
    }
    
    func handleDone() {
        if let activeSticker = activeSticker {
            activeSticker.deleteButton.isHidden = true
            activeSticker.adjustView.isHidden = true
            activeSticker.imageView.layer.borderWidth = 0
        }
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        delegate?.stickerViewControllerDidFinishEditing(newImage: img)
        dismiss(animated: false, completion: nil)
    }
    
    
}

extension StickerViewController: StickerMenuDelegate {
    func stickerMenuDidSelectSticker(image: UIImage) {
        
        let stickerView = RoastStickerView()
        stickerView.initWithImage(image: image)
        let scale = min((0.5 * image.size.width / imageView.frame.width), (0.5 * image.size.height / imageView.frame.height))
        imageView.addSubview(stickerView)
        stickerView.scale = scale
        stickerView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        stickerView.frame.size = stickerView.imageView.frame.size
        stickerView.imageView.layer.borderWidth = 1 / scale
        stickerView.imageView.layer.cornerRadius = 3 / scale
        stickerView.imageView.center = CGPoint(x: stickerView.imageView.frame.width / 2, y: stickerView.imageView.frame.height / 2)
        stickerView.center = CGPoint(x: imageView.frame.width / 2, y: imageView.frame.height / 2)
        stickerView.delegate = self
        
        activeNewSticker(newSticker: stickerView)
    }
    
    func stickerMenuDidSelectPickImage() {
        let imagePicker = ImagePickerViewController()
        imagePicker.setupImagePickerWithLimit(PickerMode.pickSticker, max: 1, highQuality: true)
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension StickerViewController: ImagePickerViewControllerDelegate {
    func imagePickerViewControllerDidFinishPicking(_ imagePicker: ImagePickerViewController, data: [Data], assets: [PHAsset]) {
        guard data.count != 0 else {return}
        guard let stickerImageData = data.first else {return}
        guard let image = UIImage(data: stickerImageData) else {return}
        
        let stickerView = RoastStickerView()
        stickerView.initWithImage(image: image)
        let heightRatio = image.size.height / imageView.frame.height
        let widthRatio = image.size.width / imageView.frame.width
        let hScale = heightRatio > 1 ? 1 / heightRatio * 0.5 : heightRatio * 0.5
        let wScale = widthRatio > 1 ? 1 / widthRatio * 0.5 : widthRatio * 0.5
        let scale = min(hScale, wScale)
        imageView.addSubview(stickerView)
        stickerView.scale = scale
        stickerView.imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        stickerView.frame.size = stickerView.imageView.frame.size
        stickerView.imageView.layer.borderWidth = 1 / scale
        stickerView.imageView.layer.cornerRadius = 3 / scale
        stickerView.imageView.center = CGPoint(x: stickerView.imageView.frame.width / 2, y: stickerView.imageView.frame.height / 2)
        stickerView.center = CGPoint(x: imageView.frame.width / 2, y: imageView.frame.height / 2)
        
        activeNewSticker(newSticker: stickerView)
    }
}

extension StickerViewController: RoastStickerViewDelegate {
    func roastStickerViewDidActive(sticker: RoastStickerView) {
        activeNewSticker(newSticker: sticker)
    }
    
    fileprivate func activeNewSticker(newSticker: RoastStickerView) {
        if let activeSticker = activeSticker {
            setActive(sticker: activeSticker, active: false)
        }
        imageView.bringSubview(toFront: newSticker)
        setActive(sticker: newSticker, active: true)
        activeSticker = newSticker
    }
    
    fileprivate func setActive(sticker: RoastStickerView, active: Bool) {
        DispatchQueue.main.async {
            sticker.deleteButton.isHidden = active ? false : true
            sticker.adjustView.isHidden = active ? false : true
            sticker.imageView.layer.borderWidth = active ? 2 : 0
            if active {
                sticker.enableDragging()
                sticker.adjustView.addGestureRecognizer(sticker.adjustPanGestureRecognizer)
                sticker.deleteButton.isUserInteractionEnabled = true
            } else {
                sticker.disableDragging()
                sticker.adjustView.removeGestureRecognizer(sticker.adjustPanGestureRecognizer)
                sticker.deleteButton.isUserInteractionEnabled = false
            }
        }
    }
    
}



