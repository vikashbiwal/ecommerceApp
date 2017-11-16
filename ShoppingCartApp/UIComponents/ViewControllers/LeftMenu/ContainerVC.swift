//
//  ContainerVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 06/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import StoreKit

extension ContainerVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class ContainerVC: ParentViewController {

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblLoyaltyPoint: Style1WidthLabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var tblLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var btnLoyaltyPoints: Style1WidthButton!
    @IBOutlet weak var viewGesture: UIView!
    @IBOutlet weak var viewMenuTable: UIView!
    var arrLeftMenu : [String] = []
    var isTableDragged = false
    var isThirdLevelOpen = false
    var isUserLogin : Bool = false
    var leadingTableView = -270.0
    weak var tabBarVC: TabBarVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.getCategoryList()
        println(_appDelegator.arrCategory.count)
        setArrLeftMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(RefreshTheTable(notification:)), name: NSNotification.Name(rawValue: "refreshTable"), object: nil)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.menuDragged(_:)))
        panGesture.delegate = self
        viewGesture.addGestureRecognizer(panGesture)
        tableView.drawShadow(0.8)
        setShutterActionBlock()
        self.tableView.tableFooterView = UIView.init(frame:CGRect.zero );
        // Tap Gesture on Imageview for User Icon
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageUserProfileTapped(tapGestureRecognizer:)))
        imgUserProfile.isUserInteractionEnabled = true
        imgUserProfile.addGestureRecognizer(tapGestureRecognizer)
        findAndSetTabbarControllerReference()
        
        
    }
    
    func setArrLeftMenu(){
        if checkUserLoggedIn(){
            lblUserName.text = dictUser.name
            btnLoyaltyPoints.setTitle(loyaltyBalance + " Points", for: .normal)
            arrLeftMenu = ["My Orders","My Returns","My Wallet","Gift Coupons", "Just For You","Consumer Insights","Contact Us","Rate Us","Share App","Privacy Policy","Store 360","Logout"]
            
            let imgUrl2 = getImageUrlWithSize(urlString: (dictUser.image), size:  self.imgUserProfile.frame.size)
            self.imgUserProfile.setImage(url: imgUrl2, placeholder: #imageLiteral(resourceName: "ic_noProfile"), completion:nil)
            if IS_IPAD{
                leadingTableView = -550
                viewAccount.frame = CGRect(x: viewAccount.frame.origin.x, y: viewAccount.frame.origin.y, width: viewAccount.frame.size.width, height: 250)
            } else {
                leadingTableView = -270
                viewAccount.frame = CGRect(x: viewAccount.frame.origin.x, y: viewAccount.frame.origin.y, width: viewAccount.frame.size.width, height: 168)
            }
        } else {
            arrLeftMenu = ["Consumer Insights","Contact Us","Rate Us","Privacy Policy","Share App", "Store 360"]
            lblUserName.text = ""
            btnLoyaltyPoints.setTitle("", for: .normal)
            self.imgUserProfile.image = #imageLiteral(resourceName: "ic_noProfile")
            if IS_IPAD{
                leadingTableView = -550
                viewAccount.frame = CGRect(x: viewAccount.frame.origin.x, y: viewAccount.frame.origin.y, width: viewAccount.frame.size.width, height: 178)
            } else {
                leadingTableView = -270
                viewAccount.frame = CGRect(x: viewAccount.frame.origin.x, y: viewAccount.frame.origin.y, width: viewAccount.frame.size.width, height: 116)
            }
        }
    }
    
    func RefreshTheTable(notification: NSNotification){
        //do stuff
        setArrLeftMenu()
        tableView.reloadData()
    }
    
//MARK: - Get the TabbarVC's Reference
    func findAndSetTabbarControllerReference() {
        for vc in self.childViewControllers {
            if vc is TabBarVC {
                self.tabBarVC = vc as! TabBarVC
                _appDelegator.tabBarVC = self.tabBarVC
            }
        }
    }
    
    
//MARK: - Get the Menu Action From ParentVC
    func setShutterActionBlock() {
        shutterActionBlock = { [unowned self] in
            self.shutterAction()
        }
    }

    @IBAction func btnLoyaltyClicked(_ sender: Style1WidthButton) {
        let lvc = storyboardLogin.instantiateViewController(withIdentifier: "LoyaltyVC") as! LoyaltyVC
        self.navigationController?.pushViewController(lvc, animated: true)
        shutterAction()
    }
    
    func imageUserProfileTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        shutterAction()
        self.tabBarVC.selectedIndex = 4;   // to actually switch to the controller (your code would work as well) - not sure if this does or not send the didSelectViewController: message to the delegate
        self.tabBarVC.delegate?.tabBarController!(self.tabBarVC, didSelect: (self.tabBarVC.viewControllers?[4])!)
       // [self.tabBarVC.delegate tabBarController:self.tabBarVC didSelectViewController:[self.tabController.viewControllers objectAtIndex:4]];
        //self.tabBarVC.selectedIndex = 4
        //self.tabBarVC.OpenLoginOrAccount(navigation: self.tabBarVC.navigationController!)
        
    }
    
    @IBAction func goHome(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        if let tab = self.tabBarController {
            tab.selectedIndex = 0  // Or whichever number you like
        }
    }
    
}

//MARK: - TableView Delegate and action related it
extension ContainerVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrLeftMenu.count + _appDelegator.arrCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if _appDelegator.arrCategory.count > section{
            return _appDelegator.arrCategory[section].childCategories.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childCategory") as! ChildCell
        cell.lblTitle.text = _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].name
        cell.contentView.backgroundColor = UIColor(colorLiteralRed: 226.0/255.0, green: 227.0/255.0, blue: 228.0/255.0, alpha: 1.0)
       
        
        // Decide Leading Space according to 2nd or 3rd Level Category
        if _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].parentCategoryId == _appDelegator.arrCategory[indexPath.section].id{
            cell.leadingLabelConstraints.constant = 25
        } else {
            cell.leadingLabelConstraints.constant = 40
        }
        
        //Showing Down Arrow or Right Arrow  or not
        if _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].childCategories.count > 0{
            cell.imgView.isHidden = false
            if _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].isOpen{
                cell.imgView.image = #imageLiteral(resourceName: "ic_downArrow")
            }else{
                cell.imgView.image = #imageLiteral(resourceName: "ic_rightArrow")
            }

        } else {
            cell.imgView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return   _appDelegator.arrCategory[indexPath.section].isOpen ? 44 * universalWidthRatio : 0
        //return 44 * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        if _appDelegator.arrCategory.count > section{
            cell.lblTitle.text = _appDelegator.arrCategory[section].name
            
            if _appDelegator.arrCategory[section].childCategories.count > 0{
                cell.imgArroe.isHidden = false
                cell.contentView.backgroundColor = UIColor(colorLiteralRed: 226.0/255.0, green: 227.0/255.0, blue: 228.0/255.0, alpha: 1.0)
                
                if _appDelegator.arrCategory[section].isOpen{
                    cell.imgArroe.image = #imageLiteral(resourceName: "ic_downArrow")
                } else {
                    cell.imgArroe.image = #imageLiteral(resourceName: "ic_rightArrow")
                }
            } else {
                cell.imgArroe.isHidden = true
                cell.contentView.backgroundColor = UIColor(colorLiteralRed: 226.0/255.0, green: 227.0/255.0, blue: 228.0/255.0, alpha: 1.0)
            }
            
        } else {
            if arrLeftMenu[section - _appDelegator.arrCategory.count] == "My Wallet"{
                
                cell.btnWalletPlus.isHidden = false
                if walletBalance != "0" {
                  cell.btnWallet.isHidden = false
                  cell.btnWallet.setTitle(RsSymbol + walletBalance, for: .normal)
                } else {
                    cell.btnWallet.isHidden = true
                }
                
            }
            cell.lblTitle.text = arrLeftMenu[section - _appDelegator.arrCategory.count]
            cell.imgArroe.isHidden = true
        }
        cell.btnSection.tag = section
        cell.btnSection.addTarget(self, action: #selector(btnSectionClicked(sender:)), for: .touchUpInside)
        return cell.contentView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parentCate = _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row]
        
        var secondLevelItems = _appDelegator.arrCategory[indexPath.section].childCategories
        let thirdLevelItems = parentCate.childCategories
        
        if !thirdLevelItems.isEmpty {
            var index = indexPath.row
            let indexPaths = thirdLevelItems.map({ cate -> IndexPath in
                index += 1
                return IndexPath(row: index, section: indexPath.section)
            })
            
            if parentCate.isOpen {
                secondLevelItems.removeSubrange(indexPath.row+1..<indexPath.row+thirdLevelItems.count+1)
                _appDelegator.arrCategory[indexPath.section].childCategories = secondLevelItems
                isThirdLevelOpen = false
                tableView.deleteRows(at: indexPaths, with: .automatic)
                _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].isOpen = false
                
                
            } else {
                secondLevelItems.insert(contentsOf: thirdLevelItems, at: indexPath.row+1)
                _appDelegator.arrCategory[indexPath.section].childCategories = secondLevelItems
                isThirdLevelOpen = true
                tableView.insertRows(at: indexPaths, with: .automatic)
                _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row].isOpen = true
            }
            tableView.reloadRows(at: [indexPath], with: .none)
            
        } else {
            
            goToProductList(categoryObj: _appDelegator.arrCategory[indexPath.section].childCategories[indexPath.row])
        }
    }
    
    @IBAction func btnSectionClicked(sender:UIButton){
        let sectionIndex = sender.tag
        
        if _appDelegator.arrCategory.count > sectionIndex{
            CheckSubCategory(index: sectionIndex)
        } else {
            switch arrLeftMenu[sectionIndex - _appDelegator.arrCategory.count]{
                
            case "Logout" :
                self.CallLogoutApi()
                break
                
            case "My Wallet":
                let wvc = storyboardLogin.instantiateViewController(withIdentifier: "WalletVC") as! WalletVC
                self.navigationController?.pushViewController(wvc, animated: true)
                break

			case "My Orders":
				let wvc = storyboardMyOrders.instantiateViewController(withIdentifier: "MyOrdersVC") as! MyOrdersVC
				self.navigationController?.pushViewController(wvc, animated: true)
				break
                
            case "My Returns":
                let rvc = storyboardMyReturn.instantiateViewController(withIdentifier: "MyReturnVC") as! MyReturnVC
                self.navigationController?.pushViewController(rvc, animated: true)
                break
                
            case "Just For You":
                let rvc = storyboardOffer.instantiateViewController(withIdentifier: "SBID_JustForYouVC") as! JustForYouVC
                self.navigationController?.pushViewController(rvc, animated: true)
                break

            case "Contact Us":
                let cvc = storyboardcontactUs.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
                self.navigationController?.pushViewController(cvc, animated: true)
                break
            
            case "Rate Us" :
                 rateUs()
                 break
                
            case "Share App" :
                shareApp(sender)
                if IS_IPAD {
                    return
                }
                break
                
            case "Gift Coupons" :
                let buygiftcouponvc = self.storyboardAccount.instantiateViewController(withIdentifier: "AddGiftCouponVC") as! AddGiftCouponVC
                self.navigationController?.pushViewController(buygiftcouponvc, animated: true)
                
            case "Privacy Policy":
                let url = "http://business.bookmyfood.co.in/Policy"
                UIApplication.shared.open(URL(string: url)! , options: [:], completionHandler: nil)
                
            case "Store 360" :
                let store360VC = self.storyboardWishListh.instantiateViewController(withIdentifier: "Store360VC") as! Store360VC
                self.navigationController?.pushViewController(store360VC, animated: true)
                break
                
            case "Consumer Insights":
                let opinionPoll = self.storyboardOpinionPoll.instantiateViewController(withIdentifier: "PollListVC") as! PollListVC
                self.navigationController?.pushViewController(opinionPoll, animated: true)
                break

            default :
                break
            } 
            
            shutterAction()
        }
    }
    
    //Checking for 2nd Level Category
    func CheckSubCategory(index:Int){
        
        let cate = _appDelegator.arrCategory[index]
        if !cate.childCategories.isEmpty {
            cate.isOpen = !cate.isOpen
            self.tableView.reloadSections([index], with: .automatic)
        } else {
            goToProductList(categoryObj: cate)
        }
    }
    
    // Navigation to Product List
    func goToProductList(categoryObj : Category){
        let productvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        //print(category.childCategories[indexPath.section].childCategories[indexPath.row].id)
        productvc.apiParam = categoryObj.apiParam
        productvc.navigationTitle = categoryObj.name
        shutterAction()
        (self.tabBarVC.selectedViewController as! UINavigationController).pushViewController(productvc, animated: true)
    }
    
    func rateUs() {
        if let url = URL(string: _appStoreUrl) {
            _application.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shareApp(_ sender: UIButton) {
        
        let shareMessage = "Check it out new exciting retailer store for online shopping and get delivery at your door step. \n\(_appStore_bitlyLink)"
        let sourceFrame = self.view.convert(sender.bounds, from: sender)
        let actVC = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        actVC.modalPresentationStyle = IS_IPAD ? .popover : .overCurrentContext
        actVC.popoverPresentationController?.sourceView  = self.view
        actVC.popoverPresentationController?.sourceRect = sourceFrame

        self.present(actVC, animated: true, completion: nil)
    }
}

//MARK: - Category Api Call
extension ContainerVC
{
    func getCategoryList() {
        print("headers are => \(wsCall.headers)")
        wsCall.getCategorylist(params: nil) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    print("category response is => \(json)")
                    _appDelegator.arrCategory = json.map({ (categoryObject) -> Category in
                        return Category(categoryObject)
                    })
                }
                self.tableView.reloadData()
            }
        }
    }
}

//MARK: -  Method for show or Hide Left Menu
extension ContainerVC {
    
    
    // Menu Slide Event - Pan Geture Event
    @IBAction func menuDragged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.viewContainer)
        println(translation)
        
        if sender.state == .changed {
            let x = self.tblLeadingConstraint.constant + translation.x
            if x < 0 {
                self.tblLeadingConstraint.constant = translation.x
            }
          
        }
        else if sender.state == .ended {
            if sender.isLeft(theViewYouArePassing: sender.view!) {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.tblLeadingConstraint.constant = CGFloat(self.leadingTableView)
                    self.viewMenuTable.backgroundColor = UIColor.clear
                    self.view.layoutIfNeeded()

                }) { (done) in
                    self.viewGesture.isHidden = true
                    self.viewMenuTable.isHidden = true
                }
            
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.tblLeadingConstraint.constant  = 0
                    self.viewMenuTable.backgroundColor = UIColor.black.alpha(0.5)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    // Showing or Hide a Menu
    func shutterAction() {
        var newValue:CGFloat = 0
        if self.tblLeadingConstraint.constant == 0 {
            newValue = CGFloat(self.leadingTableView)
            self.viewMenuTable.isHidden = true
            self.viewGesture.isHidden = true
        } else {
            newValue = 0
            self.viewMenuTable.isHidden = false
            self.viewGesture.isHidden = false
        }
        self.viewMenuTable.backgroundColor = UIColor.clear

        UIView.animate(withDuration: 0.5) {
            self.tblLeadingConstraint.constant  = newValue
            self.viewMenuTable.backgroundColor = UIColor.black.alpha(0.5)
            self.view.layoutIfNeeded()
        }
        
    }
    
    
}

extension ContainerVC{
    func CallLogoutApi(){
        
        wsCall.callLogout(params: nil) { (response) in
            if response.isSuccess {
                
                self.hideCentralGraySpinner()
                //self.tabBarVC.selectedIndex = 0
                dictUser = User()
                UserDefaults.standard.removeObject(forKey: AppPreference.userObj)
                wsCall.removeHeaderCustomerId()
                if self.tabBarVC.selectedIndex == 4{
                    self.tabBarVC.delegate?.tabBarController!(self.tabBarVC, didSelect: (self.tabBarVC.viewControllers?[4])!)
                }
                
                self.setArrLeftMenu()
                self.tableView.reloadData()
               
            } else {
                self.hideCentralGraySpinner()
                //KVAlertView.show(message: response.message)
            }
        }
        
    }

}
extension UIPanGestureRecognizer {
    
    func isLeft(theViewYouArePassing: UIView) -> Bool {
        let velo : CGPoint = velocity(in: theViewYouArePassing)
        if velo.x > 0 {
            print("Gesture went right")
            return false
        } else {
            return true
        }
    }
}

class SectionCell : TableViewCell{
    @IBOutlet var btnSection : UIButton!
    @IBOutlet var imgArroe : UIImageView!
    @IBOutlet var btnWallet : Style1WidthButton!
    @IBOutlet var btnWalletPlus : Style1WidthButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnWallet.layer.cornerRadius = 5
        btnWallet.layer.masksToBounds = true
    }
}

class ChildCell : TableViewCell{
    @IBOutlet var leadingLabelConstraints: NSLayoutConstraint!
}

