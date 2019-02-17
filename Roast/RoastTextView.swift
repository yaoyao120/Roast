//
//  RoastTextView.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-23.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

//
//  RoastStickerView.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-31.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol RoastTextViewDelegate: class {
    func roastTextViewShouldStartEditing()
    func roastTextViewDidScaled(scale: CGFloat, angle: CGFloat)
}

class RoastTextView: UIView {
    
    weak var delegate: RoastTextViewDelegate?
    
    var scale: CGFloat = 1
    var angle: CGFloat = 0
    
    var initialPoint: CGPoint = .zero
    var initialR: CGFloat = 0
    var initialScale: CGFloat = 1
    var initialCenter: CGPoint = .zero
    var initialAngle: CGFloat = 0
    
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isUserInteractionEnabled = false
        return tv
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
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        //button.setImage(#imageLiteral(resourceName: "nav_close").withRenderingMode(.alwaysTemplate), for: .normal)
        button.backgroundColor = UIColor.white
        button.tintColor = UIColor.black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
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
    
    func initWithText(text: NSAttributedString) {
        let testView = UITextView()
        testView.attributedText = text
        testView.sizeToFit()
        frame = CGRect(x: 0, y: 0, width: testView.frame.width, height: testView.frame.height)
        //setup image view
        textView.attributedText = text
        addSubview(textView)
        textView.frame = frame
        
        //setup deleteButton
        addSubview(editButton)
        editButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        editButton.center = textView.frame.origin
        
        //setup adjustButton
        addSubview(adjustView)
        adjustView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        adjustView.center = CGPoint(x: textView.frame.width + textView.frame.origin.x, y: textView.frame.height + textView.frame.origin.y)
        adjustView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleTopMargin]
        
        //Add gesture
        enableDragging()
        adjustView.addGestureRecognizer(adjustPanGestureRecognizer)
    }
    
    //Handle Userinteraction
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let pointForDeleteButton = self.convert(point, to: editButton)
        if editButton.bounds.contains(pointForDeleteButton) {
            return editButton
        }
        
        let pointForAdjustView = self.convert(point, to: adjustView)
        if adjustView.bounds.contains(pointForAdjustView) {
            return adjustView
        }
        
        return super.hitTest(point, with: event)
    }
    
    func handleEdit() {
        delegate?.roastTextViewShouldStartEditing()
    }
    
    func handleAdjust(sender: UIPanGestureRecognizer) {
        
        guard let superView = self.superview else {return}
        let location = sender.location(in: self)
        let translation = sender.translation(in: superView)
        
        if sender.state == .began {
            initialScale = scale
            initialPoint = location
            initialCenter = center
            let r0x = initialPoint.x - textView.center.x
            let r0y = initialPoint.y - textView.center.y
            initialR = sqrt(r0x * r0x + r0y * r0y)
            
            initialAngle = atan(r0y / r0x)
            
        }
        
        let rx = location.x + translation.x - textView.center.x
        let ry = location.y + translation.y - textView.center.y
        let r = sqrt(rx * rx + ry * ry)
        
        //Calculate changed angle
        let x2 = location.x + translation.x
        let y2 = location.y + translation.y
        let a2 = atan((y2 - textView.center.y) / (x2 - textView.center.x))
        angle += (a2 - initialAngle)
        
        setScale(scale: initialScale * r / initialR, angle: angle)
        
        sender.setTranslation(.zero, in: superView)
    }
    
    func setScale(scale: CGFloat, angle: CGFloat) {
        self.scale = scale
        transform = CGAffineTransform.identity
        textView.transform = CGAffineTransform(scaleX: scale, y: scale)
        frame.size = textView.frame.size
        textView.layer.cornerRadius = 3 / scale
        
        center = initialCenter
        textView.center = CGPoint(x: textView.frame.width / 2, y: textView.frame.height / 2)
        
        transform = CGAffineTransform(rotationAngle: angle)
        
        delegate?.roastTextViewDidScaled(scale: scale, angle: angle)
    }
    
}

extension RoastTextView {
    
    func enableDragging() {
        
        isUserInteractionEnabled = true
        addGestureRecognizer(movePanGestureRecognizer)
    }
    
    func disableDragging() {
        removeGestureRecognizer(movePanGestureRecognizer)
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

extension RoastTextView: UIGestureRecognizerDelegate {
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        let pDelete = self.convert(point, to: editButton)
        if editButton.bounds.contains(pDelete) {
            return false
        }
        let pAdjust = self.convert(point, to: adjustView)
        if adjustView.bounds.contains(pAdjust) {
            return false
        }
        
        return true
    }
}
