//
//  RoastStickerView.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-31.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol RoastStickerViewDelegate: class {
    func roastStickerViewDidActive(sticker: RoastStickerView)
}

class RoastStickerView: UIView {
    
    weak var delegate: RoastStickerViewDelegate?
    
    var scale: CGFloat = 1
    var angle: CGFloat = 0
    
    var initialPoint: CGPoint = .zero
    var initialR: CGFloat = 0
    var initialScale: CGFloat = 1
    var initialCenter: CGPoint = .zero
    var initialAngle: CGFloat = 0

    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 2
        iv.layer.cornerRadius = 15
        return iv
    }()
    
    lazy var adjustView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "ic_retake").withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFill
        iv.tintColor = UIColor.black
        iv.backgroundColor = UIColor.white
        iv.layer.cornerRadius = 16
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "nav_close").withRenderingMode(.alwaysTemplate), for: .normal)
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    lazy var adjustPanGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handleAdjust(sender:)))
        return recognizer
    }()
    
    lazy var movePanGestureRecognizer : UIPanGestureRecognizer = {
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(handleDragFree(sender:)))
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.cancelsTouchesInView = true
        return panRecognizer
    }()
    
    lazy var activeTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleActive))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    func initWithImage(image: UIImage) {
        frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        //setup image view
        imageView.image = image
        addSubview(imageView)
        imageView.frame = frame
        
        //setup deleteButton
        addSubview(deleteButton)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        deleteButton.center = imageView.frame.origin
        
        //setup adjustButton
        addSubview(adjustView)
        adjustView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        adjustView.center = CGPoint(x: imageView.frame.width + imageView.frame.origin.x, y: imageView.frame.height + imageView.frame.origin.y)
        adjustView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin]
        
        //Add gesture
        enableDragging()
        adjustView.addGestureRecognizer(adjustPanGestureRecognizer)
        addGestureRecognizer(activeTapGestureRecognizer)
    }
    
    //Handle Userinteraction
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let pointForDeleteButton = self.convert(point, to: deleteButton)
        if deleteButton.bounds.contains(pointForDeleteButton) {
            return deleteButton
        }
        
        let pointForAdjustView = self.convert(point, to: adjustView)
        if adjustView.bounds.contains(pointForAdjustView) {
            return adjustView
        }
        
        return super.hitTest(point, with: event)
    }
    
    func handleActive() {
        delegate?.roastStickerViewDidActive(sticker: self)
    }
    
    func handleDelete() {
        removeFromSuperview()
    }
    
    func handleAdjust(sender: UIPanGestureRecognizer) {
        
        guard let superView = self.superview else {return}
        let location = sender.location(in: self)
        let translation = sender.translation(in: superView)
        
        if sender.state == .began {
            initialScale = scale
            initialPoint = location
            initialCenter = center
            let r0x = initialPoint.x - imageView.center.x
            let r0y = initialPoint.y - imageView.center.y
            initialR = sqrt(r0x * r0x + r0y * r0y)
            
            initialAngle = atan(r0y / r0x)
            
        }
        
        let rx = location.x + translation.x - imageView.center.x
        let ry = location.y + translation.y - imageView.center.y
        let r = sqrt(rx * rx + ry * ry)
        
        //Calculate changed angle
        let x2 = location.x + translation.x
        let y2 = location.y + translation.y
        let a2 = atan((y2 - imageView.center.y) / (x2 - imageView.center.x))
        angle += (a2 - initialAngle)
        
        setScale(scale: initialScale * r / initialR)
        
        sender.setTranslation(.zero, in: superView)
    }
    
    func setScale(scale: CGFloat) {
        self.scale = scale
        transform = CGAffineTransform.identity
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        frame.size = imageView.frame.size
        imageView.layer.cornerRadius = 3 / scale
        
        center = initialCenter
        imageView.center = CGPoint(x: imageView.frame.width / 2, y: imageView.frame.height / 2)
        
        transform = CGAffineTransform(rotationAngle: angle)
    }
    
}

extension RoastStickerView {
    
    func enableDragging() {
        
        isUserInteractionEnabled = true
        addGestureRecognizer(movePanGestureRecognizer)
    }
    
    func disableDragging() {
        removeGestureRecognizer(movePanGestureRecognizer)
    }
    
    func handleDrag(sender: UIPanGestureRecognizer) {
        
        guard let superView = self.superview else {return}
        
        let locationInView = sender.location(in: self)
        
        if !self.frame.contains(locationInView) && sender.state == UIGestureRecognizerState.began {
            return
        }
        
        let translation = sender.translation(in: superView)
        let newXMin = self.frame.minX + translation.x
        let newYMin = self.frame.minY + translation.y
        
        let newXMax = newXMin + self.frame.width
        let newYMax = newYMin + self.frame.height
        
        if newXMin < superView.frame.origin.x || newXMax > superView.frame.width {
            
            if newYMin < superView.frame.origin.y || newYMax > superView.frame.height {
                //do nothing
            } else {
                frame.origin.y = newYMin
            }
            sender.setTranslation(.zero, in: superView)
            return
        }
        
        if newYMin < superView.frame.origin.y || newYMax > superView.frame.height {
            
            if newXMin < superView.frame.origin.x || newXMax > superView.frame.width {
                //do nothing
            } else {
                frame.origin.x = newXMin
            }
            sender.setTranslation(.zero, in: superView)
            return
        }
        
        frame.origin = CGPoint(x: newXMin, y: newYMin)
        sender.setTranslation(.zero, in: superView)
        
    }
    
    func handleDragFree(sender: UIPanGestureRecognizer) {
        
        guard let superView = self.superview else {return}
        let locationInView = sender.location(in: self)
        
        if !self.frame.contains(locationInView) && sender.state == UIGestureRecognizerState.began {
            return
        }
        
        let translation = sender.translation(in: superView)
        print(translation)
        let newX = self.center.x + translation.x
        let newY = self.center.y + translation.y
        self.center = CGPoint(x: newX, y: newY)
        sender.setTranslation(.zero, in: superView)
        
    }
}

extension RoastStickerView: UIGestureRecognizerDelegate {
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        let pDelete = self.convert(point, to: deleteButton)
        if deleteButton.bounds.contains(pDelete) {
            return false
        }
        let pAdjust = self.convert(point, to: adjustView)
        if adjustView.bounds.contains(pAdjust) {
            return false
        }
        
        return true
    }
}
