//
//  SharePhotoViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-26.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Photos
import Firebase

protocol SharePhotoViewControllerDelegate: class {
    func sharePhotoViewControllerDidCancel()
    func sharePhotoViewControllerDidFinishPosting()
}

class SharePhotoViewController: UIViewController {
    
    weak var delegate: SharePhotoViewControllerDelegate!
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.keyboardDismissMode = .onDrag
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let captionTextView: UITextView = {
        let textView = UITextView()
        
        textView.typingAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18) , NSForegroundColorAttributeName: TextColor.textBlack]
        textView.isScrollEnabled = false
        textView.keyboardDismissMode = .onDrag
        
        return textView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Say something about your post...", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18) , NSForegroundColorAttributeName: UIColor.lightGray])
        return label
    }()
    
    fileprivate let imageCellID = "ImageCell"
    fileprivate let captionHeaderID = "CaptionHeader"
    fileprivate let numberOfItemPerRow: CGFloat = 3
    fileprivate let middleSpacing: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate let tvPadding: CGFloat = 10
    fileprivate let minHeaderHight: CGFloat = 80
    fileprivate var headerIndex = IndexPath()
    var assetsToShare = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        setupNavigationBar()
        setupCollectionView()
        
        captionTextView.becomeFirstResponder()
    }
    
    func setupSharePhotoViewControllerWith(_ assets: [PHAsset]) {
        assetsToShare = assets
    }
    
    fileprivate func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(didTapPostButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(didTapCancelButton))
    }
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: captionHeaderID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    fileprivate func setupPlaceHolderLabel() {
        captionTextView.addSubview(placeholderLabel)
        placeholderLabel.frame = CGRect(x: 5, y: 8, width: captionTextView.frame.width, height: captionTextView.frame.height)
        placeholderLabel.sizeToFit()
        if captionTextView.text.isEmpty {
            showPlaceHolderLabel()
        } else {
            hidePlaceHolderLabel()
        }
    }
    
    fileprivate func showPlaceHolderLabel()
    {
        placeholderLabel.isHidden = false
    }
    
    fileprivate func hidePlaceHolderLabel() {
        placeholderLabel.isHidden = true
    }
    
    func didTapPostButton() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard let asset = assetsToShare.first else {return}
        
        YMAsset.initialize(with: asset, highQuality: true, completion: {
            ymAsset in
            
            guard let image = ymAsset.image else { return }
            guard let uploadData = UIImageJPEGRepresentation(image, 1) else { return }
            let filename = NSUUID().uuidString
            FIRStorage.storage().reference().child(FBKeyString.postImages).child(filename).put(uploadData, metadata: nil, completion: {
                
                metadata, err in
                
                if let err = err {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("*** Failed to upload post image: \(err)")
                    return
                }
                
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
                guard let title = self.captionTextView.text else {return}
                
                let ref =  FIRDatabase.database().reference().child(FBKeyString.posts).child(uid).childByAutoId()
                let values: [String: Any] = [
                            FBKeyString.postTitle: title,
                            FBKeyString.creationDate: Date().timeIntervalSince1970,
                            FBKeyString.postCoverImageUrls: imageUrl,
                            FBKeyString.postCoverImageWidth: image.size.width,
                            FBKeyString.postCoverImageHeight: image.size.height]
                ref.updateChildValues(values, withCompletionBlock: {
                    error, ref in
                    
                    if let error = error {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        
                        if error._code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
                            self.showNetWorkErrorAlert()
                        }
                        print("*** Fail to save album post info into database: \(error)")
                        return
                    }
                    
                    print("*** Successfully saved album post into database!")
                    DispatchQueue.main.async {
                        self.delegate.sharePhotoViewControllerDidFinishPosting()
                    }
                    NotificationCenter.default.post(name: UpdateFeedNotificationName, object: nil)
                })
            })
        })
    }
    
    func didTapCancelButton() {
        delegate.sharePhotoViewControllerDidCancel()
    }
    
    //MARK: - Data base related methods
    
}

extension SharePhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - UICollectionView Delegate and DataSource Methods
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        headerIndex = indexPath
        
        let captionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: captionHeaderID, for: indexPath) as! UICollectionViewCell
        
        captionHeader.addSubview(captionTextView)
        captionTextView.anchor(top: captionHeader.topAnchor, left: captionHeader.leftAnchor, bottom: captionHeader.bottomAnchor, right: captionHeader.rightAnchor, paddingTop: tvPadding, paddingLeft: tvPadding, paddingBottom: tvPadding, paddingRight: tvPadding, width: 0, height: 0)
        captionTextView.delegate = self
        
        setupPlaceHolderLabel()
        
        return captionHeader
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assetsToShare.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath)
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        
        //Remove all subviews before add new image view
        for subView in cell.subviews {
            subView.removeFromSuperview()
        }
        
        //Add new image view
        let imageView = UIImageView(frame: cell.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        YMAsset.initialize(with: assetsToShare[indexPath.item], highQuality: false, completion: {
            ymAsset in
            
            let image = ymAsset.image
            imageView.image = image
        })
        
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imagePicker = ImagePickerViewController(nibName: "ImagePickerViewController", bundle: nil)
        imagePicker.setupImagePickerWithLimit(.changePostImage, max: 1, highQuality: true)
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension SharePhotoViewController: ImagePickerViewControllerDelegate {
    
    func imagePickerViewControllerDidFinishPicking(_ imagePicker: ImagePickerViewController, data: [Data], assets: [PHAsset]) {
        
        assetsToShare = assets
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        
    }
}

extension SharePhotoViewController: UICollectionViewDelegateFlowLayout {
    
    //MARK: - UICollectionView Layout Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        print("*** reference Size For Header In Section called")
        
        guard let attriString = captionTextView.attributedText else {
            return CGSize(width: collectionView.bounds.width, height: minHeaderHight)
        }
        
        let tw = UITextView(frame: CGRect(x: 0, y: 0, width: captionTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        tw.attributedText = attriString
        let rect = tw.sizeThatFits(CGSize(width: captionTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let height = rect.height + 2 * tvPadding < minHeaderHight ? minHeaderHight : rect.height + 2 * tvPadding
        
        
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * 2 + middleSpacing * (numberOfItemPerRow - 1)
        let width = (collectionView.frame.width - paddingSpace) / numberOfItemPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return middleSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


extension SharePhotoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            showPlaceHolderLabel()
        } else {
            hidePlaceHolderLabel()
        }
        
        print("*** caption text view did changed")
        collectionView.collectionViewLayout.invalidateLayout()
        if let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: headerIndex) as? UICollectionViewCell {
            header.updateConstraints()
        }
        
    }
}
