//
//  CustomAnimationPresentor.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-13.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class CustomAnimationPresentor: NSObject, UIViewControllerAnimatedTransitioning {
    
    var sign: CGFloat = 1
    
    init(leftToRight: Bool) {
        self.sign = leftToRight ? -1 : 1
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.viewController(forKey: .from) else {return}
        guard let toView = transitionContext.viewController(forKey: .to) else {return}
        
        containerView.addSubview(toView.view)
        
        let startingFrame = CGRect(x: sign * toView.view.frame.width, y: 0, width: toView.view.frame.width, height: toView.view.frame.height)
        toView.view.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            
            toView.view.frame = CGRect(x: 0, y: 0, width: toView.view.frame.width, height: toView.view.frame.height)
            fromView.view.frame = CGRect(x: -self.sign * fromView.view.frame.width, y: 0, width: fromView.view.frame.width, height: fromView.view.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
}

