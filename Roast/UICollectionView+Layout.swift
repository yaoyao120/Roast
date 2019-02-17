//
//  UICollectionView+Layout.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-05.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

let headerImageRatio:CGFloat = 1.6

extension UICollectionView {
    
    
//    func ratioOfImageWith(post: Post, isRatioLimited: Bool) -> CGFloat {
//        
//        let maxRatio: CGFloat = 1.9
//        let minRatio: CGFloat = 0.8
//        
//        let imageWidth = post.coverImageWidth
//        let imageHeight = post.coverImageHeight
//        let imageRatio = CGFloat(imageWidth / imageHeight)
//        
//        if isRatioLimited {
//            if imageRatio < minRatio {
//                return minRatio
//            } else if imageRatio > maxRatio {
//                return maxRatio
//            } else {
//                return imageRatio
//            }
//        } else {
//            return imageRatio
//        }
//        
////        switch n {
////        case 1:
////            if isHeightLimited {
////                return CGSize(width: totalWidth, height: totalHeight)
////            } else {
////                let width = totalWidth
////                if ratio < minRatio {
////                    let height = width / minRatio
////                    return CGSize(width: width, height: height)
////                } else if ratio > maxRatio {
////                    let height = width / maxRatio
////                    return CGSize(width: width, height: height)
////                } else {
////                    let height = width / ratio
////                    return CGSize(width: width, height: height)
////                }
////            }
////        case 2:
////            let width = (totalWidth - imageSpacing) / 2
////            let height = totalHeight
////            return CGSize(width: width, height: height)
////        case 3:
////            let width = (totalWidth - imageSpacing) / 2
////            let height = index == 0 ? totalHeight : (totalHeight - imageSpacing) / 2
////            return CGSize(width: width, height: height)
////        case 4:
////            let width = (totalWidth - imageSpacing) / 2
////            let height = (totalHeight - imageSpacing) / 2
////            return CGSize(width: width, height: height)
////        case 5:
////            if index == 0 || index == 1 {
////                let width = (totalWidth - imageSpacing) / 2
////                let height = (totalHeight - imageSpacing) / 2
////                return CGSize(width: width, height: height)
////            } else {
////                let width = (totalWidth - 2 * imageSpacing) / 3
////                let height = (totalHeight - imageSpacing) / 2
////                return CGSize(width: width, height: height)
////            }
////        case 6:
////            let width = (totalWidth - 2 * imageSpacing) / 3
////            let height = (totalHeight - imageSpacing) / 2
////            return CGSize(width: width, height: height)
////        case 7:
////            if index == 3 || index == 4 {
////                let width = (totalWidth - imageSpacing) / 2
////                let height = (totalHeight - 2 * imageSpacing) / 3
////                return CGSize(width: width, height: height)
////            } else {
////                let width = (totalWidth - 2 * imageSpacing) / 3
////                let height = (totalHeight - 2 * imageSpacing) / 3
////                return CGSize(width: width, height: height)
////            }
////        case 8:
////            if index == 0 || index == 1 {
////                let width = (totalWidth - imageSpacing) / 2
////                let height = (totalHeight - 2 * imageSpacing) / 3
////                return CGSize(width: width, height: height)
////            } else {
////                let width = (totalWidth - 2 * imageSpacing) / 3
////                let height = (totalHeight - 2 * imageSpacing) / 3
////                return CGSize(width: width, height: height)
////            }
////        case 9:
////            let width = (totalWidth - 2 * imageSpacing) / 3
////            let height = (totalHeight - 2 * imageSpacing) / 3
////            return CGSize(width: width, height: height)
////        default:
////            return CGSize(width: totalWidth, height: totalHeight)
////        }
//        
//    }
    
    
    func sizeOfPostCellWith(post: Post) -> CGSize {
        
        let sectionInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let totalWidth = self.frame.width - 2 * sectionInsets.left
        let totalHeight = totalWidth / headerImageRatio
        
        return CGSize(width: totalWidth, height: totalHeight)
        
        
    }
    
}
