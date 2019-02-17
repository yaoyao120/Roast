//
//  ImagePickerViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-09.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit
import Photos

enum PickerMediaType: String {
    case image
    case video
}

enum PickerMode: String {
    case pickProfileImgae
    case pickBackgroundImage
    case pickPostImage
    case changePostImage
    case pickSticker
    
    case pickArticalImage
}

protocol ImagePickerViewControllerDelegate: class {
    //MARK: Required
    func imagePickerViewControllerDidFinishPicking(_ imagePicker: ImagePickerViewController, data: [Data], assets: [PHAsset])
}

let ymCheckedColor = UIColor.hex("#4BC630", alpha: 1.0)
let ymDarkTintColor = UIColor.hex("#696969", alpha: 1.0)
let ymLightTintColor = UIColor.hex("#A9A9A9", alpha: 1.0)
let ymBackgroundColor = UIColor.hex("#FFFFFF", alpha: 1.0)
let ghostWhite = UIColor.hex("#F8F8FF", alpha: 1.0)
let snow = UIColor.hex("#FFFAFA", alpha: 1.0)

var cameraRollTitle = "CAMERA ROLL"
var pickerTitleFont = UIFont(name: "AvenirNext-DemiBold", size: 17)

class ImagePickerViewController: UIViewController {
    
    weak var delegate: ImagePickerViewControllerDelegate?
    var tag: Int!
    var max: Int = 1
    var highQuality = true
    var pickerMode: PickerMode!
    
    fileprivate var albumView: AlbumView!
    fileprivate var assetCollection: AssetCollection! {
        didSet {
            if let title = assetCollection.collectionName {
                updateTitleButton(with: title)
            } else {
                updateTitleButton(with: cameraRollTitle)
            }
            self.albumView.updatePhotos(with: assetCollection)
        }
    }
    fileprivate var selectedAssets = [PHAsset]()
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var pointerButton: UIButton!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuTopConstraint: NSLayoutConstraint!
    
    
    //MARK: - Initialize the imagePickerViewController
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Must call this methods after init
    func setupImagePickerWithLimit(_ pickerMode: PickerMode, max: Int, highQuality: Bool) {
        self.max = max
        self.highQuality = highQuality
        self.pickerMode = pickerMode
        
        print("*** PickerMode: \(pickerMode.rawValue), max number: \(max), is high quality: \(highQuality)")
    }
    
    //MARK: - ImagePickerViewController Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeImage = UIImage(named: "nav_close")
        
        //Set up title, done and pointer buttons
        titleButton.addTarget(self, action: #selector(didTapTitleButton(_:)), for: .touchUpInside)
        pointerButton.addTarget(self, action: #selector(didTapTitleButton(_:)), for: .touchUpInside)
        titleButton.isHidden = true
        pointerButton.isHidden = true
        
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        //Setup View Appearance
        menuTopConstraint.constant = UIApplication.shared.statusBarFrame.height
        menuView.backgroundColor = UIColor.white
        menuView.addBottomBorder(ymLightTintColor, width: 0.5)
        closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = TextColor.textBlack
        
        //Check PhotoLibrary Authorization Status and load photos if authorized
        checkPhotoAuth()
        
        print("*** imagePickerViewController did load")
    }
    
    deinit {
        print("*** imagePickerViewController removed")
    }
    
    //MARK: - Data Related Methods
    //Create and add an album view with camera roll photos
    func loadAlbumView() {
        self.albumView = AlbumView.instance()
        self.albumView.delegate = self
        self.albumView.frame = CGRect(origin: CGPoint.zero, size: pickerContainer.bounds.size)
        self.albumView.initialize(self.max)
        self.loadCameraRoll()
        self.pickerContainer.addSubview(albumView)
    }
    
    //Load assets from camera roll collection when album view is loaded at the first time
    func loadCameraRoll() {
        if let cameralRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil).firstObject {
            self.assetCollection = AssetCollection.instance(with: cameralRoll)
        }
    }
    
    //MARK: - User Interaction and Interface Design Methods
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed() {
        print("*** did pressed done button")
        activityIndicator.startAnimating()
        doneButton.isHidden = true
        
        switch pickerMode! {
        case PickerMode.pickArticalImage:
            
            DispatchQueue.global().async {
                var selectedImageData = [Data]()
                for asset in self.selectedAssets {
                    YMAsset.initialize(with: asset, highQuality: self.highQuality, completion: {
                        ymAsset in
                        
                        if let image = ymAsset.image {
                            if let imageData = UIImageJPEGRepresentation(image, 1) {
                                selectedImageData.append(imageData)
                            }
                        }
                    })
                    
                }
                self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: selectedImageData, assets: self.selectedAssets)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        case PickerMode.pickProfileImgae, PickerMode.pickBackgroundImage, PickerMode.pickSticker, PickerMode.changePostImage:
            
            DispatchQueue.global().async {
                var selectedImageData = [Data]()
                for asset in self.selectedAssets {
                    YMAsset.initialize(with: asset, highQuality: self.highQuality, completion: {
                        ymAsset in
                        
                        if let image = ymAsset.image {
                            if let imageData = UIImageJPEGRepresentation(image, 1) {
                                selectedImageData.append(imageData)
                            }
                        }
                    })
                }
                self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: selectedImageData, assets: self.selectedAssets)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        case PickerMode.pickPostImage:
            
            let sharePhotoViewController = SharePhotoViewController()
            sharePhotoViewController.setupSharePhotoViewControllerWith(selectedAssets)
            sharePhotoViewController.delegate = self
            let shareNavController = UINavigationController(rootViewController: sharePhotoViewController)
            shareNavController.navigationBar.barTintColor = UIColor.white
            shareNavController.navigationBar.tintColor = TextColor.textBlack
            self.present(shareNavController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    fileprivate func processImages() {
        var selectedImageData = [Data]()
        for asset in selectedAssets {
            YMAsset.initialize(with: asset, highQuality: false, completion: {
                ymAsset in
                
                if let image = ymAsset.image {
                    
                    if let imageData = UIImagePNGRepresentation(image) {
                        selectedImageData.append(imageData)
                    }
                }
            })
        }
        self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: selectedImageData, assets: selectedAssets)
    }
    
    func didTapTitleButton(_ button: UIButton) {
        let allAlbumsView = AllAlbumsViewController(nibName: "AllAlbumsViewController", bundle: nil)
        allAlbumsView.delegate = self
        self.present(allAlbumsView, animated: true, completion: nil)
    }
    
    func updateTitleButton(with title: String) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.titleButton.isHidden = false
            self.pointerButton.isHidden = false
            
            let formatString = title.uppercased()
            let titleAttributeString = NSAttributedString(string: formatString, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17) , NSForegroundColorAttributeName: TextColor.textBlack])
            self.titleButton.setAttributedTitle(titleAttributeString, for: .normal)
            
            let pointerAttributeString = NSAttributedString(string: "▼", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName: TextColor.textBlack])
            pointerButton.setAttributedTitle(pointerAttributeString, for: .normal)
        } else {
            self.titleButton.isHidden = true
            self.pointerButton.isHidden = true
        }
    }
    
    // MARK: - User authorization check
    func checkPhotoAuth() {
        let authorStatus = PHPhotoLibrary.authorizationStatus()
        
        if authorStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        self.loadAlbumView()
                        print("*** Authorized")
                    case .denied, .restricted:
                        print("*** Denied")
                    case .notDetermined:
                        print("*** Undetermined")
                        break
                    }
                    
                }
            })
        }
        if authorStatus == .denied || authorStatus == .restricted {
            //Show UIAlertController is UI related, must be performed under main queue
            DispatchQueue.main.async {
                self.albumViewShowPhotoLibraryUnauthorizedAlert()
            }
        }
        
        if authorStatus == .authorized {
            self.loadAlbumView()
        }
    }
    
    func albumViewShowPhotoLibraryUnauthorizedAlert() {
        
        print("Camera roll unauthorized")
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ImagePickerViewController: AlbumViewDelegate {
    
    func albumViewDidSelectAsset(_ assetViewer: SingleAssetViewController) {
        assetViewer.doneDelegate = self
        self.present(assetViewer, animated: true, completion: nil)
    }
    
    func albumViewDidStartCarema(withMediaType mediaType: PickerMediaType) {
        if mediaType == .image {
            let cameraViewController = CameraViewController(nibName: "CameraViewController", bundle: nil)
            cameraViewController.delegate = self
            self.present(cameraViewController, animated: true, completion: nil)
        }
        
    }
    
    func albumViewDidUpdateDoneButton(withNumber number: Int, withSelectedAssets selectedAssets: [PHAsset]) {
        
        doneButton.addButtonSetTitleWithNumber(number, maxLimit: max)
        self.selectedAssets = selectedAssets
    }
    
    
}

extension ImagePickerViewController: AllAlbumsViewControllerDelegate {
    
    func allAlbumsViewController(didSelect assetCollection: AssetCollection) {
        
        self.assetCollection = assetCollection
        
    }
}

extension ImagePickerViewController: CameraViewControllerDelegate {
    
    func cameraViewControllerDidAddPhoto(withData data: Data?) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            if let data = data {
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }
            
        }, completionHandler: { success, error in
            if success {
                print("*** photo added")
            } else {
                print(error!)
            }
        })
    }
}

extension ImagePickerViewController: SingleAssetViewControllerDoneDelegate {
    func singleAssetViewControllerDidTapDoneButton(_ viewController: SingleAssetViewController) {
        
        switch pickerMode! {
        case PickerMode.pickArticalImage:
            
            DispatchQueue.global().async {
                var selectedImageData = [Data]()
                for asset in self.selectedAssets {
                    YMAsset.initialize(with: asset, highQuality: self.highQuality, completion: {
                        ymAsset in
                        
                        if let image = ymAsset.image {
                            if let imageData = UIImageJPEGRepresentation(image, 1) {
                                selectedImageData.append(imageData)
                            }
                        }
                    })
                }
                self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: selectedImageData, assets: self.selectedAssets)
                DispatchQueue.main.async {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            
        case PickerMode.pickProfileImgae, PickerMode.pickBackgroundImage, PickerMode.pickSticker, PickerMode.changePostImage:
            
            DispatchQueue.global().async {
                var selectedImageData = [Data]()
                for asset in self.selectedAssets {
                    YMAsset.initialize(with: asset, highQuality: self.highQuality, completion: {
                        ymAsset in
                        
                        if let image = ymAsset.image {
                            if let imageData = UIImageJPEGRepresentation(image, 1) {
                                selectedImageData.append(imageData)
                            }
                        }
                    })
                }
                self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: selectedImageData, assets: self.selectedAssets)
                DispatchQueue.main.async {
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            
        case PickerMode.pickPostImage:
            
            let sharePhotoViewController = SharePhotoViewController()
            sharePhotoViewController.setupSharePhotoViewControllerWith(selectedAssets)
            sharePhotoViewController.delegate = self
            let shareNavController = UINavigationController(rootViewController: sharePhotoViewController)
            shareNavController.navigationBar.barTintColor = UIColor.white
            shareNavController.navigationBar.tintColor = TextColor.textBlack
            viewController.present(shareNavController, animated: true, completion: nil)
            
        }
    }
}

extension ImagePickerViewController: SharePhotoViewControllerDelegate {
    
    func sharePhotoViewControllerDidCancel() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func sharePhotoViewControllerDidFinishPosting() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.delegate?.imagePickerViewControllerDidFinishPicking(self, data: [Data](), assets: [PHAsset]())
    }
}
