//
//  AccountVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 19/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import MessageUI

class AccountVC: ParentViewController{

    @IBOutlet weak var accountBlurImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var mainView: ProfileImageView!
    @IBOutlet weak var tblAccount: UITableView!
    
    var arrUserAccount: [[String: Any]] = []
    
    var isUserName: Bool = true
    
    var arrDeliveryAddress: [Address] = []
    
    var isNoDeliveryAddress: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
        tblAccount.isHidden = true
    
        profileImage.layer.cornerRadius = 5.0
        profileImage.layer.masksToBounds = true
        
       
        
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if _appDelegator.isBackToAccountScreen{
            
            
            _appDelegator.isBackToAccountScreen = false
            
                DispatchQueue.main.async(execute: {
                    self.getDeliveryAddress()
                    
                });

            
            return
        }
        
        if self.arrDeliveryAddress.count == 0 {
            
            DispatchQueue.main.async(execute: {
                self.getDeliveryAddress()
                
            });
        }
        
        if UserDefaults.standard.value(forKey: AppPreference.userObj) != nil{
            let userJson = UserDefaults.standard.value(forKey: AppPreference.userObj) as! [String : Any]
            dictUser = User(userJson)
        }
        
        print("dictUser.email:\(dictUser.email)")
         print("dictUser.email:\(dictUser.email)")
        
        if arrUserAccount.count > 0 {
            
            arrUserAccount.removeAll()
        }
        
        
        if !dictUser.image.isEmpty {
            
        let imgUrl = getImageUrlWithSize(urlString: (dictUser.image), size:  self.accountBlurImage.frame.size)
            
            print("imgUrl:\(imgUrl)")
            
        self.accountBlurImage.setImage(url: imgUrl, placeholder: UIImage(), completion: {
        (img) in
            
            if img != nil {
                
                //self.hideProfileCentralGraySpinner()
               // self.showCentralSpinner()
            
            self.accountBlurImage.image=self.bluredImage(view: self.view)
                
            }
        })
            
            let imgUrl2 = getImageUrlWithSize(urlString: (dictUser.image), size:  self.profileImage.frame.size)
            
            
           // self.profileImage.setImage(url: imgUrl2, placeholder: UIImage(), completion:nil)
            
           self.profileImage.setImage(url: imgUrl2, placeholder: UIImage(), completion: {
                (img) in
                
                if img != nil {
                    
                    //self.hideProfileCentralGraySpinner()
                    // self.showCentralSpinner()
                    
                    self.profileImage.image = img
                    
                }else{
                    
                    self.profileImage.image = UIImage.init(named: "ic_account")
            }
            })
            
        }else{

            //self.showCentralSpinner()
             //self.hideProfileCentralGraySpinner()
            self.accountBlurImage.backgroundColor = UIColor.lightGray
            
            // self.viewNoImage.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            
            self.accountBlurImage.layer.borderColor = UIColor.white.cgColor
            self.accountBlurImage.contentMode = .scaleAspectFill
            self.accountBlurImage.layer.borderWidth = 1.0

        }
        
        
        
        if dictUser.name != "" {
            
            arrUserAccount.append(["UserInfo":dictUser.name,"Image":""])
        }else{
            
            isUserName = false
        }
        
        
        if dictUser.email != "" {
            
            arrUserAccount.append(["UserInfo":dictUser.email,"Image":"ic_email"])
        }
        
        if dictUser.mobile != "" {
            
            arrUserAccount.append(["UserInfo":dictUser.mobile,"Image":"ic_mobile"])
        }
        
//        if dictUser.birthDate != "" {
//            
//             if dictUser.birthDate != "1900-01-01T00:00:00"{
//                
//                arrUserAccount.append(["UserInfo":dictUser.birthDate,"Image":"ic_dateOfBirth"])
//            }
//            
//            
//        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("mainView\(mainView)")
        
//        
//        mainView.bounds = profileImage.bounds
//        
//        mainView.showCentralSpinner()
        
        tblAccount.isHidden = false
        
        self.tblAccount.reloadData()

        
        
    }
    
    //MARK: - Blur Effect to UIImageView
    func snapShotImage() -> UIImage {
        UIGraphicsBeginImageContext(accountBlurImage.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.accountBlurImage.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
        
        return UIImage()
    }

 
    func bluredImage(view:UIView, radius:CGFloat = 2) -> UIImage {
        let image = self.snapShotImage()
        
        if let source = image.cgImage {
            let context = CIContext(options: nil)
            let inputImage = CIImage(cgImage: source)
            
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter?.setDefaults()
            clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
            
            if let clampedImage = clampFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let explosureFilter = CIFilter(name: "CIExposureAdjust")
                explosureFilter?.setValue(clampedImage, forKey: kCIInputImageKey)
                explosureFilter?.setValue(-1.0, forKey: kCIInputEVKey)
                
                if let explosureImage = explosureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    let filter = CIFilter(name: "CIGaussianBlur")
                    filter?.setValue(explosureImage, forKey: kCIInputImageKey)
                    filter?.setValue("\(radius)", forKey:kCIInputRadiusKey)
                    
                    if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                        let bounds = accountBlurImage.bounds
                        let cgImage = context.createCGImage(result, from: bounds)
                        let returnImage = UIImage(cgImage: cgImage!)
                        return returnImage
                    }
                }
            }
        }
        return UIImage()
    }
    
    
    func setCellCorner(cell: AddressCell, leftCorner: UIRectCorner, rigthCorner: UIRectCorner, width: Float, height: Float) -> CAShapeLayer {
        
        let shape = CAShapeLayer()
        // Create the path (with only the top-left corner rounded)
        let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: ([.topLeft,.topRight]), cornerRadii: CGSize(width: 7.0, height: 7.0))
        shape.frame = cell.bounds
        shape.path = maskPath.cgPath
        
        return shape
        
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditAccountClicked(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditAccountVC") as! EditAccountVC
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
    func showProfileImageCentralGraySpinner() {
        centralGrayActivityIndicator.center = self.mainView.center
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
    

    func hideProfileCentralGraySpinner() {
        self.view.isUserInteractionEnabled = true
        centralGrayActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralGrayActivityIndicator.alpha = 0.0
        })
    }
    
    //MARK: get address 
    
    func getDeliveryAddress(){
        
        
        let param = ["AddressId":"0"]
        
        wsCall.getDeliveryAddress(params: param) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    self.hideCentralGraySpinner()
                    
                    print("Address response is => \(json)")
                    
                    self.arrDeliveryAddress = json.map({ (object) -> Address in
                        
                        return Address(forDelivery : object)
                        
                    })
                    
                    if self.arrDeliveryAddress.count == 0{
                        
                        self.isNoDeliveryAddress = true
                    }
                    
                    print("self.arrDeliveryAddress => \(self.arrDeliveryAddress)")
                    
                  
                    
                }
            }
            
        }
    }
}

extension AccountVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
        
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if section == 0 {
            return arrUserAccount.count
        }else{
            return 1
        }
        
        
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 {
            
            return 0
        }else{
             return 10
        }
        
        
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect (x:0, y: 0, width:10, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 33*universalWidthRatio
        
    }
    
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.section == 1 {
            
            let cellIdentifier = "AccountCell1"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AccountCell
            
            cell.layer.cornerRadius = 7.0
            
            return cell

        }else{
            let cellIdentifier = "AccountCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AccountCell
            
            
            let dic = arrUserAccount[indexPath.row]
            
            
            if indexPath.row == self.arrUserAccount.count - 1 {
                
                let shape = CAShapeLayer()
                let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: ([.bottomLeft,.bottomRight]), cornerRadii: CGSize(width: 7.0, height: 7.0))
                shape.frame = cell.bounds
                shape.path = maskPath.cgPath
                cell.layer.mask = shape
                cell.layoutIfNeeded()

            }
            
            if indexPath.row == 0 {
                
                
                if self.arrUserAccount.count > 1 {
                    
                    let shape = CAShapeLayer()
                    let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: ([.topLeft,.topRight]), cornerRadii: CGSize(width: 7.0, height: 7.0))
                    shape.frame = cell.bounds
                    shape.path = maskPath.cgPath
                    cell.layer.mask = shape
                    cell.layoutIfNeeded()
                }else{
                    
                    cell.layer.cornerRadius = 7.0
                    cell.layer.masksToBounds = true
                }
                
                
               
                
                if isUserName {
                    
                    cell.lblTitle.text = dic["UserInfo"] as? String
                    
                    cell.lblTitle.font = UIFont(name: FontName.SANSBOLD, size: (16 * universalWidthRatio))
                }else{
                    
                    cell.img.image = UIImage(named:(dic["Image"] as? String)!)
                    
                    cell.lblTitle.text = dic["UserInfo"] as? String

                }
                
               
        
                
            }else if indexPath.row == 1{
                
                cell.img.image = UIImage(named:(dic["Image"] as? String)!)
                
                cell.lblTitle.text = dic["UserInfo"] as? String
                
                
            }else if indexPath.row == 2{
                
                cell.img.image = UIImage(named:(dic["Image"] as? String)!)
                
                cell.lblTitle.text = dic["UserInfo"] as? String
                
            }else if indexPath.row == 3{
                
                cell.img.image = UIImage(named:(dic["Image"] as? String)!)
                
                
                let dateF = DateFormatter()
                dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let firstDate = dateF.date(from: dic["UserInfo"] as! String)
                dateF.dateFormat = "dd-MMM-yyyy"
                let newDateString = dateF.string(from: firstDate!)
                
                cell.lblTitle.text = newDateString

            }
            
           
            
             return cell
        }
        
       
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if indexPath.section == 0 {
            
            let dic = arrUserAccount[indexPath.row]
            
            if indexPath.row == 1 {
                
                openEmail((dic["UserInfo"] as? String)!, subject: "", messageBody: "", controller: self)
                
            }else if indexPath.row == 2{
                
                makeACall(number: (dic["UserInfo"] as? String)!)
                
            }else{
                
                
            }
        }
        
                
        if indexPath.section == 1 {
            
            if self.arrDeliveryAddress.count == 0 {
                
                let controller = self.storyboardShoppingCart.instantiateViewController(withIdentifier: "AddDeliveryAddressVC") as! AddDeliveryAddressVC
                controller.isNoDeliveryAddress = isNoDeliveryAddress
                controller.isScreen = "account"
        
                self.present(controller, animated: true, completion: nil)
                
            }else{
                
                let controller = self.storyboardShoppingCart.instantiateViewController(withIdentifier: "DeliveryAddressLIstVC") as! DeliveryAddressLIstVC
                controller.isScreen = "account"
                controller.isNoDeliveryAddress = isNoDeliveryAddress
                self.present(controller, animated: true, completion: nil)
            }
            
           
        }
        
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}


class ProfileImageView: UIView, IndicatorLoader {
    
    //IndicatorLoader Protocol's property
    var centralIndicatorView = CustomActivityIndicatorView (image: UIImage(named: spinnerIcon)!)
    var indicatorContainerView: UIView {return self}
}


class AccountCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: WidthLabel!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var bg1View: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
}


