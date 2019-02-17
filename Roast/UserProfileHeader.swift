//
//  UserProfileHeader.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-17.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol UserProfileHeaderDelegate: class {
    func userProfileHeaderDidTapImageView(_ header: UserProfileHeader)
}

class UserProfileHeader: UICollectionViewCell {
    
    fileprivate let profileHolder = UIImage(named: "profile")
    
    weak var delegate: UserProfileHeaderDelegate?
    var user: User? {
        didSet {
            setupProfileImage()
            setupUserName()
            setupBGImage()
        }
    }

    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bgImageView: CustomImageView!
    
    @IBOutlet weak var profileInfoViewBottomAnchor: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.white
        setupBGImageView()
        setupProfileImageView()
        setupProfileInfoView()
        userNameLabel.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        userNameLabel.text = ""
    }

    //MARK: - UI Design Method
    
    fileprivate func setupBGImageView() {
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.backgroundColor = UIColor.white
        bgImageView.image = UIImage(named: "111")
    }
    
    fileprivate func setupProfileInfoView() {
        
        profileInfoView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
    }
    
    fileprivate func setupProfileImageView() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        
        //Add gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        profileImageView.image = profileHolder?.withRenderingMode(.alwaysTemplate)
        profileImageView.tintColor = UIColor.lightGray
    }
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        profileImageView.loadImage(urlString: profileImageUrl, showIndicator: false)
    }
    
    fileprivate func setupUserName() {
        userNameLabel.textColor = UIColor.white
        guard let name = user?.username else {return}
        DispatchQueue.main.async {
            self.userNameLabel.text = name
            self.userNameLabel.sizeToFit()
        }
    }
    
    fileprivate func setupBGImage() {
        bgImageView.image = UIImage(named: "111")
    }
    
    //MARK: - User Interaction Handler Methods
    func didTapProfileImageView() {
        delegate?.userProfileHeaderDidTapImageView(self)
    }

}
