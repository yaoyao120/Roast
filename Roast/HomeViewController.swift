//
//  HomeViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-15.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    fileprivate let cellID = "CellID"
    fileprivate let numberOfItemPerRow: CGFloat = 3
    fileprivate let middleSpacing: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate let vertPadding: CGFloat = 8
    fileprivate let horiPadding: CGFloat = 15
    fileprivate let maxRatio: CGFloat = 1.9
    fileprivate let minRatio: CGFloat = 0.8
    fileprivate let profileImageViewSize: CGFloat = 40
    
//    fileprivate let presentor = CustomAnimationPresentor(leftToRight: false)
//    fileprivate let dismissor = CustomAnimationPresentor(leftToRight: true)
    fileprivate let navDelegate = NavDelegate()
    
    var posts = [Post]()
    var roasts = [Roast]()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    lazy var searchBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "search_selected"), style: .plain, target: self, action: #selector(handleSearch))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        setupNavigationBar()
        setupCollectionView()
        
        //fetchAllPosts()
        fetchAllRoasts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        
    }
    
    fileprivate func setupViewController() {
        view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPosts), name: UpdateFeedNotificationName, object: nil)
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationItem.rightBarButtonItem = searchBarButton
    }

    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCells()
        
        //setup refresh controller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRoast), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    fileprivate func registerCells() {
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    //Database Methods
    
    //////////////////////////////
    //Fetch Posts
    fileprivate func fetchAllPosts() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            self.endFetching()
            return
        }
        
        //1. fetch current user
        self.fetchUserWithUID(uid: uid) { (currentUser) in
            //2. fetch current user posts
            self.fetchPostsWithCurrentUser(user: currentUser, completion: {
                newPosts in
                
                self.posts = newPosts
                
                //3. fetch following users and posts
                self.fetchFollowingUserPosts()
            })
        }
    }
    
    fileprivate func fetchFollowingUserPosts() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            self.endFetching()
            return
        }
        FIRDatabase.database().reference().child(FBKeyString.following).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {
                
                self.endFetching()
                return
            }
            
            var i = 0
            let count = userIdsDictionary.count
            userIdsDictionary.forEach({ (key, value) in
                self.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostsWithUser(user: user, completion: {
                        i += 1
                        print("\(i) / \(count)")
                        if i < count {
                            //Do nothing
                        } else {
                            self.endFetching()
                        }
                    })
                })
            })
            
        }) { (err) in
            
            self.endFetching()
            print("Failed to fetch following user ids:", err)
        }
    }
    
    fileprivate func fetchPostsWithCurrentUser(user: User, completion: @escaping ([Post]) -> ()) {
        
        var newPosts = [Post]()
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.posts).child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                
                self.endFetching()
                completion(newPosts)
                return
            }
            
            var i = 0
            let count = dictionaries.count
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else {
                    completion(newPosts)
                    self.endFetching()
                    return
                }
                
                let post = Post(postId: key, user: user, dictionary: dictionary)
                newPosts.append(post)
                newPosts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.fetchRoastsWith(post: post, completion: {
                    self.fetchLikesWith(post: post, completion: { 
                        i += 1
                        if i < count {
                            //Do nothing
                        } else {
                            completion(newPosts)
                        }
                    })
                })
            })
            
        }) { (err) in
            
            self.endFetching()
            completion(newPosts)
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User, completion: @escaping () -> ()) {
        let ref = FIRDatabase.database().reference().child(FBKeyString.posts).child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                
                completion()
                return
            }
            
            var i = 0
            let count = dictionaries.count
            
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else {
                    completion()
                    return
                }
                
                let post = Post(postId: key, user: user, dictionary: dictionary)
                
                self.posts.append(post)
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.fetchRoastsWith(post: post, completion: {
                    self.fetchLikesWith(post: post, completion: {
                        i += 1
                        if i < count {
                            //Do nothing
                        } else {
                            completion()
                        }
                    })
                    
                })
            })
            
        }) { (err) in
            
            completion()
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func fetchRoastsWith(post: Post, completion: @escaping () -> ()) {
        
        guard let postID = post.id else {
            completion()
            return
        }
        
        post.roasts.removeAll()
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.roastsByPost).child(postID)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            var i = 0
            let count = dictionaries.count
            post.numberOfRoasts = count
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else {
                    completion()
                    return
                }
                guard let uid = dictionary[FBKeyString.userID] as? String else {return}
                
                self.fetchUserWithUID(uid: uid, completion: { (user) in
                    i += 1
                    let roast = Roast(roastId: key, user: user, dictionary: dictionary)
                    post.roasts.append(roast)
                    if i < count {
                        //Do nothing
                    } else {
                        post.roasts.sort(by: { (c1, c2) -> Bool in
                            c1.creationDate.compare(c2.creationDate) == .orderedDescending
                        })
                        
                        completion()
                    }
                })
                
            })
            
            
        }) { (error) in
            completion()
            print("*** Failed to observe comments from db")
        }
    }
    
    fileprivate func fetchLikesWith(post: Post, completion: @escaping () -> ()) {
        
        guard let postID = post.id else {
            completion()
            return
        }
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            completion()
            return
        }
        
        FIRDatabase.database().reference().child(FBKeyString.likes).child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            post.numberOfLikes = dictionary.count
            if let liked = dictionary[uid] as? Int, liked == 1 {
                post.hasLiked = true
            } else {
                post.hasLiked = false
            }
            
            completion()
            
        }) { (error) in
            print("Failed to fetch like infor from post: \(error)")
        }
    }
    
    /////////////////////////////////////
    //Fetch Roasts
    
    fileprivate func fetchAllRoasts() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            self.endFetching()
            return
        }
        
        //1. fetch current user
        self.fetchUserWithUID(uid: uid) { (currentUser) in
            //2. fetch current user roasts
            self.fetchRoastsWithCurrentUser(user: currentUser, completion: {
                newRoasts in
                
                self.roasts = newRoasts
                
                //3. fetch following users and posts
                self.fetchFollowingUserRoasts()
            })
        }
    }
    
    fileprivate func fetchFollowingUserRoasts() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            
            self.endFetching()
            return
        }
        FIRDatabase.database().reference().child(FBKeyString.following).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {
                
                self.endFetching()
                return
            }
            
            var i = 0
            let count = userIdsDictionary.count
            userIdsDictionary.forEach({ (key, value) in
                self.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchRoastsWithUser(user: user, completion: {
                        i += 1
                        print("\(i) / \(count)")
                        if i < count {
                            //Do nothing
                        } else {
                            self.endFetching()
                        }
                    })
                })
            })
            
        }) { (err) in
            
            self.endFetching()
            print("Failed to fetch following user ids:", err)
        }
    }
    
    fileprivate func fetchRoastsWithCurrentUser(user: User, completion: @escaping ([Roast]) -> ()) {
        
        var newRoasts = [Roast]()
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.roastsByUser).child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                
                self.endFetching()
                completion(newRoasts)
                return
            }
            
            var i = 0
            let count = dictionaries.count
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else {
                    completion(newRoasts)
                    self.endFetching()
                    return
                }
                
                let roast = Roast(roastId: key, user: user, dictionary: dictionary)
                newRoasts.append(roast)
                newRoasts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.fetchCommentsWith(roast: roast, completion: {
                    self.fetchLikesWith(roast: roast, completion: {
                        i += 1
                        if i < count {
                            //Do nothing
                        } else {
                            completion(newRoasts)
                        }
                    })
                })
            })
            
        }) { (err) in
            self.endFetching()
            completion(newRoasts)
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func fetchRoastsWithUser(user: User, completion: @escaping () -> ()) {
        let ref = FIRDatabase.database().reference().child(FBKeyString.roastsByUser).child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                
                completion()
                return
            }
            
            var i = 0
            let count = dictionaries.count
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else {
                    completion()
                    return
                }
                
                let roast = Roast(roastId: key, user: user, dictionary: dictionary)
                
                
                self.roasts.append(roast)
                self.roasts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.fetchCommentsWith(roast: roast, completion: {
                    self.fetchLikesWith(roast: roast, completion: {
                        i += 1
                        if i < count {
                            //Do nothing
                        } else {
                            completion()
                        }
                    })
                    
                })
            })
            
        }) { (err) in
            
            completion()
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func fetchCommentsWith(roast: Roast, completion: @escaping () -> ()) {
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.comments).child(roast.roastId)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            roast.numberOfComments = dictionaries.count
            
            completion()
            
        }) { (error) in
            completion()
            print("*** Failed to observe comments from db")
        }
    }
    
    fileprivate func fetchLikesWith(roast: Roast, completion: @escaping () -> ()) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            completion()
            return
        }
        FIRDatabase.database().reference().child(FBKeyString.likes).child(roast.roastId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {
                completion()
                return
            }
            
            roast.numberOfLikes = dictionary.count
            if let liked = dictionary[uid] as? Int, liked == 1 {
                roast.hasLiked = true
            } else {
                roast.hasLiked = false
            }
            
            completion()
            
        }) { (error) in
            print("Failed to fetch like infor from post: \(error)")
        }
    }
    
    /////////////////////////////
    
    fileprivate func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ) {
        
        FIRDatabase.database().reference().child(FBKeyString.users).child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                
                self.endFetching()
                completion(User(uid: uid, dictionary: [FBKeyString.username: "", FBKeyString.profileImageUrl: ""]))
                return
            }
            let user = User(uid: uid, dictionary: dictionary)
            
            print("*** Successfully fetch user: \(uid)")
            
            completion(user)
            
        }, withCancel: {
            error in
            
            self.endFetching()
            completion(User(uid: uid, dictionary: [FBKeyString.username: "", FBKeyString.profileImageUrl: ""]))
            
            print("*** Fail to fetch user. Error: \(error)")
        })
    }
    
    //Handle refresh
    func refreshPosts() {
        fetchAllPosts()
    }
    
    func refreshRoast() {
        fetchAllRoasts()
    }
    
    //Handle fetch completion
    fileprivate func endFetching() {
        DispatchQueue.main.async {
            print("*** this message should only appears once ***")
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func handleSearch() {
        let searchViewController = ExploreViewController()
        let naviController = UINavigationController(rootViewController: searchViewController)
        naviController.modalPresentationStyle = .custom
        naviController.delegate = navDelegate
        self.present(naviController, animated: true, completion: nil)
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return roasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let roast = roasts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GridCell
        cell.roast = roast
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 24) / 2
        let ratio = CustomImageView.ratioOfImageViewWith(roast: roasts[indexPath.item], isRatioLimited: false)
        let heightPostImage = width / ratio
        let height = heightPostImage + 32
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let roastDetailController = RoastDetailViewController()
        roastDetailController.roast = roasts[indexPath.item]
        navigationController?.pushViewController(roastDetailController, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
}

extension HomeViewController: PostCellDelegate {
    
    func postCellDidTapProfileImageViewOf(userID: String) {
        
        let userProfileController = UserProfileViewController()
        userProfileController.userID = userID
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func postCellDidTapRoastButton(post: Post) {
        let roastViewController = RoastViewController()
        let naviController = UINavigationController(rootViewController: roastViewController)
        roastViewController.post = post
        self.present(naviController, animated: true, completion: nil)
    }
    
    func postCellDidTapLikeButton(cell: PostCell) {
        
        
    }
}

extension HomeViewController: RoastCellDelegate {
    func roastCellDidTapProfileImageViewOf(userID: String) {
        let userProfileController = UserProfileViewController()
        userProfileController.userID = userID
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    
    func roastCellDidTapCommentButton(roast: Roast) {
        
        
    }
    
    func roastCellDidTapLikeButton(cell: RoastCell) {
        
        
    }
}
