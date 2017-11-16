//
//  ConstrainedSubclasses.swift
//  manup
//
//  Created by Yudiz Solutions Pvt. Ltd. on 01/03/16.
//  Copyright © 2016 The App Developers. All rights reserved.
//

import UIKit


//MARK: - Constained Classes for All device support
// Bewlow all classed reduces text of button and Label according to device screen size

/**
 TextField with varying font size based on device's screen width.
 */

class WidthTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * universalWidthRatio)
        }
    }
}

/**
 TextView with varying font size based on device's screen width.
 */

class WidthTextView: UITextView {
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 0.5
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * universalWidthRatio)
        }
    }
}

/**
 Button with varying font size based on device's screen width.
 */

class WidthButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * universalWidthRatio)
        }
    }
}
class Style1WidthButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = UIFont(name: FontName.REGULARSTYLE1, size: (afont.pointSize * universalWidthRatio))
            
        }
    }
    
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            titleLabel?.font = titleFont
        }
    }

}
class Style2WidthButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = UIFont(name: FontName.ITALICSTYLE2, size: (afont.pointSize * universalWidthRatio))
        }
    }
}
class DigitalWidthButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = UIFont(name: FontName.DIGITALSTYLE, size: (afont.pointSize * universalWidthRatio))
        }
    }
}

/**
 Button with varying font size based on device's screen height.
 */

class HeightButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * universalWidthRatio)
        }
    }
}

/**
 Label with Custom font(Digital) and  varying font size based on device's screen width .
 */

class DigitalStyleWidthLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: FontName.DIGITALSTYLE, size: (font.pointSize * universalWidthRatio))
    }
}
/**
Label with Custom font(Digital) and  varying font size based on device's screen width .
*/

class Style1WidthLabel: UILabel {
    @IBInspectable var fontWeight: String = "Regular"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: FontName.REGULARSTYLE1, size: (font.pointSize * universalWidthRatio))
    }
}

/**
Label with Custom font(Digital) and  varying font size based on device's screen width .
*/

class Style2WidthLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: FontName.ITALICSTYLE2, size: (font.pointSize * universalWidthRatio))
    }
}

class Style3WidthLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: FontName.SEMIBOLD1, size: (font.pointSize * universalWidthRatio))
    }
}
/**
 Label with Custom font(Digital) and  varying font size based on device's screen width .
 */

class BoldWidthLabel: UILabel {
     override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont(name: FontName.SANSBOLD, size: (font.pointSize * universalWidthRatio))
    }
}
/**
 Label with varying font size based on device's screen width.
 */

class WidthLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * universalWidthRatio)
    }
}

/**
 Label with varying font size based on device's screen height.
 */

class HeightLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * universalWidthRatio)
    }
}


class WidthRoundLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * universalWidthRatio)
        self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio)/2
        self.layer.masksToBounds = true
    }
}

class HeightRoundLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * heighRatio)
        self.layer.cornerRadius = (self.bounds.size.height * heighRatio)/2
        self.layer.masksToBounds = true
    }
}

///Scalling button's icon as per button's size.
class IconButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = ((btnsize.height - (imgsize.height * universalWidthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsetsMake(verPad, 0, verPad, 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * universalWidthRatio)
        }
    }
}


/** This View contains collection of Horizontal and Vertical constrains.
 Who's constant value varies by size of device screen size.
 */
class ConstrainedView: UIView {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    @IBOutlet var universalConstraints: [NSLayoutConstraint]?

    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * heighRatio
                const.constant = v2
            }
        }
        
        if let vConst = universalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * universalWidthRatio
                const.constant = v2
            }
        }

    }
}


/** This Collection view cell contains collection of Horizontal and Vertical constrains.
    That's constant value varies by size of device screen size.
*/

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var button: UIButton!
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var constantRatioConstraint: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    @IBInspectable var roundedCell: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if roundedCell{
            self.layer.cornerRadius = 5.0
            self.layer.masksToBounds = true
        }
       
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * widthRatio
                const.constant = v2
            }
        }
        
        if let hConts = constantRatioConstraint {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * universalWidthRatio
                const.constant = v2
            }
        }

        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * heighRatio
                const.constant = v2
            }
        }
    }
    
    
    
}


/** This Table view cell contains collection of Horizontal and Vertical constrains.
    That's constant value varies by size of device screen size.
*/

class TableViewCell: UITableViewCell {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var button: UIButton?
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsets.zero
        constraintUpdate()
    }
    
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * universalWidthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * heighRatio
                const.constant = v2
            }
        }
    }
}


/** Tableview Header and Footer view
 */

class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * universalWidthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * heighRatio
                const.constant = v2
            }
        }
    }

}

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio) / 2
        self.layer.masksToBounds = true
    }
}

class RoundedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio) / 2
        self.layer.masksToBounds = true
    }
}

class RoundedCollectionView: UICollectionView {
    
    @IBInspectable var cornerRadious: Float = 2.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if cornerRadious == 2.0 {
            self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio) / CGFloat(cornerRadious)
        }
        else{
             self.layer.cornerRadius =  CGFloat(cornerRadious)
        }
       
        self.layer.masksToBounds = true
    }
}


class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio ) / 2
        self.layer.masksToBounds = true
    }
}

class RoundedLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.layer.masksToBounds = true
    }
}

class RoundedLabelWithWidthRatio: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * universalWidthRatio)
        self.layer.cornerRadius = (self.bounds.size.height * universalWidthRatio ) / 2
        self.layer.masksToBounds = true
    }
}


@IBDesignable class BorderButton: WidthButton {
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidht: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidht
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.masksToBounds = true
    }
}

@IBDesignable class RoundCornerView: UIView {
    @IBInspectable var radius: CGFloat = 5.0
    
    var corners: UIRectCorner = .allCorners
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRound(corners: corners, radius: radius)
    }
    
}


extension UIView {
    func setRound(corners: UIRectCorner, radius: CGFloat) {
        let layer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        layer.path = path.cgPath
        self.layer.mask = layer
    }
}
//extension NSLayoutConstraint {
//    
//    override open var description: String {
//        let id = identifier ?? ""
//        return "id: \(id), constant: \(constant)" //you may print whatever you want here
//    }
//}

