//
//  PaymentVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 7/21/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

let kPaymentCellReuse = "paymentcell"



//let paymentOptions = [paymentOption.init(["name":"OPTIONS1".localizedString()]),paymentOption.init(["name":"OPTIONS2".localizedString()]),paymentOption.init(["name":"OPTIONS3".localizedString()]),paymentOption.init(["name":"OPTIONS4".localizedString()])]

//let paymentOptions = [ paymentOption.init(["name":"OPTIONS1".localizedString()]),paymentOption.init(["name":"OPTIONS4".localizedString()])]





enum paymentType {
    static var cashondelivery:String {return "cod"}
    static var card:String {return "cc"}
    static var netbanking: String {return "Online"}
    static var paytmwallet:String {return "ppi"}
    
}
enum paymentStatus{
    
    static var Pending:String {return "52"}
    static var Completed:String {return "53"}
    static var Fail:String {return "54"}
    
}

class paymentOption {
    var name = ""
    var isSelected = false
    
    init(_ optionDictionary: [String : Any]) {
        name = Converter.toString(optionDictionary["name"])
        isSelected = Converter.toBool(optionDictionary["isSelected"])
    }
}


class PaymentVC: ParentViewController , PGTransactionDelegate {
    
    @IBOutlet weak var paymentOptionCollection: UICollectionView!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var btnCancelOrder: UIButton!
    
    @IBOutlet weak var lblPaymentOptions: Style1WidthLabel!
    
    
    var cartModel = CartViewModel()
    
    //it is used for placeorder - current order
    var currentOrder = Order()
    var orderPlaceTask: URLSessionTask?
    let queue = DispatchQueue.global(qos: .default)
    var placeOrderResponse = [String : Any]()
    var paymentOptions = [paymentOption]()
    var preOrderSummaries = [PreOrderAmountSummary]()
    
    var OrderPrice: Double = 0.0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OrderPrice = currentOrder.price
        
        // Do any additional setup after loading the view.
        self.navigationBarView.drawShadow()
        // self.tabBarController?.tabBar.isHidden = true
        
        //localization
        self.lblTitle.text = "PAYMENTTITLE".localizedString()
        self.btnPay.setTitle("PAYBUTTONTITLE".localizedString(), for: .normal)
        
        /*********** title need to change in string file *************/
        // self.btnCancelOrder.setTitle("CANCELORDERTITLE".localizedString(), for: .normal)
        
        if FirRCManager.shared.isCODavailable {
            paymentOptions.append(paymentOption.init(["name":"OPTIONS1".localizedString(),"isSelected" : true]))
        }
        if FirRCManager.shared.isPayTMavailable {
            paymentOptions.append(paymentOption.init(["name":"OPTIONS4".localizedString()]))
        }
        
        //be default show first option selected if COD is not in available
        let selectedOptions = paymentOptions.filter({$0.isSelected})
        if selectedOptions.isEmpty {
            paymentOptions[0].isSelected = true
        }
        
        
        
        getPreOrderSummay()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        _appDelegator.isBackToAddressScreen = true
        
        currentOrder.price = OrderPrice
        
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension PaymentVC : UITableViewDataSource, UITableViewDelegate{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var noofrow = 0
        if tableView.tag == 1000{
            noofrow = preOrderSummaries.count
        }
        else{
            noofrow = paymentOptions.count
        }
        return noofrow
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        if tableView.tag == 1000{
            //summaryCell
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "presummaryCell", for: indexPath) as! PreOrderSummaryCell
            
            let summary = preOrderSummaries[indexPath.row]
            cell.titleLabel.text =  summary.title
            cell.amountLabel.text = String(format: "%@ %.2f",RsSymbol,summary.value)
            
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentcell", for: indexPath) as! PaymentCell
            cell.selectionStyle = . none
            let option =  paymentOptions[indexPath.row]
            cell.namelabel.text = option.name
            
            if option.isSelected{
                cell.selectionImage.image = #imageLiteral(resourceName: "selectedoption")
                
            }
            else{
                cell.selectionImage.image = #imageLiteral(resourceName: "round")
                
            }
            return cell
            
        }
        
        
        
        
        
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView.tag != 1000{
            //make all option un selected
            if  paymentOptions[indexPath.row].isSelected == true{
                paymentOptions[indexPath.row].isSelected = false
            }
            else{
                let selectedOptions = paymentOptions.filter({$0.isSelected})
                if !selectedOptions.isEmpty {
                    selectedOptions[0].isSelected = false
                }
                
                paymentOptions[indexPath.row].isSelected = true
            }
            
            
            tableView.reloadData()
        }
        
    }
    
    
}
extension PaymentVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let noofiteam = 3
        return noofiteam
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 { //reload table
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "tablecell", for: indexPath as IndexPath) as! CollectionViewCell
            (cell.viewWithTag(100) as! UITableView).reloadData()
            return cell
        }
        else if indexPath.row == 1{
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCell", for: indexPath as IndexPath) as! CollectionViewCell
            let commentlabel = cell.viewWithTag(100) as! UILabel
            commentlabel.text = "USERCOMMENT".localizedString()
            return cell
        }
        else{  //order summary
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath as IndexPath) as! summaryCell
            //            let totalOrder = Cart.shared.totalCartAmount.rounded()
            //             cell.totalLabel.text = String(format: "%@ %.2f",RsSymbol, currentOrder.displayPrice)
            
            
            (cell.viewWithTag(1000) as! UITableView).reloadData()
            return cell    // Create UICollectionViewCell
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        var cellHeight =  50
        if(indexPath.row == 0){ //table view
            cellHeight = (paymentOptions.count * 44)
        }
        else if  indexPath.row == 1 {  //user comment
            cellHeight = 97
        }
        else{
            var hh = 40.0
            if IS_IPAD {
                hh = Double((CGFloat(hh) * universalWidthRatio) + CGFloat( 5.0))
            }
            cellHeight = Int(Double(preOrderSummaries.count * 27) + hh)
        }
        
        return CGSize(width: cellWidth , height:CGFloat(cellHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
}
extension PaymentVC {
    func showThankyou()  {
        
        //olde thank you screen
        /* let vc = storyboardProductList.instantiateViewController(withIdentifier: "ThankyouVC") as! ThankyouVC
         vc.placeOrderResponse = placeOrderResponse
         self.navigationController?.pushViewController(vc, animated: true)*/
        
        //new thankyou screen - NewThankyouVC
        let vc = storyboardProductList.instantiateViewController(withIdentifier: "NewThankyouVC") as! NewThankyouVC
        vc.placeOrderResponse = placeOrderResponse
        vc.currentOrder = currentOrder
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func configurePaymentType(option : paymentOption) -> String {
        
        if option.name != "OPTIONS1".localizedString() { // not COD or cash on delivery
            if currentOrder.price == 0.0 {
                currentOrder.paymentGateway = "COD"
                currentOrder.paymentStatus = 53 //completed
            }
            else{
                currentOrder.paymentGateway = "PayTM"
                currentOrder.paymentStatus = 52 //pending
                
            }
        }
        else{
            currentOrder.paymentGateway = "COD"
            currentOrder.paymentStatus = 53 //completed
        }
        
        var paymenttype = paymentType.cashondelivery
        switch option.name {
        case "OPTIONS1":
            paymenttype = paymentType.cashondelivery
        case "OPTIONS2":
            paymenttype = paymentType.card
        case "OPTIONS3":
            paymenttype = paymentType.netbanking
        case "OPTIONS4":
            paymenttype = paymentType.paytmwallet
            
        default:
            paymenttype = paymentType.cashondelivery
        }
        
        return paymenttype
        
    }
    
    @IBAction func btnPayClicked(_ sender: UIButton) {
        
        let selectedOptions = paymentOptions.filter({$0.isSelected})
        if !selectedOptions.isEmpty{
            
            
            //1: set payment gateway info..
            currentOrder.paymentType = configurePaymentType(option: selectedOptions[0] )
            
            //2: call place order API
            placeOrder(params: currentOrder.convertOrderIntoDictionary(), completion: { (sucess) in
                
                //self.clearCart(isNavigate: false)
                
                if selectedOptions[0].name != "OPTIONS1".localizedString() && self.currentOrder.price != 0.0 { // not COD or cash on delivery
                    self.showPayTMController(orderID: "1001101", amount:Converter.toString(self.currentOrder.price))
                }
                else{  // COD
                    self.showThankyou()
                }
            })
            
        }
        else{
            KVAlertView.show(message: "NO_OPTION_MSG".localizedString())
        }
        
        
        /* let selectedOptions = paymentOptions.filter({$0.isSelected})
         if !selectedOptions.isEmpty{
         if selectedOptions[0].name != "OPTIONS1".localizedString() { // not COD or cash on delivery
         showPayTMController(orderID: "1001101", amount: "1")
         }
         else{  // COD
         showThankyou()
         }
         
         }
         else{
         KVAlertView.show(message: "NO_OPTION_MSG".localizedString())
         }*/
        
    }
    
    @IBAction func btnCancelOrderClicked(_ sender: UIButton) {
        
        clearCart(isNavigate: true)
        
    }
    
    @IBAction func btnViewOrderClicked(_ sender: UIButton) {
        self.popBack(3)
    }
    
    //Remove cart item function
    func clearCart(isNavigate : Bool) {
        
        print("\nheaders are => \(wsCall.headers)")
        // print("\nparam are => \(param)")
        //func for remove item from cart
        func removeItems() {
            self.showCentralSpinner()
            wsCall.removeAllFromCart(params: nil) { (response) in
                self.hideCentralSpinner()
                if response.isSuccess {
                    Cart.shared.removeAll()
                    
                    if isNavigate {
                        self.navigationController?.popToRootViewController(animated: false)
                        if (_appDelegator.tabBarVC) != nil {
                            _appDelegator.tabBarVC.selectedIndex = 0  // Or whichever number you like
                            _appDelegator.tabBarVC.selectedViewController?.navigationController?.popToRootViewController(animated: false)
                            
                        }
                    }
                    
                } else {
                    KVAlertView.show(message: response.message)
                }
            }
            
        }
        
        if isNavigate {
            //show delete confirm alert.
            let alert = UIAlertController(title: "EMPTYCARTTITLE".localizedString(), message: "WantToEmptyCart".localizedString(), preferredStyle: .alert)
            let OK = UIAlertAction(title: "EMPTYYES".localizedString(), style: .destructive) { ACTION in
                removeItems()
            }
            
            let NO = UIAlertAction(title: "EMPTYNO".localizedString(), style: .cancel, handler: nil)
            alert.addAction(OK)
            alert.addAction(NO)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            removeItems()
        }
        
    }
}

//MARK: - PayTM -
public extension ExpressibleByIntegerLiteral {
    public static func arc4random() -> Self {
        var r: Self = 0
        arc4random_buf(&r, MemoryLayout<Self>.size)
        return r
    }
}
extension PaymentVC {
    
    //for Global retailer
    func  showPayTMController(orderID : String , amount : String)
    {
        
        //  var dictProfile = UserDefaults.standard.object(forKey: PMUserProfile) as! [String:Any]
        // let orderIDRandom = UInt32.arc4random()
        
        let orderIDRandom = self.placeOrderResponse["displayOrderId"] as! String
        var mc = PGMerchantConfiguration()
        mc = PGMerchantConfiguration.default()
        
        //CheckSum URL
        //-------------Retailer URL ------------
        
        let checkGenerationUrl = "http://digitalhotelgroup4.zoomi.in:202/api/Paytm/GetCheckSum"
        let checkValidationUrl = "http://digitalhotelgroup4.zoomi.in:202/thankyou.aspx"
        mc.checksumGenerationURL = checkGenerationUrl
        mc.checksumValidationURL = checkValidationUrl
        
        
        var orderDict = [AnyHashable: Any]()
        //Merchant configuration in the order object
        orderDict["REQUEST_TYPE"] = "DEFAULT"
        orderDict["ORDER_ID"] = Converter.toString(orderIDRandom)   //orderID
        orderDict["MID"] =  "Azuree60465127665417" //live //"azurek01632819495467"; //local
        orderDict["CHANNEL_ID"] = "WAP"
        orderDict["CUST_ID"] = String(describing: dictUser.custId)   //@"8010011505";
        orderDict["INDUSTRY_TYPE_ID"] = "Retail115" //live  "Retail" // local
        orderDict["WEBSITE"] = "Azurewap"   //live "azrknwldgwap" //local  //
        //orderDict["TXN_AMOUNT"] = String(describing:CartProductList.sharedInstance.finalOrderDict["price"]!)
        orderDict["TXN_AMOUNT"] =  amount  //"1"
        orderDict["THEME"] = "merchant"
        if !dictUser.mobile.isEmpty {
            orderDict["MOBILE_NO"] = dictUser.mobile
        }
        if !dictUser.email.isEmpty {
            orderDict["EMAIL"] = dictUser.email
        } else {
            orderDict["EMAIL"] = "abc@acb.com" //any default email.
        }
        
        orderDict["CALLBACK_URL"] = "http://digitalhotelgroup4.zoomi.in:202/thankyou.aspx"
        
        
        let order: PGOrder = PGOrder(params: orderDict)
        
        let topView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.frame.size.width), height: CGFloat(64)))
        let btn = UIButton()
        btn.titleLabel?.text = "Cancel"
        btn.titleLabel?.font =  UIFont(name: FontName.REGULARSTYLE1, size: 15 * universalWidthRatio)!
        btn.frame = CGRect(x: 5, y: 0, width: 75, height: 40)
        btn.titleLabel?.textColor = .white
        topView.addSubview(btn)
        
        let lblCancel = UILabel()
        lblCancel.frame = CGRect(x: 10, y: 18, width: 65, height: 21)
        lblCancel.text = "Cancel"
        lblCancel.font = UIFont(name: FontName.REGULARSTYLE1, size: 15 * universalWidthRatio)!
        lblCancel.textColor = .white
        topView.addSubview(lblCancel)
        
        //var txnController = PGTransactionViewController()
        let txnController = PGTransactionViewController.init(transactionFor: order)
        txnController?.serverType = eServerTypeProduction
        txnController?.merchant = mc
        // txnController?.sendAllChecksumResponseParamsToPG = true
        txnController?.delegate = self as PGTransactionDelegate
        topView.backgroundColor = UIColor.init(colorLiteralRed: 72.0/255.0, green: 184.0/255.0, blue: 167.0/255.0, alpha: 1.0)
        //txnController?.tabBarController?.tabBar.isHidden = true
        txnController?.topBar = topView
        txnController?.cancelButton = btn;
        txnController?.cancelButton.titleLabel?.text = "Cancel"
        
        
        
        
        show(txnController!)
        
    }
    
    /* func  showPayTMController(orderID : String , amount : String)  {
     
     //  var dictProfile = UserDefaults.standard.object(forKey: PMUserProfile) as! [String:Any]
     let orderIDRandom = UInt32.arc4random()
     var mc = PGMerchantConfiguration()
     mc = PGMerchantConfiguration.default()
     
     //CheckSum URL
     //-------------BMF live URL ------------
     let checkGenerationUrl = "https://business.bookmyfood.co.in/api/Paytm/GetCheckSum"
     let checkValidationUrl = "https://business.bookmyfood.co.in/thankyou.aspx"
     mc.checksumGenerationURL = checkGenerationUrl
     mc.checksumValidationURL = checkValidationUrl
     
     // ----------- Live URL -------------
     //        mc.checksumGenerationURL = "http://perfectmother.zoomi.in:203/api/Paytm/GetCheckSum"
     //        mc.checksumValidationURL = "http://perfectmother.zoomi.in:203/thankyou.aspx"
     
     //NSString *callBackUrl = @"https://business.bookmyfood.co.in/thankyou.aspx";
     //        mc.checksumGenerationURL = "https://business.bookmyfood.co.in/api/Paytm/GetCheckSum"
     //        mc.checksumValidationURL = "https://business.bookmyfood.co.in/thankyou.aspx"
     
     var orderDict = [AnyHashable: Any]()
     //Merchant configuration in the order object
     orderDict["REQUEST_TYPE"] = "DEFAULT"
     // orderDict[@"ORDER_ID"] = [RZAppUtility generateOrderIDWithPrefix:@""];
     orderDict["ORDER_ID"] = Converter.toString(orderIDRandom)   //orderID
     orderDict["MID"] =  "Azuree60465127665417" //live //"azurek01632819495467"; //local
     orderDict["CHANNEL_ID"] = "WAP"
     orderDict["CUST_ID"] = String(describing: dictUser.custId)   //@"8010011505";
     orderDict["INDUSTRY_TYPE_ID"] = "Retail115" //live  "Retail" // local
     orderDict["WEBSITE"] = "Azurewap"   //live "azrknwldgwap" //local  //
     //orderDict["TXN_AMOUNT"] = String(describing:CartProductList.sharedInstance.finalOrderDict["price"]!)
     orderDict["TXN_AMOUNT"] = "1"
     orderDict["THEME"] = "merchant"
     orderDict["MOBILE_NO"] = dictUser.mobile
     orderDict["EMAIL"] = dictUser.email
     orderDict["CALLBACK_URL"] = "https://business.bookmyfood.co.in/thankyou.aspx" //"http://perfectmother.zoomi.in:203/thankyou.aspx"
     //orderDict["CHECKSUMHASH"] = checkSum1
     
     let order: PGOrder = PGOrder(params: orderDict)
     
     let topView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.frame.size.width), height: CGFloat(64)))
     let btn = UIButton()
     btn.titleLabel?.text = "Cancel"
     btn.titleLabel?.font =  UIFont(name: FontName.REGULARSTYLE1, size: 15 * universalWidthRatio)!
     btn.frame = CGRect(x: 5, y: 0, width: 75, height: 40)
     btn.titleLabel?.textColor = .white
     topView.addSubview(btn)
     
     let lblCancel = UILabel()
     lblCancel.frame = CGRect(x: 10, y: 18, width: 65, height: 21)
     lblCancel.text = "Cancel"
     lblCancel.font = UIFont(name: FontName.REGULARSTYLE1, size: 15 * universalWidthRatio)!
     lblCancel.textColor = .white
     topView.addSubview(lblCancel)
     
     //var txnController = PGTransactionViewController()
     let txnController = PGTransactionViewController.init(transactionFor: order)
     txnController?.serverType = eServerTypeProduction
     txnController?.merchant = mc
     // txnController?.sendAllChecksumResponseParamsToPG = true
     txnController?.delegate = self as PGTransactionDelegate
     topView.backgroundColor = UIColor.init(colorLiteralRed: 72.0/255.0, green: 184.0/255.0, blue: 167.0/255.0, alpha: 1.0)
     //txnController?.tabBarController?.tabBar.isHidden = true
     txnController?.topBar = topView
     txnController?.cancelButton = btn;
     txnController?.cancelButton.titleLabel?.text = "Cancel"
     
     
     
     
     show(txnController!)
     
     }*/
    
    func show(_ controller: PGTransactionViewController) {
        present(controller, animated: true, completion: {() -> Void in
        })
        
    }
    
    func remove(_ controller: PGTransactionViewController) {
        
        controller.dismiss(animated: true, completion: {() -> Void in
        })
        
    }
    // MARK:- Delegate methods.
    
    // On Successful Payment
    public func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        print("successfully transaction \(response)")
        
        if let dictPaytm = response {
            
            var paymentDict = dictPaytm as! [String : Any]
            paymentDict["paymentStatus"] = paymentStatus.Completed
            paymentDict["TransactionStatus"] = "SUCESS"
            
            setPaymentStatus(dictPayTM: paymentDict)
            remove(controller)
            showThankyou()
        }
        
        // let  dictPaytm = response as! [String:Any]
        
        
        
    }
    public func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        print("fail transaction \(response)")
        
        if let dictPaytm = response {
            var paymentDict = dictPaytm as! [String : Any]
            paymentDict["paymentStatus"] = paymentStatus.Fail
            paymentDict["TransactionStatus"] = "FAIL"
            setPaymentStatus(dictPayTM: paymentDict)
        }
        remove(controller)
        
    }
    public func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        print(response)
        
        if let dictPaytm = response {
            var paymentDict = dictPaytm as! [String : Any]
            paymentDict["paymentStatus"] = paymentStatus.Fail
            paymentDict["TransactionStatus"] = "CANCEL"
            setPaymentStatus(dictPayTM: paymentDict)
        }
        remove(controller)
        
    }
    
    public func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print(error)
    }
    
    public func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        remove(controller)
    }
    
    public func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        print(responseString)
    }
    
    
    
    
}

//MARKS:- PLACE ORDER API CALL
extension PaymentVC{
    
    func placeOrder(params: [String:Any] , completion:@escaping (_ success:Bool) -> Void){
        //  print("\nheaders are => \(wsCall.headers)")
        //  print("\nparam are => \(param)")
        self.showCentralGraySpinner()
        wsCall.placeOrder(params: params) { (response) in
            if response.isSuccess {
                if let json = response.json as? [String: Any]
                {
                    self.placeOrderResponse = json
                }
                completion(response.isSuccess)
                
            } //sucess
            self.hideCentralGraySpinner()
        }
        
    }
    
    
    //paymentStatsu
    func setPaymentStatus(dictPayTM : [String:Any]){
        print(dictPayTM)
        
        
        self.showCentralGraySpinner()
        
        var dictParam = [String:Any]()
        
        dictParam["orderId"] = Converter.toString(self.placeOrderResponse["orderId"])
        dictParam["paymentGateway"] = "PayTM"
        dictParam["paymentType"] = dictPayTM["PAYMENTMODE"] ?? ""
        dictParam["paymentStatus"] = dictPayTM["paymentStatus"] ?? ""
        dictParam["errorCode"] = dictPayTM["RESPCODE"] ?? ""
        dictParam["errorMsg"] = dictPayTM["RESPMSG"] ?? ""
        dictParam["checksum"] = ""
        dictParam["txnid"] = dictPayTM["TXNID"] ?? ""
        dictParam["txnamount"] =  dictPayTM["txnamount"] ?? ""
        
        //        let dictParam = ["orderId" :Converter.toString(self.placeOrderResponse["orderId"]), "paymentGateway" : "PayTM", "paymentType" : dictPayTM["PAYMENTMODE"], "paymentStatus" : dictPayTM["paymentStatus"], "errorCode" : dictPayTM["RESPCODE"], "errorMsg" : dictPayTM["RESPMSG"], "checksum" : "", "txnid" : dictPayTM["TXNID"], "txnamount" : ""]
        
        wsCall.setPaymentStatus(params: dictParam) { (response) in
            if response.isSuccess {
                if let status = dictPayTM["TransactionStatus"] as? String, status == "SUCCESS" {
                    self.clearCart(isNavigate: false)
                }
                
            } //sucess
            self.hideCentralGraySpinner()
        }
        
        
        
    }
    
    //MARK: - PRE ORDER SUMMARY -
    func getPreOrderSummay(){
        
        //GiftCouponPrice={GiftCouponPrice}&GiftWrapPrice={GiftWrapPrice}&DeliveryCharge={DeliveryCharge}&WalletPrice={WalletPrice}&Pincode={Pincode}
        
        var dictParam = [String:Any]()
        
        dictParam["GiftCouponPrice"] = 0.0   //currentOrder.offerCouponDiscount
        dictParam["GiftWrapPrice"] = currentOrder.giftWarpPrice
        dictParam["DeliveryCharge"] = currentOrder.branchId == 0 ? currentOrder.deliveryCharge: 0.0
        dictParam["WalletPrice"] = currentOrder.walletPrice
        dictParam["Pincode"] = currentOrder.branchId == 0 ? currentOrder.shippingPincode : ""
        
        
        wsCall.preOrderSummary(params: dictParam) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    print("preorder summary response is => \(json)")
                    
                    let summaries = json.map({ (object) -> PreOrderAmountSummary in
                        
                        return PreOrderAmountSummary(object)
                    })
                    self.preOrderSummaries = summaries.sorted(by: { $0.sortOrder < $1.sortOrder })
                    self.currentOrder.price = summaries.filter({ $0.id == "1"  })[0].value.rounded()
                    
                    // self.paymentOptionCollection.reloadSections(NSIndexSet(index: 2) as IndexSet)
                    self.paymentOptionCollection.reloadData()
                    
                }
            }
        }
    }
    
    
}
//MARK:- UITEXTVIEW DELEGATE
extension PaymentVC : UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        if(text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        
        print(textView.text);
        let textFieldText: NSString = (textView.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: text)
        
        print("txtAfterUpdate\(txtAfterUpdate)");
        
        currentOrder.userComment = txtAfterUpdate
        
        return true
        
    }
}
