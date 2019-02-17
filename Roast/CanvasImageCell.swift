//
//  CanvasImageCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-23.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit
import QuartzCore

protocol CanvasImageCellDelegate: class {
    func canvasImageCellDidTapDeleteButtonIn(_ imageView: UIImageView)
    func canvasImageCellDidTapImageView(_ imageView: UIImageView)
}

class CanvasImageCell: UITableViewCell {
    
    weak var delegate: CanvasImageCellDelegate?
    
    fileprivate var deleteImage = UIImage(named: "delete_btn")

    let singleImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var shouldShowButton = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        singleImageView.image = nil
        singleImageView.tag = -1
        singleImageView.gestureRecognizers = nil
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupImageView () {
        // Configure image views
        addSubview(singleImageView)
        singleImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 15, paddingBottom: 10, paddingRight: 15, width: 0, height: 0)
        
        //Add tap recognizer
        self.singleImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.singleImageView.addGestureRecognizer(tapGestureRecognizer)
        
        //Configure buttons
        singleImageView.addSubview(deleteButton)
        deleteButton.anchor(top: singleImageView.topAnchor, left: nil, bottom: nil, right: singleImageView.rightAnchor, paddingTop: 17, paddingLeft: 0, paddingBottom: 0, paddingRight: 17, width: 45, height: 45)
        deleteButton.setImage(deleteImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        deleteButton.tintColor = ymBackgroundColor
        deleteButton.layer.cornerRadius = 45 / 2
        deleteButton.layer.borderColor = ymBackgroundColor.cgColor
        deleteButton.layer.borderWidth = 0.65
        deleteButton.backgroundColor = ymDarkTintColor.withAlphaComponent(0.65)
        deleteButton.layer.isHidden = true
        deleteButton.isUserInteractionEnabled = false
    }
    
    func configureCellWithImageData(_ imageData: Data, tag: Int) {
        //Update tag first!
        singleImageView.tag = tag //Tag

        if let image = UIImage(data: imageData) {
            self.singleImageView.image = image
        }
        
    }
    
    // MARK: User Interaction Method
    func deleteImage(_ sender: UIButton) {
        delegate?.canvasImageCellDidTapDeleteButtonIn(singleImageView)
    }
    
    func didTapImageView() {
        NotificationCenter.default.post(name: DismissKeyboardNotificationName, object: nil)
        shouldShowButton = !shouldShowButton
        if shouldShowButton {
            delegate?.canvasImageCellDidTapImageView(singleImageView)
            showButtons()
        } else {
            hideButtons()
        }
    }
    
    fileprivate func showButtons() {
        deleteButton.layer.removeAllAnimations()
        
        let buttonScaler = CAKeyframeAnimation(keyPath: "transform.scale")
        buttonScaler.values = [0, 1.2, 1]
        buttonScaler.keyTimes = [0, 0.85, 1]
        buttonScaler.duration = 0.2
        buttonScaler.isRemovedOnCompletion = true
        deleteButton.layer.add(buttonScaler, forKey: "show")
        deleteButton.isUserInteractionEnabled = true
        deleteButton.layer.isHidden = false
    }
    
    fileprivate func hideButtons() {
        let buttonHider = CABasicAnimation(keyPath: "transform.scale")
        buttonHider.fromValue = 1
        buttonHider.toValue = 0
        buttonHider.duration = 0.2
        buttonHider.isRemovedOnCompletion = false
        buttonHider.fillMode = kCAFillModeForwards
        buttonHider.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        deleteButton.layer.add(buttonHider, forKey: "hide")
        deleteButton.isUserInteractionEnabled = false
    }
    
    
}
