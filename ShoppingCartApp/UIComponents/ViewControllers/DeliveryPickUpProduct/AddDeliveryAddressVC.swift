//
//  AddDeliveryAddressVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

protocol addDeliveryAddressDelegate: class{
    
    func getDefaultAddress(addressObj: Address)
    func refreshAddressList()
}


class AddDeliveryAddressVC: ParentViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblAddNewAddress: UITableView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    weak var defaultAddressDelegate: addDeliveryAddressDelegate?
    
    var arrAddress: [[String:Any]] = []
    
    var isDefaultAddress: Bool = false
    
    var isNoDeliveryAddress: Bool = false
    
    var isScreen: String = ""
    
    let addressViewModel = AddressViewModel()
    
    var address: Address?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
        if address != nil {
            
            addressViewModel.address.id = (address?.id)!
            addressViewModel.address.name = (address?.name)!
            addressViewModel.address.contactNo = (address?.contactNo)!
            addressViewModel.address.email = (address?.email)!
            addressViewModel.address.address = (address?.address)!
            addressViewModel.address.city = (address?.city)!
            addressViewModel.address.state = (address?.state)!
            addressViewModel.address.country = (address?.country)!
            addressViewModel.address.pincode = (address?.pincode)!
            addressViewModel.address.isDefault = (address?.isDefault)!
        }else{
             addressViewModel.address.id =  "0"
            if UserDefaults.standard.value(forKey: AppPreference.userObj) != nil{
                let userJson = UserDefaults.standard.value(forKey: AppPreference.userObj) as! [String : Any]
                dictUser = User(userJson)
                
                addressViewModel.address.name = (dictUser.name)
                addressViewModel.address.contactNo = (dictUser.mobile)
                addressViewModel.address.email = (dictUser.email)
                addressViewModel.address.country = "India"
            }
        }
        
        addressViewModel.address.isActive = true
        
        tblAddNewAddress.reloadData()

        
        // Do any additional setup after loading the view. 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        //containerView.frame = scrollView.bounds
        
    }
    
    override func viewDidAppear(_ animated: Bool){
       super.viewDidAppear(animated)
        
        //tblAddNewAddress.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

    //MARK: button close pressed
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        
        _appDelegator.isBackToAddressScreen = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnDefaultAddressClicked(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected == true {
            
            sender.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
            isDefaultAddress = true
            
            
        }else{
            
            sender.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
            isDefaultAddress = false
        }
        
        addressViewModel.address.isDefault = isDefaultAddress
    }
   
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if IS_IPAD{
            
            if indexPath.section == 3 {
                return 155
            }else {
                return 75
            }
            
        }else{
            
            
            if indexPath.section == 3 {
                return 145
            }else {
                return 55
            }
        }
        

      
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        if indexPath.section == 3 {
            
            let cellIdentifier = "AddressCell2"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! addDeliveryAddressCell
            
           
            cell.textVAddress.layer.cornerRadius = 5.0
            cell.textVAddress.layer.masksToBounds = true
            
            let borderColor = UIColor.init(red: 204.0/255.0, green:204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            
            cell.textVAddress.layer.borderWidth = 0.5
            cell.textVAddress.layer.borderColor =  borderColor.cgColor
            
            
            if address != nil {
                
                if [addressViewModel.address.address].isEmpty{
                    
                    cell.lblAddress2.isHidden = false
                    
                    cell.lblAddress2.text = "LABEL_ADDRESS".localizedString()
                }else{
                    
                    if addressViewModel.address.address == "" {
                        
                        cell.lblAddress2.isHidden = false
                        
                        cell.lblAddress2.text = "LABEL_ADDRESS".localizedString()
                        
                    }else{
                        
                        
                        cell.lblAddress2.isHidden = false
                        
                        cell.lblAddress2.text = "LABEL_ADDRESS".localizedString()
                        
                        cell.textVAddress.text = addressViewModel.address.address
                    }
                    
                    
                }

            }else{
                
                cell.lblAddress2.isHidden = false
                
                cell.lblAddress2.text = "LABEL_ADDRESS".localizedString()
            }
        
            
            
           
            
            return cell
            
            
        }else if indexPath.section == 8 {
            
            let cellIdentifier = "AddressCell3"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! addDeliveryAddressCell
            
            cell.lblAddress.text = "LABEL_DEFAULT_ADDRESS".localizedString()
            
            
            if isNoDeliveryAddress == true {
                
                 isDefaultAddress = true
                addressViewModel.address.isDefault = isDefaultAddress
                 cell.btnDefaultAddress.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
                cell.btnDefaultAddress.isUserInteractionEnabled = false
                
            }else{
                
                cell.btnDefaultAddress.isUserInteractionEnabled = true
                
                if addressViewModel.address.isDefault == true{
                    
                    cell.btnDefaultAddress.setImage(UIImage(named:"ic_address_selected"), for: UIControlState.normal)
                    
                    
                }else{
                    
                    cell.btnDefaultAddress.setImage(UIImage(named:"ic_address_unselected"), for: UIControlState.normal)
                }

            }
            
            
            
            cell.btnDefaultAddress.tag = indexPath.section
            
            return cell
        }
        else{
         
            let cellIdentifier = "AddressCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! addDeliveryAddressCell
            
            
                var strValue:String = ""
                
                strValue = strTextFieldValue(indexPath: indexPath as IndexPath)
                
                if strValue.isEmpty{
                    
                    cell.lblAddress.isHidden = false
                    
                    cell.lblAddress.text = self.cellLabelTitle(indexPath: indexPath)
                    
                    
                }else{
                    
                    if strValue == "" {
                        
                        cell.lblAddress.isHidden = false
                        
                        cell.lblAddress.text = self.cellLabelTitle(indexPath: indexPath)
                        
                        
                    }else{
                        
                        cell.lblAddress.isHidden = false
                        
                        cell.lblAddress.text = self.cellLabelTitle(indexPath: indexPath)
                        
                        cell.txtAddress.text = strValue
                        
                        
                    }
                    
                    
                }
                
            
            
            
            if indexPath.section == 0 {
              cell.AddressType =  AddressType.name
            }else if (indexPath.section == 1){
              cell.AddressType =  AddressType.contactNo
            }else if (indexPath.section == 2){
              cell.AddressType =  AddressType.email
            }else if (indexPath.section == 4){
             cell.AddressType =  AddressType.city
            }else if (indexPath.section == 5){
              cell.AddressType =  AddressType.state
            }else if (indexPath.section == 6){
              cell.AddressType =  AddressType.country
            }else if (indexPath.section == 7){
             cell.AddressType =  AddressType.pincode
            }
            
            
            return cell

        }
        
        
        
    }

    func cellLabelTitle(indexPath: IndexPath) ->  String{
        
        var strTitle:String = ""
        
        if indexPath.section == 0 {
            
            
            
            strTitle = "LABLE_NAME".localizedString()
        }else if (indexPath.section == 1){
            strTitle = "LABLE_CONTACT_NUMBER".localizedString()
        }else if (indexPath.section == 2){
            strTitle = "LABEL_EMAIL_ADDRESS".localizedString()
        }else if (indexPath.section == 4){
            strTitle = "LABEL_CITY".localizedString()
        }else if (indexPath.section == 5){
            strTitle = "LABEL_STATE".localizedString()
        }else if (indexPath.section == 6){
            strTitle = "LABEL_COUNTRY".localizedString()
        }else if (indexPath.section == 7){
            strTitle = "LABEL_PINCODE".localizedString()
        }
        
         return strTitle
        
    }
    
    
    func strTextFieldValue(indexPath: IndexPath) -> String {
        
        var strValue:String = ""
        
        if indexPath.section == 0 {
            
            strValue = addressViewModel.address.name
            
        }else if (indexPath.section == 1){
            
            strValue = addressViewModel.address.contactNo
            
        }else if (indexPath.section == 2){
            
            strValue = addressViewModel.address.email
            
        }else if (indexPath.section == 4){
            
            strValue = addressViewModel.address.city
            
        }else if (indexPath.section == 5){
            
            strValue = addressViewModel.address.state
            
        }else if (indexPath.section == 6){
            
            strValue = addressViewModel.address.country
            
        }else if (indexPath.section == 7){
            
            strValue = addressViewModel.address.pincode
        }
        
        return strValue
    }
    
    
    
    
}



extension AddDeliveryAddressVC: UIKeyboardObserver, UITextViewDelegate{
    
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tblAddNewAddress.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tblAddNewAddress.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    func textViewShouldReturn(textView: UITextView!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textView.resignFirstResponder()
        return true;
    }
    
    func textViewDidBeginEditing(_ textField: UITextView) {
        
        print("textViewDidBeginEditing")
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
            
            let indexPath = NSIndexPath(row: 0, section: 3)
            
            let cell = self.tblAddNewAddress.cellForRow(at: indexPath as IndexPath) as! addDeliveryAddressCell
            
            if IS_IPAD{
                
                cell.lblAddress2.font = cell.lblAddress2.font.withSize(12*universalWidthRatio)
                
                cell.lblAddress2TopConst.constant = -2.0
                
            }else{
                cell.lblAddress2.font = cell.lblAddress2.font.withSize(12*universalWidthRatio)
                
                cell.lblAddress2TopConst.constant = -7.0
            }
            
            
            
            cell.lblAddress2LeadingConst.constant = 0.0
            
            cell.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
   
    
    func textViewDidEndEditing(_ textField: UITextView) {
        print("textViewDidEndEditing")
        
        
        if textField.text.characters.count == 0 {
            
            let indexPath = NSIndexPath(row: 0, section: 3)
            
            let cell = self.tblAddNewAddress.cellForRow(at: indexPath as IndexPath) as! addDeliveryAddressCell
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                
                if IS_IPAD{
                    
                    cell.lblAddress2.font = cell.lblAddress2.font.withSize(14*universalWidthRatio)
                    cell.lblAddress2TopConst.constant = 30
                    
                    
                }else{
                    cell.lblAddress2.font = cell.lblAddress2.font.withSize(14*universalWidthRatio)
                    cell.lblAddress2TopConst.constant = 16.5
                }
                
                
                cell.lblAddress2LeadingConst.constant = 8.0
                
                cell.layoutIfNeeded()
                
                
            }, completion: nil)
        }
        
       
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        print(textView.text);
         let textFieldText: NSString = (textView.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: text)
        
         print("txtAfterUpdate\(txtAfterUpdate)");
        
        addressViewModel.address.address = txtAfterUpdate
        
        return true
        
    }
    
   
}

extension AddDeliveryAddressVC{
    
    @IBAction func textFiledTextChanged(_ tf: AddressTextFiled) {
        
        switch tf.type {
        case .name:
             addressViewModel.address.name = tf.text!
        case .contactNo:
            addressViewModel.address.contactNo = tf.text!
        case .email:
            addressViewModel.address.email = tf.text!
        case .city:
            addressViewModel.address.city = tf.text!
        case .state:
             addressViewModel.address.state  = tf.text!
        case .country:
            addressViewModel.address.country  = tf.text!
        case .pincode:
            addressViewModel.address.pincode  = tf.text!
            
        default:
            break
        }
    }
    
    // MARK: submit button clicked
    
    @IBAction func btnSubmitPressed(_ sender: UIButton) {
        
        let (success, errorMessage) = addressViewModel.isValidAddressModel()
        if success {
            
            self.showCentralGraySpinner()
            addressViewModel.saveAddress_apiCall(block: { (success, address) in
            self.hideCentralGraySpinner()
                if(success){
                    print("address:\(address!)")
                    
                    if(address != nil){
                        
                        if(self.isScreen == "account" || self.isScreen == "addresslist"){
                            
                            self.defaultAddressDelegate?.refreshAddressList()
                            
                        }else{
                             self.defaultAddressDelegate?.getDefaultAddress(addressObj: address!)
                        }
                        
                       
                        self.dismiss(animated: true, completion: nil)

                    }
                    
                    
                }
                
            })
            

        } else {
            KVAlertView.show(message: errorMessage)
        }
        
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
        
        addressViewModel.address.address = textView.text

    }
    
   
}

enum AddressType {
    case name, contactNo, email, city, state, country, pincode, isDefault
}

class AddressTextFiled: UITextField {
    var type = AddressType.name
}


class addDeliveryAddressCell: UITableViewCell, UITextFieldDelegate{
    
    @IBOutlet weak var txtAddress: AddressTextFiled!
    
    @IBOutlet weak var lblAddress: WidthLabel!
    
    @IBOutlet weak var textVAddress: WidthTextView!
    
    @IBOutlet weak var lblAddress2: WidthLabel!
    
    @IBOutlet weak var btnDefaultAddress: UIButton!
    
    @IBOutlet weak var lblAddressTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblAddressLeadingConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblAddress2TopConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblAddress2LeadingConst: NSLayoutConstraint!
    
   
    
    var AddressType: AddressType = .name {
        didSet {
            txtAddress.type = AddressType
            setKeyBoardType()
        }
    }
    
    func setKeyBoardType() {
        
        let tooBar: UIToolbar = UIToolbar()
        tooBar.backgroundColor = UIColor.init(red: 209.0/255.0, green: 210.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        tooBar.tintColor = UIColor.darkGray
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(addDeliveryAddressCell.donePressed))]
        tooBar.sizeToFit()
        
        
        switch AddressType {
        case .email:
            txtAddress.keyboardType = .emailAddress
        case .contactNo :
            txtAddress.keyboardType = .numberPad
            txtAddress.inputAccessoryView = tooBar
        case .pincode :
            txtAddress.keyboardType = .numberPad
            txtAddress.inputAccessoryView = tooBar
        default:
            txtAddress.keyboardType = .default
        }
    }
    
    func donePressed () {
        txtAddress.resignFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if txtAddress != nil {
            if txtAddress.text!.isEmpty {
                
                 if lblAddress != nil {
                    
                    if IS_IPAD{
                        
                        self.lblAddress.font = self.lblAddress.font.withSize(14*universalWidthRatio)
                        self.lblAddressTopConst.constant = 16.5
                    }else{
                        self.lblAddress.font = self.lblAddress.font.withSize(14*universalWidthRatio)
                        self.lblAddressTopConst.constant = 16.5
                    }
                    
                    
                    self.lblAddressLeadingConst.constant = 8.0
                    
                }
                
               
                
            } else {
                
                 if lblAddress != nil {
                
                if IS_IPAD{
                    
                    self.lblAddress.font = self.lblAddress.font.withSize(12*universalWidthRatio)
                    
                    self.lblAddressTopConst.constant = -55.0
                    
                }else{
                    self.lblAddress.font = self.lblAddress.font.withSize(12*universalWidthRatio)
                    
                    self.lblAddressTopConst.constant = -35.0
                }
                
                self.lblAddressLeadingConst.constant = 0.0
                
                
            }
                
            }
        }
        
        
        if textVAddress != nil {
            
              if textVAddress.text!.isEmpty {
                
                if IS_IPAD{
                    
                    self.lblAddress2.font = self.lblAddress2.font.withSize(14*universalWidthRatio)
                    self.lblAddress2TopConst.constant = 30
                    
                    
                }else{
                    self.lblAddress2.font = self.lblAddress2.font.withSize(14*universalWidthRatio)
                    self.lblAddress2TopConst.constant = 16.5
                }
                
                
                self.lblAddress2LeadingConst.constant = 8.0
                
              }else{
                
                if lblAddress2 != nil {
                    
                    if IS_IPAD{
                        
                        self.lblAddress2.font = self.lblAddress2.font.withSize(12*universalWidthRatio)
                        
                        self.lblAddress2TopConst.constant = -2.0
                        
                    }else{
                        self.lblAddress2.font = self.lblAddress2.font.withSize(12*universalWidthRatio)
                        
                        self.lblAddress2TopConst.constant = -7.0
                    }
                    
                    
                    
                    self.lblAddress2LeadingConst.constant = 0.0
                }
            }
            
            
            
        }
       
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tf = textField as! AddressTextFiled
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            return true
        }
        switch tf.type {
        case .name:
            if tf.text!.characters.count >= 25{
                return false
            }
            break
        case .contactNo:
            if tf.text!.characters.count >= 15{
                return false
            }
            break
        case .email:
            if tf.text!.characters.count >= 100{
                return false
            }
            break
        case .pincode:
            if tf.text!.characters.count >= 6{
                return false
            }
            break
            
        default:
            break
        }
        return true
    }

   
    
   func textFieldDidBeginEditing(_ textField: UITextField) {
        
        print("textFieldDidBeginEditing")
        
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
                
                if IS_IPAD{
                    
                    self.lblAddress.font = self.lblAddress.font.withSize(12*universalWidthRatio)
                    
                    self.lblAddressTopConst.constant = -55.0
                    
                }else{
                    self.lblAddress.font = self.lblAddress.font.withSize(12*universalWidthRatio)
                    
                    self.lblAddressTopConst.constant = -35.0
                }
                
                self.lblAddressLeadingConst.constant = 0.0
                
                self.layoutIfNeeded()
                
            }, completion: nil)
            

    }
    
    
   func textFieldDidEndEditing(_ textField: UITextField) {
    
        print("textFieldDidEndEditing")
        
         if textField.text?.characters.count == 0 {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                
                if IS_IPAD{
                    
                    self.lblAddress.font = self.lblAddress.font.withSize(14*universalWidthRatio)
                    self.lblAddressTopConst.constant = 16.5
                }else{
                    self.lblAddress.font = self.lblAddress.font.withSize(14*universalWidthRatio)
                    self.lblAddressTopConst.constant = 16.5
                }
                
                
                self.lblAddressLeadingConst.constant = 8.0
                
                self.layoutIfNeeded()
                
                
            }, completion: nil)
            
        }
    
    
    
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    
    }
    
    
    
    
}

