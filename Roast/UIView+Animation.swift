//
//  UIView+Animation.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-06.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func popWith(force: CGFloat, duration: CGFloat, repeatCount: Int, delay: CGFloat) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "transform.scale"
        animation.values = [0, 0.2*force, -0.2*force, 0.2*force, 0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
        animation.duration = CFTimeInterval(duration)
        animation.isAdditive = true
        animation.repeatCount = Float(repeatCount)
        animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay)
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "pop")
        
    }
    
    func shakeWith(force: CGFloat, duration: CGFloat, repeatCount: Int, delay: CGFloat) {
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [1*force, 10*force, -10*force, 10*force, 0]
        animation.keyTimes = [0, 0.167, 0.5, 0.833, 1]
        animation.duration = CFTimeInterval(duration)
        animation.repeatCount = Float(repeatCount)
        animation.beginTime = CACurrentMediaTime() + CFTimeInterval(delay)
        animation.isAdditive = true
        animation.isRemovedOnCompletion = true
        layer.add(animation, forKey: "shake")
        
    }
    
    func popIn(superView: UIView, origin: CGPoint, duration: CGFloat, delay: CGFloat) {
        
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        superView.addSubview(self)
        superView.sendSubview(toBack: self)
        self.frame.origin = origin
        
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(delay), options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.alpha = 1
            self.transform = CGAffineTransform.identity
            
        }, completion: { (completed) in
            //Do nothing
        })
        
    }
    
    func popOut(superView: UIView, origin: CGPoint, duration: CGFloat, delay: CGFloat) {
        
        self.alpha = 1
        
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(delay), options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
            
        }, completion: { (completed) in
            self.removeFromSuperview()
        })
        
    }
}
