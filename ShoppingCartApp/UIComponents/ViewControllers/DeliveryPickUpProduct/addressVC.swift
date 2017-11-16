//
//  addressVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 22/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView


class addressVC: ParentViewController, UITableViewDataSource, UITableViewDelegate, pickUpAddressDelegate, DeliveryAddressDelegate,addDeliveryAddressDelegate,applyGiftCouponDelegate {
    func refreshAddressList() {
        
    }

    @IBOutlet weak var tblAddress: UITableView!
    
    var isPickup: Bool = false
    
    var isTextFieldEdit: Bool = false
    
    var defaultDeliverySelection: Bool = true
    
    var checkPickupSelection: Bool = true
    
    var checkDeliverySelection: Bool = true
    
    var isDeliverySelected: Bool = true
    
    var arrShippingCharge = [ShippingCharge]()
    
    var arrCustomerBalance = [CustomerBalance]()
    
    var strBranchTitle = ""
    
    var pickUpAddressObject: Address?
    
    var addressObject: Address?
    
    var arrDeliveryAddress: [Address] = []
    
    var arrDefaultDeliveryAddress:[Address] = []
    
    var arrPickupTime:[Address] = []
    
    var selectedDelivery: Int = -1 {
        didSet {
            
                print("Select ShippingDate::\(currentOrder.displayPrice)")
                
                if selectedDelivery != -1 && self.arrShippingCharge.count > 0 {
                    
                    let shippingCharge = self.arrShippingCharge[selectedDelivery]
                    
                    if shippingCharge.changeExpectedShippingDate != "" { //expected date is changed by user
                        
                        currentOrder.deliveryPickupDate = shippingCharge.changeExpectedShippingDate
                    }else{
                        currentOrder.deliveryPickupDate = shippingCharge.expectedShippingDate
                    }
                    
                    currentOrder.deliveryCharge = Double(shippingCharge.shippingCharge)
                    
                    print("shippingCharge :\(selectedDelivery)")
                    
                }else{
                    
                    if selectedDelivery == -1 {
                        
                         currentOrder.deliveryCharge = 0.0
                    }
                    
                }// not -1
            
        }
    }
    
    var loyaltyBalance: Float = 0.0
    
    var walletBalance: Float = 0.0
    
    var isCancelLoyaltyRewards:Bool = false
    
    var isRedeemWallets:Bool = false
    
    var arrGiftCoupons = [GiftCouponList]()
    
    var totalGiftCoupon: Float = 0.0
    
    var isGiftCoupon:Bool = false
    
    var isCancelEnable:Bool = false
    
    var strNetCartAmount:String = ""
    
    var shippingCharge: ShippingCharge?
    
    var pickupTimeAddress: Address?
    
    var finalWalletValue: Float = 0.0 {
        didSet{
            currentOrder.walletPrice = Double(finalWalletValue)
        }
    }
    
    var isFirstTimeWallet: Bool = true
    
    var isWalletCancel: Bool = false
    
    @IBOutlet weak var btnMakePayment: UIButton!
    
    var totalOrder: Double = 0.0
    
    //it is used for placeorder
    var currentOrder = Order()
    
    var isNoDeliveryAddress: Bool = false
    
   
    lazy var datepicker: VDatePickerView = {
        let picker = VDatePickerView.loadDatePicker()
        picker.dateMode = UIDatePickerMode.date
        picker.dateSelectionBlock = { date in
        
          
        }
        return picker
    } ()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
     
        navigationBarView.drawShadow()
        
        print("currentOrder.displayPrice->\(currentOrder.displayPrice)")
        
        strNetCartAmount =  Cart.shared.totalCartAmount.rounded().ToString()
        //totalOrder = Cart.shared.totalCartAmount.rounded()
        totalOrder = Cart.shared.totalCartAmount
        
        tblAddress.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        btnMakePayment.setTitle("MAKE_PAYMENT".localizedString(), for: UIControlState.normal)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if _appDelegator.isBackToAddressScreen{

//            checkPickupSelection = true
//            checkDeliverySelection = true

            
        _appDelegator.isBackToAddressScreen = false
            
            return
            
        }else if _appDelegator.isViewOrder{
            
            print("currentOrder.arrOrderShippingCharge:\(currentOrder.arrOrderShippingCharge.count)")
            
            if _appDelegator.isTextFieldInput{
                
                isTextFieldEdit = _appDelegator.isTextFieldInput
            }
            
            addressObject = currentOrder.deliveryAddress
            pickUpAddressObject = currentOrder.pickupAddress
            
            if currentOrder.isDeliveryPickup{
                
                checkDeliverySelection = false
                checkPickupSelection = true
                
            }else{
                
                if (pickUpAddressObject != nil){
                    
                    print("pickupObj")
                    
                    checkDeliverySelection = true
                    checkPickupSelection = false
                    //defaultDeliverySelection = false
                    isPickup = true

                
                    self.arrPickupTime.append(currentOrder.selectedAddress)
                }
                
                
            }
            
            
            self.arrShippingCharge = currentOrder.arrOrderShippingCharge
            
            selectedDelivery = currentOrder.selectedOrderDelivery
            
            walletBalance = currentOrder.totalWalletBalance
            
            self.tblAddress.reloadData()
            
            let indexPath = NSIndexPath(row: 0, section: 5) //wallet
            
            let cell = self.tblAddress.cellForRow(at: indexPath as IndexPath) as? AddressCell
            
            print("usedWalletBalance\(currentOrder.usedWalletBalance)")
            
            if currentOrder.usedWalletBalance == 0.0 {
                
                isWalletCancel = true
            }
            
            if currentOrder.usedWalletBalance != -1 {
                
                cell?.walletChangeValue = currentOrder.usedWalletBalance
            }
            
            
            
            self.getDeliveryAddress()
            
            addKeyboardObserver()
        
            _appDelegator.isViewOrder = false
            
            
        }else{
            
            if defaultDeliverySelection == false {
                
                if currentOrder.usedWalletBalance == 0.0 {
                    
                    isWalletCancel = true
                    
                    defaultDeliverySelection = true

                }
            }
            
            tblAddress.isHidden = true
            self.getDeliveryAddress()
            self.getCustomerBalance()
            addKeyboardObserver()
        }
        
       

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //tblAddress.reloadData()
    }
    
    // MARK: Delivery Address Clicked

    @IBAction func btnDeliveryAddressClicked(_ sender: UIButton) {
        
       // defaultDeliverySelection = false
        
       // _appDelegator.arrGiftCoupons = self.arrGiftCoupons
        
        let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DeliveryAddressLIstVC") as! DeliveryAddressLIstVC
        controller.delegateDelivery = self
        controller.arrDeliveryAddress = arrDeliveryAddress
        controller.isScreen = "addresslist"
        controller.isNoDeliveryAddress = isNoDeliveryAddress
        self.present(controller, animated: true, completion: nil)
        
    }
    
    // MARK: Pickup Address Clicked
    
    @IBAction func btnSelectPickupAddressClicked(_ sender: UIButton) {
        
       // defaultDeliverySelection = false
        
       // _appDelegator.arrGiftCoupons = self.arrGiftCoupons
        
        let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PickupAddressListVC") as! PickupAddressListVC
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
     // MARK: add new Address Clicked
    
    @IBAction func btnAddNewAddressPressed(_ sender: UIButton) {
        
        //defaultDeliverySelection = false
        
       // _appDelegator.arrGiftCoupons = self.arrGiftCoupons
        
        let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddDeliveryAddressVC") as! AddDeliveryAddressVC
        controller.defaultAddressDelegate = self
        controller.isNoDeliveryAddress = isNoDeliveryAddress
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: getPickupAddress delegate
    
    func getPickupAddress(pickUpAddressObj: Address){
        
        print("pickUpAddressObj:\(pickUpAddressObj)")
        
        isPickup = true
        
        print("Total:\(totalOrder)")
        
        
        //defaultDeliverySelection = true
        
        let indexPath = NSIndexPath(row: 0, section: 2)
        
        let cell = tblAddress.cellForRow(at: indexPath as IndexPath) as! AddressCell
        
        pickUpAddressObject = pickUpAddressObj
        
        arrPickupTime.removeAll()
        
        arrPickupTime.append(pickUpAddressObject!)
        
        checkPickupSelection = true
        
        self.btnDeliveryAddressSelection(cell.btnPickupSeletion)
        
        currentOrder.price = totalOrder
        currentOrder.deliveryCharge = 0.0
        
        tblAddress.reloadData()
    }
    
   
    
    // MARK: getDeliveryAddress delegate
    
    func getDeliveryAddress(addressObj: Address){
        
         isPickup = false
        
        // defaultDeliverySelection = true
        
         print("Address:\(addressObj.name)")
        
         let indexPath = NSIndexPath(row: 0, section: 0)
        
         let cell = tblAddress.cellForRow(at: indexPath as IndexPath) as! AddressCell
        
         cell.btnDeliverySelection.isEnabled = true
        
         addressObject = addressObj
        
        if pickUpAddressObject != nil {
            
            pickUpAddressObject = nil
        }
       
        checkDeliverySelection = false
        
        isDeliverySelected = false
        
         self.btnDeliveryAddressSelection(cell.btnDeliverySelection)
        
         tblAddress.reloadData()
        
        // self.getShippingCharge()
        
        
    }
    
     // MARK: get default delivery address delegate
    
    func getDefaultAddress(addressObj: Address) {
        
       // defaultDeliverySelection = false
        
        let indexPath = NSIndexPath(row: 0, section: 0)
        
        let cell = tblAddress.cellForRow(at: indexPath as IndexPath) as! AddressCell
        
        cell.btnDeliverySelection.isEnabled = true
        
        addressObject = addressObj
        
        if pickUpAddressObject != nil {
            
            pickUpAddressObject = nil
        }
        
        checkDeliverySelection = true
        
        isDeliverySelected = false
        
        self.btnDeliveryAddressSelection(cell.btnDeliverySelection)
        
        tblAddress.reloadData()
        
    }
    
     //MARK: delivery address selection
    
    @IBAction func btnDeliveryAddressSelection(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            isPickup = false
           
            
            checkDeliverySelection = false
            
            checkPickupSelection = true
            
            
            
//            let indexPath1 = NSIndexPath(row: 0, section: 0)
//            
//            let indexPath2 = NSIndexPath(row: 0, section: 2)
            
//            tblAddress.reloadRows(at: [indexPath1 as IndexPath], with: .none)
//            
//            tblAddress.reloadRows(at: [indexPath2 as IndexPath], with: .none)
            
            if isDeliverySelected == true {
                
                
                if self.arrShippingCharge.count > 0 {
                    
                    let address = self.arrShippingCharge[selectedDelivery]
                    
                    currentOrder.deliveryCharge = Converter.toDouble(address.shippingCharge)
                }
                
                DispatchQueue.main.async(execute: {
                    self.tblAddress.reloadData()
                    
                });
                
                if sender.currentImage == UIImage(named:"ic_address_selected") {
                    
                    return
                }
            }else{
                isDeliverySelected = true
                self.getShippingCharge()
            }

            
            
            
        }else if sender.tag == 2{
            
            if checkPickupSelection {
                
                checkDeliverySelection = true
                
                checkPickupSelection = false
                
                let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "PickupAddressListVC") as! PickupAddressListVC
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
                return
            }
            
           /* checkDeliverySelection = true
            
            checkPickupSelection = false
            
            let indexPath1 = NSIndexPath(row: 0, section: 0)
            
            let indexPath2 = NSIndexPath(row: 0, section: 2)
            
            tblAddress.reloadRows(at: [indexPath1 as IndexPath], with: .none)
            
            tblAddress.reloadRows(at: [indexPath2 as IndexPath], with: .none)*/
            
          
        }else{
            
             sender.isSelected = !sender.isSelected
            
             if sender.isSelected == true {
                sender.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.selected)
                
             }else{
                 sender.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
            }
        }
        

    }
    
    //MARK: btn back button cliked
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        
        _appDelegator.arrGiftCoupons.removeAll()
        
       // currentOrder = Order()
        
       // currentOrder.displayPrice = totalOrder
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
            return 8
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if section == 3{
            
            if isPickup{
                
                return self.arrPickupTime.count
                
            }else{
                
                return self.arrShippingCharge.count
            }
            
            
        }
        
        return 1
    }
    
   
       
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 && addressObject == nil {
            
         return 0.00001
            
        }else if section == 3{
            
            if isPickup{
                
                if self.arrPickupTime.count == 0{
                 
                     return 0.00001
                }else{
                    
                    return 10
                }
                
                
            }else {
                
                if self.arrShippingCharge.count == 0{
                 
                    return 0.00001
                }else{
                    return 10
                }
                
                
            }
            
        }else if section == 3  && self.arrShippingCharge.count > 0 && checkPickupSelection == false{
            
            
            return 0.00001
            
        }else if section == 4  && loyaltyBalance == 0.0 {
            
            return 0.00001
            
        }else if section == 5  && walletBalance == 0.0 {
            
            return 0.00001
            
        }
        else if section == 6  &&  self.arrGiftCoupons.count == 0 {
            
            return 0.00001
            
        }else{
            
                return 10
          
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   
        if indexPath.section == 0 {
            
            if addressObject == nil {
                
                return 0
            }else{
               
                return UITableViewAutomaticDimension
            }
            
           
        }else if indexPath.section == 1{
            return 45*universalWidthRatio
        }else if indexPath.section == 2{
            return UITableViewAutomaticDimension
        }else if indexPath.section == 3{
            
            if isPickup {
                
                if self.arrPickupTime.count > 0 {
                    
                     return 70*universalWidthRatio
                }else{
                    return 0

                }
                
            }else{
                
                if self.arrShippingCharge.count > 0 && checkPickupSelection == true{
                    return 70*universalWidthRatio
                }else{
                    return 0
                }
            }
       
        }else if indexPath.section == 4{
            
            if loyaltyBalance == 0.0 {
                return 0
            }else{
                 return 55*universalWidthRatio
            }
        }else if indexPath.section == 5{
            if walletBalance == 0.0 {
                return 0
            }else{
                
                return 55*universalWidthRatio
            }
        }else if indexPath.section == 6{
            
            if self.arrGiftCoupons.count > 0 {
                
                 return 55*universalWidthRatio
            }else{
                
                 return 0
            }
            
           
        }
        else{
            return 70*universalWidthRatio
        }

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
         if indexPath.section == 3{
            
            if isPickup && self.arrPickupTime.count > 0{
                
                return 0
            }else{
                return 0
            }
            
         }else{
            
             return 111
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.section == 0 {
            let cellIdentifier = "DeliveryAddressCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            
            if addressObject == nil {
                
                cell.btnDeliverySelection.isHidden = true
                cell.btnDeliveryAddressDropDown.isHidden = true
                cell.lblTitle.isHidden = true
                cell.lblDtail.isHidden = true
                
                return cell
                
            }else{
                
                cell.btnDeliverySelection.isHidden = false
                cell.btnDeliveryAddressDropDown.isHidden = false
                cell.lblTitle.isHidden = false
                cell.lblDtail.isHidden = false
                
                if addressObject != nil {
                    
                    cell.lblTitle.text = addressObject?.name
                    
                    cell.lblDtail.text = addressObject?.fullAddress
                    
                    if checkPickupSelection == true {
                        
                        cell.btnDeliverySelection.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
                    }
                    
                    
                }
                
                if checkDeliverySelection == false {
                    
                    cell.btnDeliverySelection.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
                }else{
                    
                    
                     cell.btnDeliverySelection.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
                }
                
//                if defaultDeliverySelection {
//                    
//                    cell.btnDeliverySelection.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
//                }
                
                cell.btnDeliverySelection.tag = indexPath.section
                
                return cell
            }
            
           
            
        }else if indexPath.section == 1{
            let cellIdentifier = "AddNewAddressCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            cell.lblTitle.text = "ADD_DELIVERY_ADDRESS".localizedString()
            return cell
            
        }else if indexPath.section == 2{
            let cellIdentifier = "SelectPickUpAddressCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            
            
            
            if pickUpAddressObject != nil {
                
                if checkDeliverySelection == false {
                    cell.lblTitle.text = "SELECT_THE_STORE".localizedString()
                    
                    cell.lblDtail.text = ""
                }else{
                    
                    cell.lblTitle.text = pickUpAddressObject?.name
                    
                    cell.lblDtail.text = pickUpAddressObject?.fullAddress
                }
                
            }else{
                
                cell.lblTitle.text = "SELECT_THE_STORE".localizedString()
                
                 cell.lblDtail.text = ""
            }
            
            
            if checkPickupSelection == false {
                
                cell.btnPickupSeletion.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
            }else{
                
                cell.lblTitle.text = "SELECT_THE_STORE".localizedString()
                cell.btnPickupSeletion.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
            }
            
            cell.btnPickupSeletion.tag = indexPath.section
            return cell
            
        }else if indexPath.section == 3{
            
            
            var cellIdentifier = ""
            
            if isPickup {
                cellIdentifier = "EstimatedDeliveryTimeSingleCell"
            }else{
                
                if self.arrShippingCharge.count > 1 {
                    
                    cellIdentifier = "EstimatedDeliveryTimeCell"
                }else{
                    cellIdentifier = "EstimatedDeliveryTimeSingleCell"
                }
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeliveryChargeCell
            
            if isPickup {
                
                if self.arrPickupTime.count > 0 {
                    
                    
                    cell.lblDeliveryChargeRs.isHidden = true
                    cell.lblStaticDeliveryCharge.isHidden = true
                    cell.btnSelectTime.isHidden = true
                    cell.deliveyChargesWidhConst.constant = 15.0
                    cell.layer.cornerRadius = 8.0
                    cell.layer.masksToBounds = true
                    
                    let pickupTime = self.arrPickupTime[indexPath.row]
                    
                    cell.lblTitle.text = "Estimated pick up time"
                    
                    let dateF = DateFormatter()
                    dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    
                    if pickupTime.changePickUpDate == "" {
                        
                        let firstDate = dateF.date(from: pickupTime.pickupDate)
                        dateF.dateFormat = "dd MMM yyyy"
                        let newDateString = dateF.string(from: firstDate!)
                        cell.lblDtail.text = newDateString
                        
                    }else{
                        
//                        let firstDate = dateF.date(from: pickupTime.changePickUpDate)
//                        dateF.dateFormat = "dd MMM yyyy"
//                        let newDateString = dateF.string(from: firstDate!)
                        cell.lblDtail.text = pickupTime.changePickUpDate
                    }
                }
                
            }else{
                
                if self.arrShippingCharge.count > 0 {
                    
                    
                    cell.lblDeliveryChargeRs.isHidden = false
                    cell.lblStaticDeliveryCharge.isHidden = false
                    
                    let shippingCharge = self.arrShippingCharge[indexPath.row]
                    
                    if self.arrShippingCharge.count > 1 {
                        
                        
                        if indexPath.row == 0 {
                            let shape = CAShapeLayer()
                            
                            let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: ([.topLeft,.topRight]), cornerRadii: CGSize(width: 8.0, height: 8.0))

                            shape.frame = cell.bounds
                            shape.path = maskPath.cgPath
                            cell.layer.mask = shape
                            
                            cell.layoutIfNeeded()
                        }
                        
                        if indexPath.row == (self.arrShippingCharge.count-1) {
                            let shape = CAShapeLayer()
                            
                            let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: ([.bottomLeft,.bottomRight]), cornerRadii: CGSize(width: 8.0, height: 8.0))
                            shape.frame = cell.bounds
                            shape.path = maskPath.cgPath
                            cell.layer.mask = shape
                            
                            cell.layoutIfNeeded()
                        }
                        
                        cell.btnSelectTime.isHidden = false
                        cell.deliveyChargesWidhConst.constant = 40.0
                        
                        if selectedDelivery == indexPath.row {
                            
                            cell.btnSelectTime.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
                        }else{
                            
                            cell.btnSelectTime.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
                        }
                        
                    }else if (self.arrShippingCharge.count == 1){
                        cell.btnSelectTime.isHidden = true
                        cell.deliveyChargesWidhConst.constant = 15.0
                        cell.layer.cornerRadius = 8.0
                        cell.layer.masksToBounds = true
                    }
                    
                    if shippingCharge.shippingType == "Express" {
                        
                        cell.lblTitle.text = "Express delivery time"
                        
                    }else{
                        
                        cell.lblTitle.text = "Standard delivery time"
                        
                    }
                    
                    
                    if shippingCharge.changeExpectedShippingDate == "" {
                        
                        cell.lblDtail.text = shippingCharge.expectedShippingDate
                    }else{
                        cell.lblDtail.text = shippingCharge.changeExpectedShippingDate
                    }
                    
                    
                    if shippingCharge.shippingCharge == 0.0 {
                        cell.lblDeliveryChargeRs.text = "Free"
                    }else{
                        cell.lblDeliveryChargeRs.text = "₹ " + String(format: "%.f", shippingCharge.shippingCharge)
                    }
                    
                    
                    cell.btnSelectTime.tag = indexPath.row
                    
                    
                }
            }
          
           
            
            return cell
            
        }else if indexPath.section == 4{
            let cellIdentifier = "LoyaltyRewardsCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            
            
            if loyaltyBalance != 0.0 {
                
                cell.lblStaticLoyaltyRewards.isHidden = false
                cell.lblLoyaltyBalance.isHidden = false
                cell.txtLoyaltyBalance.isHidden = false
                cell.btnLoyaltyRewards.isHidden = false
                cell.lblLoyaltyView.isHidden = false
                
                if isCancelLoyaltyRewards{
                    
                    cell.txtLoyaltyBalance.text = "0"
                    cell.lblLoyaltyBalance.text = String(format: "%.f points", loyaltyBalance)
                    
                    cell.btnLoyaltyRewards.setTitle("Redeem", for: UIControlState.normal)
                    
                }else{
                    
                    cell.btnLoyaltyRewards.setTitle("Cancel", for: UIControlState.normal)
                    
                    if loyaltyBalance != 0.0{
                        
                        if cell.txtLoyaltyBalance.text == "" {
                            
                            cell.lblLoyaltyBalance.text = String(format: "%.f points", loyaltyBalance)
                            
                            cell.txtLoyaltyBalance.text = String(format: "%.f", loyaltyBalance)
                            
                            cell.cellLoyalityBalance = loyaltyBalance
                            
                        }
                        
                        if isCancelEnable{
                            
                            if isCancelLoyaltyRewards == false{
                                
                                cell.lblLoyaltyBalance.text = String(format: "%.f points", loyaltyBalance)
                                
                                cell.txtLoyaltyBalance.text = String(format: "%.f", loyaltyBalance)
                                
                                cell.cellLoyalityBalance = loyaltyBalance
                                
                            }
                            
                            isCancelEnable = false
                            
                        }
                        
                    }
                }
                
                cell.btnLoyaltyRewards.tag = indexPath.section
                return cell

            }else{
                
                cell.lblStaticLoyaltyRewards.isHidden = true
                cell.lblLoyaltyBalance.isHidden = true
                cell.txtLoyaltyBalance.isHidden = true
                cell.btnLoyaltyRewards.isHidden = true
                cell.lblLoyaltyView.isHidden = true
                
                return cell

                
            }
            
            
        }else if indexPath.section == 5{
            let cellIdentifier = "WalletCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            
            
            if walletBalance != 0.0 {
                
                cell.lblStaticWallets.isHidden = false
                cell.lblWalletRs.isHidden = false
                cell.txtWalletBalance.isHidden = false
                cell.btnWallets.isHidden = false
                cell.lblWalletView.isHidden = false
                
                cell.btnWallets.setTitle("Cancel", for: UIControlState.normal)
                
                cell.lblStaticWallets.text = "WALLETS".localizedString()
                
                if cell.walletChangeValue != 0 {
                    
                    if isWalletCancel {
                        
                        cell.txtWalletBalance.text = "0"
                        
                        cell.walletChangeValue = 0.0
                        
                        cell.btnWallets.isHidden = true
                        
                        finalWalletValue = 0.0

                        isWalletCancel = false
                        
                    }else{
                        
                        if isTextFieldEdit == false {
                            
                            if !isPickup {
                                
                                if Converter.toDouble(self.walletBalance) > totalOrder {
                                    
                                    if selectedDelivery != -1 {
                                        
                                        var netPrice: Double = totalOrder
                                        
                                        netPrice = netPrice + currentOrder.deliveryCharge
                                        
                                        cell.txtWalletBalance.text = String(format: "%.2f", netPrice)
                                        
                                        cell.walletChangeValue = Converter.toFloat(netPrice)
                                    }else{
                                        
                                        cell.txtWalletBalance.text = String(format: "%.2f", totalOrder)
                                        
                                        cell.walletChangeValue = Converter.toFloat(totalOrder)
                                    }
                                    
                                    finalWalletValue = cell.walletChangeValue
                                    
                                }else{
                                    
                                    cell.txtWalletBalance.text = String(format: "%.2f", cell.walletChangeValue)
                                    
                                    finalWalletValue = cell.walletChangeValue
                                    
                                }
                                
                                
                            }else{
                                
                                if Converter.toDouble(self.walletBalance) > totalOrder {
                                    
                                    cell.txtWalletBalance.text = String(format: "%.2f", totalOrder)
                                    
                                    cell.walletChangeValue = Converter.toFloat(totalOrder)
                                }else{
                                    cell.txtWalletBalance.text = String(format: "%.2f", walletBalance)
                                    
                                    cell.walletChangeValue = Converter.toFloat(walletBalance)
                                }
                                
                                 finalWalletValue = cell.walletChangeValue
                            }
                            
                            
                        }else{
                            cell.txtWalletBalance.text = String(format: "%.2f", cell.walletChangeValue)
                            
                            finalWalletValue = cell.walletChangeValue
                        }
                        
                        
                        
                    }
                    
                    
                }else{
                    
                    if isWalletCancel {
                        cell.txtWalletBalance.text = "0"
                        
                        cell.walletChangeValue = 0.0
                        
                        finalWalletValue = 0.0
                        
                        cell.cellWalltetRs = walletBalance
                        
                        cell.btnWallets.setTitle("", for: UIControlState.normal)
                        
                    }else{
                        
                        
                        if Converter.toDouble(self.walletBalance) > currentOrder.displayPrice {
                            
                            cell.walletChangeValue = Converter.toFloat(currentOrder.displayPrice)
                            
                        }else{
                            cell.walletChangeValue = self.walletBalance
                        }
                        
                        
                        cell.txtWalletBalance.text = String(format: "%.2f", cell.walletChangeValue)
                        
                        finalWalletValue = cell.walletChangeValue
                        
                        cell.cellWalltetRs = cell.walletChangeValue
                        
                        cell.btnWallets.setTitle("Cancel", for: UIControlState.normal)
                    }
                    
                    
                }
                
                 cell.lblWalletRs.text = String(format: "%@ %.f",RsSymbol, walletBalance)
                
                
                cell.btnWallets.tag = indexPath.section

            }else{
                
                cell.lblStaticWallets.isHidden = true
                cell.lblWalletRs.isHidden = true
                cell.txtWalletBalance.isHidden = true
                cell.btnWallets.isHidden = true
                cell.lblWalletView.isHidden = true
            }
            
            
            return cell
            
        }else if indexPath.section == 6{
            let cellIdentifier = "GiftCoupanCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            cell.txtGiftCoupanAmt.delegate = self
            
            
            if self.arrGiftCoupons.count > 0 {
                
                cell.lblStaticGiftCoupons.isHidden = false
                cell.btnGiftCoupan.isHidden = false
                cell.txtGiftCoupanAmt.isHidden = false
                cell.lblCouponView.isHidden = false
                
                if totalGiftCoupon != 0.0 {
                    
                    cell.txtGiftCoupanAmt.text = String(format: "%@ %.f",RsSymbol, totalGiftCoupon)
                    
                    
                }else{
                    
                    cell.txtGiftCoupanAmt.text = ""
                }
                
                cell.btnGiftCoupan.tag = indexPath.section
            }else{
                cell.lblStaticGiftCoupons.isHidden = true
                cell.btnGiftCoupan.isHidden = true
                cell.txtGiftCoupanAmt.isHidden = true
                cell.lblCouponView.isHidden = true
            }
            
            return cell
            
        }else{
            
            let cellIdentifier = "OrderSummeryCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddressCell
            
            cell.lblTitle.text = "ORDER_SUMMERY".localizedString()
            
            cell.lblDtail.text =  "ORDER_TOTAL".localizedString()
            
            cell.btnViewOrder.setTitle("VIEW_ORDER".localizedString(), for: UIControlState.normal)
            
            print("order display price:\(currentOrder.displayPrice)")
            
           
            if finalWalletValue == 0.0 {
                
                if isPickup {
                    
                    cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,totalOrder)
                }else{
                    cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                }
                
                
            }else{
                
                if isTextFieldEdit == false {
                    
                    var netPrice: Double = totalOrder
                    
                    netPrice = netPrice + currentOrder.deliveryCharge
                    
                    if Converter.toDouble(self.walletBalance) > netPrice {
                        
                        cell.lblOrderTotal.text = String(format: "%@ %@",RsSymbol,"0.00")
                    }else{
                        
                        if walletBalance != 0.0 {
                            
                            if isPickup {
                            cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,totalOrder-Converter.toDouble(walletBalance))
                            }else{
                            cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                            }
                            
                        }else{
                            cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                        }
                        
                        
                    }
                }else{
                    
                    if walletBalance != 0.0 {
                        
                        if isPickup {
                            
                            let posOrZero = max(currentOrder.displayPrice, 0)
                            
                            print("posOrZero:\(posOrZero)")
                            
                            if posOrZero == 0.0 {
                                cell.lblOrderTotal.text = String(format: "%@ %@",RsSymbol,"0.00")
                            }else{
                               cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,totalOrder-Converter.toDouble(finalWalletValue))
                            }
                            
                           
                        }else{

                            let posOrZero = max(currentOrder.displayPrice, 0)
                            
                            print("posOrZero:\(posOrZero)")
                            
                            if posOrZero == 0.0 {
                                cell.lblOrderTotal.text = String(format: "%@ %@",RsSymbol,"0.00")
                            }else{
                                 cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                            }
                            
                            
                        }
                    }else{
                       
                         cell.lblOrderTotal.text = String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                        
                    }
                    
                   
                }
            }
            
           
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if indexPath.section == 3 {
            
            
            if isPickup {
                
                pickupTimeAddress = self.arrPickupTime[indexPath.row]
                
                print("Select Pick up Time:\(String(describing: self.pickupTimeAddress?.changePickUpDate))")
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
               
                
                let pickTime:Date
                var currentDate = Date()
                
                if pickupTimeAddress?.changePickUpDate == "" {
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    pickTime = dateFormatter.date(from: ((pickupTimeAddress?.pickupDate))!)!
                    currentDate = dateFormatter.date(from: ((pickupTimeAddress?.pickupDate))!)!
                    
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                }else{
                    
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    pickTime = dateFormatter.date(from: ((pickupTimeAddress?.changePickUpDate))!)!
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    
                    
                }
                
                
                datepicker.minDate = currentDate
                datepicker.currentDate = pickTime
                datepicker.show()
                
                datepicker.dateSelectionBlock = { date in
                    
                    if  date > currentDate {
                        
                        print("selected date:\(date)")
                        dateFormatter.dateFormat = "dd MMM yyyy"
                        let changeDate = dateFormatter.string(from: date)
                        
                        print("selected firstDate:\(changeDate)")
                        
                        self.pickupTimeAddress?.changePickUpDate = changeDate
                        
                        self.tblAddress.reloadData()

                    }else{
                        
                        let dateF = DateFormatter()
                        dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let firstDate = dateF.date(from:  (self.pickupTimeAddress?.pickupDate)!)
                        dateF.dateFormat = "dd MMM yyyy"
                        let changeDate = dateF.string(from: firstDate!)
                        
                        self.pickupTimeAddress?.changePickUpDate = changeDate
                        
                        self.tblAddress.reloadData()

                    }
                    
                }

               
            }else{
                
                
                if self.arrShippingCharge.count > 0 && checkPickupSelection == true{
                    
                    shippingCharge = self.arrShippingCharge[indexPath.row]
                    
                    print("Select Shipping Charge Date:\(String(describing: shippingCharge?.expectedShippingDate))")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    
                    let shippingDate: Date?
                    
                    if  shippingCharge?.changeExpectedShippingDate == ""{
                        
                        shippingDate = dateFormatter.date(from: (shippingCharge?.expectedShippingDate)!)!
                        
                    }else{
                        shippingDate = dateFormatter.date(from: (shippingCharge?.changeExpectedShippingDate)!)!
                    }
                    
                    let currentDate = dateFormatter.date(from: (shippingCharge?.expectedShippingDate)!)!
                    
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    datepicker.minDate = currentDate
                    datepicker.currentDate = shippingDate
                    datepicker.show()
                    
                    datepicker.dateSelectionBlock = { date in
                        
                        if date >= currentDate {
                        
                            print("selected date:\(date)")
                            dateFormatter.dateFormat = "dd MMM yyyy"
                            let changeDate = dateFormatter.string(from: date)
                            
                            print("selected firstDate:\(changeDate)")
                            
                            self.shippingCharge?.changeExpectedShippingDate = changeDate
                            self.tblAddress.reloadData()

                        }else{
                            
                            self.shippingCharge?.changeExpectedShippingDate = (self.shippingCharge?.expectedShippingDate)!
                            self.tblAddress.reloadData()
                        }
                        
                        
                    }
                                        
                }
            }
            
            
            
        }else if indexPath.section == 1{
            
            let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "AddDeliveryAddressVC") as! AddDeliveryAddressVC
            controller.defaultAddressDelegate = self
            controller.isNoDeliveryAddress = isNoDeliveryAddress
            self.present(controller, animated: true, completion: nil)
            
        }else if indexPath.section == 0 && addressObject != nil{
            
            if isTextFieldEdit {
                
                isTextFieldEdit = false
            }
            
            let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DeliveryAddressLIstVC") as! DeliveryAddressLIstVC
            controller.delegateDelivery = self
            controller.arrDeliveryAddress = arrDeliveryAddress
            controller.isScreen = "addresslist"
            controller.isNoDeliveryAddress = isNoDeliveryAddress
            self.present(controller, animated: true, completion: nil)
            
        }else if indexPath.section == 2{
            
            let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PickupAddressListVC") as! PickupAddressListVC
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)

        }
        
    }
    
    
    
    
   // MARK: btn Loyalty Cancel
    
    @IBAction func btnCancelCliked(_ sender: UIButton) {
        
        isCancelEnable = true
        
         if sender.titleLabel?.text == "Cancel"{
            
            isCancelLoyaltyRewards = true
            
         }else{
            isCancelLoyaltyRewards = false
        }
        
        self.tblAddress.reloadData()
        
//        let indexPath = NSIndexPath(row: 0, section: 4)
//        
//        tblAddress.reloadRows(at: [indexPath as IndexPath], with: .none)
        
    }
    
     // MARK: btn Wallet clicked
    
    
    @IBAction func btnWalletClicked(_ sender: UIButton) {
        
        
        //totalOrder = Cart.shared.totalCartAmount.rounded()
        
        finalWalletValue = 0.0
        
        isWalletCancel = true
        
        self.tblAddress.reloadData()

        
    }
    
    // MARK: btn select deleivery time
    
    @IBAction func btnSelectDeliveryTime(_ sender: UIButton) {
        
        selectedDelivery = sender.tag  // 0 = standart delivery , 1 = express delivery
        
        tblAddress.reloadData()
        
        
    }
    
      // MARK: btn view coupon
    
    @IBAction func btnViewCouponClicked(_ sender: UIButton) {
        
        let GiftCouponVC = storyboardShoppingCart.instantiateViewController(withIdentifier: "GiftCouponVC") as! GiftCouponVC
        GiftCouponVC.modalPresentationStyle = .overFullScreen
        GiftCouponVC.arrGiftCoupons = arrGiftCoupons
        GiftCouponVC.totalGiftCoupon = totalGiftCoupon
        GiftCouponVC.couponDelegate = self;
        self.present(GiftCouponVC, animated: false, completion: nil)
 
    }
    
    // MARK: apply coupon delegate
    
    func applyCoupon(totalCouponPrice: Float) {
        
        print("arrGiftCoupons:\(self.arrGiftCoupons)")
        
        totalGiftCoupon = totalCouponPrice
        
        isGiftCoupon = true
        
         self.arrGiftCoupons = _appDelegator.arrGiftCoupons
        
        print("_appDelegator.arrGiftCoupons 1:\(_appDelegator.arrGiftCoupons[0].isActive)")
        print("_appDelegator.arrGiftCoupons 2:\(_appDelegator.arrGiftCoupons[1].isActive)")
        print("_appDelegator.arrGiftCoupons 2:\(_appDelegator.arrGiftCoupons[2].isActive)")
        
        
        DispatchQueue.main.async(execute: {
            self.tblAddress.reloadData()
        });
        
        
    }
    
    // MARK: clear all coupon delegate
    
    func clearAllCoupon() {
        
        totalGiftCoupon = 0.0
        
        DispatchQueue.main.async(execute: {
            self.tblAddress.reloadData()
        });

    }
    
    
    @IBAction func btnViewOrderClicked(_ sender: UIButton) {
        
        _appDelegator.isViewOrder = true
        
        if isTextFieldEdit {
            
            if finalWalletValue != 0.0 {
                
                _appDelegator.isTextFieldInput = isTextFieldEdit
            }
            
            
            
           // isTextFieldEdit = false
        }
        
        self.currentOrderRequestParameter()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("begin:")
        
        isTextFieldEdit = true
        
        isWalletCancel = false
        
        let indexPath = NSIndexPath(row: 0, section: 5)
        
        let indexPath1 = NSIndexPath(row: 0, section: 7)
        
        let cell = self.tblAddress.cellForRow(at: indexPath as IndexPath) as! AddressCell
        
        let cell1 = self.tblAddress.cellForRow(at: indexPath1 as IndexPath) as? AddressCell
        
        if(cell.txtWalletBalance != nil){
            
            if(textField == cell.txtWalletBalance){
                                
                cell.walletChangeValue = 0.0
                
                finalWalletValue = 0.0
                
                if cell1?.lblOrderTotal != nil {
                    
                    if isPickup {
                        cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,totalOrder)
                        currentOrder.price = totalOrder
                    }else{
                        cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                    }
                    
                    
                    
                }
                
                cell.txtWalletBalance.text = ""
                
                cell.btnWallets.isHidden = true
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        let indexPath = NSIndexPath(row: 0, section: 5) //wallet
        
        let cell = self.tblAddress.cellForRow(at: indexPath as IndexPath) as? AddressCell
        
        let indexPath1 = NSIndexPath(row: 0, section: 7) // order summary
        
        let cell1 = self.tblAddress.cellForRow(at: indexPath1 as IndexPath) as? AddressCell
        
        if newText != "" {
          
            
            if(cell?.txtWalletBalance != nil){
                
                if(textField == cell?.txtWalletBalance){
                    
                    if Int(newText) == 0 {
                        
                        return false
                    }
                    
                   let arrCharacterCount = newText.components(separatedBy: ".")
                    
                    if arrCharacterCount.count >= 2 {
                        
                        let strCharcter = arrCharacterCount[1]
                        
                        if strCharcter.characters.count > 2 {
                            
                            return false
                        }
                    }
                    
                    if Converter.toDouble(self.walletBalance) > totalOrder {
                        
                        cell?.cellWalltetRs = Converter.toFloat(totalOrder)
                        
                    }
                    
                    if let intValue = Float(newText), intValue <= Float((cell?.cellWalltetRs)!){
                        
                        cell?.btnWallets.isHidden = false
                        
                        cell?.btnWallets.setTitle("Cancel", for: UIControlState.normal)
                        
                        cell?.walletChangeValue = Converter.toFloat(newText)
                        
                        finalWalletValue = Float(Converter.toDouble(cell?.walletChangeValue))
                        
                        if cell1?.lblOrderTotal != nil {
                            if isPickup {
                                currentOrder.price = totalOrder
                                currentOrder.deliveryCharge = 0.0
                                cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                            }else{
                                cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                            }
                        }
            
                        
                        return true
                    }
                }
                
            }
                
             return false
            
           
            
        }else{
            
            
            if(cell?.txtWalletBalance != nil){
                
                if(textField == cell?.txtWalletBalance){
                    
                        cell?.btnWallets.isHidden = true
                    
                        cell?.btnWallets.setTitle("Cancel", for: UIControlState.normal)
                        
                        cell?.walletChangeValue = Converter.toFloat(textField)
                    
                        finalWalletValue = Float(Converter.toDouble(cell?.walletChangeValue))
                        
                        if cell1?.lblOrderTotal != nil {
                            if isPickup {
                                currentOrder.price = totalOrder
                                 currentOrder.deliveryCharge = 0.0
                                cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                               // currentOrder.price = totalOrder
                            }else{
                            cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,currentOrder.displayPrice)
                            }
                            
                            
                        }
                        
                        
                        return true
                }
                
            }
            
            return false

        }
        
    }
    
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }

    
    
}


extension addressVC: UIKeyboardObserver{
    
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tblAddress.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tblAddress.contentInset = UIEdgeInsets(top: 18, left: 0, bottom: 15, right: 0)
    }
    
    func getDeliveryAddress(){
        
         self.showCentralGraySpinner()
        
        let param = ["AddressId":"0"]
        
        wsCall.getDeliveryAddress(params: param) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    print("Address response is => \(json)")
                    
                    self.arrDeliveryAddress.removeAll()
                    
                    self.arrDefaultDeliveryAddress.removeAll()
                    
                    self.arrDeliveryAddress = json.map({ (object) -> Address in
                        
                        return Address(forDelivery : object)
                        
                    })
                    
                    
                    self.arrDefaultDeliveryAddress = json.map({ (object) -> Address in
                        
                        return Address(forDelivery : object)
                        
                    }).filter({ (po) -> Bool in
                        
                        return po.isDefault
                        
                    })
                    
                    if (self.arrDefaultDeliveryAddress.count != 0){
                        
                        if self.addressObject == nil{
                            self.addressObject = self.arrDefaultDeliveryAddress[0]
                            self.checkDeliverySelection = false
                            self.getShippingCharge()
                        }
                        
                    }else if(self.arrDeliveryAddress.count > 0){
                        
                        if self.addressObject == nil{
                        self.addressObject = self.arrDeliveryAddress[0]
                            self.checkDeliverySelection = false
                            self.getShippingCharge()
                        }
                        
                    }else if(self.arrDeliveryAddress.count == 0){
                        
                        self.addressObject = nil
                        self.isNoDeliveryAddress = true
                        
                    }else{
                        
                    }
                    
                    self.tblAddress.isHidden = false
                    self.tblAddress.reloadData()
                    
                 
                }
            }else{
                
                let code = response.code
                
                if(code == 400){
                    
                    if let json = response.json as? [String:Any] {
                        
                        KVAlertView.show(message: json["message"] as! String)
                    }
                }
                
            }
            
            self.hideCentralGraySpinner()
        }
    }
    
    
    func getCustomerBalance(){
        
        self.showCentralGraySpinner()
        
        wsCall.getCustomerBalance(params: nil) { (response) in
            if response.isSuccess {
                if let json = response.json as? [String:Any] {
                    
                    self.hideCentralGraySpinner()
                    
                    print("customer balance response is => \(json)")
                    
                     let customerBalance =  CustomerBalance(json: json)
                    
                  /*  self.loyaltyBalance = Converter.toFloat(customerBalance.loyaltyBalance)
                    
                    if(self.loyaltyBalance != 0.0){
                        
                        let netcartAmt:Float = Converter.toFloat(self.strNetCartAmount)
                        
                        if self.loyaltyBalance <= netcartAmt{
                            
                            
                        }else{
                            
                            self.loyaltyBalance = netcartAmt
                        }

                    }*/
                    
                    self.walletBalance =  Converter.toFloat(customerBalance.walletBalance)
                    
//                    if(self.walletBalance != 0.0){
//                        
//                        if self.arrShippingCharge.count > 0{
//                            
//                            let shippingCharge = self.arrShippingCharge[self.selectedDelivery]
//                            
//                             if shippingCharge.shippingCharge == 0.0 {
//                                
//                                self.walletBalance = self.walletBalance + shippingCharge.shippingCharge
//                                
//                                currentOrder.displayPrice = currentOrder.displayPrice +  shippingCharge.shippingCharge
//                                
//                            }
//                            
//                        }
//                        
//                    }
                    
                    
                   /* if(self.walletBalance != 0.0){
                        
                        let indexPath = NSIndexPath(row: 0, section: 5)
                        
                        let indexPath1 = NSIndexPath(row: 0, section: 7)
                        
                        let cell = self.tblAddress.cellForRow(at: indexPath as IndexPath) as? AddressCell
                        
                        let cell1 = self.tblAddress.cellForRow(at: indexPath1 as IndexPath) as? AddressCell
                        
                        if(cell?.txtWalletBalance != nil){
                            
                            cell?.btnWallets.isHidden = false
                            
                            cell?.btnWallets.setTitle("Cancel", for: UIControlState.normal)
                            
                            if Converter.toDouble(self.walletBalance) > self.totalOrder {
                                
                                cell?.walletChangeValue = Converter.toFloat(self.totalOrder)
                                
                            }else{
                                cell?.walletChangeValue = self.walletBalance
                            }
                            
                            self.finalWalletValue = Float(Converter.toDouble(cell?.walletChangeValue))
                            
                            if cell1?.lblOrderTotal != nil {
                                
                                cell1?.lblOrderTotal.text =  String(format: "%@ %.2f",RsSymbol,self.currentOrder.displayPrice)
                                
                            }

                        }
                    }*/
                    
                  /*  if(self.walletBalance != 0.0){
                        
                        self.isRedeemWallets = true
                        
                        let netcartAmt:Float = Converter.toFloat(self.strNetCartAmount)
                        
                        if self.walletBalance <= (netcartAmt - self.loyaltyBalance) {
                            
                            
                        }else if self.walletBalance > (netcartAmt - self.loyaltyBalance){
                            
                            self.walletBalance = netcartAmt - self.loyaltyBalance
                        }

                        
                    }*/
                    
                   /* if(customerBalance.giftCouponList.count > 0){
                        
                    self.arrGiftCoupons = customerBalance.giftCouponList
                        
                        
                    } */
                    
                    DispatchQueue.main.async(execute: {
                        self.tblAddress.reloadData()
                    });
                    
                   
                    
                }
            }else{
                
                let code = response.code
                
                self.hideCentralGraySpinner()
                
                if(code == 400){
                   
                    if let json = response.json as? [String:Any] {
                        
                        KVAlertView.show(message: json["message"] as! String)
                    }
                    
                }
                
                
            }
            
        }
    }
    
    func getShippingCharge()  {
        
        self.showCentralGraySpinner()
        
        if let address = addressObject {
            let pin = address.pincode
            
             let param = ["Pincode":pin]
            
            wsCall.getShippingCharge(params: param) { (response) in
                if response.isSuccess {
                    if let json = response.json as? [[String:Any]] {
                        
                        self.hideCentralGraySpinner()
                        
                        print("Delivery Charge response is => \(json)")
                        
                        self.arrShippingCharge = json.map({ (object) -> ShippingCharge in
                            
                            return ShippingCharge(json: object)
                        })
                        
                        if(self.arrShippingCharge.count > 0){
                            
                            self.selectedDelivery = 0
                            
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.tblAddress.reloadData()

                        });
                        
                        
                    }
                }else{
                    
                    let code = response.code
                    
                    self.hideCentralGraySpinner()
                    
                    if(code == 400){
                        
                        self.arrShippingCharge.removeAll()
                        
                        self.selectedDelivery = -1
                        
                        if let json = response.json as? [String:Any] {
                            
                            KVAlertView.show(message: json["message"] as! String)
                        }
                        
                        
                        DispatchQueue.main.async(execute: {
                            self.tblAddress.reloadData()
                        });
                    }
                    
                    
                }
                
            }

        }
        
    }

    
}

class DeliveryChargeCell: UITableViewCell{
    
    @IBOutlet weak var lblTitle: WidthLabel!
    
    @IBOutlet weak var lblDtail: WidthLabel!
    
    @IBOutlet weak var lblDeliveryChargeRs: WidthLabel!
    
    @IBOutlet weak var btnSelectTime: UIButton!
    
    @IBOutlet weak var lblStaticDeliveryCharge:  WidthLabel!
    
    @IBOutlet weak var deliveyChargesWidhConst: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.drawShadow(0.05)
        
    }

}


class AddressCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: WidthLabel!
    
    @IBOutlet weak var lblDtail: WidthLabel!
    
    @IBOutlet weak var btnDeliverySelection: UIButton!
    
    @IBOutlet weak var btnPickupSeletion: UIButton!
    
    @IBOutlet weak var btnLoyaltyRewards: UIButton!
    
    @IBOutlet weak var btnWallets: UIButton!
    
    @IBOutlet weak var btnGiftCoupan: UIButton!
    
    @IBOutlet weak var txtGiftCoupanAmt: WidthTextField!
    
    @IBOutlet weak var btnGiftCoupanApply: UIButton!
    
    @IBOutlet weak var btnDeliveryAddressDropDown: UIButton!
    
    @IBOutlet weak var txtLoyaltyBalance: WidthTextField!
    
    @IBOutlet weak var lblLoyaltyBalance: WidthLabel!
    
    @IBOutlet weak var txtWalletBalance: WalletsTextFiled!
    
    @IBOutlet weak var lblWalletRs: WidthLabel!
    
    var cellLoyalityBalance: Float = 0.0
    
    var cellWalltetRs: Float = 0.0
    
    var walletChangeValue:Float = 0.0
    
    @IBOutlet weak var lblOrderTotal: WidthLabel!
    
    @IBOutlet weak var lblStaticLoyaltyRewards: WidthLabel!
    
    @IBOutlet weak var lblStaticWallets: WidthLabel!
    
    @IBOutlet weak var lblStaticGiftCoupons: WidthLabel!
    
    @IBOutlet weak var lblLoyaltyView: UILabel!
    
    @IBOutlet weak var lblWalletView: UILabel!
    
    @IBOutlet weak var lblCouponView: UILabel!
    
    @IBOutlet weak var btnViewOrder: WidthButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
        self.drawShadow(0.05)
        
//        if txtWalletBalance != nil {
//            
//            let addressVCObj: addressVC = addressVC()
//            
//            if addressVCObj.walletBalance != 0.0{
//                
//                walletChangeValue = addressVCObj.walletBalance
//                
////                if Converter.toDouble(addressVCObj.walletBalance) > addressVCObj.totalOrder {
////                    
////                    cellWalltetRs = Converter.toFloat(addressVCObj.totalOrder)
////                    
////                }
//            }
//            
//        }
        
        
    }
    
    var walletType: WalletsFieldType = .wallets {
        didSet {
            txtWalletBalance.type = walletType
        }
    }
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("begin:")
        
        if(txtWalletBalance != nil){
            
             if(textField == txtWalletBalance){
                
                txtWalletBalance.text = ""
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        if newText != "" {
            
            if txtLoyaltyBalance != nil {
                
                if textField ==  txtLoyaltyBalance{
                    
                    if Int(newText) == 0 {
                        
                        return false
                    }
                    
                    if let intValue = Int(newText), intValue <= Int(cellLoyalityBalance){
                        
                        btnLoyaltyRewards.setTitle("Redeem", for: UIControlState.normal)
                        
                        return true
                    }
                    
                }
            }else if(txtWalletBalance != nil){
                
                if(textField == txtWalletBalance){
                    
                    if Int(newText) == 0 {
                        
                        return false
                    }
                    
                    if let intValue = Int(newText), intValue <= Int(cellWalltetRs){
                        
                        btnWallets.setTitle("Cancel", for: UIControlState.normal)
                        
                        walletChangeValue = Converter.toFloat(newText)
                        
                        totalOrder = Cart.shared.totalCartAmount.rounded()
                        
                        totalOrder = totalOrder - Converter.toDouble(walletChangeValue)
                    
                        
//                        if lblOrderTotal != nil {
//                            
//                             lblOrderTotal.text =  String(format: "%@ %@",RsSymbol,totalOrder.ToString())
//                            
//                            
//                        }
                       

                        return true
                    }
            }
            
        }
            
            return false
            
        }else{
            
            return true
        }
       
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }*/
    
   
    
    // MARK: btn Gift Coupan apply cliked
    
    @IBAction func btnApplyGiftCopon(_ sender: UIButton) {
        
        var  offerCodeApiParam: [String: Any]{
            
            return["Offercode":txtGiftCoupanAmt.text!,
                   "Productid":0,
                   "Qty":2]
        }
        
        wsCall.applyGiftCoupon(params: offerCodeApiParam) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [String:Any] {
                    
                    print("Address response is => \(json)")
                    
                    
                    
                    
                    
                }
            }
            
        }
        
         print("gift coupon amt:\(txtGiftCoupanAmt.text!)")
        
    }

}



extension addressVC {
    
    
     // MARK: Payment Clicked
    
    @IBAction func btnMakePaymentClicked(_ sender: UIButton) {
        
//        if addressObject == nil && pickUpAddressObject == nil {
//            KVAlertView.show(message:"SELECT_DELIVERY_OR_PICKUP_ADDRESS".localizedString())
//            return
//            
//        }else if checkDeliverySelection == false && selectedDelivery == -1 {
//            
//            KVAlertView.show(message:"DELIVERY_IS_NOT_AVAILABLE".localizedString())
//            return
//        }else{
        
            if checkDeliverySelection == false && selectedDelivery == -1 {
            
                KVAlertView.show(message:"DELIVERY_IS_NOT_AVAILABLE".localizedString())
                return
            }
        
        
            self.currentOrderRequestParameter()
        
        
            print("Total:\(totalOrder)")
        
            print("Wallet price:\(finalWalletValue)")
       
        
        if currentOrder.branchId != 0  || currentOrder.shippingAddress != "" {  // address is selected then open payment screen
            
            if currentOrder.shippingAddress != "" && self.arrShippingCharge.count == 0  && currentOrder.branchId == 0{
                
            }
            else{
                 print("current order display price:\(currentOrder.displayPrice)")
                defaultDeliverySelection = false
                let paymentvc = storyboardProductList.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
                paymentvc.currentOrder = self.currentOrder
                self.navigationController?.pushViewController(paymentvc, animated: true)
            }
            
        }
        else{
            KVAlertView.show(message:"SELECT_DELIVERY_OR_PICKUP_ADDRESS".localizedString())
            return
        }
        
       
        
    }
    
    
    // MARK: current order api request parameter
    
    func currentOrderRequestParameter(){
        
        if checkPickupSelection == false{ //pick up
            
            print("pick up address selected.\(String(describing: pickUpAddressObject))")
            currentOrder.isDeliveryPickup = false
            currentOrder.branchId = Converter.toInt(pickUpAddressObject?.id)
            currentOrder.selectedAddress = pickUpAddressObject!
            currentOrder.addressname = (pickUpAddressObject?.name)!
            
            let pickupTime = self.arrPickupTime[0]
            
            if pickupTime.changePickUpDate != ""  {
                
                currentOrder.deliveryPickupDate = pickupTime.changePickUpDate
                
            }else{
                
                let dateF = DateFormatter()
                dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let firstDate = dateF.date(from: pickupTime.pickupDate)
                dateF.dateFormat = "dd MMM yyyy"
                let newDateString = dateF.string(from: firstDate!)
                currentOrder.deliveryPickupDate = newDateString
            }
        }
        
        if checkDeliverySelection == false{  //delivery
            
            print("delivery address selected.\(String(describing: addressObject))")
            currentOrder.isDeliveryPickup = true
            currentOrder.branchId = 0
            currentOrder.shippingAddress = (addressObject?.address)!
            currentOrder.shippingCity = (addressObject?.city)!
            currentOrder.shippingEmail = (addressObject?.email)!
            currentOrder.shippingState = (addressObject?.state)!
            currentOrder.shippingPincode = (addressObject?.pincode)!
            currentOrder.shippingFullname = (addressObject?.fullAddress)!
            currentOrder.shippingContactNo = (addressObject?.contactNo)!
            
            currentOrder.selectedAddress = addressObject!
            currentOrder.addressname = dictUser.name
            
            if selectedDelivery != -1 && self.arrShippingCharge.count > 0 {
                let shippingCharge = self.arrShippingCharge[selectedDelivery]
                
                if shippingCharge.changeExpectedShippingDate != "" { //expected date is changed by user
                    
                    currentOrder.deliveryPickupDate = shippingCharge.changeExpectedShippingDate
                }else{
                    currentOrder.deliveryPickupDate = shippingCharge.expectedShippingDate
                }
                currentOrder.deliveryCharge = Double(shippingCharge.shippingCharge)
                print("shippingCharge :\(selectedDelivery)")
            }
            
            
            
            
        }
        
        
        currentOrder.selectedOrderDelivery = selectedDelivery
        
        currentOrder.arrOrderShippingCharge = arrShippingCharge
        
        currentOrder.deliveryAddress = addressObject
        
        currentOrder.pickupAddress = pickUpAddressObject
        
        let indexPath = NSIndexPath(row: 0, section: 5) //wallet
        
        let cell = self.tblAddress.cellForRow(at: indexPath as IndexPath) as? AddressCell
        
        if cell?.txtWalletBalance.text != nil || cell?.txtWalletBalance.text != "" {
            
            print("txtWalletBalance\(String(describing: cell?.txtWalletBalance.text))")
            
            if cell?.txtWalletBalance.text != "" {
                
                 currentOrder.usedWalletBalance = Converter.toFloat(cell?.txtWalletBalance.text)
            }else{
                currentOrder.usedWalletBalance = -1

            }
            
        }
        
        currentOrder.totalWalletBalance = walletBalance

        
    }
   
}

enum WalletsFieldType {
    case wallets
}


class WalletsTextFiled: WidthTextField {
    
    var type = WalletsFieldType.wallets
}
