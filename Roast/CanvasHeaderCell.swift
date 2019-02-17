//
//  CanvasHeaderCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-24.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol CanvasHeaderCellDelegate: class {
    func canvasHeaderCellDidTapDeleteButtonIn(_ imageView: UIImageView)
    func canvasHeaderCellDidTapImageView(_ imageView: UIImageView)
}

class CanvasHeaderCell: UITableViewCell {
    
    weak var delegate: CanvasHeaderCellDelegate!
    
    @IBOutlet weak var coverImageView: CustomImageView!
    @IBOutlet weak var titleTextView: RichTextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        coverImageView.image = nil
        titleTextView.attributedText = NSAttributedString()
        titleTextView.placeholderLabel = nil
        coverImageView.tag = -1
        titleTextView.tag = -1
        titleTextView.toolBar.tag = -1
    }
    
    override func awakeFromNib() {
        
        self.selectionStyle = .none
        self.titleTextView.placeholderLabel = nil
    }
    
    func configureHeaderCellWith(_ width: CGFloat, imageData: Data, text: NSAttributedString, tag: Int) {
        
        //Update tag first!
        coverImageView.tag = tag //Tag
        titleTextView.tag = tag //Tag
        
        // Configure image view
        coverImageView.contentMode = .scaleAspectFit
        coverImageView.clipsToBounds = true
        coverImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        coverImageView.addGestureRecognizer(tapGestureRecognizer)
        
        
        if let image = UIImage(data: imageData) {
            self.coverImageView.image = image
        }
        
        
        
        // Configure text view and toolbar
        titleTextView.initializeTextView(width, text: text)
        titleTextView.toolBar.tag = tag //Tag
        
    }
    
    //Handle user interaction methods
    func didTapImageView() {
        NotificationCenter.default.post(name: DismissKeyboardNotificationName, object: nil)
        delegate.canvasHeaderCellDidTapImageView(coverImageView)
    }
    
}
