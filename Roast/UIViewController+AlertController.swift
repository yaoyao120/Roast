//
//  UIViewController+AlertController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-14.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    
    func showNetWorkErrorAlert() {
        let alert = UIAlertController(title: "Network error 😐", message: "Please check your network connection.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showServiceErrorAlert() {
        let alert = UIAlertController(title: "Oops! Service error 😅", message: "There is something wrong on our end, please try again later.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showUserErrorAlert() {
        let alert = UIAlertController(title: "User not available 🤔", message: "The user you were looking for is currently not available, please email customer service.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMaximumPictureReachedAlert(_ max: Int) {
        var p = "pictures."
        if max == 1 {
            p = "picture."
        }
        let alert = UIAlertController(title: "You can choose maximum \(max) \(p)", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showLogOutAlert() {
        let alert = UIAlertController(title: "Log Out of Roast?", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: {
            action in
            
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                print("*** Failed ot sign out: \(error)")
            }
            DispatchQueue.main.async {
                let welcome = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
                self.present(welcome, animated: true, completion: nil)
            }
            
        })
        alert.addAction(cancel)
        alert.addAction(logout)
        self.present(alert, animated: true, completion: nil)
    }
}
