//
//  PurchaseWalletVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 04/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class PurchaseWalletVC: ParentViewController {

    @IBOutlet weak var tbWalletPurchase: UITableView!
    var pageNumber = 1
    var canLoadMore = true
    var arrPurchase : [[String:Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        pageNumber = 1
        
        self.callGetWalletPurchase()
        self.tbWalletPurchase.tableFooterView = UIView.init(frame:CGRect.zero );
    }

}


extension PurchaseWalletVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPurchase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell") as! TableViewCell
        let buyPrice = Converter.toString(arrPurchase[indexPath.row]["buyPrice"])
        let getPrice = Converter.toString(arrPurchase[indexPath.row]["getPrice"])
        cell.lblTitle.text = "Buy " + RsSymbol + buyPrice
        cell.lblSubTitle.text = "Get " + RsSymbol + getPrice
        
        cell.button?.tag = indexPath.row
        cell.button?.addTarget(self, action: #selector(btnPurchaseClicked(_sender:)), for: .touchUpInside)
        
        if indexPath.row == arrPurchase.count - 1
        { //last row then reload data
            launchReloadPurchase()
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90 * universalWidthRatio
        
    }
    
    @IBAction func btnPayClicked(_sender : UIButton){
        let advc = self.storyboard?.instantiateViewController(withIdentifier: "AddWallet") as! AddWallet
        self.navigationController?.pushViewController(advc, animated: true)
    }
    
    @IBAction func btnPurchaseClicked(_sender : UIButton){
       
        //open pay tm page directly with 8 digit random number
        let buyPrice = Converter.toString(arrPurchase[_sender.tag]["buyPrice"])
        let pvc = storyboardProductList.instantiateViewController(withIdentifier: "PayTmVC") as! PayTmVC
        pvc.amount = buyPrice
        self.navigationController?.pushViewController(pvc, animated: true)
    }
}


//MARK: Wallet Purchase Api Calling
extension PurchaseWalletVC{
    
    func launchReloadPurchase(){
        if self.canLoadMore{
            pageNumber = pageNumber + 1
            callGetWalletPurchase()
        }
    }
    
    func callGetWalletPurchase() {
        let dictParameter = ["pageNumber":pageNumber,"PageSize":COUNTPERPAGE] as [String : Any]
        
        if pageNumber == 1{
            self.showCentralGraySpinner()
            self.arrPurchase.removeAll()
        }
        wsCall.callWalletPurchase(params: dictParameter) { (response) in
            if response.isSuccess {
                self.canLoadMore = false
                
                if let arrResponse = response.json as? [[String:Any]] {
                    
                    if arrResponse.count > 0{
                        
                        if self.arrPurchase.count == 0{
                            self.arrPurchase = arrResponse
                            //self.lblWalletBalance.text = arrResponse[0].availableWalletBalance
                        }
                        else{
                            self.arrPurchase += arrResponse
                        }
                        
                        if arrResponse.count == COUNTPERPAGE{
                            self.canLoadMore = true
                        }
                    }
                    self.tbWalletPurchase.reloadData()
                    if self.arrPurchase.count == 0 {
                        //add no result found image
                        //first remove previously added view then show new one again
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Wallet Purchase Offer Found!")
                        
                    }
                    else{
                        //remove no result found view
                        removeNoResultFoundImage(fromView: self.view)
                        if self.pageNumber == 1{
                            self.tbWalletPurchase.setContentOffset(CGPoint.zero, animated: false)
                        }
                        
                    }
                    
                }
                self.hideCentralGraySpinner()
            }
        }
    }

}

