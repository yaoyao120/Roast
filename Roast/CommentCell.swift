//
//  CommentCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-07-02.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol CommentCellDelegate: class {
    func commentCellDidTapProfileImageViewOf(userID: String)
}

class CommentCell: UICollectionViewCell {
    
    weak var delegate: CommentCellDelegate?
    
    let profileImageViewSize: CGFloat = 35
    let likeButtonSize: CGSize = {
        let image = #imageLiteral(resourceName: "like_selected")
        let ratio = image.size.width / image.size.height
        return CGSize(width: 24, height: 24 / ratio)
    }()
    let likeLabelSize: CGFloat = 12
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else {return}
            
            DispatchQueue.main.async {
                self.textLabel.text = comment.text
                self.profileImageView.loadImage(urlString: comment.user.profileImageUrl, showIndicator: false)
                let username = comment.user.username
                let date = comment.creationDate.timeAgoDisplay().lowercased()
                self.userLabel.text = username + " • " + date
                self.likeButton.setImage(comment.hasLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_unselected"), for: .normal)
                self.likeLabel.text = String(comment.numberOfLikes)
            }
        }
    }
    
    lazy var profileTapRecognizor: UITapGestureRecognizer = {
        let recognizor = UITapGestureRecognizer(target: self, action: #selector(handleTapProfile))
        recognizor.numberOfTapsRequired = 1
        return recognizor
    }()
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.lightGray
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var textLabel: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = TextColor.textBlack
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.textContainerInset.top = 4
        
        return textView
    }()
    
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = TextColor.textGray
        label.numberOfLines = 1
        label.backgroundColor = .clear
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.hex("#FD0D31", alpha: 1)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()
    
    lazy var likeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 10)
        label.textColor = TextColor.textBlack
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
    
    //Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(profileImageView)
        addSubview(userLabel)
        addSubview(textLabel)
        addSubview(likeButton)
        addSubview(likeLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: profileImageViewSize, height: profileImageViewSize)
        profileImageView.layer.cornerRadius = profileImageViewSize / 2
        profileImageView.addGestureRecognizer(profileTapRecognizor)
        
        userLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 4, width: 0, height: 14)
        
        textLabel.anchor(top: userLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 2, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        
        likeButton.anchor(top: userLabel.bottomAnchor, left: textLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: likeButtonSize.width, height: likeButtonSize.height)
        
        likeLabel.anchor(top: likeButton.topAnchor, left: likeButton.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: likeLabelSize, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        DispatchQueue.main.async {
            self.textLabel.text = ""
            self.profileImageView.image = nil
            self.likeLabel.text = ""
            self.userLabel.text = ""
            self.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        }
        
    }
    
    //Handle User Interaction
    func handleTapProfile() {
        guard let uid = comment?.user.uid else {return}
        delegate?.commentCellDidTapProfileImageViewOf(userID: uid)
    }
    
    func handleLike() {
        
        guard let comment = comment else {return}
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        let commentID = comment.commentID
        if comment.hasLiked {
            FIRDatabase.database().reference().child(FBKeyString.likes).child(commentID).child(uid).removeValue(completionBlock: { (error, ref) in
                if let error = error {
                    print("*** Failed to unlike comment: \(error)")
                    return
                }
                comment.hasLiked = !comment.hasLiked
                comment.numberOfLikes = comment.hasLiked ? comment.numberOfLikes + 1 : comment.numberOfLikes - 1
                DispatchQueue.main.async {
                    self.likeButton.setImage(comment.hasLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_unselected"), for: .normal)
                    self.likeLabel.text = String(comment.numberOfLikes)
                }
                if comment.hasLiked {
                    self.likeButton.popWith(force: 2, duration: 1, repeatCount: 0, delay: 0)
                } else {
                    self.likeButton.popWith(force: 1, duration: 0.6, repeatCount: 0, delay: 0)
                }
                print("*** Successfully \(comment.hasLiked ? "liked" : "unliked") comment")
                
            })
            
        } else {
            let values = [uid: 1]
            FIRDatabase.database().reference().child(FBKeyString.likes).child(commentID).updateChildValues(values) { (error, ref) in
                
                if let error = error {
                    print("*** Failed to like comment: \(error)")
                    return
                }
                comment.hasLiked = !comment.hasLiked
                comment.numberOfLikes = comment.hasLiked ? comment.numberOfLikes + 1 : comment.numberOfLikes - 1
                DispatchQueue.main.async {
                    self.likeButton.setImage(comment.hasLiked ? #imageLiteral(resourceName: "like_selected") : #imageLiteral(resourceName: "like_unselected"), for: .normal)
                    self.likeLabel.text = String(comment.numberOfLikes)
                }
                if comment.hasLiked {
                    self.likeButton.popWith(force: 2, duration: 1, repeatCount: 0, delay: 0)
                } else {
                    self.likeButton.popWith(force: 1, duration: 0.6, repeatCount: 0, delay: 0)
                }
                
                print("*** Successfully \(comment.hasLiked ? "liked" : "unliked") comment")
            }
        }
    }
    
}
