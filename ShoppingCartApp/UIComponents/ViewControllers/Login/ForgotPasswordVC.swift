//
//  ForgotPasswordVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 15/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class ForgotPasswordVC: ParentViewController,UIKeyboardObserver {
    
    @IBOutlet weak var txtForgotEmail: UITextField!

    @IBOutlet weak var btnForgotSend: Style1WidthButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnForgotSend.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1, borderColor1: UIColor.darkGray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
        if txtForgotEmail.text!.characters.count >= 35{
            return false
        } else {
            return true
        }
        
    }


    @IBAction func btnForgotSendClicked(_ sender: Style1WidthButton) {
        if txtForgotEmail.text == ""{
            KVAlertView.show(message: "EMAIL".localizedString())
        } else if !(txtForgotEmail.text?.isValidEmailAddress())!{
            KVAlertView.show(message: "EMAIL_VALID".localizedString())
        } else {
            callForgotApi()
        }
    }
    
    func callForgotApi(){
        self.showCentralGraySpinner()
        let dictForgot :[String:Any] = [
            "UserName": txtForgotEmail.text!]
        
        wsCall.callForgotPassword(params: dictForgot) { (response) in
            if response.isSuccess {
                self.hideCentralGraySpinner()
                KVAlertView.show(message: "Please check your email to retrieve password")
                if let json = response.json as? [[String:Any]] {
                    print("  response is => \(json)")
                    
                                        
                }
                self.txtForgotEmail.text = ""
                
                self.navigationController?.popViewController(animated: false)

            } else {
                self.hideCentralGraySpinner()

                KVAlertView.show(message: response.message)
            }
        }
        
      
    }
}
