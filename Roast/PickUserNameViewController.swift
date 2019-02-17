//
//  PickUserNameViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-16.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import Firebase

protocol PickUserNameViewControllerDelegate: class {
    func pickUserNameViewControllerDidPickUserName()
}

class PickUserNameViewController: UIViewController {
    
    weak var delegate: PickUserNameViewControllerDelegate?

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameErrorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var isSaving = false {
        didSet {
            if isSaving {
                nextButton.isEnabled = false
                nextButton.setTitle("", for: .normal)
                activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                self.nextButton.isEnabled = true
                self.nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPickUserNameView()
        setupUserNameTextField()
        setupNextButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userNameTextField.becomeFirstResponder()
    }
    
    fileprivate func setupPickUserNameView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupUserNameTextField() {
        userNameTextField.addTarget(self, action: #selector(textInputDidChange), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(didPressNextButton), for: .editingDidEndOnExit)
        userNameTextField.textColor = TextColor.textBlack
        
        userNameErrorLabel.textColor = TextColor.textRed
        userNameErrorLabel.isHidden = true
    }
    
    fileprivate func setupNextButton() {
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = ymDarkTintColor.cgColor
        nextButton.isEnabled = false
    }
    
    func textInputDidChange() {
        if let username = userNameTextField.text, username.characters.count > 0 {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
        
    }
    
    func resignTextField() {
        if userNameTextField.isFirstResponder {
            userNameTextField.resignFirstResponder()
        }
        
    }
    
    func didTapBackButton() {
        resignTextField()
        dismiss(animated: true, completion: nil)
    }
    
    func didPressNextButton() {
        guard let name = userNameTextField.text, name.characters.count > 0 else { return }
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        isSaving = true
        resignTextField()
        userNameErrorLabel.isHidden = true
        
        let dictionaryValues: [String : Any] = [FBKeyString.username: name]
        let values = [uid: dictionaryValues]
        
        //Save username into database
        FIRDatabase.database().reference().child(FBKeyString.users).updateChildValues(values, withCompletionBlock: {
            (error, reference) in
            
            if let error = error {
                self.isSaving = false
                print("*** Failed to save user's name into db:", error.localizedDescription)
                return
            }
            print("*** Successfully saved user's name to db")
        })
        isSaving = false
        delegate?.pickUserNameViewControllerDidPickUserName()
    }


}
