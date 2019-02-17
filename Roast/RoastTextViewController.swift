//
//  RoastTextViewController.swift
//  Roast
//
//  Created by Xiang Li on 2017-06-17.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

import Photos

protocol RoastTextViewControllerDelegate: class {
    func roastTextViewControllerDidFinishEditing(newImage: UIImage, roastComment: String)
}

class RoastTextViewController: UIViewController, UITextViewDelegate {
    
    weak var delegate: RoastTextViewControllerDelegate?
    
    fileprivate let titleAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16) , NSForegroundColorAttributeName: TextColor.textBlack]
    
    fileprivate let textAttribute: [String: Any] = {
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let attribute = [NSParagraphStyleAttributeName: textStyle,NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.white]
        return attribute
    }()
    
    fileprivate var bottomContrains: NSLayoutConstraint?
    
    var roastTextView: RoastTextView?
    var scale: CGFloat = 1
    var angle: CGFloat = 0
    
    lazy var textEditorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var inputTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.white
        tv.typingAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: TextColor.textBlack]
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.delegate = self
        return tv
    }()
    
    lazy var doneEditButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.addTarget(self, action: #selector(handleDoneEdit), for: .touchUpInside)
        let title = NSAttributedString(string: "Done", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16)])
        button.setAttributedTitle(title, for: .normal)
        button.tintColor = UIColor.lightGray
        button.isEnabled = false
        return button
    }()
    
    lazy var cancelEditButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.addTarget(self, action: #selector(handleTapBlackView), for: .touchUpInside)
        let title = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: TextColor.textBlack])
        button.setAttributedTitle(title, for: .normal)
        return button
    }()
    
    lazy var blackView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    var image = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupImageView()
        setupTextEditor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardNotification(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardNotification(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupImageView() {
        view.addSubview(imageView)
        let ratio = CustomImageView.ratioOfImageViewWith(image: image, isRatioLimited: true)
        let height = view.frame.width / ratio
        imageView.anchor(top: topLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: height)
        //imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = TextColor.textBlack
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = titleAttribute
        navigationItem.title = "Text"
        
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_close"), style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = closeButton
        
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_check"), style: .plain, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    fileprivate func setupTextEditor() {
        
        view.addSubview(blackView)
        view.addSubview(textEditorView)
        textEditorView.addSubview(inputTextView)
        textEditorView.addSubview(doneEditButton)
        textEditorView.addSubview(cancelEditButton)
        
        //black view
        blackView.addGestureRecognizer(blackViewTapRecognizer)
        blackView.frame = view.frame
        blackView.alpha = 0
        
        //textEditor view
        textEditorView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: 88)
        
        bottomContrains = NSLayoutConstraint(item: textEditorView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomContrains!)
        
        //input textView
        inputTextView.anchor(top: textEditorView.topAnchor, left: textEditorView.leftAnchor, bottom: nil, right: textEditorView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        //buttons
        doneEditButton.anchor(top: inputTextView.bottomAnchor, left: nil, bottom: nil, right: textEditorView.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 50, height: 20)
        cancelEditButton.anchor(top: inputTextView.bottomAnchor, left: textEditorView.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 55, height: 20)
    }
    
    // MARK: - Gestures and User Interactions
    
    lazy var blackViewTapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapBlackView))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    func handleClose() {
        dismiss(animated: false, completion: nil)
    }
    
    func handleDone() {
        
        guard let text = roastTextView?.textView.text else { return }
        
        roastTextView?.textView.layer.borderWidth = 0
        roastTextView?.adjustView.isHidden = true
        roastTextView?.editButton.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        delegate?.roastTextViewControllerDidFinishEditing(newImage: img, roastComment: text)
        dismiss(animated: false, completion: nil)
    }
    
    func handleDoneEdit() {
        if roastTextView != nil {
            if let text = inputTextView.text {
                guard let c = roastTextView?.center else {return}
                
                let roastView = RoastTextView()
                roastView.delegate = self
                let attrText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black])
                
                roastView.initWithText(text: attrText)
                imageView.addSubview(roastView)
                
                roastView.scale = scale
                roastView.angle = angle
                roastView.textView.layer.borderWidth = 1
                roastView.textView.layer.cornerRadius = 3
                roastView.transform = CGAffineTransform.identity
                roastView.textView.transform = CGAffineTransform(scaleX: scale, y: scale)
                roastView.frame.size = roastView.textView.frame.size
                roastView.center = c
                roastView.textView.center = CGPoint(x: roastView.textView.frame.width / 2, y: roastView.textView.frame.height / 2)
                roastView.transform = CGAffineTransform(rotationAngle: angle)
                
                roastTextView?.removeFromSuperview()
                roastTextView = roastView
            }
        } else {
            
            if let text = inputTextView.text {
                
                let roastView = RoastTextView()
                roastView.delegate = self
                let attrText = NSAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black])
                
                roastView.initWithText(text: attrText)
                imageView.addSubview(roastView)
                let testView = UITextView()
                testView.attributedText = attrText
                testView.sizeToFit()
                roastView.frame.size = testView.frame.size
                roastView.textView.center = CGPoint(x: roastView.textView.frame.width / 2, y: roastView.textView.frame.height / 2)
                roastView.textView.layer.borderWidth = 1
                roastView.textView.layer.cornerRadius = 3
                roastView.center = CGPoint(x: imageView.frame.width / 2, y: imageView.frame.height / 2)
                roastTextView = roastView
            }
        }
        
        inputTextView.resignFirstResponder()
    }
    
    func handleTapBlackView() {
        inputTextView.resignFirstResponder()
    }
    
    func handleKeyBoardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let isShowing = notification.name == Notification.Name.UIKeyboardWillShow
            if isShowing {
                if let text = roastTextView?.textView.text {
                    inputTextView.text = text
                    doneEditButton.isEnabled = text.isEmpty ? false : true
                    doneEditButton.tintColor = text.isEmpty ? UIColor.lightGray : TextColor.textBlack
                }
            }
            
            navigationItem.rightBarButtonItem?.isEnabled = !isShowing
            
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                blackView.alpha = isShowing ? 1 : 0
                bottomContrains?.constant = isShowing ? -keyboardFrame.height : 0
                
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
            }
        }
    }
    
    // MARK: - Text View Delegate
    
    func textViewDidChange(_ textView: UITextView) {
//        let testView = UITextView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        testView.attributedText = textView.attributedText
//        let rect = testView.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        let height = rect.height
//        
//        DispatchQueue.main.async {
//            textView.frame.size = CGSize(width: self.view.frame.width, height: height)
//        }
        
        guard let t = textView.text else {return}
        doneEditButton.isEnabled = t.isEmpty ? false : true
        doneEditButton.tintColor = t.isEmpty ? UIColor.lightGray : TextColor.textBlack
        
    }
}

extension RoastTextViewController: RoastTextViewDelegate {
    func roastTextViewShouldStartEditing() {
        inputTextView.becomeFirstResponder()
    }
    
    func roastTextViewDidScaled(scale: CGFloat, angle: CGFloat) {
        self.scale = scale
        self.angle = angle
    }
}
