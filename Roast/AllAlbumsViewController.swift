//
//  AllAlbumsTableViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-18.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit
import Photos

protocol AllAlbumsViewControllerDelegate: class {
    func allAlbumsViewController(didSelect assetCollection: AssetCollection)
}

class AllAlbumsViewController: UIViewController {

    weak var delegate: AllAlbumsViewControllerDelegate?
    var imageManager: PHCachingImageManager?
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    var selectedAlbums: [AssetCollection]!
    
    fileprivate let cellSize = CGSize(width: 200, height: 200)
    fileprivate let backImage = UIImage(named: "back_btn")
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuTopConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AlbumCollectionCell", bundle: nil), forCellReuseIdentifier: "AlbumCollectionCell")
        
        //Configure the TableView and MenuView
        tableView.separatorStyle = .none
        
        menuTopConstraint.constant = UIApplication.shared.statusBarFrame.height
        menuView.backgroundColor = ymBackgroundColor
        menuView.addBottomBorder(ymLightTintColor, width: 0.5)
        closeButton.setImage(backImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = TextColor.textBlack
        
        //Check for photo authorization and load album
        let authorStatus = PHPhotoLibrary.authorizationStatus()
        if authorStatus == .authorized {
            self.loadAlbums()
        }
    }
    
    deinit {
        //PHPhotoLibrary.shared().unregisterChangeObserver(self)
        
        print("*** allAlbumViewController removed")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: - User Interaction Methods
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Data Related Methods
    func loadAlbums() {
        imageManager = PHCachingImageManager()
        selectedAlbums = [AssetCollection]()
        
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: options)
        
        smartAlbums.enumerateObjects({( collection, index, stop) in
            
            let assetCollection = AssetCollection.instance(with: collection)
            if assetCollection.totalCount > 0 {
                //1. if camera roll, put in the first index
                //2. if recently deleted album, ignore it
                //3. add all the rest smart albums
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    self.selectedAlbums.insert(assetCollection, at: 0)
                } else if collection.assetCollectionSubtype.hashValue == 0 {
                    // do nothing
                } else {
                    self.selectedAlbums.append(assetCollection)
                }
                
            }
        })
        
        userCollections.enumerateObjects({(collection, index, stop) in
            if let collection = collection as? PHAssetCollection {
                let assetCollection = AssetCollection.instance(with: collection)
                if assetCollection.totalCount > 0 {
                    self.selectedAlbums.append(assetCollection)
                }
            }
        })
        //PHPhotoLibrary.shared().register(self)
        
    }

}

extension AllAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectedAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCollectionCell", for: indexPath) as! AlbumCollectionCell
        
        let collection = selectedAlbums[indexPath.row]
        cell.albumTitleLabel.text = collection.collectionName
        cell.numberLabel.text = String(collection.totalCount)
        if let firstAsset = collection.fetchResult.firstObject {
            self.imageManager?.requestImage(for: firstAsset, targetSize: cellSize, contentMode: .aspectFill, options: nil, resultHandler: { result, info in
                
                if let result = result {
                    cell.albumImage = result
                } else {
                    cell.albumImage = UIImage(named: "placeholder")
                }
            })
        } else {
            cell.albumImage = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.allAlbumsViewController(didSelect: selectedAlbums[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
