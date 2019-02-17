//
//  CustomImageView.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-30.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase
import Nuke

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = .gray
        ai.hidesWhenStopped = true
        return ai
    }()
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String, showIndicator: Bool) {
        
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            return
        }
        Nuke.loadImage(with: url, into: self) { (response, isFromCache) in
            self.image = response.value
        }
        
//        lastURLUsedToLoadImage = urlString
//        
//        DispatchQueue.main.async {
//            self.image = nil
//        }
//        
//        if showIndicator {
//            addSubview(activityIndicator)
//            activityIndicator.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//            activityIndicator.startAnimating()
//        }
//        
//        //Data Caching
//        if let cachedImage = imageCache[urlString] {
//            DispatchQueue.main.async {
//                self.image = cachedImage
//            }
//            activityIndicator.stopAnimating()
//            return
//        }
//        
//        guard let url = URL(string: urlString) else {
//            activityIndicator.stopAnimating()
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { (data, response, err) in
//            if let err = err {
//                
//                if err._code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
//                    print("*** Network error!")
//                }
//                self.activityIndicator.stopAnimating()
//                print("Failed to fetch post image:", err)
//                return
//            }
//            
//            if url.absoluteString != self.lastURLUsedToLoadImage {
//                
//                self.activityIndicator.stopAnimating()
//                return
//            }
//            
//            guard let imageData = data else {
//                
//                self.activityIndicator.stopAnimating()
//                return
//            }
//            
//            let photoImage = UIImage(data: imageData)
//            
//            //Data Cache
//            imageCache[url.absoluteString] = photoImage
//            
//            DispatchQueue.main.async {
//                self.image = photoImage
//                
//                self.activityIndicator.stopAnimating()
//            }
//            
//            }.resume()
    }
    
    static func ratioOfImageViewWith(post: Post, isRatioLimited: Bool) -> CGFloat {
        
        let maxRatio: CGFloat = 1.1
        let minRatio: CGFloat = 0.8
        
        let imageWidth = post.coverImageWidth
        let imageHeight = post.coverImageHeight
        let imageRatio = CGFloat(imageWidth / imageHeight)
        
        if isRatioLimited {
            if imageRatio < minRatio {
                return minRatio
            } else if imageRatio > maxRatio {
                return maxRatio
            } else {
                return imageRatio
            }
        } else {
            return imageRatio
        }
    }
    
    static func ratioOfImageViewWith(roast: Roast, isRatioLimited: Bool) -> CGFloat {
        
        let maxRatio: CGFloat = 1.2
        let minRatio: CGFloat = 0.8
        
        let imageWidth = roast.roastImageWidth
        let imageHeight = roast.roastImageHeight
        let imageRatio = CGFloat(imageWidth / imageHeight)
        
        if isRatioLimited {
            if imageRatio < minRatio {
                return minRatio
            } else if imageRatio > maxRatio {
                return maxRatio
            } else {
                return imageRatio
            }
        } else {
            return imageRatio
        }
    }
    
    static func ratioOfImageViewWith(image: UIImage, isRatioLimited: Bool) -> CGFloat {
        
        let maxRatio: CGFloat = 1.1
        let minRatio: CGFloat = 0.8
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let imageRatio = CGFloat(imageWidth / imageHeight)
        
        if isRatioLimited {
            if imageRatio < minRatio {
                return minRatio
            } else if imageRatio > maxRatio {
                return maxRatio
            } else {
                return imageRatio
            }
        } else {
            return imageRatio
        }
    }
    
}
