//
//  CommentCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-16.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class CommentView: UIView {
    
    var originX: Double = 0.0
    var originY: Double = 0.0
    
    var comment: Comment? = nil {
        didSet {
            guard let comment = comment else {return}
            
            commentTextView.text = comment.text
//            originX = comment.originX
//            originY = comment.originY
            profileImageView.loadImage(urlString: comment.user.profileImageUrl, showIndicator: false)
            if comment.uid == FIRAuth.auth()?.currentUser?.uid {
                self.profileImageView.layer.borderColor = ymCheckedColor.cgColor
            }
        }
    }
    
    var isNewComment: Bool = false {
        didSet {
            if isNewComment {
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
                fetchUserWithUID(uid: uid, completion: { (user) in
                    self.profileImageView.loadImage(urlString: user.profileImageUrl, showIndicator: false)
                })
                profileImageView.alpha = 1
                profileImageView.layer.borderColor = TextColor.textRed.cgColor
            }
        }
    }
    
    fileprivate let profileImageHeight: CGFloat = 28
    fileprivate let commentFontAttribute: [String: Any] = {
        
        let attribute = [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white]
        return attribute
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.clear
        iv.alpha = 0.8
        iv.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.keyboardType = .default
        tv.backgroundColor =  UIColor(white: 0, alpha: 0.5)
        tv.layer.cornerRadius = 5
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 2)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        
        addSubview(commentTextView)
        addSubview(profileImageView)
        setupCommentTextView()
        setupProfileImageView()
        
        DispatchQueue.main.async {
            self.layoutIfNeeded()
            self.fitSize()
        }
    }
    
    func fitSize() {
        
        DispatchQueue.main.async {
            var w: CGFloat = 0
            var h: CGFloat = 0
            for view in self.subviews {
                if view.frame.origin.x + view.frame.width >= w { w = view.frame.origin.x + view.frame.width }
                if view.frame.origin.y + view.frame.height >= h { h = view.frame.origin.y + view.frame.height }
            }
            let size = CGSize(width: w, height: h)
            self.frame.size = size
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 5
    }
    
    fileprivate func setupProfileImageView() {
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: profileImageHeight, height: profileImageHeight)
        profileImageView.layer.cornerRadius = profileImageHeight / 2
        
    }
    
    fileprivate func setupCommentTextView() {
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: -5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        commentTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
        commentTextView.typingAttributes = commentFontAttribute
    }
    
    //Database related methods
    
    fileprivate func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ) {
        
        FIRDatabase.database().reference().child(FBKeyString.users).child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                
                return
            }
            let user = User(uid: uid, dictionary: dictionary)
            
            print("*** Successfully fetch user: \(uid)")
            
            completion(user)
            
        }, withCancel: {
            error in
            
            print("*** Fail to fetch user. Error: \(error)")
        })
    }
    
}
