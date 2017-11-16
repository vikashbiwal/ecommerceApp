//
//  PickupAddressListVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol pickUpAddressDelegate: class {
    
    func getPickupAddress(pickUpAddressObj: Address)
}

class PickupAddressListVC: ParentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtSearchAddress: UITextField!
    @IBOutlet weak var tblAddressList: UITableView!
    @IBOutlet weak var serachbarViewHeightConst: NSLayoutConstraint!
    
    weak var delegate: pickUpAddressDelegate?
    
    var arrPickupAddress: [Address] = []
    
    var isSearch:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
        self.tblAddressList.tableFooterView = UIView(frame: .zero)
        
        self.txtSearchAddress.text = ""
        
        self.getPickupAddress()

        // Do any additional setup after loading the view.
    }
    
      //MARK: button close pressed
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        _appDelegator.isBackToAddressScreen = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func textFieldDidChange(_ sender: UITextField) {
        
        print("search text:\(self.txtSearchAddress.text!)")
        
        //self.lblSearchTitle.text = String(format: "%@ ",self.txtSearch.text!)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getPickupAddress), object: nil)
        
        if sender.text?.characters.count == 0 {
            self.perform(#selector(self.getPickupAddress), with: nil, afterDelay: 0.0)
        }
        else {
            if ((sender.text?.characters.count)! >= 3 ) {
                self.perform(#selector(self.getPickupAddress), with: nil, afterDelay: 0.5)
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) // became first responder
    {
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    {}
    func textFieldShouldClear(_ textField: UITextField) -> Bool // called when clear button pressed. return NO to ignore (no notifications)
    {
        return true
    }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.txtSearchAddress.resignFirstResponder()
        return true
    }



    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.arrPickupAddress.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
            let cellIdentifier = "PickupAddressCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PickupAddressCell
            cell.drawShadow(0.05)
        
            let address = self.arrPickupAddress[indexPath.row]
        
            cell.lblBranchName.text = address.name
        
            cell.lblFullAddress.text = address.fullAddress
        
            return cell
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
       // _appDelegator.isBackToAddressScreen = true
        let address = self.arrPickupAddress[indexPath.row]
        delegate?.getPickupAddress(pickUpAddressObj: address)
        self.dismiss(animated: true, completion: nil)
    }
}


extension PickupAddressListVC{
    
    func getPickupAddress(){
        
        if isSearch == false {
            
            self.showCentralGraySpinner()

        }
        
        let param = ["searchText":self.txtSearchAddress.text!]
        
        wsCall.GetPickupAddress(params: param) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    print("Address response is => \(json)")
                    
                    self.arrPickupAddress = json.map({ (object) -> Address in
                        
                        return Address(forBranch : object)
                        
                    })
                    
                    if self.arrPickupAddress.count  <= 10{
                        
                        self.serachbarViewHeightConst.constant = 0
                        self.txtSearchAddress.isHidden = true
                        
                        
                    }else{
                        
                        self.serachbarViewHeightConst.constant = 53.0
                        self.txtSearchAddress.isHidden = false
                    }
                    
                    print("arrPickupAddress => \(self.arrPickupAddress)")
                    
                    self.tblAddressList.reloadData()
                    
                }
            }
            
            if self.isSearch == false {
                
                self.hideCentralGraySpinner()
                
                self.isSearch = true
            }
            
            
            
        }
    }

}

class PickupAddressCell: TableViewCell {
    
    @IBOutlet weak var lblBranchName: WidthLabel!
    
    @IBOutlet weak var lblFullAddress: WidthLabel!
}

