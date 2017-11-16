//
//  StringExtension.swift
//
//  Created by Tom Swindell on 07/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Registration Validation
extension String {
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[A-Z0-9a-z_]{3,20}"
        let temp = NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
        return temp
    }

    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let temp = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        return temp
    }
    
    func isValidMobileNumber() -> Bool {
        if self.characters.count > 15 || self.characters.count < 10 {
            return false
        }
        let newCharacters = CharacterSet(charactersIn: self)
        return CharacterSet.decimalDigits.isSuperset(of: newCharacters)
    }

    func isValidPincode() -> Bool {
        if self.characters.count <= 6 {
            return false
        }
        let newCharacters = CharacterSet(charactersIn: self)
        return CharacterSet.decimalDigits.isSuperset(of: newCharacters)
    }
}

// MARK: - Character check
extension String {
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find, options: NSString.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(_ newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: CharacterSet.whitespaces)
        }
    }
}

// MARK: - Conversion
extension String {
    var doubleValue: Double? {
        return Double(self)
    }
    
    var floatValue: Float? {
        return Float(self)
    }
    
    var integerValue: Int? {
        return Int(self)
    }
}



// MARK: - Attributed
extension NSAttributedString {
    
    // This will give combined string with respective attributes
    func attributedText(_ texts: [String], attributes: [[String : AnyObject]]) -> NSAttributedString {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        return attbStr
    }
}

//MARK: - Rounded Corner Button
extension UIButton{
    
    func buttonRoundedCorner(cornerRadius1 : CGFloat,borderWidth1 : CGFloat,borderColor1:UIColor){
        
        self.layer.cornerRadius = cornerRadius1
        self.layer.borderWidth = borderWidth1
        self.layer.borderColor = borderColor1.cgColor
    }
}

