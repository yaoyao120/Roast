//
//  AssetCollecion.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-20.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import Photos

class AssetCollection {
    
    var collectionId: String!
    var collectionName: String!
    var totalCount: Int!
    var originalCollection: PHAssetCollection!
    var fetchResult: PHFetchResult<PHAsset>!
    var isCaremaRoll = false
    
    class func instance(with collection: PHAssetCollection) -> AssetCollection {
        //Set up fetch options
        let options = PHFetchOptions()
        let predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.predicate = predicate
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //Fetch assets from photo collection
        let assetCollection = AssetCollection()
        assetCollection.collectionId = collection.localIdentifier
        assetCollection.collectionName = collection.localizedTitle
        assetCollection.fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        assetCollection.originalCollection = collection
        assetCollection.totalCount = assetCollection.fetchResult.count
        if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
            assetCollection.isCaremaRoll = true
        }
        
        return assetCollection
    }
    
}
