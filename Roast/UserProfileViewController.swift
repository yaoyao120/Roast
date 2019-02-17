//
//  UserProfileViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-14.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase
import Photos

class UserProfileViewController: UIViewController {
    
    var userID: String?
    var user: User?
    var posts = [Post]()
    
    lazy var settingLauncher: SettingLauncher = {
        let launcher = SettingLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.alwaysBounceVertical = true
        cv.bounces = true
        return cv
    }()
    
    let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        return button
    }()
    
    let navBGView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate var headerIndexPath = IndexPath()
    fileprivate let bottomDefaultSpacing: CGFloat = 80
    fileprivate let minBottomSpacing: CGFloat = 22
    fileprivate let settingImage = UIImage(named: "menu")
    fileprivate let albumCellID = "AlbumCell"
    fileprivate let numberOfItemPerRow: CGFloat = 3
    fileprivate let middleSpacing: CGFloat = 5
    fileprivate let sectionInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    fileprivate let vertPadding: CGFloat = 8
    fileprivate let horiPadding: CGFloat = 15
    fileprivate let maxRatio: CGFloat = 1.9
    fileprivate let minRatio: CGFloat = 0.8
    fileprivate let profileImageViewSize: CGFloat = 40
    fileprivate let headerRatio: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewController()
        self.setupNavigationBar()
        self.setupCollectionView()
        
        fetchUser()
        
        print("*** UserProfileViewController did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateHeaderAppearance()
    }
    
    //MARK: - Setup Methods
    
    fileprivate func setupViewController() {
        view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPosts), name: UpdateFeedNotificationName, object: nil)
    }
    
    fileprivate func setupNavigationBar() {
        
        guard let nc = navigationController else { return }
        nc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nc.navigationBar.shadowImage = UIImage()
        nc.navigationBar.isTranslucent = true
        nc.navigationBar.barTintColor = UIColor.clear
        nc.navigationBar.tintColor = UIColor.white
        
        menuButton.tintColor = UIColor.white
        menuButton.target = self
        navigationItem.rightBarButtonItems = [menuButton]
        if let mb = navigationItem.rightBarButtonItems?.first {
            mb.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -3, right: -8)
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18) , NSForegroundColorAttributeName: TextColor.textBlack]
        
        if userID == nil {
            menuButton.image = settingImage
            menuButton.action = #selector(didTapSettingButton)
        } else {
            menuButton.title = "•••"
            menuButton.action = #selector(didTapMoreActionButton)
        }
        
    }
    
    fileprivate func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        registerElements()
        
        //add navibar background view
        view.addSubview(navBGView)
        navBGView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navBGView.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        //setup refresh controller
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        //setup collectionview content inset and naviBGview height
        guard let h1 = navigationController?.navigationBar.frame.height else {
            collectionView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
            navBGView.heightAnchor.constraint(equalToConstant: 64).isActive = true
            return
        }
        let h2 = UIApplication.shared.statusBarFrame.height
        collectionView.contentInset = UIEdgeInsets(top: -(h1+h2), left: 0, bottom: 0, right: 0)
        navBGView.heightAnchor.constraint(equalToConstant: h1 + h2).isActive = true
    }
    
    fileprivate func registerElements() {
        let headerNib = UINib(nibName: "UserProfileHeader", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "UserProfileHeader")
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: albumCellID)
    }
    
    //MARK: - User Interaction Handler Methods
    
    func didTapSettingButton() {
        settingLauncher.showSettings()
    }
    
    func didTapMoreActionButton() {
        
    }
    
    func showControllerForSetting(setting: Setting) {
        
        switch setting.name {
        case .logout:
            self.showLogOutAlert()
        default:
            let settingViewController = UIViewController()
            
            //1. self.navigationItem.backBarButtonItem defaults to nil, You must create your own button object in order to set it's title
            //2. The backBarButtonItem only affects it's child views that are pushed on top of it in the navigation stack
            let backButton = UIBarButtonItem()
            backButton.title = ""
            navigationItem.backBarButtonItem = backButton
            
            settingViewController.navigationItem.title = setting.name.rawValue
            settingViewController.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17) , NSForegroundColorAttributeName: TextColor.textBlack]
            navigationController?.navigationBar.tintColor = TextColor.textBlack
            navigationController?.pushViewController(settingViewController, animated: true)
        }
        
    }
    
    //MARK: - User Interface desing methods
    fileprivate func updateHeaderAppearance() {
        
        //update navibar, menubutton and backbutton color
        let currentOffset = collectionView.contentOffset.y
        guard currentOffset > 0 else {return}
        let alpha = currentOffset / (collectionView.frame.width * headerRatio - 64)
        if alpha < 0.2 {
            navBGView.backgroundColor = UIColor.white.withAlphaComponent(0)
        } else if alpha > 0.95 {
            navBGView.backgroundColor = UIColor.white.withAlphaComponent(1)
        } else {
            navBGView.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        }
        menuButton.tintColor = UIColor(white: 1 - alpha , alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor(white: 1 - alpha , alpha: 1)
        
        //update navibar title
        if alpha > 0.7 {
            navigationItem.title = user?.username
        } else {
            navigationItem.title = ""
        }
        
        //update infoview location
        guard let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: headerIndexPath) as? UserProfileHeader else { return }
        guard bottomDefaultSpacing - currentOffset >= minBottomSpacing else { return }
        header.profileInfoViewBottomAnchor.constant = bottomDefaultSpacing - currentOffset
    }
    
    //MARK: - Database related methods
    func refreshPosts() {
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        
        let uid = userID ?? (FIRAuth.auth()?.currentUser?.uid ?? "")
        
        self.fetchUserWithUID(uid: uid, completion: {
            user in
            self.user = user
            
            self.fetchPosts(user: user, completion: {
                newPosts in
                
                self.posts = newPosts
                self.endFetching()
            })
            
        })
        
    }
    
    fileprivate func fetchPosts(user: User, completion: @escaping ([Post]) -> ()) {
        
        let ref = FIRDatabase.database().reference().child(FBKeyString.posts).child(user.uid)
        var newPosts = [Post]()
        
        ref.observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                self.posts.removeAll()
                self.endFetching()
                return
            }
            dictionaries.forEach({
                key, value in
                
                guard let dictionary = value as? [String: Any] else {
                    
                    self.endFetching()
                    return
                }
                let post = Post(postId: key, user: user, dictionary: dictionary)
                newPosts.append(post)
            })
            
            newPosts.sort(by: {post1, post2 in
                return post1.creationDate > post2.creationDate
            })
            
            completion(newPosts)
            
        }, withCancel: {
            error in
            
            self.endFetching()
            print("*** Fail to fetching posts: \(error)")
        })
    }
    
    fileprivate func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ) {
        
        FIRDatabase.database().reference().child(FBKeyString.users).child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                self.endFetching()
                return
            }
            let user = User(uid: uid, dictionary: dictionary)
            
            print("*** Successfully fetch user: \(uid)")
            
            completion(user)
            
        }, withCancel: {
            error in
            
            self.endFetching()
            print("*** Fail to fetch user. Error: \(error)")
        })
    }
    
    fileprivate func endFetching() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: - UICollectionView Delegate and DataSource Methods
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UserProfileHeader", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        
        headerIndexPath = indexPath
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateHeaderAppearance()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = posts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: albumCellID, for: indexPath) as! PostCell
        cell.post = post
        return cell
        
    }
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: view.frame.width * headerRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let heightProfileImage = profileImageViewSize + 2 * vertPadding
        let width = view.frame.width
        let ratio = CustomImageView.ratioOfImageViewWith(post: posts[indexPath.item], isRatioLimited: true)
        let heightPostImage = width / ratio
        let height = heightPostImage + heightProfileImage + 50
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension UserProfileViewController: UserProfileHeaderDelegate {
    func userProfileHeaderDidTapImageView(_ header: UserProfileHeader) {
        let actionSheet = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Select Photo", style: .default, handler: {
            action in
            let imagePicker = ImagePickerViewController(nibName: "ImagePickerViewController", bundle: nil)
            imagePicker.setupImagePickerWithLimit(PickerMode.pickProfileImgae, max: 1, highQuality: false)
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(action)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension UserProfileViewController: ImagePickerViewControllerDelegate {
    func imagePickerViewControllerDidFinishPicking(_ imagePicker: ImagePickerViewController, data: [Data], assets: [PHAsset]) {
        
        guard data.count != 0 else {return}
        guard let profileImageData = data.first else {return}
        //Upload profile photo to database
        FIRDatabase.uploadProfileImageData(imageData: profileImageData, completion: {
            self.refreshPosts()
        })
    }

}
