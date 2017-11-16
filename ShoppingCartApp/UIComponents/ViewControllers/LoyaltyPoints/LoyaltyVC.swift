//
//  LoyaltyVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class LoyaltyVC: ParentViewController {

    @IBOutlet weak var lblAvailablePoints: BoldWidthLabel!
    var pageNumber = 1
    var canLoadMore = true
    var loyalty = [Loyalty]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblAvailablePoints.layer.cornerRadius = 5
        lblAvailablePoints.layer.masksToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        pageNumber = 1
        self.loyalty.removeAll()
        self.callGetLoyaltyHistory()    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}


extension LoyaltyVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loyalty.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loyaltyCell1") as! LoyaltyCell
        let data = loyalty[indexPath.row]
        
        cell.lblOrderID.text = "Order #" + data.displayOrderId
        cell.lblPoints.textColor = UIColor.red
        
        let date1 = serverDateFormator.date(from: data.date)
        cell.lblDate.text = dateFormator.string(from: date1!)
        cell.lblPoints.text = data.loyaltyPoints
        
        if indexPath.row == loyalty.count - 1
        { //last row then reload data
            launchReload()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 * universalWidthRatio
    }
}

extension LoyaltyVC{
    
    func launchReload(){
        if self.canLoadMore{
            pageNumber = pageNumber + 1
            callGetLoyaltyHistory()
        }
    }
    
    func callGetLoyaltyHistory() {
        let dictParameter = ["pageNumber":pageNumber,"PageSize":COUNTPERPAGE] as [String : Any]
        
        if pageNumber == 1{
            self.showCentralGraySpinner()
            self.loyalty.removeAll()
        }
        wsCall.callLoyalty(params: dictParameter) { (response) in
            if response.isSuccess {
                self.canLoadMore = false
                
                if let json = response.json as? [[String:Any]] {
                    print("category response is => \(json)")
                    let arrLoyalty = json.map({ (loyaltyObj) -> Loyalty in
                        return Loyalty(loyaltyObj)
                    })
                    
                    if arrLoyalty.count > 0{
                        
                        if self.loyalty.count == 0{
                            self.loyalty = arrLoyalty
                            self.lblAvailablePoints.text = arrLoyalty[0].availableLoyaltyPoints
                        }
                        else{
                            self.loyalty += arrLoyalty
                        }
                        
                        if arrLoyalty.count == COUNTPERPAGE{
                            self.canLoadMore = true
                        }
                    }
                    self.tableView.reloadData()
                    if self.loyalty.count == 0 {
                        //add no result found image
                        //first remove previously added view then show new one again
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Loyalty History Found!")
                        self.lblAvailablePoints.isHidden = true
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




class LoyaltyCell : TableViewCell{
    @IBOutlet var lblOrderID : Style1WidthLabel!
    @IBOutlet var lblDate : Style1WidthLabel!
    @IBOutlet var lblPoints : BoldWidthLabel!
}
