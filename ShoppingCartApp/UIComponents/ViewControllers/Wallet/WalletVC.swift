//
//  WalletVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 22/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class WalletVC: ParentViewController {

    
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lblWalletBalance: BoldWidthLabel!
    @IBOutlet weak var segWallet: UISegmentedControl!
    var pageNumber = 1
    var canLoadMore = true
//    var pageNumberPurchase = 1
//    var canLoadMore = true
    var wallet = [Wallet]()
    var arrPurchase : [[String:Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblWalletBalance.layer.cornerRadius = 5
        lblWalletBalance.layer.masksToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        pageNumber = 1
        self.wallet.removeAll()
        self.callGetWalletHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension WalletVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return wallet.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell1") as! WalletCell
        let data = wallet[indexPath.row]
        
        if Int(data.walletPrice)! > 0 {
            cell.lblOrderID.text = "Transaction #" + data.displayOrderId
            cell.lblPoints.textColor = UIColor.black
            
        }else{
            cell.lblOrderID.text = "Order #" + data.displayOrderId
            cell.lblPoints.textColor = UIColor.red
        }
        let date1 = serverDateFormator.date(from: data.date)
        cell.lblDate.text = dateFormator.string(from: date1!)
        cell.lblPoints.text = data.walletPrice
        cell.lblComment.text = "This transaction from wallet. If u want add some money to wallet so please add."
        
        if indexPath.row == wallet.count - 1
        { //last row then reload data
            launchReload()
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.rowHeight
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
}

//MARK: Wallet History Api Calling
extension WalletVC{
    
    func launchReload(){
        if self.canLoadMore{
            pageNumber = pageNumber + 1
            callGetWalletHistory()
        }
    }
    
    func callGetWalletHistory() {
        let dictParameter = ["pageNumber":pageNumber,"PageSize":COUNTPERPAGE] as [String : Any]
        
        if pageNumber == 1{
            self.showCentralGraySpinner()
            self.wallet.removeAll()
        }
        wsCall.callWalletHistory(params: dictParameter) { (response) in
            if response.isSuccess {
                self.canLoadMore = false
                
                if let json = response.json as? [[String:Any]] {
                    print("category response is => \(json)")
                    let arrwallet = json.map({ (walletObj) -> Wallet in
                        return Wallet(walletObj)
                    })
                    
                    if arrwallet.count > 0{
                        
                        if self.wallet.count == 0{
                            self.wallet = arrwallet
                            self.lblWalletBalance.text = RsSymbol + arrwallet[0].availableWalletBalance
                        }
                        else{
                            self.wallet += arrwallet
                        }
                        
                        if arrwallet.count == COUNTPERPAGE{
                            self.canLoadMore = true
                        }
                    }
                    self.tableView.reloadData()
                    if self.wallet.count == 0 {
                        //add no result found image
                        //first remove previously added view then show new one again
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Wallet History Found!")
                        self.lblWalletBalance.isHidden = true
                    }
                    else{
                        //remove no result found view
                        removeNoResultFoundImage(fromView: self.view)
                        if self.pageNumber == 1{
                            self.tableView.setContentOffset(CGPoint.zero, animated: false)
                        }
                        
                    }
                    
                }
                self.hideCentralGraySpinner()
            }
        }
    }
    
    
}

//MARK: - Wallet Plus Clicked
extension WalletVC{
    
    @IBAction func btnWalletPlusClicked(_ sender: UIButton) {
        createWalletPlusView()
    }
    
    func createWalletPlusView()
    {
        var walletByView: WalletPlusView!
        walletByView =  WalletPlusView.instanceFromNib()
        
        walletByView.frame =  UIScreen.main.bounds
        walletByView.tranparentView.frame = walletByView.frame
        
        _ = btnPlus.superview?.frame
        
        let sortButtonFrame = btnPlus.frame
        let centerviewframe = walletByView.centerView.frame
        let ypoint = 65
        //let ypoint = (sViewFrame?.origin.y)! + sortButtonFrame.origin.y + sortButtonFrame.size.height
        walletByView.centerView.frame = CGRect(x: sortButtonFrame.origin.x - 80, y: CGFloat(ypoint), width: sortButtonFrame.size.width + 80, height: centerviewframe.size.height - 80)
        
        walletByView.tbWalletPlus.frame = walletByView.centerView.frame
        
        self.view.addSubview(walletByView)
        
        walletByView.arrItem = ["Buy gift coupons","Add to wallet"]
        
        walletByView.actionBlock = {(strSelect) in
            //TODO-
            
            walletByView.removeFromSuperview()
            if strSelect == "Add to wallet"{
                let pwvc = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseWalletVC") as! PurchaseWalletVC
                self.navigationController?.pushViewController(pwvc, animated: true)
            } else {
                
                let buygiftcouponvc = self.storyboardAccount.instantiateViewController(withIdentifier: "AddGiftCouponVC") as! AddGiftCouponVC
                self.navigationController?.pushViewController(buygiftcouponvc, animated: true)
            }
            
        }
    }

}
class WalletCell : TableViewCell{
    @IBOutlet var lblOrderID : Style1WidthLabel!
    @IBOutlet var lblDate : Style1WidthLabel!
    @IBOutlet var lblPoints : BoldWidthLabel!
    @IBOutlet var lblComment : Style1WidthLabel!
}
