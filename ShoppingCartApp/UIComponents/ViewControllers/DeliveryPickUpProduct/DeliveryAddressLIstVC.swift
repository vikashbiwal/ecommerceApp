//
//  DeliveryAddressLIstVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol DeliveryAddressDelegate: class {
    
    func getDeliveryAddress(addressObj: Address)
    
}

class DeliveryAddressLIstVC: ParentViewController, UITableViewDelegate, UITableViewDataSource, addDeliveryAddressDelegate{
    func getDefaultAddress(addressObj: Address) {
    }


    @IBOutlet weak var tblDeliveyAddress: UITableView!
    
    weak var delegateDelivery: DeliveryAddressDelegate?
    
    var isScreen: String = ""
    
    var arrDeliveryAddress: [Address] = []
    
    var isNoDeliveryAddress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarView.drawShadow()
        
        self.tblDeliveyAddress.tableFooterView = UIView(frame: .zero)
        
        if isScreen == "account" {
            
            self.getDeliveryAddress()
        }
        
       // self.getDeliveryAddress()

        // Do any additional setup after loading the view.
    }

    //MARK: button close pressed
   
    @IBAction func btnClosePressed(_ sender: UIButton) {
        
        _appDelegator.isBackToAddressScreen = true
        _appDelegator.isBackToAccountScreen = true
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: add new Address Clicked
    
    @IBAction func btnAddNewAddressPressed(_ sender: UIButton) {
        
        let controller = self.storyboardShoppingCart.instantiateViewController(withIdentifier: "AddDeliveryAddressVC") as! AddDeliveryAddressVC
        controller.isScreen = isScreen
        controller.defaultAddressDelegate = self
        controller.isNoDeliveryAddress = isNoDeliveryAddress
        self.present(controller, animated: true, completion: nil)
    }
    
    func refreshAddressList(){
        
        tblDeliveyAddress.scrollsToTop = true
        
        self.getDeliveryAddress()
    }
    
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.arrDeliveryAddress.count
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
        
        let cellIdentifier = "DeliveryAddressCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DeliveryAddressCell
        cell.drawShadow(0.05)
        
        let address = self.arrDeliveryAddress[indexPath.row]
        
        if address.isDefault ==  true {
            
            cell.lblDefaultAddress.text = "Default Address"
        }else{
             cell.lblDefaultAddress.text = ""
        }
        
        cell.lblFullName.text = address.name
        
        cell.lblAddress.text = address.fullAddress
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
       // _appDelegator.isBackToAddressScreen = true
        if(isScreen != "account"){
        let address = self.arrDeliveryAddress[indexPath.row]
        delegateDelivery?.getDeliveryAddress(addressObj: address)
        self.dismiss(animated: true, completion: nil)
            
        }else if(isScreen == "account"){
            
            let address = self.arrDeliveryAddress[indexPath.row]
            
            let controller = self.storyboardShoppingCart.instantiateViewController(withIdentifier: "AddDeliveryAddressVC") as! AddDeliveryAddressVC
            controller.isScreen = isScreen
            controller.address = address
            controller.defaultAddressDelegate = self
            controller.isNoDeliveryAddress = false
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        if(isScreen == "account"){
            
             return true
        }else{
             return false
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            
            let deleteAlert = UIAlertController(title: "", message: "Do you want to delete address ?", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                             let address = self.arrDeliveryAddress[indexPath.row]
                
                             let addressViewModel = AddressViewModel()
                
                            addressViewModel.address.id = address.id
                            addressViewModel.address.name = address.name
                            addressViewModel.address.contactNo = address.contactNo
                            addressViewModel.address.email = address.email
                            addressViewModel.address.address = address.address
                            addressViewModel.address.city = address.city
                            addressViewModel.address.state = address.state
                            addressViewModel.address.country = address.country
                            addressViewModel.address.pincode = address.pincode
                            addressViewModel.address.isDefault = address.isDefault
                
                            addressViewModel.address.isActive = false
                
                            self.showCentralGraySpinner()
                            addressViewModel.saveAddress_apiCall(block: { (success, address) in
                                self.hideCentralGraySpinner()
                                if(success){
                                    print("address:\(address!)")
                                    
                                    if(address != nil){
                                        
                                       
                                        self.refreshAddressList()
                                        
                                    }
                
                                    
                                }
                                
                            })

                
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in

            }))
            
            present(deleteAlert, animated: true, completion: nil)
            

            
        }
    }


}

//MARK: get delivery address

extension DeliveryAddressLIstVC{
    
    func getDeliveryAddress(){
        
        tblDeliveyAddress.isHidden = true
        
        self.showCentralGraySpinner()
        
         let param = ["AddressId":"0"]
        
        wsCall.getDeliveryAddress(params: param) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    self.hideCentralGraySpinner()
                    
                    print("Address response is => \(json)")
                    
                    self.arrDeliveryAddress = json.map({ (object) -> Address in
                        
                        return Address(forDelivery : object)
                        
                    })
                    
                    print("self.arrDeliveryAddress => \(self.arrDeliveryAddress)")
                    
                    self.tblDeliveyAddress.isHidden = false
                    
                    self.tblDeliveyAddress.reloadData()
                    
                }
            }
            
        }
    }
}

//MARK: get delivery address cell

class DeliveryAddressCell: TableViewCell {
    
    @IBOutlet weak var lblFullName: WidthLabel!
    
    @IBOutlet weak var lblAddress: WidthLabel!
    
    @IBOutlet weak var lblDefaultAddress: WidthLabel!
    
}

