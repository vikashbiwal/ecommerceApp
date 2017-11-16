//
//  FeedbackVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 24/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class FeedbackVC: ParentViewController {
    
    @IBOutlet weak var tblFeedback: UITableView!
    
    @IBOutlet weak var btnSendFeedback: UIButton!
    
    let feedbackModel = FeedbackModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
        
        if UserDefaults.standard.value(forKey: AppPreference.userObj) != nil{
            let userJson = UserDefaults.standard.value(forKey: AppPreference.userObj) as! [String : Any]
            dictUser = User(userJson)
            
            feedbackModel.name = (dictUser.name)
            feedbackModel.contactNo = (dictUser.mobile)
            feedbackModel.email = (dictUser.email)
        }

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

    
    // MARK: send feedback button pressed
    
    @IBAction func btnSendFeedbackPressed(_ sender: UIButton) {
        
        let (success, errorMessage) = feedbackModel.isFeedbackValidModel()
        if success {
            
            
           // self.showCentralGraySpinner()
            
        } else {
            KVAlertView.show(message: errorMessage)
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension FeedbackVC: UITableViewDelegate, UITableViewDataSource, UIKeyboardObserver, UITextViewDelegate{
    
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if IS_IPAD{
            
            if indexPath.section == 4 {
                return 155
            }else {
                return 75
            }
            
        }else{
            
            
            if indexPath.section == 4 {
                return 145
            }else {
                return 55
            }
        }
        
        
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.section == 4 {
            
            let cellIdentifier = "AddFeedbackTextViewCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! addFeedbackCell
            
            cell.textVFeedback.layer.cornerRadius = 5.0
            cell.textVFeedback.layer.masksToBounds = true
            
            let borderColor = UIColor.init(red: 204.0/255.0, green:204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            
            cell.textVFeedback.layer.borderWidth = 0.5
            cell.textVFeedback.layer.borderColor =  borderColor.cgColor
            
            cell.lblFeedbackTextView.text = "LABLE_COMMENT".localizedString()
            
            return cell

        }else{
            
            let cellIdentifier = "AddFeedbackTextFieldCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! addFeedbackCell
            
            var strValue:String = ""
            
            strValue = strTextFieldValue(indexPath: indexPath as IndexPath)
            
            cell.lblFeedbackTextField.text = self.cellLabelTitle(indexPath: indexPath)
            
            if strValue != "" {
                
                cell.txtFeedback.text = strValue
                
            }
            
            
            if indexPath.section == 0 {
                cell.FeedbackType =  FeedbackType.name
            }else if (indexPath.section == 1){
                cell.FeedbackType =  FeedbackType.email
            }else if (indexPath.section == 2){
                cell.FeedbackType =  FeedbackType.contactNo
            }else if (indexPath.section == 3){
                cell.FeedbackType =  FeedbackType.topic
            }
           
            
            return cell
            
        }
        
    }
    
    
    func strTextFieldValue(indexPath: IndexPath) -> String {
        
        var strValue:String = ""
        
        if indexPath.section == 0 {
            
            strValue = feedbackModel.name
            
        }else if (indexPath.section == 1){
            
            strValue = feedbackModel.email
            
        }else if (indexPath.section == 2){
            
            strValue = feedbackModel.contactNo
            
        }
        return strValue
    }
    
    func cellLabelTitle(indexPath: IndexPath) ->  String{
        
        var strTitle:String = ""
        
        if indexPath.section == 0 {
            strTitle = "LABLE_NAME".localizedString()
        }else if (indexPath.section == 1){
            strTitle = "LABEL_EMAIL_ADDRESS".localizedString()
        }else if (indexPath.section == 2){
             strTitle = "LABLE_CONTACT_NUMBER".localizedString()
        }else if (indexPath.section == 3){
            strTitle = "LABLE_TOPIC".localizedString()
        }
        
        return strTitle
        
    }
    
    
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tblFeedback.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tblFeedback.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
            
            let indexPath = NSIndexPath(row: 0, section: 4)
            
            self.tblFeedback.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            
            let cell = self.tblFeedback.cellForRow(at: indexPath as IndexPath) as! addFeedbackCell
            
            if IS_IPAD{
                
                cell.lblFeedbackTextView.font = cell.lblFeedbackTextView.font.withSize(12*universalWidthRatio)
                
                cell.lblFeedbackTextViewTopConst.constant = -2.0
                
            }else{
                cell.lblFeedbackTextView.font = cell.lblFeedbackTextView.font.withSize(12*universalWidthRatio)
                
                cell.lblFeedbackTextViewTopConst.constant = -7.0
            }
            
            
            cell.lblFeedbackTextViewLeadingConst.constant = 0.0
            
            cell.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    
    
    func textViewDidEndEditing(_ textField: UITextView) {
        print("textViewDidEndEditing")
        
        
        if textField.text.characters.count == 0 {
            
            let indexPath = NSIndexPath(row: 0, section: 4)
            
            let cell = self.tblFeedback.cellForRow(at: indexPath as IndexPath) as! addFeedbackCell
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                
                if IS_IPAD{
                    
                    cell.lblFeedbackTextView.font = cell.lblFeedbackTextView.font.withSize(14*universalWidthRatio)
                    cell.lblFeedbackTextViewTopConst.constant = 30
                    
                    
                }else{
                    cell.lblFeedbackTextView.font = cell.lblFeedbackTextView.font.withSize(14*universalWidthRatio)
                    cell.lblFeedbackTextViewTopConst.constant = 16.5
                }
                
                
                cell.lblFeedbackTextViewLeadingConst.constant = 8.0
                
                cell.layoutIfNeeded()
                
                
            }, completion: nil)
        }
        
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        print(textView.text);
        let textFieldText: NSString = (textView.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: text)
        
        print("txtAfterUpdate\(txtAfterUpdate)");
        
        feedbackModel.comment = txtAfterUpdate
        
        return true
        
    }

}

extension FeedbackVC{
    
    @IBAction func textFiledTextChanged(_ tf: FeedBackTextFiled) {
        
        switch tf.type {
        case .name:
            feedbackModel.name = tf.text!
        case .email:
           feedbackModel.email = tf.text!
        case .contactNo:
            feedbackModel.contactNo = tf.text!
        case .topic:
            feedbackModel.topic = tf.text!
        default:
            break
        }
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
        
        feedbackModel.comment = textView.text
        
    }
}

enum FeedbackType {
    case name,email,contactNo,topic
}

class FeedBackTextFiled: UITextField {
    var type = FeedbackType.name
}

class addFeedbackCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var txtFeedback: FeedBackTextFiled!
    
    @IBOutlet weak var lblFeedbackTextField: WidthLabel!
    
    @IBOutlet weak var textVFeedback: WidthTextView!
    
    @IBOutlet weak var lblFeedbackTextView: WidthLabel!
    
    @IBOutlet weak var lblFeedbackTextFieldTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblFeedbackTextFieldLeadingConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblFeedbackTextViewTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var lblFeedbackTextViewLeadingConst: NSLayoutConstraint!
    
    var FeedbackType: FeedbackType = .name {
        didSet {
            txtFeedback.type = FeedbackType
            setKeyBoardType()
        }
    }
    
    func setKeyBoardType() {
        
        let tooBar: UIToolbar = UIToolbar()
        tooBar.backgroundColor = UIColor.init(red: 209.0/255.0, green: 210.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        tooBar.tintColor = UIColor.darkGray
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(addFeedbackCell.donePressed))]
        tooBar.sizeToFit()
        
        
        switch FeedbackType {
            
        case .email:
            txtFeedback.keyboardType = .emailAddress
            
        case .contactNo :
            txtFeedback.keyboardType = .numberPad
            txtFeedback.inputAccessoryView = tooBar
            
            default:
            txtFeedback.keyboardType = .default
        }
    }
    
    func donePressed () {
        txtFeedback.resignFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if txtFeedback != nil {
            if txtFeedback.text!.isEmpty {
                
                if lblFeedbackTextField != nil {
                    
                    if IS_IPAD{
                        
                        self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(14*universalWidthRatio)
                        self.lblFeedbackTextFieldTopConst.constant = 16.5
                    }else{
                        self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(14*universalWidthRatio)
                        self.lblFeedbackTextFieldTopConst.constant = 16.5
                    }
                    
                    
                    self.lblFeedbackTextFieldLeadingConst.constant = 8.0
                    
                }
                
                
                
            } else {
                
                if lblFeedbackTextField != nil {
                    
                    if IS_IPAD{
                        
                        self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(12*universalWidthRatio)
                        
                        self.lblFeedbackTextFieldTopConst.constant = -55.0
                        
                    }else{
                        self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(12*universalWidthRatio)
                        
                        self.lblFeedbackTextFieldTopConst.constant = -35.0
                    }
                    
                    self.lblFeedbackTextFieldLeadingConst.constant = 0.0
                    
                    
                }
                
            }
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tf = textField as! FeedBackTextFiled
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            return true
        }
        switch tf.type {
       
        case .contactNo:
            if tf.text!.characters.count >= 15{
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
                
                self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(12*universalWidthRatio)
                
                self.lblFeedbackTextFieldTopConst.constant = -55.0
                
            }else{
                self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(12*universalWidthRatio)
                
                self.lblFeedbackTextFieldTopConst.constant = -35.0
            }
            
            self.lblFeedbackTextFieldLeadingConst.constant = 0.0
            
            self.layoutIfNeeded()
            
        }, completion: nil)
        
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        print("textFieldDidEndEditing")
        
        if textField.text?.characters.count == 0 {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                
                if IS_IPAD{
                    
                    self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(14*universalWidthRatio)
                    self.lblFeedbackTextFieldTopConst.constant = 16.5
                }else{
                    self.lblFeedbackTextField.font = self.lblFeedbackTextField.font.withSize(14*universalWidthRatio)
                    self.lblFeedbackTextFieldTopConst.constant = 16.5
                }
                
                
                self.lblFeedbackTextFieldLeadingConst.constant = 8.0
                
                self.layoutIfNeeded()
                
                
            }, completion: nil)
            
        }
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }

    

}
