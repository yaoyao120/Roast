//
//  RoastViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-05-17.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class RoastViewController: UIViewController {
    
    var post: Post? {
        didSet {
            guard let post = self.post else {return}
            imageView.loadImage(urlString: post.coverImageUrl, showIndicator: true)
        }
    }
    
    var roastImage: UIImage?
    var roastComments: String = ""
    
    fileprivate var keyboardFrame: CGRect?
    fileprivate let cellID = "CellID"
    fileprivate let commentFontAttribute: [String: Any] = {
        let attribute = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: UIColor.white]
        return attribute
    }()
    
    fileprivate let barButtonAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: TextColor.textBlack]
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.white
        tv.keyboardDismissMode = .onDrag
        tv.backgroundColor = UIColor.white
        return tv
    }()
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var menuBar: RoastMenuBar = {
        let mb = RoastMenuBar()
        return mb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        view.addSubview(menuBar)
        
        setupNavigationBar()
        setupMenuBar()
        setupTableView()
        registerKeyboardNotification()
        
    }
    
    deinit {
        unregisterKeyboardNotification()
    }
    
    fileprivate func setupTableView() {
        
        tableView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: menuBar.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = cancelButton
        cancelButton.setTitleTextAttributes(barButtonAttribute, for: .normal)
        let postButton = UIBarButtonItem(title: "Roast", style: .plain, target: self, action: #selector(handlePost))
        postButton.setTitleTextAttributes(barButtonAttribute, for: .normal)
        navigationItem.rightBarButtonItem = postButton
    }
    
    fileprivate func setupMenuBar() {
        menuBar.delegate = self
        menuBar.anchor(top: nil, left: view.leftAnchor, bottom: bottomLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
    }
    
    //MARK: - User interaction Handler
    func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func handlePost() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        guard let image = imageView.image else {return}
        guard let uploadData = UIImageJPEGRepresentation(image, 1) else {return}
        guard let postID = self.post?.id else {return}
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        //upload image
        let filename = NSUUID().uuidString
        FIRStorage.storage().reference().child(FBKeyString.roastImages).child(filename).put(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("*** Failed to upload roast image: \(error)")
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
            
            let values: [String: Any] =
                [FBKeyString.userID: uid,
                 FBKeyString.creationDate: Date().timeIntervalSince1970,
                 FBKeyString.roastImageUrl: imageUrl,
                 FBKeyString.roastImageWidth: image.size.width,
                 FBKeyString.roastImageHeight: image.size.height,
                 FBKeyString.roastText: self.roastComments]
            let values2: [String: Any] = [
                FBKeyString.postID: postID,
                FBKeyString.roastImageUrl: imageUrl,
                FBKeyString.roastImageWidth: image.size.width,
                FBKeyString.roastImageHeight: image.size.height,
                FBKeyString.roastText: self.roastComments
            ]
            
            let reference = FIRDatabase.database().reference().child(FBKeyString.roastsByPost).child(postID).childByAutoId()
            reference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    if error._code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
                        self.showNetWorkErrorAlert()
                    }
                    print("*** Failed to save roast info into database: \(error)")
                    return
                }
                
                FIRDatabase.database().reference().child(FBKeyString.roastsByUser).child(uid).child(reference.key).updateChildValues(values2, withCompletionBlock: { (error, ref) in
                    
                    if let error = error {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        
                        if error._code == FIRAuthErrorCode.errorCodeNetworkError.rawValue {
                            self.showNetWorkErrorAlert()
                        }
                        print("*** Failed to save roast info into database: \(error)")
                        return
                    }
                    print("*** Successfully saved roast into database!")
                    self.dismiss(animated: true, completion: nil)
                })
                
            })
            
        }
        
    }
    
    //MARK: - Keyboard Methods
    
    fileprivate func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    fileprivate func unregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                self.keyboardFrame = keyboardFrame
            }
        }
    }
    
}

extension RoastViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.addSubview(imageView)
        cell.selectionStyle = .none
        imageView.anchor(top: cell.topAnchor, left: cell.leftAnchor, bottom: cell.bottomAnchor, right: cell.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let post = self.post else { return view.frame.width }
        let ratio = CustomImageView.ratioOfImageViewWith(post: post, isRatioLimited: true)
        let height = view.frame.width / ratio
        return height
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension RoastViewController: RoastMenuBarDelegate {
    func roastMenuBarDidSelectTool(index: Int) {
        switch index{
        case 0:
            guard let image = imageView.image else { return }
            let textController = RoastTextViewController()
            let navController = UINavigationController(rootViewController: textController)
            textController.image = image
            textController.delegate = self
            self.present(navController, animated: false, completion: nil)
        case 1:
            guard let image = imageView.image else { return }
            let stickerController = StickerViewController()
            let navController = UINavigationController(rootViewController: stickerController)
            stickerController.image = image
            stickerController.delegate = self
            self.present(navController, animated: false, completion: nil)
            
        case 2:
            guard let image = imageView.image else { return }
            let drawController = RoastDrawViewController()
            let navController = UINavigationController(rootViewController: drawController)
            drawController.image = image
            drawController.delegate = self
            self.present(navController, animated: false, completion: nil)
        default:
            break
        }
    }
}

extension RoastViewController: StickerViewControllerDelegate {
    func stickerViewControllerDidFinishEditing(newImage: UIImage) {
        imageView.image = newImage
        roastImage = newImage
    }
}

extension RoastViewController: RoastTextViewControllerDelegate {
    func roastTextViewControllerDidFinishEditing(newImage: UIImage, roastComment: String) {
        imageView.image = newImage
        roastImage = newImage
        roastComments.append(" ")
        roastComments.append(roastComment)
    }
}

extension RoastViewController: RoastDrawViewControllerDelegate {
    func roastDrawViewControllerDidFinishEditing(newImage: UIImage) {
        imageView.image = newImage
        roastImage = newImage
    }
}


