//
//  ExploreViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-07.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class ExploreViewController: UIViewController {

    let searchCellID = "SearchCell"
    
    var users = [User]()
    var filteredUsers = [User]()
    var followingUserIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        setupCollectionView()
        
        fetchUsers()
        fetchFollowingUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.isHidden = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        searchBar.becomeFirstResponder()
        
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search post and people"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(colorLiteralRed: 230/256, green: 230/256, blue: 230/256, alpha: 1)
        sb.delegate = self
        return sb
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(handleBack))
        return button
    }()

    fileprivate func setupNavigationBar() {
        guard let navController = self.navigationController else {return}
        navController.navigationBar.isOpaque = true
        //navController.navigationBar.barTintColor = UIColor.white
        navController.navigationBar.tintColor = TextColor.textBlack
        navController.navigationBar.addSubview(searchBar)
        
        navigationItem.leftBarButtonItem = backButton
        let navBar = navController.navigationBar
        
        searchBar.anchor(top: navBar.topAnchor, left: navBar.leftAnchor, bottom: navBar.bottomAnchor, right: navBar.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        
    }
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: searchCellID)
        
        let refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        collectionView.refreshControl = refreshControll
    }
    
    //Mark: - Database related Methods
    fileprivate func fetchUsers() {
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.users)
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                self.collectionView.refreshControl?.endRefreshing()
                return
            }
            
            self.users.removeAll()
            
            dictionaries.forEach({
                key, value in
                
                //check if the user is my self
                if key == FIRAuth.auth()?.currentUser?.uid {
                    self.collectionView.refreshControl?.endRefreshing()
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else {
                    self.collectionView.refreshControl?.endRefreshing()
                    return
                }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
                
            })
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
            }
        }, withCancel: {
            error in
            print("Failed to fetch users for search: \(error)")
        })
    }
    
    fileprivate func fetchFollowingUsers() {
        
        guard let currentUserID = FIRAuth.auth()?.currentUser?.uid else {
            self.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.following).child(currentUserID)
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let followingUserIDs = snapshot.value as? [String: Any] else {
                self.collectionView.refreshControl?.endRefreshing()
                self.followingUserIDs.removeAll()
                return
            }
            
            self.followingUserIDs.removeAll()
            followingUserIDs.forEach({
                key, value in
                
                self.followingUserIDs.append(key)
            })
            self.collectionView.refreshControl?.endRefreshing()
            
        }, withCancel: {
            error in
            print("Failed to fetch following users: \(error)")
        })
    }
    
    fileprivate func checkIsFollowing(userID: String) -> Bool {
        if followingUserIDs.isEmpty {
            return false
        }
        
        for uid in followingUserIDs {
            if uid == userID {
                return true
            }
        }
        
        return false
    }
    
    func refreshView() {
        fetchUsers()
        fetchFollowingUsers()
    }
    
    //Handle User interaction
    func handleBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ExploreViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredUsers = users.filter({ (user) -> Bool in
            
            return user.username.lowercased().contains(searchText.lowercased())
        })
        
        filteredUsers.sort { (u1, u2) -> Bool in
            u1.username.compare(u2.username) == .orderedAscending
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        
        let user = filteredUsers[indexPath.item]
        let userProfileController = UserProfileViewController()
        userProfileController.userID = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchCellID, for: indexPath) as! UserSearchCell
        let user = filteredUsers[indexPath.item]
        cell.user = user
        cell.isFollowing = checkIsFollowing(userID: user.uid)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension ExploreViewController: UserSearchCellDelegate {
    
    func userSearchCellDidTapFollowButton() {
        fetchFollowingUsers()
    }
}
