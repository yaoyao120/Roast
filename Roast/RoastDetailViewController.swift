//
//  RoastDetailViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-07-01.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class RoastDetailViewController: UIViewController {
    
    let roastCellID = "RoastCell"
    let commentCellID = "CommentCell"
    fileprivate let vertPadding: CGFloat = 8
    fileprivate let profileImageViewSize: CGFloat = 35
    
    var roast: Roast?
    var comments = [Comment]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.alwaysBounceVertical = true
        cv.bounces = true
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.typingAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 10), NSForegroundColorAttributeName: TextColor.textBlack]
        tf.placeholder = "Enter comment..."
        tf.clearButtonMode = .whileEditing
        tf.delegate = self
        return tf
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        button.isEnabled = false
        button.tintColor = UIColor.gray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        setupNavigationBar()
        setupCollectionView()
        
        refreshComments(completion: {
            //do nothing
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            
            containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
            containerView.addSubview(inputTextField)
            inputTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 0, width: view.frame.width - 85, height: 0)
            containerView.addSubview(submitButton)
            submitButton.anchor(top: containerView.topAnchor, left: inputTextField.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
            
            containerView.addTopBorder(UIColor.gray, width: 0.5)
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - setup methods
    fileprivate func setupNavigationBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) , NSForegroundColorAttributeName: TextColor.textBlack]
    }
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        registerElements()
        
        //setup refresh controller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    fileprivate func registerElements() {
        collectionView.register(RoastCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: roastCellID)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: commentCellID)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: commentCellID)
    }
    
    //MARK: - Handle User Interaction
    func handleSubmit() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        guard let roastID = roast?.roastId else { return }
        guard let text = inputTextField.text else {return}
        
        let value = [FBKeyString.userID: uid, FBKeyString.creationDate: Date().timeIntervalSince1970, FBKeyString.commentText: text] as [String : Any]
        
        FIRDatabase.database().reference().child(FBKeyString.comments).child(roastID).childByAutoId().updateChildValues(value) { (error, ref) in
            if let error = error {
                print("*** Failed to upload comment \(error)")
                return
            }
            
            self.refreshComments(completion: {
                DispatchQueue.main.async {
                    self.inputTextField.text = nil
                    self.inputTextField.resignFirstResponder()
                    if !self.comments.isEmpty {
                        let topIndex = IndexPath(item: 0, section: 0)
                        
                        self.collectionView.scrollToItem(at: topIndex, at: UICollectionViewScrollPosition.top, animated: true)
                    }
                }
            })
            print("Successfully uploaded comment")
        }
    }
    
    //MARK: - Database methods
    func refresh() {
        guard let roast = roast else { return }
        fetchCommentsWith(roast: roast) {
            print("*** Should appear only once")
            self.endFetching()
        }
    }
    
    func refreshComments(completion: @escaping () -> ()) {
        guard let roast = roast else { return }
        fetchCommentsWith(roast: roast) {
            print("*** Should appear only once")
            self.endFetching()
            completion()
        }
    }
    
    fileprivate func endFetching() {
        DispatchQueue.main.async {
            print("*** this message should only appears once ***")
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    fileprivate func fetchCommentsWith(roast: Roast, completion: @escaping () -> ()) {
        
        roast.comments.removeAll()
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.comments).child(roast.roastId)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            var i = 0
            let count = dictionaries.count
            roast.numberOfComments = dictionaries.count
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else {
                    completion()
                    return
                }
                guard let uid = dictionary[FBKeyString.userID] as? String else {
                    completion()
                    return
                }
                
                self.fetchUserWithUID(uid: uid, completion: { (user) in
                    
                    let comment = Comment(commentID: key, user: user, dictionary: dictionary)
                    roast.comments.append(comment)
                    
                    self.fetchLikesWith(comment: comment, completion: {
                        i += 1
                        if i < count {
                            //Do nothing
                        } else {
                            roast.comments.sort(by: { (c1, c2) -> Bool in
                                c1.creationDate.compare(c2.creationDate) == .orderedDescending
                            })
                            self.comments = roast.comments
                            completion()
                        }
                    })
                })
            })
            
        }) { (error) in
            completion()
            print("*** Failed to observe comments from db")
        }
    }
    
    fileprivate func fetchLikesWith(comment: Comment, completion: @escaping () -> ()) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            completion()
            return
        }
        
        FIRDatabase.database().reference().child(FBKeyString.likes).child(comment.commentID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            comment.numberOfLikes = dictionary.count
            
            if let liked = dictionary[uid] as? Int, liked == 1 {
                comment.hasLiked = true
            } else {
                comment.hasLiked = false
            }
            
            completion()
            
        }) { (error) in
            print("Failed to fetch like infor from post: \(error)")
        }
    }
    
    fileprivate func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ) {
        
        FIRDatabase.database().reference().child(FBKeyString.users).child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                
                completion(User(uid: uid, dictionary: [FBKeyString.username: "", FBKeyString.profileImageUrl: ""]))
                return
            }
            let user = User(uid: uid, dictionary: dictionary)
            
            print("*** Successfully fetch user: \(uid)")
            
            completion(user)
            
        }, withCancel: {
            error in
            
            completion(User(uid: uid, dictionary: [FBKeyString.username: "", FBKeyString.profileImageUrl: ""]))
            
            print("*** Fail to fetch user. Error: \(error)")
        })
    }
    
}

extension RoastDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - UICollectionView Delegate and DataSource Methods
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: roastCellID, for: indexPath) as! RoastCell
        header.roast = self.roast
        header.delegate = self
        
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let comment = comments[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellID, for: indexPath) as! CommentCell
        cell.comment = comment
        cell.delegate = self
        return cell
    }
}

extension RoastDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let roast = self.roast else {
            return CGSize(width: collectionView.frame.width, height: view.frame.width)
        }
        
        let heightProfileImage = profileImageViewSize + 2 * vertPadding
        let width = collectionView.frame.width
        let ratio = CustomImageView.ratioOfImageViewWith(roast: roast, isRatioLimited: true)
        let heightPostImage = width / ratio
        let height = heightPostImage + heightProfileImage + 50
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.textLabel.text = comments[indexPath.item].text
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(estimatedSize.height, profileImageViewSize + 2 * vertPadding)
        print(height)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension RoastDetailViewController: RoastCellDelegate {
    func roastCellDidTapProfileImageViewOf(userID: String) {
        let userProfileController = UserProfileViewController()
        userProfileController.userID = userID
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func roastCellDidTapCommentButton(roast: Roast) {
        inputTextField.becomeFirstResponder()
    }
    
    func roastCellDidTapLikeButton(cell: RoastCell) {
        
    }
}

extension RoastDetailViewController: CommentCellDelegate {
    func commentCellDidTapProfileImageViewOf(userID: String) {
        let userProfileController = UserProfileViewController()
        userProfileController.userID = userID
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}

extension RoastDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let oldText = textField.text as NSString? else { return false }
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        submitButton.isEnabled = (newText.length > 0)
        submitButton.tintColor = newText.length > 0 ? TextColor.textBlue : UIColor.gray
        
        return true
    }
}
