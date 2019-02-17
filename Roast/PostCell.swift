//
//  PostCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-28.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol PostCellDelegate: class {
    func postCellDidTapProfileImageViewOf(userID: String)
    func postCellDidTapRoastButton(post: Post)
    func postCellDidTapLikeButton(cell: PostCell)
}

class PostCell: UICollectionViewCell {
    
    weak var delegate: PostCellDelegate?
    
    fileprivate let imageCellID = "ImageCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    fileprivate let imageSpacing:CGFloat = 1
    fileprivate let vertPadding: CGFloat = 8
    fileprivate let horiPadding: CGFloat = 15
    fileprivate let maxRatio: CGFloat = 1.9
    fileprivate let minRatio: CGFloat = 0.8
    fileprivate let collectionViewRatio: CGFloat = 1.6
    fileprivate let profileImageViewSize: CGFloat = 40
    fileprivate let titleAttributes: [String: Any] = [NSFontAttributeName: UIFont(name: "Baskerville-SemiBold", size: 20) as Any, NSForegroundColorAttributeName: UIColor.white]
    
    var post: Post? {
        didSet {
            
            if let post = post {                
                
                DispatchQueue.main.async {
                    self.userProfileImageView.loadImage(urlString: post.user.profileImageUrl, showIndicator: true)
                    self.postImageView.loadImage(urlString: post.coverImageUrl, showIndicator: true)
                    self.titleLabel.attributedText = NSAttributedString(string: post.caption, attributes: self.titleAttributes)
                    self.usernameLabel.text = post.user.username
                    self.creationDateLabel.text = post.creationDate.timeAgoDisplay()
                    self.likeButton.setImage(post.hasLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_unselected"), for: .normal)
                    
                }
            }
        }
    }
    
    let postImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        return label
    }()
    
    let creationDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.hex("#FD0D31", alpha: 1)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [self.likeButton, self.commentButton, self.sendMessageButton])
        sv.distribution = .fillEqually
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        DispatchQueue.main.async {
            self.addSubview(self.userProfileImageView)
            self.addSubview(self.optionsButton)
            self.addSubview(self.postImageView)
            self.addSubview(self.usernameLabel)
            self.addSubview(self.stackView)
            self.addSubview(self.bookmarkButton)
            
            self.setupHeader()
            self.setupPostImageView()
            self.setupActionButtons()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        DispatchQueue.main.async {
            self.usernameLabel.text = nil
            self.userProfileImageView.image = nil
            self.titleLabel.attributedText = nil
            self.creationDateLabel.text = nil
            self.postImageView.image = nil
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupHeader() {
        //setup profileimageview
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: vertPadding , paddingLeft: horiPadding, paddingBottom: 0, paddingRight: 0, width: profileImageViewSize, height: profileImageViewSize)
        userProfileImageView.layer.cornerRadius = profileImageViewSize / 2
        
        let tapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showUserProfilePage))
        tapRecognizer1.numberOfTapsRequired = 1
        userProfileImageView.isUserInteractionEnabled = true
        userProfileImageView.addGestureRecognizer(tapRecognizer1)
        
        //setup optionbutton
        optionsButton.anchor(top: topAnchor, left: nil, bottom: postImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        //setup usernamelabel
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: vertPadding + 1, paddingLeft: 8, paddingBottom: 0, paddingRight: horiPadding, width: 0, height: 0)
        
        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(showUserProfilePage))
        tapRecognizer2.numberOfTapsRequired = 1
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tapRecognizer2)
        
        addSubview(creationDateLabel)
        creationDateLabel.anchor(top: usernameLabel.bottomAnchor, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    fileprivate func setupPostImageView() {
        
        self.postImageView.anchor(top: self.userProfileImageView.bottomAnchor, left: self.leftAnchor, bottom: self.stackView.topAnchor, right: self.rightAnchor, paddingTop: self.vertPadding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.backgroundColor = UIColor.white
    }
    
    fileprivate func setupTitleView() {
        addSubview(titleView)
        titleView.anchor(top: nil,
                          left: postImageView.leftAnchor,
                          bottom: postImageView.bottomAnchor,
                          right: postImageView.rightAnchor,
                          paddingTop: 0,
                          paddingLeft: 0,
                          paddingBottom: 0,
                          paddingRight: 0,
                          width: 0,
                          height: 80)
        
        //Add titleLabel
        addSubview(titleLabel)
        titleLabel.anchor(top: titleView.topAnchor,
                          left: titleView.leftAnchor,
                          bottom: nil,
                          right: titleView.rightAnchor,
                          paddingTop: vertPadding,
                          paddingLeft: horiPadding,
                          paddingBottom: 0,
                          paddingRight: horiPadding,
                          width: 0,
                          height: 0)
        titleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 60).isActive = true
        
    }
    
    fileprivate func setupActionButtons() {
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        bookmarkButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
        
        commentButton.addTarget(self, action: #selector(handleRoast), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
    }
    
    //MARK: - Handle user interaction methods
    
    func showUserProfilePage() {
        guard let uid = post?.user.uid else {return}
        delegate?.postCellDidTapProfileImageViewOf(userID: uid)
    }
    
    func handleRoast() {
        guard let post = post else {return}
        delegate?.postCellDidTapRoastButton(post: post)
    }
    
    func handleLike() {
        
    }
    
}
