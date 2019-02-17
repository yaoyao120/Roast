//
//  AlbumViewCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-13.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit

protocol AlbumViewCellDelegate: class {
    func albumViewCellDidTapCheckButton(in cell: AlbumViewCell)
}

class AlbumViewCell: UICollectionViewCell {
    
    //Private variable
    @IBOutlet weak var checkImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shadeView: UIView!
    fileprivate let checkImage = UIImage(named: "ic_check")
    
    //Public variable
    weak var delegate: AlbumViewCellDelegate?
    var representedAssetIdentifier: String!
    var isAssetSelected: Bool = false {
        didSet {
            toggleCheckedView(isAssetSelected)
        }
    }
    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    //Life-Circle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = ymLightTintColor.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 1
        
    checkImageButton.setImage(checkImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkImageButton.layer.cornerRadius = checkImageButton.bounds.width / 2
        checkImageButton.isOpaque = false
        isAssetSelected = false
        checkImageButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
    }
    
    override func prepareForReuse() {
        self.image = nil
        self.isAssetSelected = false
    }
    
    fileprivate func toggleCheckedView(_ isSelected: Bool) {
        
        checkImageButton.layer.borderColor = isSelected ? ymCheckedColor.cgColor : ghostWhite.cgColor
        checkImageButton.layer.borderWidth = isSelected ? 0 : 1.3
        checkImageButton.tintColor = isSelected ? UIColor.white : ghostWhite
        checkImageButton.backgroundColor = isSelected ? ymCheckedColor : ymLightTintColor.withAlphaComponent(0.3)
        shadeView.backgroundColor = isSelected ? UIColor(white: 1, alpha: 0.5) : UIColor.clear
        
    }
    
    func didTapButton(_ button: UIButton) {
        
        delegate?.albumViewCellDidTapCheckButton(in: self)
    }
    
    
    
}
