//
//  YMAsset.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-01.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Photos

class YMAsset {
    
    var imageManager: PHCachingImageManager?
    var localIdentifier: String?
    var image: UIImage?
    var pixelWidth: Int?
    var pixelHeight: Int?
    var mediaType: PickerMediaType!
    var duration: Double?
    
    
    class func initialize(with asset: PHAsset, highQuality: Bool, completion: @escaping (YMAsset) -> ()) {
        print("*** Original Image in pixel: \(asset.pixelWidth) * \(asset.pixelHeight)")

        var width = Double(asset.pixelWidth)
        var height = Double(asset.pixelHeight)
        if highQuality {
            let ratio = width / height
            //case 1: long image
            if ratio < 0.5 {
                print("*** long image")
                if width > 640 {
                    width = 640
                    height = 640 / ratio
                }
            } else if ratio < 1.91 {
                print("*** normal ratio image")
                //case 2: normal ratio image
                if width > 1080 {
                    width = 1080
                    height = 1080 / ratio
                }
            } else {
                print("*** short ratio image")
                //case 3: short image
                if height > 640 {
                    height = 640
                    width = 640 * ratio
                }
            }
            
        } else {
            width = 200
            height = 200
        }
        
        print("*** Resized Image in pixel: \(width) * \(height)")
        
        let ymAsset = YMAsset()
        ymAsset.localIdentifier = asset.localIdentifier
        if asset.mediaType == .image {
            ymAsset.mediaType = PickerMediaType.image
            //1. High quality Image Only
            //2. The requestImage blocks the calling thread until image data is ready or an error occurs.
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            option.isSynchronous = true
            option.resizeMode = highQuality ? .exact : .fast
            ymAsset.imageManager = PHCachingImageManager()
            ymAsset.imageManager?.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: option, resultHandler: {
                result, info in
                ymAsset.pixelWidth = asset.pixelWidth
                ymAsset.pixelHeight = asset.pixelHeight
                ymAsset.image = result
                
            })
        } else if asset.mediaType == .video {
            ymAsset.mediaType = PickerMediaType.video
            ymAsset.duration = asset.duration
        }
        
        completion(ymAsset)
    }
    
    deinit {
        print("*** YMAsset Removed")
    }
}
