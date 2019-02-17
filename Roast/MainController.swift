//
//  MainTabBarController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-14.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if FIRAuth.auth()?.currentUser == nil {
            DispatchQueue.main.async {
                let welcome = WelcomeViewController(nibName: "WelcomeViewController", bundle: nil)
                self.present(welcome, animated: false, completion: nil)
            }
            return
        }

        setupViewControllers()
    }

    func setupViewControllers() {

        setupTabBar()

        //home
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController())
        //plus
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UIViewController())
        //user profile
        let userProfileController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileViewController())

        viewControllers = [homeNavController, plusNavController, userProfileController]

    }

    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return navController
    }

    fileprivate func setupTabBar() {
        self.delegate = self
        tabBar.tintColor = TextColor.textBlack
        tabBar.barTintColor = UIColor.white
        tabBar.isOpaque = false
        tabBar.isTranslucent = true
    }

}

extension MainController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        let index = viewControllers?.index(of: viewController)

        if index == 1 {

            let imagePicker = ImagePickerViewController(nibName: "ImagePickerViewController", bundle: nil)
            imagePicker.setupImagePickerWithLimit(.pickPostImage, max: 1, highQuality: true)
            self.present(imagePicker, animated: true, completion: nil)

            return false
        }
        return true
    }
}





