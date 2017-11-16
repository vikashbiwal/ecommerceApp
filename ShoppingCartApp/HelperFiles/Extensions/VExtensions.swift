//
//  VExtensions.swift
//  SawACar
//
//  Created by Vikash Kumar. on 17/06/16.
//  Copyright © 2016 Yudiz Solutions Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

//MARK:============================= Extensions ===================================

//MARK: - String
extension String {
    //func for get localized string from localizable file. 
    func localizedString()-> String {
        return NSLocalizedString(self, comment: "")//
    }
    
    func height(maxWidth: CGFloat, font: UIFont)-> CGFloat {
        let lbl = UILabel()
        lbl.font = font
        lbl.text = self
        lbl.numberOfLines = 0
        lbl.sizeToFit()

        return lbl.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    func width(font: UIFont)-> CGFloat {
        let lbl = UILabel()
        lbl.font = font
        lbl.text = self
        lbl.numberOfLines = 1
         lbl.sizeToFit()
        return lbl.frame.width
    }

    //variable : used to convert string to json object.
    var json: Any? {
        if let data = self.data(using: String.Encoding.utf8) {
            let js = try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .allowFragments, .mutableLeaves])
            return js
        }
        return nil
        
    }
}

//MARK:- HTMLString
protocol HTMLString {
    var _textColor: UIColor {get}
    var _font: UIFont {get}
    func htmlAttributtedString(string: String)->NSAttributedString?
}

extension HTMLString {
    
    func attributedString(fromHTML html: String, fontFamily: String) -> NSAttributedString? {
        let prefix = "<style>* { font-family: \(fontFamily); font-size:\(_font.pointSize); color: black }</style>"
        return (prefix + html).data(using: .utf8).map {
            let attText = try! NSMutableAttributedString(
                data: $0,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                documentAttributes: nil
                
            )
//            attText.addAttribute(NSFontAttributeName, value: self._font, range: NSMakeRange(0, attText.length))
//            attText.addAttribute(NSForegroundColorAttributeName, value: self._textColor, range: NSMakeRange(0, attText.length))
            return attText
        }
    }

    func htmlAttributtedString(string: String)->NSAttributedString? {
        guard let data = string.data(using: .unicode) else {
            return nil
        }
        do {
            

            let attText = try NSMutableAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
           // attText.addAttribute(NSFontAttributeName, value: self._font, range: NSMakeRange(0, attText.length))
            attText.addAttribute(NSForegroundColorAttributeName, value: self._textColor, range: NSMakeRange(0, attText.length))
            return attText
        }
        catch {
            print(error)
            return nil
        }
    }
}


//MARK: - Int
extension Int {
    func ToString() -> String {
        return "\(self)"
    }
    
    public static func random(upper: Int = max) -> Int {
        return Int(arc4random_uniform(UInt32(upper)))
    }

    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }

}

extension Double {
    func ToString() -> String {
        return "\(self)"
    }

	func ToStringWithFractionValue() -> String {
		return String(format: "%.2f", self)
	}
    
    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: self as NSNumber);
        return result!;
    }

}

extension Float {
    func ToString() -> String {
        return "\(self)"
    }
}
//MARK: - UIView
extension UIView {
    //Draw a shadow
    func drawShadow(_ opacity: Float = 0.3, offSet: CGSize = CGSize(width: 3, height: 3)) {
        self.layer.masksToBounds = true;
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = 4.0;
        self.layer.shadowOpacity = opacity
        self.layer.shadowColor  = UIColor.black.cgColor
		self.clipsToBounds = false
    }
    
    func gradient(colors: [UIColor]) {
        let cgColors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        
        let grLayer = CAGradientLayer()
        grLayer.frame = self.bounds
        grLayer.colors = cgColors
        self.layer.insertSublayer(grLayer, at: 0)
        self.backgroundColor = UIColor.clear

    }
    
    func borderWithRoundCorner(radius: CGFloat = 5.0, borderWidth: CGFloat = 1.0, color: UIColor = UIColor.black) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
}

//MARK: - UIImage
extension UIImage {
    //MARK: Compressed image
    var uncompressedPNGData: Data      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:Data   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

extension Array where Element: Equatable {
    mutating func removeElement(_ element: Element) {
        if let ind = self.index(of: element) {
            remove(at: ind)
        }
    }
}

//MARK: - DateFormator
extension DateFormatter {
    func stringFromDate(_ date: Date, format: String) -> String {
        self.dateFormat = format
        return self.string(from: date)
    }
    
    func stringFromDate(_ date: Date, style:DateFormatter.Style) -> String {
        self.dateStyle = style
        return self.string(from: date)
    }
    
    func dateFromString(_ strDate: String, fomat: String) -> Date? {
        self.dateFormat = fomat
        return self.date(from: strDate)
    }
    
    func dateString(_ strDate: String, fromFomat: String, toFromat: String) -> String {
        self.dateFormat = fromFomat
        let date = self.date(from: strDate)
        if let date = date {
         self.dateFormat = toFromat
            return string(from: date)
        }
        return ""
    }
    
    func dateString(_ strDate: String, fromFomat: String, style: DateFormatter.Style) -> String {
        self.dateFormat = fromFomat
        let date = self.date(from: strDate)
        if let date = date {
            self.dateStyle = style
            return string(from: date)
        }
        return ""
    }

}

//MARK: - NSDate
extension Date {
 //
    func dateByAddingYearOffset(_ offset: Int) -> Date? {
        
        let calendar  =     Calendar(identifier: Calendar.Identifier.gregorian)
        var offsetComponent = DateComponents()
        offsetComponent.year = offset
        let date = (calendar as NSCalendar).date(byAdding: offsetComponent, to: self, options: NSCalendar.Options.wrapComponents)
        return date
    }
    
    func dateByAddingDayOffset(_ offset: Int)-> Date? {
        let calendar  =     Calendar.current
        var offsetComponent = DateComponents()
        offsetComponent.day = offset
        let date = (calendar as NSCalendar).date(byAdding: offsetComponent, to: self, options: NSCalendar.Options.matchStrictly)
        return date
    }

	func daysOffset(withDate endDate: Date) -> Int {
        let cal = Calendar.current
        let diff = cal.dateComponents([.hour], from: self, to: endDate)
        print(diff.hour!)
        var hours = 0
        if diff.hour! % 24 == 0{
            hours = diff.hour! / 24
        }
        else {
            hours = diff.hour! / 24
            hours += 1
        }
        return hours
	}

    func dayOffset(withDate endDate: Date)-> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: self) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: endDate) else {
            return 0
        }
        return end - start 

    }

    
}

//MARK: - TableView
extension UITableView {
    func addRefreshControl(_ target: UIViewController, selector: Selector) -> UIRefreshControl {
        let refControl = UIRefreshControl()
        refControl.addTarget(target, action: selector, for: UIControlEvents.valueChanged)
        self.addSubview(refControl)
        return refControl
    }
}

//MARK: - UIViewController
extension UIViewController {
    
    //Push View Controller from specified direction with layer animation.
    //Used value for directions are: kCATransitionFromBottom, kCATransitionFromTop, kCATransitionFromLeft, kCATransitionFromRight
    func push(controller: UIViewController, inDirection direction: String) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = direction
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    //Pop View Controller from specified direction with layer animation.
    //Used value for directions are: kCATransitionFromBottom, kCATransitionFromTop, kCATransitionFromLeft, kCATransitionFromRight
    func pop(inDirection direction: String) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = direction
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = self.navigationController?.popViewController(animated: false)
    }

}

extension UIViewController {
    //Show activity view controller for given items. 
    func showShareView(for items: [Any]) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

	func redirectToPaytm() {
		let url = URL(string: "https://paytm.com/")!
		if UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
}

//MARK: - UILocalizedIndexedCollaction configuration
extension UILocalizedIndexedCollation {
    //Add below commented line in your viewController for accesing func partitionObjects(_:)
    // let indexedCollation = UILocalizedIndexedCollation.currentCollation()

    func partitionObjects(_ array:[AnyObject], collationStringSelector:Selector) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        
        //Create a array to hold the data for each section
        for _ in self.sectionTitles {
            //var array = [AnyObject]()
            unsortedSections.append([])
        }
        
        //put each objects into a section
        for item in array {
            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        //sort each sections
        //sectionTitles  = NSMutableArray()
        for index in 0  ..< unsortedSections.count
        {
            if unsortedSections[index].count > 0 {
                sectionTitles.append(self.sectionTitles[index])
                sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }
        }
        return (sections, sectionTitles)
    }

}

//MARK: - ============================= SubClasses ===================================
//Swift view resize as per device ratio
class VkUISwitch: UISwitch {
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        let constantValue: CGFloat = 0.9 //Default Scale value which changed as per device base.
        let scale = constantValue * widthRatio
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

// This view is used for Maintain height of the view as per device size
class HeightView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        var frame = self.frame
        frame.size.height = frame.size.height * widthRatio
        self.frame = frame
    }
}


class IndexPathButton: WidthButton {
    var indexPath : IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class IndexPathTextField: WidthTextField {
    var indexpath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class CornerRadiusView: ConstrainedView {
    @IBInspectable var cornerRadius : CGFloat = 3.0
    @IBInspectable var topLeft      : Bool = true
    @IBInspectable var topRight     : Bool = true
    @IBInspectable var bottomLeft   : Bool = true
    @IBInspectable var bottomRight  : Bool = true
    @IBInspectable var blurEffect   : Bool = false
    
    var corners : UIRectCorner!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        corners = UIRectCorner()
        if topLeft {
            corners.insert(.topLeft)
        }
        if topRight {
            corners.insert(.topRight)
        }
        if bottomLeft {
            corners.insert(.bottomLeft)
        }
        
        if bottomRight {
            corners.insert(.bottomRight)
        }
        

        if corners.isEmpty {
            
        } else {
            
            if (topLeft && topRight && bottomLeft && bottomRight) {
                self.layer.cornerRadius = cornerRadius * widthRatio
                self.clipsToBounds = true
                
            } else {
                var fr = self.bounds
                fr.size.width = fr.size.width * widthRatio
                fr.size.height = fr.size.height * widthRatio
                
                let path = UIBezierPath(roundedRect:fr, byRoundingCorners:corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
                let maskLayer = CAShapeLayer()
                maskLayer.path = path.cgPath
                self.layer.mask = maskLayer
            }

        }
        
        if blurEffect {
            self.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(blurEffectView)
            self.sendSubview(toBack: blurEffectView)

        }
    }
}


//MARK: - GestureHandlerTableView is used to handle scroll issue, which occur when tableview scroll within other tableview cell.
class GestureHandlerTableView: UITableView, UIGestureRecognizerDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if  gestureRecognizer is UIPanGestureRecognizer {
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let velocity = panGesture.velocity(in: self)
            if velocity.y > 0 {
                if contentOffset.y <= 0 {
                    return true
                }
            } else {
                if Int((contentOffset.y + self.frame.height)) >= Int(self.contentSize.height) {
                    return true
                }
            }
        }
        
        return false
    }
}

//VCollectionView used to keep enable interactive navigation of Navigation controller. 
//Not working proper if the collection view has other scrollview within it with horizontal scrolling .
class VCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.contentOffset.x == 0 {
            return true
        }
        return false
    }
    
}

//Operation for call location related API :
//Added by vikash
class VPOperation: Operation {
    var url : URL!
    var block: ((Any?) -> Void)?
    
    init(strUrl: String, block:@escaping (Any?) -> Void) {
        self.url = URL(string: strUrl)
        self.block = block
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        print("Request URL : \(url.absoluteString)")
        let data = try? Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        if self.isCancelled {
            return
        }
        block?(json)
    }
}

//MARK:- ============================= Important Enums ===================================
//enum UIUserInterfaceIdiom : Int {
//    case unspecified
//    case phone
//    case pad
//}

enum VAction {
    case cancel, done, share
}

//MARK:- ============================= Functions ===================================

//Convert degree to radian angle
func radian(degree: CGFloat)-> CGFloat {
    return CGFloat((Double.pi * Double(degree)) / 180)
}

//Convert radian to degree angle
func degree(radian: CGFloat)-> CGFloat {
    return CGFloat((180 *  Double(radian)) / Double.pi)
}


func getCurrencyCode(forCountryCode code: String)-> String? {
//    let components = [NSLocale.Key.countryCode : code]
//    let localeIdent = Locale.identifier(fromComponents: components as! [String : String])
//    let locale = Locale(localeIdentifier: localeIdent)
//    let currencyCode = locale.object(forKey: NSLocale.Key.currencyCode) as? String
    return nil
}

func getCountryCodeFromCurrentLocale()-> String? {
    let locale = Locale.current
    let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String
    return code
}

//Store Any custom object to UserDefault with a key
func archiveObject(_ obj: Any, key: String) {
    let archive = NSKeyedArchiver.archivedData(withRootObject: obj)
    _userDefault.set(archive, forKey: key)
}

//Get a object from userDefault with key
func unArchiveObjectForKey(_ key: String) -> Any? {
    if let data = _userDefault.object(forKey: key) as? Data {
        let unarchiveObj = NSKeyedUnarchiver.unarchiveObject(with: data)
        return unarchiveObj
    }
    return nil
}

func convertTimeStampToLocalDate(_ timeStampString: String)-> Date? {
    if !timeStampString.isEmpty {
        let index = timeStampString.characters.index(timeStampString.startIndex, offsetBy: 10)
        let timeStamp = TimeInterval(Double(timeStampString.substring(to: index))!)
        let date = Date(timeIntervalSince1970: timeStamp)
        return date
    }
    return nil
}

//Convert timestamp string to date string
func convertTimeStampToLocalDateString(_ timeStampString: String)-> String {
    if !timeStampString.isEmpty {
        let index = timeStampString.characters.index(timeStampString.startIndex, offsetBy: 10)
        let timeStamp = TimeInterval(Double(timeStampString.substring(to: index))!)
        let date = Date(timeIntervalSince1970: timeStamp)
        return dateFormator.stringFromDate(date, format: "dd-MM-yyyy")
    }
    return ""
}

// Comment in release mode
func println(_ items: Any...) {
    for item in items {
        print(item)
    }
}

//func for make a call
func makeACall(number: String, completion:((Bool, String)-> Void)? = nil) {
    if let url = URL(string: "tel://\(number)") {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            completion?(true, "")

        } else {
            completion?(false, "Sim Card Not Installed.")
        }
    } else {
        completion?(false, "Invalid number.")
    }
}

// func for open email

func openEmail(_ emailAddress: String, subject: String, messageBody: String, controller: UIViewController) {
    // If user has not setup any email account in the iOS Mail app
    if !MFMailComposeViewController.canSendMail() {
        print("Mail services are not available")
        let url = URL(string: "mailto:" + emailAddress)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
        
        return
    }
    
    // Use the iOS Mail app
    let composeVC = MFMailComposeViewController()
    composeVC.mailComposeDelegate = controller as? MFMailComposeViewControllerDelegate
    composeVC.setToRecipients([emailAddress])
    composeVC.setSubject("")
    composeVC.setMessageBody("", isHTML: false)
    
    // Present the view controller modally.
    controller.present(composeVC, animated: true, completion: nil)
}



//MARK:- ============================= Struct ===================================
struct MediaUrl {
    var original = ""
    var thumb = ""
}

//LoadMore used for calling paging api.
struct LoadMore {
    var limit = 15
    var offset = 1
    var totalItemCount = 0
    var loadedItemCount = 0
    var isLoading = false
    
    var canLoadMore: Bool {
        return (loadedItemCount < totalItemCount) && !isLoading
    }
    
    mutating func reset() {
        offset = 0
        totalItemCount = 0
        loadedItemCount = 0
    }
}
//Used for defining category thumb and original images.
struct  Media {
	var thumURL:URL?
	var original: URL?
}


//MARK: Keyboard
@objc protocol UIKeyboardObserver {
    func keyboardWillShow(nf: NSNotification)
    func keyboardWillHide(nf: NSNotification)
}

extension UIKeyboardObserver {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(nf:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(nf:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}


//MARK:- ============================= Protocols ===================================

//should import GoogleMaps sdk in your project
//MARK: Google Map Route Path Protocol
//import GoogleMaps
//protocol GoogleMapRoutePath {
//    var mapView: GMSMapView {get set}
//}
//
//extension GoogleMapRoutePath {
//    //Get route beween two location using google map direction api.
//    func getRoutesFromGoogleApi(_ originCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D) {
//        var paths = [GMSPath]()
//        let fromLatLong = "\(originCoordinates.latitude),\(originCoordinates.longitude)"
//        let toLatLong = "\(destinationCoordinates.latitude),\(destinationCoordinates.longitude)"
//        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(fromLatLong)&destination=\(toLatLong)&sensor=false"
//        
//        let operation = VPOperation(strUrl: url) { (response) in
//            if let response = response as? [String : AnyObject] {
//                jprint("Route API Request URL: \(url)\nResponse:\n\(response)")
//                if let routes = response["routes"] as? [[String : AnyObject]] {
//                    if let firstRoute = routes.first {
//                        if let legs = firstRoute["legs"] as? [[String : AnyObject]] {
//                            if let firstLeg = legs.first {
//                                if let steps = firstLeg["steps"] as? [[String : AnyObject]] {
//                                    for step in steps {
//                                        
//                                        if let encodedPolyline = step["polyline"] as? [String : AnyObject] {
//                                            if let encodedPolylinePoints = encodedPolyline["points"] as? String {
//                                                let path = GMSPath(fromEncodedPath: encodedPolylinePoints)!
//                                                paths.append(path)
//                                                print(encodedPolylinePoints)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                print(paths)
//                DispatchQueue.main.async(execute: {
//                    self.drawRouteOnGoogleMap(paths, zoomLocation: originCoordinates)
//                })
//            }
//        }
//        let operationQueue = OperationQueue()
//        operationQueue.addOperation(operation)
//    }
//    
//    //Draw route path on map
//    func drawRouteOnGoogleMap(_ paths: [GMSPath], zoomLocation: CLLocationCoordinate2D) {
//        let startPositionCoordinates = zoomLocation
//        let cameraPositionCoordinates = startPositionCoordinates
//        let cameraPosition = GMSCameraPosition.camera(withTarget: cameraPositionCoordinates, zoom: 8)
//        mapView.animate(to: cameraPosition)
//        
//        
//        for path in paths {
//            let rectangle = GMSPolyline(path: path)
//            rectangle.strokeWidth = 3.0
//            rectangle.strokeColor = UIColor.scHeaderColor()
//            rectangle.map = mapView
//        }
//    }
//    
//}


