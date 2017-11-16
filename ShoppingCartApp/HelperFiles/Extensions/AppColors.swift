//
//  AppColors.swift
//  BookMyHotel
//
//  Created by Vikash Kumar on 14/02/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class var commonTopBarColor : UIColor {
        return UIColor(colorLiteralRed: 6.0/255.0, green: 147.0/255.0, blue: 219.0/255.0, alpha: 1)
    }
    
    class func random()-> UIColor {
        let colors = [UIColor.red, .magenta, UIColor(red: 245.0/255.0, green: 145.0/255.0, blue: 48.0/255.0, alpha: 1 ),
                      UIColor(red: 3.0/255.0, green: 165.0/255.0, blue: 155.0/255.0, alpha: 1),
                      UIColor(red: 38.0/255.0, green: 167.0/255.0, blue: 224.0/255.0, alpha: 1),
                      UIColor(red: 214.0/255.0, green: 15.0/255.0, blue: 91.0/255.0, alpha: 1),
                      UIColor(red: 3.0/255.0, green: 165.0/255.0, blue: 155.0/255.0, alpha: 1)]
        let rnIndex = Int.random(upper: colors.count)
        return colors[rnIndex]
    }
    
    class func patternImageColor(_ image: UIImage)-> UIColor {
        return UIColor(patternImage: image)
    }

}

extension UIColor {
    func alpha(_ value: CGFloat) -> UIColor {
        return self.withAlphaComponent(value)
    }
    
    func cgColorWithAlpha(_ value: CGFloat) -> CGColor {
        return self.alpha(value).cgColor
    }
    
    
}

extension UIColor {
   static var backgroundColor : UIColor {return UIColor(colorLiteralRed: 230.0/255.0, green: 228.0/255.0, blue: 231.0/255.0, alpha: 1)}
	
}

// show color from hex value
extension UIColor {
    
    convenience init(hexString: String) {
        // Trim leading '#' if needed
        var cleanedHexString = hexString
        if hexString.hasPrefix("#") {
            //            cleanedHexString = dropFirst(hexString) // Swift 1.2
            cleanedHexString = String(hexString.characters.dropFirst()) // Swift 2
        }
        
        // String -> UInt32
        var rgbValue: UInt32 = 0
        Scanner(string: cleanedHexString).scanHexInt32(&rgbValue)
        
        // UInt32 -> R,G,B
        let red = CGFloat((rgbValue >> 16) & 0xff) / 255.0
        let green = CGFloat((rgbValue >> 08) & 0xff) / 255.0
        let blue = CGFloat((rgbValue >> 00) & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var hexString: String {
        if let components = self.cgColor.components {
            var red:Float = 1
            var green: Float = 1
            var blue: Float = 1
            
            if components.count > 0 {
                 red = Float(components[0])
            }
            if components.count > 1 {
                 green = Float(components[1])
            }
            if components.count > 2 {
                 blue = Float(components[2])
            }
            return String(format: "#%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        }
        return ""
    }

    
}


extension UIColor {
}
