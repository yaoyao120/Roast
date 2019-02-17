//
//  UserSearchCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-07.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol UserSearchCellDelegate: class {
    func userSearchCellDidTapFollowButton()
}

class UserSearchCell: UICollectionViewCell {
    
    weak var delegate: UserSearchCellDelegate!
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            guard let profileImageUrl = user?.profileImageUrl else {return}
            
            profileImageView.loadImage(urlString: profileImageUrl, showIndicator: true)
        }
    }
    var isFollowing = false {
        didSet {
            if isFollowing {
                DispatchQueue.main.async {
                    self.followButton.setTitle("Unfollow", for: .normal)
                    self.followButton.tintColor = TextColor.textBlack
                    self.followButton.layer.borderColor = TextColor.textBlack.cgColor
                    self.followButton.layer.borderWidth = 1.2
                }
            } else {
                DispatchQueue.main.async {
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.tintColor = ymCheckedColor
                    self.followButton.layer.borderWidth = 1.2
                    self.followButton.layer.borderColor = ymCheckedColor.cgColor
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProfileImageView()
        setupUserLabel()
        setupFollowButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = ""
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        return button
    }()
    
    fileprivate func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 25
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    fileprivate func setupUserLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupFollowButton() {
        addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 80, height: 30)
        followButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        followButton.layer.cornerRadius = 30 / 2
        followButton.addTarget(self, action: #selector(handleTapFollowButton), for: .touchUpInside)
        
    }
    
    //MARK: - Handle User Interaction Methods
    func handleTapFollowButton() {
        
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else {return}
        guard let userID = user?.uid else {return}
        
        if isFollowing {
            FIRDatabase.database().reference().child(FBKeyString.following).child(currentUserID).child(userID).removeValue(completionBlock: {
                error, ref in
                
                if let error  = error {
                    print("Failed to unfollow user: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.isFollowing = false
                }
                
                self.delegate.userSearchCellDidTapFollowButton()
            })
        } else {
            let ref = FIRDatabase.database().reference().child(FBKeyString.following).child(currentUserID)
            
            let values = [userID: 1]
            ref.updateChildValues(values, withCompletionBlock: {
                error, ref in
                
                if let error  = error {
                    print("Failed to follow user: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.isFollowing = true
                }
                
                self.delegate.userSearchCellDidTapFollowButton()
            })
        }
    }
    
}
