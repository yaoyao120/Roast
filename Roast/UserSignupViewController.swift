//
//  UserSignupViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-10.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol UserSignUpViewControllerDelegate: class {
    func userSignUpViewControllerDidSignUp()
}

class UserSignupViewController: UIViewController {
    
    weak var delegate: UserSignUpViewControllerDelegate?
    
    fileprivate let backImage = UIImage(named: "back_btn")
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    fileprivate var isSigningUp = false {
        didSet {
            if isSigningUp {
                signUpButton.isEnabled = false
                signUpButton.setTitle("", for: .normal)
                activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                self.signUpButton.isEnabled = true
                self.signUpButton.setTitle("Sign Up", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserSignupView()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupBackButton()
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
    
    fileprivate func setupUserSignupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupEmailTextField() {
        emailTextField.keyboardType = .emailAddress
        emailTextField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(jumpToPasswordTextField), for: .editingDidEndOnExit)
        emailTextField.textColor = TextColor.textBlack
        
        emailErrorLabel.textColor = TextColor.textRed
        emailErrorLabel.isHidden = true
    }
    
    fileprivate func setupPasswordTextField() {
        passwordTextField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didPressSignUpButton), for: .editingDidEndOnExit)
        passwordTextField.textColor = TextColor.textBlack
        
        passwordErrorLabel.textColor = TextColor.textRed
        passwordErrorLabel.isHidden = true
    }
    
    fileprivate func setupSignUpButton() {
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.addTarget(self, action: #selector(didPressSignUpButton), for: .touchUpInside)
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = ymDarkTintColor.cgColor
        signUpButton.isEnabled = false
    }

    
    
    //MARK: - Handler of User Interactions
    func didPressSignUpButton() {
        
        guard let email = emailTextField.text, email.characters.count > 0 else {return}
        guard let password = passwordTextField.text, password.characters.count > 0 else {return}
        
        resignTextField()
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        isSigningUp = true
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {
            userInfo, error in
            
            if let error = error {
                
                self.isSigningUp = false
                
                print("*** Failed to create user: \(error.localizedDescription)")
                
                //Deal with all error cases
                switch error._code {
                case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                    self.emailErrorLabel.text = ErrorMessage.emailInvalid
                    self.emailErrorLabel.sizeToFit()
                    self.emailErrorLabel.isHidden = false
                    self.emailTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
                case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
                    self.emailErrorLabel.text = ErrorMessage.emailAlreadyInUse
                    self.emailErrorLabel.sizeToFit()
                    self.emailErrorLabel.isHidden = false
                    self.emailTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
                case FIRAuthErrorCode.errorCodeWeakPassword.rawValue:
                    self.passwordErrorLabel.text = ErrorMessage.passwordWeak
                    self.passwordErrorLabel.sizeToFit()
                    self.passwordErrorLabel.isHidden = false
                    self.passwordTextField.shakeWith(force: 1, duration: 0.3, repeatCount: 0, delay: 0)
                case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                    self.showNetWorkErrorAlert()
                default:
                    self.showServiceErrorAlert()
                    break
                }
                return
            }
            
            //Save uid and default username (empty string) to FIR database
            guard let uid = userInfo?.uid else { return }
            let dictionaryValues: [String : Any] = ["name": ""]
            let values = [uid: dictionaryValues]
            FIRDatabase.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, reference) in
                
                if let error = error {
                    print("Failed to save user info into db:", error.localizedDescription)
                    return
                }
                print("*** Successfully saved user info to db")
                
            })
            
            self.isSigningUp = false
            print("*** Successfully create user: \(String(describing: userInfo?.uid))")
            
            //Present pick username controller
            DispatchQueue.main.async {
                let pickUserNameController = PickUserNameViewController(nibName: "PickUserNameViewController", bundle: nil)
                pickUserNameController.delegate = self
                self.present(pickUserNameController, animated: true, completion: nil)
            }
            
        })
    }
    
    func textInputDidChange() {
        if let email = emailTextField.text, email.characters.count > 0, let password = passwordTextField.text, password.characters.count > 0 {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
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

extension UserSignupViewController: PickUserNameViewControllerDelegate {
    func pickUserNameViewControllerDidPickUserName() {
        delegate?.userSignUpViewControllerDidSignUp()
    }
}


