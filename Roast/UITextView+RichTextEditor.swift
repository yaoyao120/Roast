//
//  UITextView+RichTextEditor.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-06.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    func fontAtIndex(index: Int) -> UIFont {
        
        let dictionary = self.typingAttributes
        return dictionary[NSFontAttributeName] as! UIFont
    }
    
    func alignmentAtIndex(index: Int) -> NSTextAlignment {
        
        var theIndex = index
        if index == self.attributedText.length && !self.text.isEmpty {
            theIndex = index - 1
        }
        let dictionary = self.text.isEmpty ? self.typingAttributes : self.attributedText.attributes(at: theIndex, effectiveRange: nil)
        if let paragraphStyle = dictionary[NSParagraphStyleAttributeName] as? NSParagraphStyle {
            print("*** alignment \(paragraphStyle.alignment.hashValue)")
            return paragraphStyle.alignment
        }
        print("*** error getting alignment")
        return NSTextAlignment.left
    }
    
    func colorAtIndex(index: Int) -> UIColor {
        let dictionary = self.typingAttributes
        if let color = dictionary[NSForegroundColorAttributeName] as? UIColor {
            return color
        }
        return TextColor.textBlack
    }
    
    func heightOfTextBeforeRange(_ range: NSRange, attributes: [String : Any]) -> CGFloat {
        print("*** selected Range: \(range.location), \(range.length)")
        let allRange = NSRange(location: 0, length: (range.location))
        let attrString = self.attributedText.attributedSubstring(from: allRange)
        let testView = UITextView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        if self.attributedText.length == 0 {
            //If no string, make one
            testView.attributedText = NSAttributedString(string: "TEST", attributes: attributes)
        } else {
            testView.attributedText = attrString
        }
        let rect = testView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        print("text height: \(rect.height)")
        return rect.height
    }
    
    func toNSRangeFromUITextRange(_ range: UITextRange) -> NSRange {
        let beginning = self.beginningOfDocument
        let start = range.start
        let end = range.end
        let location = self.offset(from: beginning, to: start)
        let length = self.offset(from: start, to: end)
        return NSRange(location: location, length: length)
    }
    
}
