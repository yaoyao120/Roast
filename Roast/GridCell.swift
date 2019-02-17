//
//  GridCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-07-05.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
    
    fileprivate let profileImageSize: CGFloat = 20
    fileprivate let buttonHeight: CGFloat = 12
    fileprivate let buttonWidth: CGFloat = 14
    
    var roast: Roast? {
        didSet {
            DispatchQueue.main.async {
                guard let roast = self.roast else {return}
                self.coverImageView.loadImage(urlString: roast.roastImageUrl, showIndicator: false)
                self.profileImageView.loadImage(urlString: roast.user.profileImageUrl, showIndicator: false)
                self.commentNumberLabel.text = String(roast.numberOfComments)
                self.likeNumberLabel.text = String(roast.numberOfLikes)
            }
            
        }
    }
    
    var post: Post? {
        didSet {
            guard let post = post else {return}
            coverImageView.loadImage(urlString: post.coverImageUrl, showIndicator: false)
            captionTextView.text = post.caption
        }
    }
    
    lazy var coverImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    lazy var profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = self.profileImageSize / 2
        return imageView
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.isUserInteractionEnabled = false
        button.tintColor = TextColor.textRed
        return button
    }()
    
    lazy var likeNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Roman", size: 12)
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var commentNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Roman", size: 12)
        return label
    }()
    
    lazy var captionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = TextColor.textBlack
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.textContainerInset.top = 4
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        DispatchQueue.main.async {
            self.backgroundColor = .white
            self.clipsToBounds = true
            self.setupRoastView()
            self.setupPostView()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupRoastView() {
        if roast != nil {
            
            addSubview(coverImageView)
            coverImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            addSubview(profileImageView)
            profileImageView.anchor(top: coverImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 4, paddingLeft: 2, paddingBottom: 4, paddingRight: 0, width: profileImageSize, height: profileImageSize)
            addSubview(commentNumberLabel)
            commentNumberLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0).isActive = true
            commentNumberLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 0, height: 12)
            commentNumberLabel.sizeToFit()
            
            addSubview(commentButton)
            commentButton.centerYAnchor.constraint(equalTo: commentNumberLabel.centerYAnchor, constant: 0).isActive = true
            commentButton.anchor(top: nil, left: nil, bottom: nil, right: commentNumberLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: buttonWidth, height: buttonHeight)
            
            addSubview(likeNumberLabel)
            likeNumberLabel.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor, constant: 0).isActive = true
            likeNumberLabel.anchor(top: nil, left: nil, bottom: nil, right: commentButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 6, width: 0, height: 12)
            likeNumberLabel.sizeToFit()
            
            addSubview(likeButton)
            likeButton.centerYAnchor.constraint(equalTo: likeNumberLabel.centerYAnchor, constant: 0).isActive = true
            likeButton.anchor(top: nil, left: nil, bottom: nil, right: likeNumberLabel.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: buttonWidth, height: buttonHeight)
            
            //            addSubview(captionTextView)
            //
            //            captionTextView.anchor(top: coverImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        }
    }
    
    fileprivate func setupPostView() {
        if let post = post {
            if !post.caption.isEmpty {
                addSubview(coverImageView)
                coverImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
                
                addSubview(captionTextView)
                
                captionTextView.anchor(top: coverImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 12)
            } else {
                addSubview(coverImageView)
                coverImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
            }
        }
    }
    
}
