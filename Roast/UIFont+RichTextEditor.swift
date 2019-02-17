//
//  UIFont+RichTextEditor.swift
//  Roast
//
//  Created by Xiang Li on 2017-04-02.
//  Copyright © 2017 Xiang Li. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func isBold() -> Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    func isItalic() -> Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
    func setBold() -> UIFont {
        if isBold() {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitBold])
            //Returns a new font descriptor that is the same as the receiver but with the specified symbolic traits taking precedence over the existing ones.
            if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symTraits) {
                return UIFont(descriptor: newFontDescriptor, size: 0)
            } else {
                return self
            }
        }
    }
    
    func removeBold() -> UIFont {
        if !isBold() {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.remove([.traitBold])
            //Returns a new font descriptor that is the same as the receiver but with the specified symbolic traits taking precedence over the existing ones.
            if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symTraits) {
                return UIFont(descriptor: newFontDescriptor, size: 0)
            } else {
                return self
            }
        }
    }
    
    func setItalic() -> UIFont {
        if isItalic() {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitItalic])
            //Returns a new font descriptor that is the same as the receiver but with the specified symbolic traits taking precedence over the existing ones.
            if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symTraits) {
                return UIFont(descriptor: newFontDescriptor, size: 0)
            } else {
                return self
            }
        }
    }
    
    func removeItalic() -> UIFont {
        if !isItalic() {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.remove([.traitItalic])
            //Returns a new font descriptor that is the same as the receiver but with the specified symbolic traits taking precedence over the existing ones.
            if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symTraits) {
                return UIFont(descriptor: newFontDescriptor, size: 0)
            } else {
                return self
            }
        }
    }
    
    func printAllFonts() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
    
    //MARK: - Custom Font List
    /*
     
     Oswald
     == Oswald-Bold
     == Oswald-ExtraLight
     == Oswald-Medium
     == Oswald-Light
     == Oswald-SemiBold
     == Oswald-Regular
     
     Lato
     == Lato-Black
     == Lato-BoldItalic
     == Lato-Bold
     == Lato-BlackItalic
     == Lato-Italic
     == Lato-HairlineItalic
     == Lato-Regular
     == Lato-Hairline
     == Lato-LightItalic
     == Lato-Light
     
     */
}
