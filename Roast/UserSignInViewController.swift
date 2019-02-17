//
//  UserSignInViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-13.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol UserSignInViewControllerDelegate: class {
    func userSignInViewControllerDidSignIn()
}

class UserSignInViewController: UIViewController {
    
    weak var delegate: UserSignInViewControllerDelegate?
    
    fileprivate let backImage = UIImage(named: "back_btn")

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var isLogingIn = false {
        didSet {
            if isLogingIn {
                logInButton.isEnabled = false
                logInButton.setTitle("", for: .normal)
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
                logInButton.isEnabled = true
                logInButton.setTitle("Log In", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackButton()
        setupUserLogInView()
        setupUserInfoTextField()
        setupPasswordTextField()
        setupLogInButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.becomeFirstResponder()
    }

    fileprivate func setupBackButton() {
        topBarView.backgroundColor = UIColor.clear
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(backImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = ymDarkTintColor
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    fileprivate func setupUserLogInView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupUserInfoTextField() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(jumpToPasswordTextField), for: .editingDidEndOnExit)
        emailTextField.textColor = TextColor.textBlack
        
        emailErrorLabel.textColor = TextColor.textRed
        emailErrorLabel.isHidden = true
    }
    
    fileprivate func setupPasswordTextField() {
        passwordTextField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didPressLogInButton), for: .editingDidEndOnExit)
        passwordTextField.textColor = TextColor.textBlack
        
        passwordErrorLabel.textColor = TextColor.textRed
        passwordErrorLabel.isHidden = true
    }
    
    fileprivate func setupLogInButton() {
        logInButton.setTitle("Log In", for: .normal)
        logInButton.addTarget(self, action: #selector(didPressLogInButton), for: .touchUpInside)
        logInButton.layer.cornerRadius = 5
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = ymDarkTintColor.cgColor
        logInButton.isEnabled = false
    }
    
    //MARK: - Handle User Interaction
    
    func didPressLogInButton() {
        guard let email = emailTextField.text, email.characters.count > 0 else {return}
        guard let password = passwordTextField.text, password.characters.count > 0 else {return}
        
        resignTextField()
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        isLogingIn = true
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
            userInfo, error in
            
            if let error = error {
                self.isLogingIn = false
                
                let errorDescription = error.localizedDescription
                print("*** Failed to log in user: \(errorDescription)")
                
                //Deal with all error cases
                switch error._code {
                case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                    self.emailErrorLabel.text = ErrorMessage.emailInvalid
                    self.emailErrorLabel.sizeToFit()
                    self.emailErrorLabel.isHidden = false
                    self.emailTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
                case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
                    self.passwordErrorLabel.text = ErrorMessage.passwordWrong
                    self.passwordErrorLabel.sizeToFit()
                    self.passwordErrorLabel.isHidden = false
                    self.passwordTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
                case FIRAuthErrorCode.errorCodeUserNotFound.rawValue:
                    self.emailErrorLabel.text = ErrorMessage.userNotFound
                    self.emailErrorLabel.sizeToFit()
                    self.emailErrorLabel.isHidden = false
                    self.emailTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
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
            
            self.isLogingIn = false
            print("*** Successfully log in user: \(String(describing: userInfo?.uid))")
            
            DispatchQueue.main.async {
                self.delegate?.userSignInViewControllerDidSignIn()
            }
            
        })
        
    }
    
    func textInputDidChange() {
        if let email = emailTextField.text, email.characters.count > 0, let password = passwordTextField.text, password.characters.count > 0 {
            logInButton.isEnabled = true
        } else {
            logInButton.isEnabled = false
        }
        
    }
    
    func jumpToPasswordTextField() {
        passwordTextField.becomeFirstResponder()
    }
    
    func resignTextField() {
        if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        }
    }
    
    func didTapBackButton() {
        resignTextField()
        dismiss(animated: true, completion: nil)
    }
    

}
