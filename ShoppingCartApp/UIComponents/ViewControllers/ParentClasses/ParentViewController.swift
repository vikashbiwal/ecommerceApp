//
//  ParentViewController.swift
//  Tilyn
//
//  Created by Yudiz Solutions Pvt. Ltd. on 28/12/16.
//  Copyright © 2016 Yudiz Solutions Pvt. Ltd. All rights reserved.
//

import UIKit
import KVAlertView
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class ParentViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tableView :UITableView!
    @IBOutlet weak var lblTitle  :Style1WidthLabel!
    @IBOutlet weak var navigationBarView: UIView!
    
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
         
    //MARK: Storyboard References
    let storyboardWishListh = UIStoryboard(name: "MyWishbox", bundle: Bundle(for: ParentViewController.self))
    let storyboardMain = UIStoryboard(name: "Main", bundle: Bundle(for: ParentViewController.self))
    let storyboardCategory = UIStoryboard(name: "Category", bundle: Bundle(for: ParentViewController.self))
    let storyboardProductList = UIStoryboard(name: "ProductList", bundle: Bundle(for: ParentViewController.self))
    let storyboardProductDetail = UIStoryboard(name: "ProductDetail", bundle: Bundle(for: ParentViewController.self))
    let storyboardOffer = UIStoryboard(name: "Offer", bundle: Bundle(for: ParentViewController.self))
    let storyboardShoppingCart = UIStoryboard(name: "ShoppingCart", bundle: Bundle(for: ParentViewController.self))
    let storyboardAccount = UIStoryboard(name: "Account", bundle: Bundle(for: ParentViewController.self))
    let storyboardLogin = UIStoryboard(name: "Login", bundle: Bundle(for: ParentViewController.self))
    let storyboardMyOrders = UIStoryboard(name: "MyOrders", bundle: Bundle(for: ParentViewController.self))
    let storyboardMyReturn = UIStoryboard(name: "MyReturn", bundle: Bundle(for: ParentViewController.self))
    let storyboardcontactUs = UIStoryboard(name: "ContactUs", bundle: Bundle(for: ParentViewController.self))
    let storyboardFeedbackInquiry = UIStoryboard(name: "FeedbackInquiry", bundle: Bundle(for: ParentViewController.self))
    let storyboardSearch = UIStoryboard(name: "Search", bundle: Bundle(for: ParentViewController.self))
	let storyboardOpinionPoll = UIStoryboard(name: "OpinionPoll", bundle: Bundle(for: ParentViewController.self))




    //Added by shraddha
    //instance id and fcm token are used for push notification. that will send with sign-in/login and guest login api.
    var fcmIntanceID = ""
    var fcmToken = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        constraintUpdate()
        self.view.backgroundColor = UIColor.backgroundColor
        self.navigationBarView?.drawShadow()
        
        //set fontcolor and fonttype of navigation title
        if self.lblTitle != nil {
            self.lblTitle.textColor = UIColor.init(red: 105.0/255.0, green: 105.0/255.0, blue: 107.0/255.0, alpha: 1.0)
            self.lblTitle.font = UIFont(name: FontName.REGULARSTYLE1, size: (20 * universalWidthRatio))
            self.lblTitle.textAlignment = .left
        }
        
        self.getFCMTokenAndID() // get FCM Instance id and token id
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //This will update constaints and shrunk it as device screen goes lower.
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
    }

    //MARK: CentralActivityIndicator, CentralGrayActivityIndicator
    lazy internal var centralActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "spinnerIcon_gray")!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var centralGrayActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "spinnerIcon_gray")!
        let v = CustomActivityIndicatorView(image: image)
        v.backgroundColor = UIColor.clear
        return v
    }()

    lazy var emptyDataView: EmptyDataView = {
        let edView = EmptyDataView.loadFromNib()
        return edView
    }()
    

}

//MARK: Parent IBActions
extension ParentViewController {
    
    @IBAction func shutterButtonTapped(sender: UIButton?) {
        shutterActionBlock()
    }
    
    @IBAction func parentBackAction(sender: UIButton?) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func parentDismissAction(sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: Textfield Delegate
extension ParentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

//MARK: Present SearchController Action
extension ParentViewController {
    @IBAction func search_btnClicked(sender: UIButton) {
        self.presentSearchController()
    }
    
    func presentSearchController() {
        if let searchNavVC = self.storyboardSearch.instantiateViewController(withIdentifier: "SBID_SearchNavVC") as? UINavigationController {
            searchNavVC.modalPresentationStyle = .overCurrentContext
            self.present(searchNavVC, animated: false, completion: nil)
            

            if let searchVC = searchNavVC.viewControllers.first as? SearchViewController {
                searchVC.searchResultAction = {[weak self, weak searchNavVC] parameter, type , title in
                    searchNavVC?.dismiss(animated: false, completion: nil)
                   
                    if type == .productDetail {
                        ProductDetailVC.showProductDetail(in: self!, productId: parameter, product: nil,isFromCart: false,identifier: nil, shouldShowTab: false)
                        
                    } else if type == .productList {
                      self?.navigateToProductList(apiParams: parameter , title: title!)
                    }
                }
            }
        }
    }
    
    func navigateToProductList(apiParams: String , title : NSAttributedString) {
        let productvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        productvc.apiParam = apiParams
        productvc.navigationTitle = title.string
        productvc.isFromSearch = true
        self.navigationController?.pushViewController(productvc, animated: true)
    }

}

//MARK:- Activity Indicator view.
extension ParentViewController {
    
    func showCentralSpinner(_ inView: UIView? = nil, uiInteractionEnable: Bool = false) {
        let containerView: UIView
        if let v = inView {
            containerView = v
        } else {
            containerView = self.view
        }
        containerView.addSubview(centralActivityIndicator)
        centralActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let xConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        
        centralActivityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        
        self.view.isUserInteractionEnabled = uiInteractionEnable
        centralActivityIndicator.startAnimating()
       
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralActivityIndicator.alpha = 1.0
        })
    }
    func hideCentralSpinner() {
        self.view.isUserInteractionEnabled = true
        centralActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralActivityIndicator.alpha = 0.0
        })
    }
    
    
    func showCentralGraySpinner() {
        centralGrayActivityIndicator.center = self.view.center
        self.view.addSubview(centralGrayActivityIndicator)
        centralGrayActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        centralGrayActivityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        centralGrayActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralGrayActivityIndicator.alpha = 1.0
        })
    }
    
    func hideCentralGraySpinner() {
        self.view.isUserInteractionEnabled = true
        centralGrayActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralGrayActivityIndicator.alpha = 0.0
        })
    }


}

//Image url based on sizes.
extension ParentViewController {
//    func thumbSizeImageUrl(urlString:String, size: CGSize) -> String {
//        
//        let str = String(format: "%@?w=%d&h=%d",urlString,Int((size.width)*2),Int((size.height)*2))
//        return str
//    }
    
    func fulllSizeImageUrl(urlString:String) -> URL {
        let str = String(format: "%@?h=%f&w=%f",urlString,self.view.bounds.size.height,self.view.bounds.size.width)
        return URL(string: str)!
    }
}

//MARK: - Showing Left Menu
extension ParentViewController{
    @IBAction func btnMenuClicked(sender:UIButton!){
        shutterActionBlock()
    }
}

//MARK: - Func for getting FCM token and Instance ID. : Added By shraddha
extension ParentViewController{
    
    func getFCMTokenAndID() {
        InstanceID.instanceID().getID { (id, error) in
            if let id = id {
                self.fcmIntanceID = id
            }
        }
        
        if let token = InstanceID.instanceID().token() {
            self.fcmToken = token
        }
    }
}

    func thumbSizeImageUrl(urlString:String, size: CGSize) -> String {

        let str = String(format: "%@?w=%d&h=%d",urlString,Int((size.width)*2),Int((size.height)*2))
        return str
    }

