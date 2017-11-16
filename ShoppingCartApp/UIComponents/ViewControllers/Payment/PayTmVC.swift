//
//  PayTmVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 8/26/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import UIKit

class PayTmVC: ParentViewController ,PGTransactionDelegate {
    var orderId = 0
    var amount = ""
    var mobileNumber = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showPayTMController(orderID: orderId, amount:amount)
        
        
        
    }
    
    func generateRandomNumber(numDigits: Int) -> Int {
        var place = 1
        var finalNumber = 0
        for i in 0..<numDigits {
            place *= 10
            let randomNumber = arc4random_uniform(10)
            finalNumber += Int(randomNumber) *  place
        }
        return finalNumber
    }
    
    //for Global retailer
    func  showPayTMController(orderID : Int , amount : String)
    {
        
        //  var dictProfile = UserDefaults.standard.object(forKey: PMUserProfile) as! [String:Any]
        //  let orderIDRandom = UInt32.arc4random()
        orderId = orderID == 0 ? generateRandomNumber(numDigits: 8) : 0 // generate 8 digit random number
        
        
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
        orderDict["ORDER_ID"] = Converter.toString(orderId)   //orderID
        orderDict["MID"] =  "Azuree60465127665417" //live //"azurek01632819495467"; //local
        orderDict["CHANNEL_ID"] = "WAP"
        orderDict["CUST_ID"] = String(describing: dictUser.custId)   //@"8010011505";
        orderDict["INDUSTRY_TYPE_ID"] = "Retail115" //live  "Retail" // local
        orderDict["WEBSITE"] = "Azurewap"   //live "azrknwldgwap" //local  //
        //orderDict["TXN_AMOUNT"] = String(describing:CartProductList.sharedInstance.finalOrderDict["price"]!)
        orderDict["TXN_AMOUNT"] = amount
        orderDict["THEME"] = "merchant"
        if !self.mobileNumber.isEmpty{
             orderDict["MOBILE_NO"] = self.mobileNumber
        }
        else{
            if !dictUser.mobile.isEmpty {
                orderDict["MOBILE_NO"] = dictUser.mobile
            }
        }
        
        if !dictUser.email.isEmpty {
            orderDict["EMAIL"] = dictUser.email
        } else {
            orderDict["EMAIL"] = "abc@acb.com" //any default email.
        }
        
        orderDict["CALLBACK_URL"] = "http://digitalhotelgroup4.zoomi.in:202/thankyou.aspx"
        
        
        let order: PGOrder = PGOrder(params: orderDict)
        
        let topView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(screenSize.width), height: CGFloat(64)))
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
    
    func show(_ controller: PGTransactionViewController) {
        present(controller, animated: true, completion: nil)
        
    }
    func remove(_ controller: PGTransactionViewController) {
        
        controller.dismiss(animated: true, completion: {() -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        
    }

    
}
extension PayTmVC {
    // On Successful Payment
    public func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        print("successfully transaction \(response)")
        
        if let dictPaytm = response {
            
            var paymentDict = dictPaytm as! [String : Any]
            paymentDict["paymentStatus"] = paymentStatus.Completed
            paymentDict["TransactionStatus"] = "SUCESS"
            
            setPaymentStatus(dictPayTM: paymentDict)
            remove(controller)
            
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
extension PayTmVC{
    //paymentStatsu
    func setPaymentStatus(dictPayTM : [String:Any]){
        print(dictPayTM)
        
        
        
        
        var dictParam = [String:Any]()
        
        dictParam["orderId"] = Converter.toString(orderId)
        dictParam["paymentGateway"] = "PayTM"
        dictParam["paymentType"] = dictPayTM["PAYMENTMODE"] ?? ""
        dictParam["paymentStatus"] = dictPayTM["paymentStatus"] ?? ""
        dictParam["errorCode"] = dictPayTM["RESPCODE"] ?? ""
        dictParam["errorMsg"] = dictPayTM["RESPMSG"] ?? ""
        dictParam["checksum"] = ""
        dictParam["txnid"] = dictPayTM["TXNID"] ?? ""
        dictParam["txnamount"] = "1"
        
        //        let dictParam = ["orderId" :Converter.toString(self.placeOrderResponse["orderId"]), "paymentGateway" : "PayTM", "paymentType" : dictPayTM["PAYMENTMODE"], "paymentStatus" : dictPayTM["paymentStatus"], "errorCode" : dictPayTM["RESPCODE"], "errorMsg" : dictPayTM["RESPMSG"], "checksum" : "", "txnid" : dictPayTM["TXNID"], "txnamount" : ""]
        
        wsCall.setPaymentStatus(params: dictParam) { (response) in
            if response.isSuccess {
                
                
            } //sucess
            
        }
        
        
        
    }
    
    
}

