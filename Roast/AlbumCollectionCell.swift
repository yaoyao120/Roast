//
//  AlbumCollectionCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-02-18.
//  Copyright © 2017 Junction Seven. All rights reserved.
//

import UIKit

class AlbumCollectionCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    var albumImage: UIImage? {
        didSet {
            self.albumImageView.image = albumImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.albumImageView.layer.cornerRadius = 5
        self.albumImageView.contentMode = .scaleAspectFill
        self.albumImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        self.albumImage = UIImage(named: "placeholder")
    }
    

}
