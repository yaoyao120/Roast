//
//  UIButton+SetTitle.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-19.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

extension UIButton {
    func addButtonSetTitleWithNumber(_ number: Int, maxLimit: Int) {
        
        let forwardImage = UIImage(named: "forward_btn")
        
        if number == 0 {
            self.isHidden = true
        } else {
            
            let doneButtonTitle = maxLimit == 1 ? "Use" : "Add (\(number))"
            let titleAttributeString = NSAttributedString(string: doneButtonTitle, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: TextColor.textBlack])
            self.setAttributedTitle(titleAttributeString, for: .normal)
            self.setImage(forwardImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = TextColor.textBlack
            self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            self.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1.0)
            self.imageView?.transform = CGAffineTransform(scaleX: -1.4, y: 1.0)
            self.sizeToFit()
            self.isHidden = false
        }
    }
}
