//
//  Constants.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 08/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import UIKit


//MARK: -
let _twitterUrl             = "https://api.twitter.com/1.1/account/verify_credentials.json"
let _twitterFriendsUrl      = "https://api.twitter.com/1.1/friends/list.json"
let _fbMeUrl                = "https://graph.facebook.com/me"
let _googleUrl              = "https://maps.googleapis.com/maps/api/place"
let _appStoreUrl            = "https://itunes.apple.com/us/app/retail-store/id1288509822?ls=1&mt=8"
let _appStore_bitlyLink     = "http://apple.co/2wT6iGf"
let _fbLoginReadPermissions = ["public_profile","email"]
let _fbUserInfoRequestParam = "email, first_name,  last_name, name, id, gender, picture.type(large)"

let _defaultCenter          = NotificationCenter.default
let _userDefault            = UserDefaults.standard
let _appDelegator           = UIApplication.shared.delegate! as! AppDelegate
let _application            = UIApplication.shared

let  systemVersion          = UIDevice.current.systemVersion
let  screenSize             = UIScreen.main.bounds.size
let  heighRatio             = screenSize.height/667
let  widthRatio             = screenSize.width/375
let  COUNTPERPAGE = 10

let PDCOLOR = UIColor(red: 71/255, green: 72/255, blue: 76/255, alpha: 1.0)

//Used for showing ActivityIndicator icon.
let spinnerIcon = "spinnerIcon_gray"
var loginFromTabbar = true
var loyaltyBalance = ""
var walletBalance = "0"

struct AppPreference {
	private init() {}
	static let authToken  = "AppPreference_authToken"
	static let userInfo = "AppPreference_userInfo"
    static let userObj = "AppPreference_UserObj"
    
}
struct HomeArrayOrder {
	private init() {}
	static let categoryOrder  = "HomeArrayOrder_categoryOrder"
	static let subCategoryOrder = "HomeArrayOrder_subCategoryOrder"
	static let hotDeals = "HomeArrayOrder_hotDeals"

}


var shutterActionBlock: (Void)-> Void = {_ in}

//return width ratio as per iphone screen size and 1.5 for ipad device
var  universalWidthRatio: CGFloat {get{return UI_USER_INTERFACE_IDIOM() == .pad ? 1.2 : widthRatio}}
var dictUser = User()


//Custom Font
enum FontName {
    static var REGULARSTYLE1:String {return "OpenSans"}
    static var SEMIBOLD1:String {return "OpenSans-Semibold"}
    static var ITALICSTYLE2: String {return "DroidSerif-Italic"}
    static var SANSBOLD:String {return "OpenSans-Bold"}
    static var DIGITALSTYLE: String {return "Digital-7"}
}

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

//Local Date formatter
let dateFormator: DateFormatter = {
    let df = DateFormatter()
    //df.locale = Locale(identifier: "zh_Hans")
    df.dateFormat = "dd-MMM-yyyy"
    return df
}()

//Server Date formatter
let serverDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
var serverDateFormator: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = serverDateFormat
    df.timeZone = TimeZone(identifier: "IST")
    return df
}()

//MARK:- This function is for setting BADGE according to item is added in to the cart -
func setCartBadge() -> Int {
    
        var quantity = 0
        if CartProducts.sharedInstance.products.count > 0 {
            
            quantity = CartProducts.sharedInstance.products.count
        }
        return quantity

}
func getImageUrlWithSize(urlString:String, size: CGSize) -> URL {
	let height = Int(size.height * 2)
	let width = Int(size.width * 2)
	let str = String(format: "%@?h=\(height)&w=\(width)",urlString.replacingOccurrences(of: " ", with: ""))
	return URL(string: str)!
}


func checkUserLoggedIn() -> Bool{
    return dictUser.custId == "" ? false : true
}

func getDynamicHeightBasedOnRatio(size:CGSize) -> CGFloat {
	return (screenSize.width * size.height) / size.width
	//return dynamicHeight
}
func downloadImage(url: URL, block: @escaping (CGFloat)->Void) {

	DispatchQueue.global().async {
		if let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
		{
			DispatchQueue.main.async {
				if let image = UIImage(data: data) {
					let height = getDynamicHeightBasedOnRatio(size: image.size)
					block(height)
				} else {
					block(100.0)
				}
			}
		} else {
			block(100.0)
		}

	}
}
//MARK: - NO result found image
func showNoResultFoundImage(onView: UIView, withText: String , noDataImg: UIImage = #imageLiteral(resourceName: "nodatafound")){
    let theImageView = UIImageView()
    theImageView.image = noDataImg //#imageLiteral(resourceName: "nodatafound")
    theImageView.tag = 464646
    theImageView.translatesAutoresizingMaskIntoConstraints = false //You need to call this property so the image is added to your view
    onView.addSubview(theImageView)
    
    
    let theLabel = UILabel(frame: CGRect(x:theImageView.frame.origin.x, y:theImageView.frame.origin.y + theImageView.frame.size.height, width:225, height: 50))
    theLabel.textColor = .black
    theLabel.translatesAutoresizingMaskIntoConstraints = false
    
    theLabel.font = UIFont(name: FontName.REGULARSTYLE1, size: 15 * universalWidthRatio)!
   
    
    theLabel.textAlignment = .center
    theLabel.tag = 474747
    theLabel.text = withText
    onView.addSubview(theLabel)
    
    if #available(iOS 9.0, *) {
        theImageView.widthAnchor.constraint(equalToConstant: 225).isActive = true
        theImageView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        theImageView.centerXAnchor.constraint(equalTo: onView.centerXAnchor).isActive = true
        theImageView.centerYAnchor.constraint(equalTo: onView.centerYAnchor, constant: -30).isActive = true
        
        theLabel.widthAnchor.constraint(equalToConstant: 275).isActive = true
        theLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        theLabel.centerXAnchor.constraint(equalTo: onView.centerXAnchor).isActive = true
        theLabel.centerYAnchor.constraint(equalTo: onView.centerYAnchor, constant:95).isActive = true
        
    } else {
        // Fallback on earlier versions
    }
    
    
    
}


func removeNoResultFoundImage(fromView:UIView) {
    let noresultImgView : UIImageView = ((fromView.viewWithTag(464646)) != nil) ? fromView.viewWithTag(464646) as! UIImageView : UIImageView()
    
    let noresultLabel : UILabel = ((fromView.viewWithTag(474747)) != nil) ? fromView.viewWithTag(474747) as! UILabel : UILabel()
    
    noresultImgView.removeFromSuperview()
    noresultLabel.removeFromSuperview()
    
}

//MARK:- show price label as attributed text -
func showAttributedPriceString(product:Product , font: UIFont) -> NSAttributedString
{
    
    
    let attributedString = NSMutableAttributedString()
    
    var displayPrice = ""
    
    let fontAttributes = [NSForegroundColorAttributeName: UIColor.black, NSBackgroundColorAttributeName: UIColor.clear, NSFontAttributeName:UIFont(name: font.fontName,size: font.pointSize)!]
    
    if product.displayPrice == product.maxPrice || product.maxPrice == 0{
        //current flow and open shopping cart screen
        
        //define attributes
        let smallfontAttributes = [NSForegroundColorAttributeName: UIColor.black, NSBackgroundColorAttributeName: UIColor.clear, NSFontAttributeName:UIFont(name: font.fontName,size: font.pointSize - 2)!]
        
        let baselineAttributes = [NSBaselineOffsetAttributeName:0 ]
        let strikeAttributes = [NSStrikethroughStyleAttributeName:1 ]  //
        
        
        let colorAttributes = [NSForegroundColorAttributeName: UIColor(red: 102.0/255.0, green: 195.0/255.0, blue: 121.0/255.0, alpha: 1)]
        
        
        //discounted price with its attribute
        
        var displayPrice = String(format: "%@ %@",RsSymbol,Converter.toString(Converter.toInt(product.displayPrice.rounded())))
        let displayPriceattributedString = NSMutableAttributedString(string: displayPrice as String)
        displayPriceattributedString.addAttributes(fontAttributes, range:NSRange(location:0,length:displayPrice.characters.count))
        
        // original price with its attribute
        var originalPrice = String(format: "   %@ %@",RsSymbol,Converter.toString(Converter.toInt(product.productPrice.rounded())))
        let originalPriceattributedString = NSMutableAttributedString(string: originalPrice as String)
        
        let totalcout = originalPrice.characters.count
        
        
        originalPriceattributedString.addAttributes(smallfontAttributes, range:NSRange(location:3,length:Int(totalcout - 3)))
        originalPriceattributedString.addAttributes(baselineAttributes, range: NSRange(location:3,length:Int(totalcout - 3) ))
        originalPriceattributedString.addAttributes(strikeAttributes, range: NSRange(location:3,length:Int(totalcout - 3) ))
        
        // discount label  ex. 50% OFF with its attribute
        var offPrice = String(format: "  %@%@ OFF",Converter.toString(product.discountPerc),"%")
        let offPriceattributedString = NSMutableAttributedString(string: offPrice as String)
        
        offPriceattributedString.addAttributes(smallfontAttributes, range:NSRange(location:0,length:offPrice.characters.count))
        offPriceattributedString.addAttributes(colorAttributes, range: NSRange(location:0 ,length:offPrice.characters.count))
        
        //concate all three in one attributed string
        attributedString.append(displayPriceattributedString)
        
        if product.displayPrice != product.productPrice && product.productPrice != 0{
            attributedString.append(originalPriceattributedString)
            
            if product.isNewArrival == true{
                attributedString.append(offPriceattributedString)
            }
        }
    }
        
    else if product.maxPrice == -1 {  //show + price like 99 +
        displayPrice = String(format: "%@%@ +",RsSymbol,Converter.toString(product.displayPrice))
        let displayPriceattributedString = NSMutableAttributedString(string: displayPrice as String)
        displayPriceattributedString.addAttributes(fontAttributes, range:NSRange(location:0,length:displayPrice.characters.count))
        attributedString.append(displayPriceattributedString)
    }
    else{  //max price is greater than display price  show range in price like 300 - 500
        displayPrice = String(format: "%@%@ - %@",RsSymbol,Converter.toString(product.displayPrice),Converter.toString(product.maxPrice))
        let displayPriceattributedString = NSMutableAttributedString(string: displayPrice as String)
        displayPriceattributedString.addAttributes(fontAttributes, range:NSRange(location:0,length:displayPrice.characters.count))
        attributedString.append(displayPriceattributedString)
    }
    
    
    
    return attributedString
}
//MARK :- color code is hex value or URL
func setColorOrImageOnButton(colorCode : String, button : UIButton) {
 /*   let hexstring = colorCode
    if hexstring.characters.first == "#"{
        if hexstring == "#ffffff" {
            button.borderWithRoundCorner(radius: 0.0, borderWidth: 1, color: .black)
            button.frame = CGRect(x:Int(itemX), y: Int(itemY), width: Int(itemWidth), height:Int(itemHeight))
        }
    } //hex color
    else{
        let urlString = hexstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let sizeUrl = String(format: "%@?w=%d&h=%d",urlString,Int((button.frame.size.width)*2),Int((button.frame.size.height)*2))
        
        button.setImage(url: URL(string: sizeUrl)!, placeholder: UIImage(), completion: { (img) in
            button.setImage(img, for: .normal)
        })*/
}

//MARK: - Get Loyalty Balance & Wallet Balance
func getCustomerBalance(block : @escaping(Bool) -> Void){
    wsCall.getCustomerBalance(params: nil) { (response) in
        if response.isSuccess {
            if let json = response.json as? [String:Any] {
                
                print("customer balance response is => \(json)")
                
//                _ = json.map({ (object) -> CustomerBalance in
//                    
//                    return CustomerBalance(json: object)
//                })
                walletBalance = Converter.toString(json["walletBalance"])
               
                loyaltyBalance = Converter.toString(json["loyaltyBalance"])
                 block(true)
            }
           
        } else {
            block(false)
        }
    }
}
//MARK: -  ADD TO CART ANIMATION
/*
 onimage - imageview which should be animated
 rect - start frame for animation
 endPoint - end point for animation
 onview - view on which animated view is added
 block - its completion block
 */
func addToCartAnimation(onimage:UIImageView, rect:CGRect,endPoint:CGPoint ,onView:UIView , block:  ()->Void)  {
    // create new duplicate image
    let starView = UIImageView(image: onimage.image)
    starView.frame = rect
    starView.tag = 9595
    starView.layer.cornerRadius = 5
    starView.layer.borderColor = UIColor.black.cgColor
    starView.layer.borderWidth = 1
    onView.addSubview(starView)
    
    
    // begin ---- apply position animation
    let pathAnimation = CAKeyframeAnimation(keyPath: "position")
    pathAnimation.calculationMode = kCAAnimationPaced
    pathAnimation.fillMode = kCAFillModeForwards
    pathAnimation.isRemovedOnCompletion = false
    pathAnimation.duration = 0.65
   // pathAnimation.delegate = self as CAAnimationDelegate
    
    
    let curvedPath: CGMutablePath = CGMutablePath()
    curvedPath.move(to: CGPoint(x: starView.frame.origin.x, y: starView.frame.origin.y), transform: .identity)
    curvedPath.addCurve(to: CGPoint(x: endPoint.x, y: endPoint.y), control1: CGPoint(x: endPoint.x, y: starView.frame.origin.y), control2: CGPoint(x: endPoint.x, y: starView.frame.origin.y), transform: .identity)
    pathAnimation.path = curvedPath
    
    // apply transform animation
    let basic = CABasicAnimation(keyPath: "transform")
    basic.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.1, 0.1, 0.1))
    basic.autoreverses = false
    basic.isRemovedOnCompletion = false
    basic.fillMode = kCAFillModeForwards
    basic.duration = 0.65
    starView.layer.add(pathAnimation, forKey: "curveAnimation")
    starView.layer.add(basic, forKey: "transform")
    // perform(#selector(removeanimationview), with: nil, afterDelay: 0.65)
    block()
    
}

//MARK: -  pop back n th viewcontroller
extension UIViewController {

    func popBack(_ nb: Int) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
}

