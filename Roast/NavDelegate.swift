//
//  NavDelegate.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-28.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class NavDelegate: NSObject, UINavigationControllerDelegate {
    
    private let presentor = CustomAnimationPresentor(leftToRight: false)
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return presentor
    }
}
