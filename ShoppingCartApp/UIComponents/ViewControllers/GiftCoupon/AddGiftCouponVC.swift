//
//  AddGiftCouponVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 22/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class AddGiftCouponVC: ParentViewController {
    
    @IBOutlet weak var giftCouponCollectionview: UICollectionView!
    var numberOfItemInRow: Int {return IS_IPAD ? 8 : 4}
    var arrGiftCouponList:[GiftCouponList] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        giftCouponCollectionview.contentInset = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: 0)
        
        navigationBarView.drawShadow()
        
        giftCouponCollectionview.isHidden = true
        
        self.getGiftCouponsList()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        //containerView.frame = scrollView.bounds
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        //tblAddNewAddress.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }


   
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
         self.navigationController?.popViewController(animated: true)
    }
    
    // get gift coupons list
    
    func getGiftCouponsList(){
        
         self.showCentralGraySpinner()
        
        wsCall.getGiftCoupons(params: nil) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    print("Address response is => \(json)")
                    
                    self.arrGiftCouponList = json.map({ (object) -> GiftCouponList in
                        
                        return GiftCouponList(json: object)
                        
                    }).filter({ (po) -> Bool in
                        
                        return po.isActive
                        
                    })
                    
                    if self.arrGiftCouponList.count > 0{
                        
                        removeNoResultFoundImage(fromView: self.view)
                        
                        self.giftCouponCollectionview.isHidden = false
                        self.giftCouponCollectionview.reloadData()
                    }else{
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Gift Coupons Found!")

                    }
                    
                    
                }
            }else{
                
                //let code = response.code
                
              //  if(code == 400){
                    
                    if let json = response.json as? [String:Any] {
                        
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Gift Coupons Found!")

                        KVAlertView.show(message: json["message"] as! String)
                    }
               // }
                
            }
            
            self.hideCentralGraySpinner()
        }
    }
    
    // purchase gift coupons button
    
    @IBAction func btnPurchasePressed(_ sender: UIButton) {
        
        let indexPath = NSIndexPath(row: 0, section: 1) // order summary
        
        let cell = self.giftCouponCollectionview.cellForItem(at: indexPath as IndexPath) as? GiftToCell
        
        let arrSelectedGiftCoupons = arrGiftCouponList.filter( { return $0.isSelected } )
        
        if arrSelectedGiftCoupons.count == 0 {
            
            KVAlertView.show(message:"SELECT_GIFT_COUPONS".localizedString())
            return
            
        }else if cell?.txtMobileNo.text == "" {
            
            KVAlertView.show(message:"MOBILE".localizedString())
            return
            
        }else if !(cell?.txtMobileNo.text?.isValidMobileNumber())! {
            
            KVAlertView.show(message:"MOBILE_LENGTH".localizedString())
            return
            
        }else{
            
            print("arrSelected::\(arrSelectedGiftCoupons.count)")
            
            let giftCoupon:GiftCouponList = arrSelectedGiftCoupons[sender.tag]
            
            let buyPrice = Converter.toString(giftCoupon.price)
            let pvc = storyboardProductList.instantiateViewController(withIdentifier: "PayTmVC") as! PayTmVC
            pvc.mobileNumber = (cell?.txtMobileNo.text)!
            pvc.amount = buyPrice
            self.navigationController?.pushViewController(pvc, animated: true)
            
            print("done.")
        }
        
//        let cvc = storyboardcontactUs.instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
//        self.navigationController?.pushViewController(cvc, animated: true)
        
        
    }

}


extension AddGiftCouponVC: UICollectionViewDelegate, UIKeyboardObserver, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                giftCouponCollectionview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        giftCouponCollectionview.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
        return self.arrGiftCouponList.count
        }else{
        return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if  kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "giftCouponCollectionHeaderView", for: indexPath) as! giftCouponCollectionHeaderView
            
            return headerView
        }
         fatalError("Unexpected element kind")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCouponCell", for: indexPath as IndexPath) as! GiftCouponCell
            
            let giftCoupon = self.arrGiftCouponList[indexPath.row]
            
            if giftCoupon.isSelected{
                
                cell.bgView.backgroundColor = UIColor.init(red: 56.0/255.0, green: 179.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                cell.lblGiftCouponAmt.textColor = UIColor.white

                
            }else{
                
                cell.bgView.backgroundColor = UIColor.init(red: 209.0/255.0, green: 210.0/255.0, blue: 212.0/255.0, alpha: 1.0)
                cell.lblGiftCouponAmt.textColor = UIColor.black

            }
            
            cell.lblGiftCouponAmt.text = String(format: "%@ %.f",RsSymbol, giftCoupon.price)
            
            return cell
            
        }else{
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftToCell", for: indexPath as IndexPath)
            
            return cell
        }
        
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
             return CGSize(width: collectionView.frame.size.width, height:33)
        }else{
            
            return CGSize(width: collectionView.frame.width, height: CGFloat.leastNormalMagnitude)
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            return CGSize(width: (screenSize.width - CGFloat(40 + 10 * (numberOfItemInRow - 1)) )/CGFloat(numberOfItemInRow), height:35 * universalWidthRatio)
        }else{
            
            if IS_IPAD {
                return CGSize(width: collectionView.frame.width-10, height:130)
            }else{
                return CGSize(width: collectionView.frame.width-10, height:120)
            }
            
            
        }
        
        
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        if indexPath.section == 0 {
            
            // multiple selection logic
            
           /* let giftCoupon = self.arrGiftCouponList[indexPath.row]
            
            giftCoupon.isSelected = !giftCoupon.isSelected
            
            giftCouponCollectionview.reloadData()*/
            
            // multiple selection logic
            
            let giftCouponObj = self.arrGiftCouponList[indexPath.row]
            
            for giftCoupon in self.arrGiftCouponList {
                
                if giftCouponObj.giftCouponId == giftCoupon.giftCouponId {
                    
                    giftCoupon.isSelected = true
                }else{
                    giftCoupon.isSelected = false
                }
                
            }
            
             giftCouponCollectionview.reloadData()
            
        }
        
    }

    
}

class giftCouponCollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var lblSelectGiftCoupons: WidthLabel!
    
}

class GiftCouponCell: CollectionViewCell {
    
    @IBOutlet weak var bgView: CornerRadiusView!
    @IBOutlet weak var lblGiftCouponAmt: WidthLabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        
    }
    
}

class GiftToCell: CollectionViewCell {
    
    @IBOutlet weak var txtMobileNo: WidthTextField!
    @IBOutlet weak var btnPurchase: BorderButton!
    
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
    
        let tooBar: UIToolbar = UIToolbar()
        tooBar.backgroundColor = UIColor.init(red: 209.0/255.0, green: 210.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        tooBar.tintColor = UIColor.darkGray
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(GiftToCell.donePressed))]
        tooBar.sizeToFit()
        
        txtMobileNo.inputAccessoryView = tooBar
    
        }
    
    func donePressed () {
        txtMobileNo.resignFirstResponder()
    }

}

