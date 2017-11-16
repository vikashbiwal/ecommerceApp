//
//  MyReturnVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 16/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class MyReturnVC: ParentViewController {

    var pageNumber = 1
    var canLoadMore = true
    var arrOrderReturn : [[String:Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageNumber = 1
        
        self.callGetOrderReturn()
        self.tableView.tableFooterView = UIView.init(frame:CGRect.zero );
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MyReturnVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "returnCell") as! MyReturnCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130 * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        ReturnBox.showReturnBox(in: self, sourceFrame: self.view.frame,viewDisplayType: .returnOrder) { obj in
            /*if success {
            }*/
        }
    }
}
 
//MARK: Wallet Purchase Api Calling
extension MyReturnVC{
    
    func launchReloadOrderReturn(){
        if self.canLoadMore{
            pageNumber = pageNumber + 1
            callGetOrderReturn()
        }
    }
    
    func callGetOrderReturn() {
        let dictParameter = ["pageNumber":pageNumber,"PageSize":COUNTPERPAGE] as [String : Any]
        
        if pageNumber == 1{
            self.showCentralGraySpinner()
            self.arrOrderReturn.removeAll()
        }
        wsCall.callWalletPurchase(params: dictParameter) { (response) in
            if response.isSuccess {
                self.canLoadMore = false
                
                if let arrResponse = response.json as? [[String:Any]] {
                    
                    if arrResponse.count > 0{
                        
                        if self.arrOrderReturn.count == 0{
                            self.arrOrderReturn = arrResponse
                            //self.lblWalletBalance.text = arrResponse[0].availableWalletBalance
                        }
                        else{
                            self.arrOrderReturn += arrResponse
                        }
                        
                        if arrResponse.count == COUNTPERPAGE{
                            self.canLoadMore = true
                        }
                    }
                    self.tableView.reloadData()
                    if self.arrOrderReturn.count == 0 {
                        //add no result found image
                        //first remove previously added view then show new one again
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "There is no return item found")
                        
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



class MyReturnCell : TableViewCell{
    
    @IBOutlet var lblReturnOrderId : Style1WidthLabel!
    @IBOutlet var lblPrice : Style1WidthLabel!
    @IBOutlet var lblItemNamne : Style1WidthLabel!
    @IBOutlet var lblReturnDate : Style1WidthLabel!
    @IBOutlet var lblQuantity : Style1WidthLabel!
    @IBOutlet var lblOrderStatus: Style1WidthLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
