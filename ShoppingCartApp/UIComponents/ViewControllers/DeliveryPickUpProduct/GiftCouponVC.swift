//
//  GiftCouponVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 29/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol applyGiftCouponDelegate: class{
    
    func applyCoupon(totalCouponPrice: Float)
    func clearAllCoupon()
}


class GiftCouponVC: ParentViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tblGiftCoupon: UITableView!
    
    @IBOutlet weak var viewBottomConst: NSLayoutConstraint!
    
    var arrGiftCoupons = [GiftCouponList]()
    
    var arrSelectedCoupons = [GiftCouponList]()
    
    weak var couponDelegate: applyGiftCouponDelegate?
    
    var totalGiftCoupon:Float = 0.0
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBottomConst.constant = -567*universalWidthRatio
        
        self.view.backgroundColor = UIColor.clear
        
        
        if _appDelegator.arrGiftCoupons.count > 0 {
            
            
            self.arrGiftCoupons = _appDelegator.arrGiftCoupons
            
           
        }
        
       
        tblGiftCoupon.tableFooterView = UIView(frame: .zero)
        
        containerView.drawShadow(0.7, offSet: CGSize(width: 0, height: 0) )
        
        containerView.layer.zPosition = 20

        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            self.viewBottomConst.constant = 55
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            self.view.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    //MARK: button close clicked
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        
        _appDelegator.isBackToAddressScreen = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            self.viewBottomConst.constant = -567*universalWidthRatio
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
     //MARK: button apply clicked
    
    @IBAction func btnApplyCouponClicked(_ sender: UIButton) {
        
        //_appDelegator.isBackToAddressScreen = true
       
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            self.viewBottomConst.constant = -567*universalWidthRatio
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.dismiss(animated: false, completion: { () -> Void in
                
                
                _appDelegator.arrGiftCoupons = self.arrGiftCoupons
                
                print("_appDelegator.arrGiftCoupons 1: GC\(_appDelegator.arrGiftCoupons[0].isActive)")
                print("_appDelegator.arrGiftCoupons 2: GC\(_appDelegator.arrGiftCoupons[1].isActive)")
                print("_appDelegator.arrGiftCoupons 2: GC\(_appDelegator.arrGiftCoupons[2].isActive)")
                
                self.couponDelegate?.applyCoupon(totalCouponPrice: self.totalGiftCoupon)
                
                
            })
        }
        
    }
    
    // MARK: check / uncheck gift coupon
    
    
    @IBAction func btnSelectGiftCoupon(_ sender: UIButton) {
        
        let coupon = self.arrGiftCoupons[sender.tag]
        
        if coupon.isActive == false {
            
             coupon.isActive = true
            
             sender.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.selected)
            
             totalGiftCoupon = totalGiftCoupon + coupon.price
            
        }else{
            
            coupon.isActive = false
            
            sender.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.selected)
            
            totalGiftCoupon = totalGiftCoupon - coupon.price
            
        }
        
        self.tblGiftCoupon.reloadData()
    
        
    }
    
    //MARK: clear all clicked
    
    @IBAction func btnClearAllClicked(_ sender: UIButton) {
       
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            self.viewBottomConst.constant = -567*universalWidthRatio
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.dismiss(animated: false, completion: { () -> Void in
                
                
                for coupon in self.arrGiftCoupons {
                    
                    coupon.isActive = false
                }
                
                _appDelegator.arrGiftCoupons.removeAll()
                
                self.couponDelegate?.clearAllCoupon()
                
                
            })
        }

        
    }

}


extension GiftCouponVC: UITableViewDelegate, UITableViewDataSource{
    
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.arrGiftCoupons.count
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "CouponCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CouponCell
        
        let coupon = self.arrGiftCoupons[indexPath.row]
        
        
        if coupon.isActive == false {
            
            cell.btnApplyCoupon.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
            
        }else{
            
            cell.btnApplyCoupon.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
        }
        
        cell.lblCouponName.text = coupon.giftCoupon
        
        cell.lblCouponPrice.text = String(format: "%@ %.f",RsSymbol, coupon.price)
//        
        cell.btnApplyCoupon.tag = indexPath.row
        
        return cell
        
    }
    
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let coupon = self.arrGiftCoupons[indexPath.row]
        
        if coupon.isActive == false {
            
            coupon.isActive = true
            
           // sender.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.selected)
            
            totalGiftCoupon = totalGiftCoupon + coupon.price
            
        }else{
            
            coupon.isActive = false
            
           // sender.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.selected)
            
            totalGiftCoupon = totalGiftCoupon - coupon.price
            
        }
        
        self.tblGiftCoupon.reloadData()
        
        
    }
    
}


class CouponCell: UITableViewCell {
    
    @IBOutlet weak var lblCouponName: WidthLabel!
    
    @IBOutlet weak var lblCouponPrice: WidthLabel!
    
    @IBOutlet weak var btnApplyCoupon: UIButton!
    
}
