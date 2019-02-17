//
//  SettingCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-21.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class SettingCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var setting: Setting? {
        didSet {
            
            if let name = setting?.name, let imageName = setting?.imageName {
                nameLabel.text = name.rawValue
                nameLabel.textColor = TextColor.textBlack
                nameLabel.sizeToFit()
                
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.image = UIImage(named: imageName)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor =  isSelected ? ymLightTintColor : UIColor.white
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor =  isHighlighted ? ymLightTintColor : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : TextColor.textBlack
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = ""
        iconImageView.image = nil
    }
}
