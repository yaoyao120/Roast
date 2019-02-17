//
//  RichTextView.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-01.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import UIKit

protocol RichTextViewDelegate: class {
    func richTextViewDidChangeFont(_ textView: RichTextView, newAttributedString: NSAttributedString)
    
}

class RichTextView: UITextView {
    weak var editorDelegate: RichTextViewDelegate?
    
    let PARA_LINE_SPACING: CGFloat = 8
    let PARA_PARA_SPACING: CGFloat = 17
    
    let TITLE_LINE_SPACING: CGFloat = 0
    let TITLE_PARA_SPACING: CGFloat = 10
    
    var placeholderLabel: UILabel?
    let placeholderAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Oswald-Light", size: 30) ?? UIFont.systemFont(ofSize: 30), NSForegroundColorAttributeName: UIColor.lightGray]
    var titleDefaultAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Oswald-Light", size: 30) ?? UIFont.systemFont(ofSize: 30), NSForegroundColorAttributeName: TextColor.textBlack]
    var paraDefaultAttribute: [String: Any] = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: TextColor.textBlack]
    
    
    var toolBar: TextEditorToolBar!
    
    func initializeTextView(_ width: CGFloat, text: NSAttributedString) {
        
        if text.string.isEmpty {
            if self.tag == 0 {
                let titleStyle = NSMutableParagraphStyle()
                titleStyle.alignment = .left
                titleStyle.lineSpacing = TITLE_LINE_SPACING
                titleStyle.paragraphSpacing = TITLE_PARA_SPACING
                titleDefaultAttribute[NSParagraphStyleAttributeName] = titleStyle
                self.attributedText = NSAttributedString(string: "test", attributes: titleDefaultAttribute)
                self.text = ""
                self.typingAttributes = titleDefaultAttribute
            } else {
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.alignment = .left
                paraStyle.lineSpacing = PARA_LINE_SPACING
                paraStyle.paragraphSpacing = PARA_PARA_SPACING
                paraDefaultAttribute[NSParagraphStyleAttributeName] = paraStyle
                self.attributedText = NSAttributedString(string: "test", attributes: paraDefaultAttribute)
                self.text = ""
                self.typingAttributes = paraDefaultAttribute
            }
        } else {
            self.attributedText = text
        }
        
        //Add placeholder if is header
        if self.tag == 0 {
            //Remove the old placeholder from text view first
            for subView in self.subviews {
                if subView is UILabel {
                    subView.removeFromSuperview()
                }
            }
            
            placeholderLabel = UILabel(frame: CGRect(x: 5, y: 0, width: self.frame.width, height: self.frame.height))
            placeholderLabel?.attributedText = NSAttributedString(string: "Enter title here...", attributes: placeholderAttribute)
            placeholderLabel?.sizeToFit()
            placeholderLabel?.center.y = self.frame.height / 2
            self.addSubview(placeholderLabel!)
            
            if self.text.isEmpty {
                showPlaceHolderLabel()
            } else {
                hidePlaceHolderLabel()
            }
        }
        
        //Add ToolBar
        toolBar = TextEditorToolBar.instance()
        toolBar.frame = CGRect(x: 0, y: 0, width: width, height: 44)
        toolBar.initialize()
        toolBar.textDelegate = self
        self.inputAccessoryView = toolBar
        
        //Listen to Notification
        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: DismissKeyboardNotificationName, object: nil)
    }
    
    //MARK: - Toolbox methods
    func dismissKeyboard() {
        resignFirstResponder()
    }
    
    func showPlaceHolderLabel()
    {
        placeholderLabel?.isHidden = false
    }
    
    func hidePlaceHolderLabel() {
        placeholderLabel?.isHidden = true
    }
    
    fileprivate func applyFontAttributesWithBold(_ shouldSetBold: Bool, toTextAtRange range:NSRange) {
        
        // If any text selected apply attributes to text
        if range.length > 0 {
            let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.beginEditing()
            attributedString.enumerateAttributes(
                in: range,
                options: .longestEffectiveRangeNotRequired,
                using: {dictionary, editRange, stop in
                    let font = dictionary[NSFontAttributeName] as! UIFont
                    let newFont = shouldSetBold ? font.setBold() : font.removeBold()
                    attributedString.addAttribute(NSFontAttributeName, value: newFont, range: editRange)
            })
            attributedString.endEditing()
            self.attributedText = attributedString
            self.selectedRange = range
        } else {
            // If no text is selected apply attributes to typingAttribute
            let font = fontAtIndex(index: range.location)
            let newFont = shouldSetBold ? font.setBold() : font.removeBold()
            self.typingAttributes[NSFontAttributeName] = newFont
        }
    }
    
    fileprivate func applyFontAttributesWithItalic(_ shouldSetItalic: Bool, toTextAtRange range:NSRange) {
        
        // If any text selected apply attributes to text
        if range.length > 0 {
            let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.beginEditing()
            attributedString.enumerateAttributes(
                in: range,
                options: .longestEffectiveRangeNotRequired,
                using: {dictionary, editRange, stop in
                    let font = dictionary[NSFontAttributeName] as! UIFont
                    let newFont = shouldSetItalic ? font.setItalic() : font.removeItalic()
                    attributedString.addAttribute(NSFontAttributeName, value: newFont, range: editRange)
            })
            attributedString.endEditing()
            self.attributedText = attributedString
            self.selectedRange = range
        } else {
            // If no text is selected apply attributes to typingAttribute
            let font = fontAtIndex(index: range.location)
            let newFont = shouldSetItalic ? font.setItalic() : font.removeItalic()
            self.typingAttributes[NSFontAttributeName] = newFont
        }
    }
    
    fileprivate func applyFontAttributesWithColor(_ color: UIColor, toTextAtRange range:NSRange) {
        
        // If any text selected apply attributes to text
        if range.length > 0 {
            let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.beginEditing()
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            attributedString.endEditing()
            self.attributedText = attributedString
            self.selectedRange = range
        } else {
            // If no text is selected apply attributes to typingAttribute
            self.typingAttributes[NSForegroundColorAttributeName] = color
        }
    }
    
    fileprivate func applyFontAttributesWithAlignment(_ alignmentType: NSTextAlignment, toTextAtRange range:NSRange) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        if self.tag == 0 {
            paragraphStyle.lineSpacing = TITLE_LINE_SPACING
            paragraphStyle.paragraphSpacing = TITLE_PARA_SPACING
        } else {
            paragraphStyle.lineSpacing = PARA_LINE_SPACING
            paragraphStyle.paragraphSpacing = PARA_PARA_SPACING
        }
        
        //Get range of paragraphs within the selected range
        let nsString = self.text as NSString
        let rangeOfParagraphs = nsString.paragraphRange(for: self.selectedRange)
        
        // If there is text in textView
        if !self.text.isEmpty {
            
            print("paragraph range location: \(rangeOfParagraphs.location), length: \(rangeOfParagraphs.length)")
            let attributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString
            attributedString.beginEditing()
            paragraphStyle.alignment = alignmentType.nextAlignmentType()
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: rangeOfParagraphs)
            attributedString.endEditing()
            self.attributedText = attributedString
            self.selectedRange = range
        } else {
            // If no text in textView, apply attributes to typingAttribute
            paragraphStyle.alignment = alignmentType.nextAlignmentType()
            self.typingAttributes[NSParagraphStyleAttributeName] = paragraphStyle
        }
        
        // Adjust the placeholder label accordingly
        if self.tag == 0 {
            if let ph = placeholderLabel {
                switch paragraphStyle.alignment {
                case .left:
                    ph.frame.origin.x = 5
                case .center:
                    ph.center.x = self.center.x
                case .right:
                    ph.center.x = self.bounds.width - 5 - ph.bounds.width / 2
                default:
                    ph.frame.origin.x = 5
                }
            }
        }
    }
    
}

extension RichTextView: TextEditorTooBarTextDelegate {
    
    func textEditorToolBarDidSelectUndo() {
        
    }
    
    func textEditorToolBarDidSelectFont() {
    }
    
    func textEditorToolBarDidSelectBold() {
        let range = self.selectedRange
        let font = self.fontAtIndex(index: range.location)
        applyFontAttributesWithBold(!font.isBold(), toTextAtRange: range)
        editorDelegate?.richTextViewDidChangeFont(self, newAttributedString: self.attributedText)
        
    }
    
    func textEditorToolBarDidSelectItalic() {
        let range = self.selectedRange
        let font = self.fontAtIndex(index: range.location)
        applyFontAttributesWithItalic(!font.isItalic(), toTextAtRange: range)
        editorDelegate?.richTextViewDidChangeFont(self, newAttributedString: self.attributedText)
    }
    
    func textEditorToolBarDidSelectAlignment() {
        let range = self.selectedRange
        let alignment = self.alignmentAtIndex(index: range.location)
        applyFontAttributesWithAlignment(alignment, toTextAtRange: range)
        editorDelegate?.richTextViewDidChangeFont(self, newAttributedString: self.attributedText)
    }
    
    func textEditorToolBarDidSelectColor(_ textColor: UIColor) {
        applyFontAttributesWithColor(textColor, toTextAtRange: selectedRange)
        editorDelegate?.richTextViewDidChangeFont(self, newAttributedString: self.attributedText)
    }
    
}
