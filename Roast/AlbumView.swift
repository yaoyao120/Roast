//
//  AlbumView.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-11.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit
import Photos

protocol AlbumViewDelegate: class {
    func albumViewDidSelectAsset(_ assetViewer: SingleAssetViewController)
    func albumViewDidStartCarema(withMediaType mediaType: PickerMediaType)
    func albumViewDidUpdateDoneButton(withNumber number: Int, withSelectedAssets selectedAssets: [PHAsset])
}

class AlbumView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var caremaButton: UIButton!
    weak var delegate: AlbumViewDelegate?
    var images: PHFetchResult<PHAsset>!
    var selectedAssets = [PHAsset]() {
        didSet {
            delegate?.albumViewDidUpdateDoneButton(withNumber: selectedAssets.count, withSelectedAssets: selectedAssets)
        }
    }
    fileprivate var imageManager: PHCachingImageManager?
    fileprivate let numberOfItemPerRow: CGFloat = 3
    fileprivate var maxNumber: Int = 1
    fileprivate var lastSelectedIndexPath: IndexPath?
    
    fileprivate let cellSize = CGSize(width: 200, height: 200)
    fileprivate let sectionInsets = UIEdgeInsets(top: 3, left: 5, bottom: 8, right: 5)
    fileprivate var previousPreheatRect: CGRect = .zero
    fileprivate let cameraImage = UIImage(named: "ic_photo_camera")
    
    //MARK: - AlbumView LifeCycle
    class func instance() -> AlbumView {
        return UINib(nibName: "AlbumView", bundle: nil).instantiate(withOwner: self, options: nil).first as! AlbumView
    }
    
    func initialize(_ max: Int) {
        maxNumber = max
        collectionView.register(UINib(nibName: "AlbumViewCell", bundle: nil), forCellWithReuseIdentifier: "AlbumViewCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        imageManager = PHCachingImageManager()
        PHPhotoLibrary.shared().register(self)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        resetCachedAssets()
        updateCachedAssets()
    }
    
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
        print("*** albumView removed")
    }
    
    //MARK: - User Interface Setup Methods
    fileprivate func setupCameraButton() {
        caremaButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        caremaButton.backgroundColor = ghostWhite.withAlphaComponent(0.95)
        caremaButton.tintColor = ymDarkTintColor
        caremaButton.layer.cornerRadius = caremaButton.bounds.height / 2
        caremaButton.layer.shadowOpacity = 0.8
        caremaButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        
    }
    
    //MARK: - User Interaction Methods
    @IBAction func startCarema(_ sender: UIButton) {
        delegate?.albumViewDidStartCarema(withMediaType: PickerMediaType.image)
        
    }
    
    //MARK: - Data Related Methods
    func updatePhotos(with collection: AssetCollection) {
        if let fetchResults = collection.fetchResult {
            images = fetchResults
            if collection.isCaremaRoll {
                setupCameraButton()
                caremaButton.isHidden = false
            } else {
                caremaButton.isHidden = true
            }
            collectionView.reloadData()
            self.resetCachedAssets()
            print("*** photo updated")
        }
    }
    
    //MARK: - UIScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            updateCachedAssets()
        }
    }
    
    //MARK: - Asset Caching
    fileprivate func updateCachedAssets() {
        
        // Update only if the view is visible.
        guard collectionView.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = collectionView.bounds.insetBy(dx: 0, dy: -0.5 * collectionView.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > collectionView.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.aapl_indexPathsForElementsInRect(rect) }
            .map { indexPath in images.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.aapl_indexPathsForElementsInRect(rect) }
            .map { indexPath in images.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager?.startCachingImages(for: addedAssets,
                                        targetSize: cellSize, contentMode: .aspectFill, options: nil)
        imageManager?.stopCachingImages(for: removedAssets,
                                       targetSize: cellSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    
}

extension AlbumView: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: images)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            
            // Before reloading the PHFetchResult, if any asset was removed, delete same asset that was included in selected array
            if let removedIndexSet = changes.removedIndexes, removedIndexSet.count > 0 {
                //Gather all removed assets first
                let removedAssets = images.objects(at: removedIndexSet)
                //Loop through the removed asset, if matches any asset in selected array, delete that asset from selected array
                for asset in removedAssets {
                    for selected in selectedAssets {
                        if selected.localIdentifier == asset.localIdentifier {
                            if let index = selectedAssets.index(of: selected) {
                                selectedAssets.remove(at: index)
                            }
                        }
                    }
                }

            }
            
            
            // Hang on to the new fetch result.
            images = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                        print("*** item deleted")
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                        print("*** item inserted")
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                        print("*** item changed")
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                        print("*** item moved")
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
    
}

extension AlbumView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images == nil ? 0 : images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return images == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        let asset = self.images[indexPath.item]
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        imageManager?.requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: option, resultHandler: {
            result, info in
            
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.image = result
            } else {
                print("*** cell have been recycled")
            }
        })
        cell.layer.cornerRadius = 10
        
        //When reusing a cell, check if the asset it contains is in the selected array
        cell.delegate = self
        if !selectedAssets.isEmpty {
            let theAsset = images.object(at: indexPath.item)
            for i in 0..<selectedAssets.count {
                //Loop through the array to find matched asset
                if selectedAssets[i].localIdentifier == theAsset.localIdentifier {
                    cell.isAssetSelected = true
                }
            }
        }
        
        print("*** cell \(indexPath.item) loaded")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = self.images[indexPath.item]
        let assetViewer = SingleAssetViewController(nibName: "SingleAssetViewController", bundle: nil)
        assetViewer.initialize(with: asset)
        if !selectedAssets.isEmpty {
            for i in 0..<selectedAssets.count {
                //Loop through the array to find matched asset
                if selectedAssets[i].localIdentifier == asset.localIdentifier {
                    assetViewer.isAssetSelected = true
                }
            }
        }
        if assetViewer.isAssetSelected {
            assetViewer.doneButton.addButtonSetTitleWithNumber(self.selectedAssets.count, maxLimit: maxNumber)
        }
        assetViewer.delegate = self
        
        delegate?.albumViewDidSelectAsset(assetViewer)
        
    }
    
    
}

extension AlbumView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (self.numberOfItemPerRow + 1)
        let width = (collectionView.bounds.width - paddingSpace) / numberOfItemPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension AlbumView: AlbumViewCellDelegate {
    
    func albumViewCellDidTapCheckButton(in cell: AlbumViewCell) {
        
        if let indexPath = self.collectionView.indexPath(for: cell) {
            
            let theAsset = self.images.object(at: indexPath.item)
            if selectedAssets.isEmpty {
                cell.popWith(force: 0.3, duration: 0.8, repeatCount: 0, delay: 0)
                cell.checkImageButton.popWith(force: 1, duration: 0.8, repeatCount: 0, delay: 0)
                selectedAssets.append(theAsset)
                cell.isAssetSelected = true
                lastSelectedIndexPath = indexPath
                return
            }
            //Loop through the array to delete existing asset
            for i in 0..<selectedAssets.count {
                if selectedAssets[i].localIdentifier == theAsset.localIdentifier {
                    selectedAssets.remove(at: i)
                    cell.isAssetSelected = false
                    return
                }
            }
            //If no match, add to array as new asset (if not reach maximum limit)
            //If can only select one image, remove the previous one first and add new asset to selected list
            if maxNumber == 1 {
                selectedAssets.removeAll()
                if let index = lastSelectedIndexPath {
                    if let previousCell = collectionView.cellForItem(at: index) as? AlbumViewCell {
                        previousCell.isAssetSelected = false
                    }
                }
                
                cell.popWith(force: 0.3, duration: 0.8, repeatCount: 0, delay: 0)
                cell.checkImageButton.popWith(force: 1, duration: 0.8, repeatCount: 0, delay: 0)
                selectedAssets.append(theAsset)
                cell.isAssetSelected = true
                lastSelectedIndexPath = indexPath
                return
            }
            guard selectedAssets.count < self.maxNumber else {
                cell.shakeWith(force: 0.6, duration: 0.2, repeatCount: 0, delay: 0)
                return
            }
            cell.popWith(force: 0.3, duration: 0.8, repeatCount: 0, delay: 0)
            cell.checkImageButton.popWith(force: 1, duration: 0.8, repeatCount: 0, delay: 0)
            selectedAssets.append(theAsset)
            cell.isAssetSelected = true
            lastSelectedIndexPath = indexPath
        }
    }
}

extension AlbumView: SingleAssetViewControllerDelegate {
    
    func singleAssetViewControllerDidTapCheckButton(with asset: PHAsset, in viewer: SingleAssetViewController) {
        
        let indexPath = IndexPath(item: self.images.index(of: asset), section: 0)
        
        if selectedAssets.isEmpty {
            viewer.selectionButton.popWith(force: 1.5, duration: 0.8, repeatCount: 0, delay: 0)
            selectedAssets.append(asset)
            DispatchQueue.main.async {
                viewer.doneButton.addButtonSetTitleWithNumber(self.selectedAssets.count, maxLimit: self.maxNumber)
            }
            viewer.isAssetSelected = true
            lastSelectedIndexPath = indexPath
            return
        }
        //Loop through the array to delete existing asset
        for i in 0..<selectedAssets.count {
            if selectedAssets[i].localIdentifier == asset.localIdentifier {
                selectedAssets.remove(at: i)
                DispatchQueue.main.async {
                    viewer.doneButton.addButtonSetTitleWithNumber(self.selectedAssets.count, maxLimit: self.maxNumber)
                }
                viewer.isAssetSelected = false
                return
            }
        }
        //If no match, add to array as new asset (if not reach maximum limit)
        //If can only select one image, remove the previous one first and add new asset to selected list
        if maxNumber == 1 {
            selectedAssets.removeAll()
            viewer.selectionButton.popWith(force: 1.2, duration: 0.8, repeatCount: 0, delay: 0)
            selectedAssets.append(asset)
            DispatchQueue.main.async {
                viewer.doneButton.addButtonSetTitleWithNumber(self.selectedAssets.count, maxLimit: self.maxNumber)
            }
            viewer.isAssetSelected = true
            lastSelectedIndexPath = indexPath
            return
        }
        
        guard selectedAssets.count < self.maxNumber else {
            viewer.selectionButton.shakeWith(force: 1, duration: 0.2, repeatCount: 0, delay: 0)
            return
        }
        viewer.selectionButton.popWith(force: 1.2, duration: 0.8, repeatCount: 0, delay: 0)
        selectedAssets.append(asset)
        DispatchQueue.main.async {
            viewer.doneButton.addButtonSetTitleWithNumber(self.selectedAssets.count, maxLimit: self.maxNumber)
        }
        viewer.isAssetSelected = true
        lastSelectedIndexPath = indexPath
    }
    
    func singleAssetViewControllerDidClosed(with asset: PHAsset) {
        //Reload the coresponding albumviewcell
        DispatchQueue.main.async {
            //let indexPath = [IndexPath(item: self.images.index(of: asset), section: 0)]
            //self.collectionView.reloadItems(at: indexPath)
            self.collectionView.reloadData()
        }
    }
    
}
