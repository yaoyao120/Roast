//
//  WelcomeViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-13.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

struct ErrorMessage {
    static let emailInvalid = "Invalid email address"
    static let emailAlreadyInUse = "This email address is already in use"
    static let passwordWeak = "Password must be 6 characters or more"
    static let passwordWrong = "Incorrect password"
    static let userNotFound = "User not found"
}

class WelcomeViewController: UIViewController {

    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLoginButton()
        self.setupCreateAccountButton()
        self.setupFBLoginButton()
    }
    
    fileprivate func setupLoginButton() {
        logInButton.addTarget(self, action: #selector(didTapLogInButton), for: .touchUpInside)
    }
    
    fileprivate func setupCreateAccountButton() {
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
    }

    fileprivate func setupFBLoginButton() {
        
        fbButton.addTarget(self, action: #selector(didPressFBLoginButton), for: .touchUpInside)
        
    }
    
    //MARK: - Handle User Interaction
    func didTapLogInButton() {
        let signInConcroller = UserSignInViewController(nibName: "UserSignInViewController", bundle: nil)
        signInConcroller.delegate = self
        self.present(signInConcroller, animated: true, completion: nil)
    }
    
    func didTapCreateAccountButton() {
        let signUpConcroller = UserSignupViewController(nibName: "UserSignupViewController", bundle: nil)
        signUpConcroller.delegate = self
        self.present(signUpConcroller, animated: true, completion: nil)
    }

}

extension WelcomeViewController: FBSDKLoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("*** Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print("*** \(error)")
            return
        }
        getFBUserEmailAddress()
        
        print("*** Successfully logged in with facebook")
    }
    
    func didPressFBLoginButton() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self, handler: {
            result, error in
            
            if error != nil {
                print("*** \(String(describing: error))")
                return
            }
            self.getFBUserEmailAddress()
        })
    }
    
    fileprivate func getFBUserEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credential, completion: {
            user, error in
            if let error = error {
                print("*** \(String(describing: error))")
                
                switch error._code {
                case FIRAuthErrorCode.errorCodeUserDisabled.rawValue:
                    self.showUserErrorAlert()
                case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                    self.showNetWorkErrorAlert()
                default:
                    self.showServiceErrorAlert()
                    break
                }
                return
            }
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, friends"]).start(completionHandler: {
                connection, result, err in
                
                if err != nil {
                    print("*** Failed to start graph request: \(String(describing: err))")
                    return
                }
                if let result = result as? [String: Any] {
                    print("*** \(result)")
                    
                    //Save uid, profile image and fb username (fb username) to FIR database
                    guard let uid = user?.uid else { return }
                    guard let name = result[FBKeyString.username] as? String else { return }
                    guard let userID = result[FBKeyString.userID] as? String else { return }
                    let fbProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
                    let dictionaryValues: [String: Any] = [FBKeyString.username: name,  FBKeyString.profileImageUrl: fbProfileUrl]
                    let values = [uid: dictionaryValues]
                    FIRDatabase.database().reference().child(FBKeyString.users).updateChildValues(values, withCompletionBlock: { (error, reference) in
                        
                        if let error = error {
                            print("Failed to save user info into db:", error.localizedDescription)
                            return
                        }
                        print("*** Successfully saved user info to db")
                    })
                    
                    
                } else {
                    print("*** FB: Error getting graph request result")
                }
            })
            
            print("*** Successfully logged in with user: \(String(describing: user))")
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            mainTabBarController.setupViewControllers()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
        
    }
}


extension WelcomeViewController: UserSignInViewControllerDelegate, UserSignUpViewControllerDelegate {
    func userSignInViewControllerDidSignIn() {
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
        mainTabBarController.setupViewControllers()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userSignUpViewControllerDidSignUp() {
        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
        mainTabBarController.setupViewControllers()
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
