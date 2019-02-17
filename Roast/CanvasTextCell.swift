//
//  CanvasTextCell.swift
//  Roast
//
//  Created by Xiang Li on 2017-03-25.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

class CanvasTextCell: UITableViewCell {
    
    var textContent: NSAttributedString?
    
    let textView: RichTextView = {
        let tv = RichTextView()
        tv.isScrollEnabled = false
        return tv
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.attributedText = NSAttributedString()
        textView.tag = -1
        textView.toolBar.tag = -1
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        setupTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupTextView() {
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        self.textView.placeholderLabel = nil
    }

    func configureTextCellWithContent(_ width: CGFloat, textContent: NSAttributedString, tag: Int) {
        
        //Update tag first!
        textView.tag = tag
        
        //Configure textView
        textView.initializeTextView(width, text: textContent)
        
        textView.toolBar.tag = tag //Tag
    }
    
    
}
