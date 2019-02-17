//
//  ColorCollectionViewCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-04.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    fileprivate let colorImage = UIImage(named: "text_color")
    
    @IBOutlet weak var colorButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorButton.setImage(colorImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        colorButton.isUserInteractionEnabled = false
    }
    
    
}
