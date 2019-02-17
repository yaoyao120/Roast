//
//  SettingLauncher.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-21.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class Setting: NSObject {
    let name: SettingName
    let imageName: String
    
    init(name: SettingName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

enum SettingName: String {
    case edit = "Edit my profile"
    case liked = "Posts I've liked"
    case facebook = "Connect to facebook"
    case twitter = "Connect to twitter"
    case privacy = "Privacy settings"
    case password = "Change password"
    case logout = "Log out"
}

class SettingLauncher: NSObject {
    
    var homeController: UserProfileViewController?
    
    let cellID = "SettingCell"
    let blackView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white

        return cv
    }()
    
    let settings: [Setting] = {
        let settings = [Setting(name: .edit, imageName: "setting_profile"),
                        Setting(name: .liked, imageName: "setting_liked"),
                        Setting(name: .facebook, imageName: "setting_facebook"),
                        Setting(name: .twitter, imageName: "setting_twitter"),
                        Setting(name: .privacy, imageName: "setting_password"),
                        Setting(name: .password, imageName: "setting_privacy"),
                        Setting(name: .logout, imageName: "setting_logout")]
        return settings
    }()
    
    override init() {
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let cellNib = UINib(nibName: cellID, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellID)
    }
    
    func showSettings() {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        window.windowLevel = UIWindowLevelStatusBar + 1
        blackView.removeFromSuperview()
        collectionView.removeFromSuperview()
        
        //Add blackView first
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.frame = window.frame
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBlackView)))
        window.addSubview(blackView)
        
        //Add collectionView secondly
        let width = window.frame.width * 0.75
        let height = window.frame.height
        collectionView.frame = CGRect(x: -width, y: 0, width: width, height: height)
        collectionView.layer.shadowOffset = CGSize(width: 2, height: 2)
        window.addSubview(collectionView)
        
        blackView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 1
            self.collectionView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }, completion: nil)
        
    }
    
    func didTapBlackView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.collectionView.frame = CGRect(x: -self.collectionView.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            window.windowLevel = UIWindowLevelNormal
        })
        
    }
    
}

extension SettingLauncher: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! SettingCell
        cell.setting = settings[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
    }
    
    //Interaction
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.collectionView.frame = CGRect(x: -self.collectionView.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                window.windowLevel = UIWindowLevelNormal
            })
        }, completion: {
            completed in
            let setting = self.settings[indexPath.item]
            self.homeController?.showControllerForSetting(setting: setting)
        })
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
