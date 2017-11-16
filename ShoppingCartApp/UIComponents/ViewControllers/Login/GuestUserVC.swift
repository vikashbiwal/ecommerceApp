//
//  GuestUserVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 15/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class GuestUserVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.contentInset = UIEdgeInsets(top: 250 * universalWidthRatio, left: 0, bottom: 0, right: 0)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard))
        tableView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension GuestUserVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell1") as! GuestRegisterCell
            cell.btnGuestRegister.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1, borderColor1: UIColor.darkGray)
            cell.btnGuestRegister.addTarget(self, action: #selector(btnGuestRegisterClicked(_:)), for: .touchUpInside)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell1") as! GuestDataCell
            
            if indexPath.row == 0{
                cell.txtGuest.placeholder = "Name"
                cell.txtGuest.keyboardType = .default
                cell.imgIconGuest.image = #imageLiteral(resourceName: "ic_username")
              
            } else {
                cell.txtGuest.placeholder = "Mobile Number"
                cell.txtGuest.keyboardType = .phonePad
                cell.imgIconGuest.image = #imageLiteral(resourceName: "ic_mobile")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2{
            return 80 * universalWidthRatio
        } else {
            return 50 * universalWidthRatio
        }
        
    }
    
}


//MARK:- Guest Cells
class GuestDataCell : TableViewCell {
    @IBOutlet var txtGuest : TextFiled!
    @IBOutlet var imgIconGuest : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtGuest.layer.borderColor = UIColor.lightGray.cgColor
        self.txtGuest.layer.borderWidth = 1.0
        self.txtGuest.layer.cornerRadius = 5.0
        self.txtGuest.spellCheckingType = .no
        self.txtGuest.autocorrectionType = .no
    }
}


class GuestRegisterCell : TableViewCell {
    @IBOutlet var btnGuestRegister : UIButton!
}


//MARK: KeyBoard Hide or Show or Return Key
extension GuestUserVC: UIKeyboardObserver{
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // For BackSpace
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            return true
        }
        
        let cell = tableView.cellForRow(at:IndexPath(row: 0, section: 0)) as! GuestDataCell
        let cellMobile = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GuestDataCell
        if cell.txtGuest.text!.characters.count >= 25{
            return false
        } else if cellMobile.txtGuest.text!.characters.count >= 15{
            return false
        } else {
            return true
        }
        
    }
}

extension GuestUserVC{
    
    @IBAction func btnGuestRegisterClicked(_ sender: UIButton) {
        let (success, errorMessage) = isValidateLogin()
        if success {
            CallGuestApi()
        } else {
            KVAlertView.show(message: errorMessage)
        }
    }
    
    func isValidateLogin()-> (Bool, String){
        let cell = tableView.cellForRow(at:IndexPath(row: 0, section: 0)) as! GuestDataCell
        let cellMobile = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GuestDataCell
        
        if cell.txtGuest.text == ""{
            return (false,"NAME".localizedString())
        } else if cellMobile.txtGuest.text == ""{
            return (false,"MOBILE".localizedString())
        } else if !(cellMobile.txtGuest.text?.isValidMobileNumber())!{
            return (false,"MOBILE_LENGTH".localizedString())
        }else {
            return (true,"Success")
        }
    }
    
    func CallGuestApi(){
        self.showCentralGraySpinner()
        let cell = tableView.cellForRow(at:IndexPath(row: 0, section: 0)) as! GuestDataCell
        let cellMobile = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GuestDataCell
        let isGuestUser : Bool = true
       
        let dictLogin :[String:Any] = [
            "socialUserId": "",
            "socialToken" : "",
            "socialType" : "",
            "name"  : cell.txtGuest.text!,
            "mobile" : cellMobile.txtGuest.text!,
            "email" : "",
            "userName" : "",
            "password" : "",
            "isGuestuser" : isGuestUser]
        
        wsCall.callLogin(params: dictLogin) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [String:Any] {
                    print("Guest  response is => \(json)")
                    dictUser = User(json)
                    _userDefault.set(json, forKey: AppPreference.userObj)
                    wsCall.setHeaderCustomerId(custId: dictUser.custId)
                }
                
                self.hideCentralGraySpinner()
                cell.txtGuest.text = ""
                cellMobile.txtGuest.text = ""
                self.navigationController?.dismiss(animated: true, completion: nil)     //For Cart Screen
                
            } else {
                 self.hideCentralGraySpinner()
                KVAlertView.show(message: response.message)
            }
        }
        
    }
}

