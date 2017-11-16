//
//  SignUpVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 12/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class SignUpVC: ParentViewController {

    var arrPlaceHolderName : [String] = []
    var arrImage : [UIImage] = []
    var selectedGender = "M"
    var signupModel = SignupViewModel()
    var singupCellItems = [SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_username"), placeholder: "Name", singupType: SignupFieldType.name),
                           SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_email"), placeholder: "Email", singupType: SignupFieldType.email),
                           SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_mobile"), placeholder: "Mobile Number", singupType: SignupFieldType.mobile),
                           SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_password"), placeholder: "Password", singupType: SignupFieldType.password),
                           SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_password"), placeholder: "Re-enter Password", singupType: SignupFieldType.confiPassword),
                            SignupCellIem( imgIcon: #imageLiteral(resourceName: "ic_gender"), placeholder: "", singupType: SignupFieldType.gender)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        arrPlaceHolderName = ["Name","Email","Mobile Number","Gender","DOB","Password","Re-enter Password"]
        arrImage = [#imageLiteral(resourceName: "ic_username"),#imageLiteral(resourceName: "ic_email"),#imageLiteral(resourceName: "ic_mobile"),#imageLiteral(resourceName: "ic_gender"),#imageLiteral(resourceName: "ic_dateOfBirth"),#imageLiteral(resourceName: "ic_password"),#imageLiteral(resourceName: "ic_password")]
        self.tableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: 0, right: 0)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard))
        tableView.addGestureRecognizer(tap)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

}

extension SignUpVC: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singupCellItems.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell") as! GenderCell
            cell.btnMAle.addTarget(self, action: #selector(btnMaleClicked(_sender:)), for: .touchUpInside)
            cell.btnFemale.addTarget(self, action: #selector(btnFemaleClicked(_sender:)), for: .touchUpInside)
            return cell
            
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell") as! RegisterCell
            cell.btnRegister.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1, borderColor1: UIColor.darkGray)
            cell.btnRegister.addTarget(self, action: #selector(signup_btnClicked(_:)), for: .touchUpInside)
            return cell
            
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "skipCell") as! SkipCell
            cell.btnLoginScreen.addTarget(self, action: #selector(loginScreenButtonClicked(_sender: )), for: .touchUpInside)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! DataCell
            let cellItem = singupCellItems[indexPath.row]
            cell.imgIcon.image = cellItem.imgIcon
            cell.txtdata.placeholder = cellItem.placeholder
            cell.signupType = cellItem.singupType
            
            if indexPath.row == 3 || indexPath.row == 4{
                cell.txtdata.isSecureTextEntry = true
            }
            return cell
           
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 6{
            if IS_IPAD{
                return 105  * universalWidthRatio
            } else {
                return 80 * universalWidthRatio
            }
           
        } else {
            return 50 * universalWidthRatio
        }
        
    }
    
    
    
//MARK: - Gender Button Event
    
    @IBAction func btnMaleClicked(_sender:UIButton){
        let cell = tableView.cellForRow(at:IndexPath(row: 5, section: 0)) as! GenderCell
        _sender.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
        cell.btnFemale.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
        selectedGender = "M"
        
    }
    
    @IBAction func btnFemaleClicked(_sender:UIButton){
        let cell = tableView.cellForRow(at:IndexPath(row: 5, section: 0)) as! GenderCell
        _sender.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
        cell.btnMAle.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)

        selectedGender = "F"
    }

}

extension SignUpVC {
    //MARK: Register Button Click Event
    @IBAction func signup_btnClicked(_ sender: UIButton) {
        signupModel.gender = selectedGender
        signupModel.instanceId = self.fcmIntanceID
        signupModel.token = self.fcmToken
        let (success, errorMessage) = signupModel.isValidModel()
        if success {
            self.showCentralGraySpinner()
            signupModel.singup_apiCall(block: { (success,errmsg) in
                self.hideCentralGraySpinner()
                if success{
                    if let _ = self.tabBarController {      // Decide Go To Account Screen or Cart Screen
                        let avc = self.storyboardAccount.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
                        self.navigationController?.pushViewController(avc, animated: true)
                    } else {
                        self.navigationController?.dismiss(animated: true, completion: nil)     //For Cart Screen
                    }
                    getCustomerBalance(block: {success in
                        NotificationCenter.default.post(name: NSNotification.Name("refreshTable"), object: nil)
                    }) 
                } else {
                    KVAlertView.show(message: errmsg)
                }

            })
        } else {
            KVAlertView.show(message: errorMessage)
        }
    }
    
    @IBAction func loginScreenButtonClicked(_sender: UIButton){
       self.navigationController?.popViewController(animated: false)
    }
}

//MARK: KeyBoard Hide or Show or Return Key
extension SignUpVC: UIKeyboardObserver{
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
}

//MARK: - Text Field Touch Event & Text Changed Event
extension SignUpVC {
    
    @IBAction func textFiledTextChanged(_ tf: TextFiled) {
        switch tf.type {
        case .name:
            signupModel.name = tf.text!
        case .mobile:
            signupModel.mobile = tf.text!
        case .password:
            signupModel.passwod = tf.text!

        case .email:
            signupModel.email = tf.text!
        case .confiPassword:
            signupModel.confiPassword = tf.text!

        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tf = textField as! TextFiled
        
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
        case .mobile:
            if tf.text!.characters.count >= 15{
                return false
            }
            break
        case .password:
            if tf.text!.characters.count >= 20{
                return false
            }
            break
        case .email:
            if tf.text!.characters.count >= 100{
                return false
            }
            break
        case .confiPassword:
            if tf.text!.characters.count >= 20{
                return false
            }
            break
        default:
            break
        }
        return true
    }
    
////MARK: - DatePicker Code
//    @IBAction func textFiledbeginChanged(_ tf: TextFiled) {
//        switch tf.type {
//        case .dob:
//            setDatePickerView(txtField: tf)
//            break
//            
//        default:
//            break
//        }
//    }
//
////MARK : SetDatePicker
//    func setDatePickerView(txtField:TextFiled){
//        let datePickerView:UIDatePicker = UIDatePicker()
//        datePickerView.datePickerMode = UIDatePickerMode.date
//        datePickerView.addTarget(self, action: #selector(onDatePickerValueChanged(picker:)), for: .valueChanged)
//        txtField.inputView = datePickerView
//        
//        // datepicker toolbar setup
//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.barTintColor = UIColor.init(colorLiteralRed: 210.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1.0)
//        toolBar.isTranslucent = true
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(SignUpVC.cancelDatePickerPressed))
//        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(SignUpVC.doneDatePickerPressed))
//        
//        // if you remove the space element, the "done" button will be left aligned
//        // you can add more items if you want
//        toolBar.setItems([cancelButton,space, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        toolBar.sizeToFit()
//        
//        txtField.inputAccessoryView = toolBar
//        
//    }
//    
//// Done Button Event
//    func doneDatePickerPressed(){
//
//		let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! DataCell
//		if cell.txtdata.text?.characters.count == 0 {
//			let picker: UIDatePicker? = (cell.txtdata.inputView as? UIDatePicker)
//			picker?.maximumDate = Date()
//			let dateFormat = DateFormatter()
//			let eventDate: Date? = picker?.date
//			dateFormat.dateFormat = "dd-MMM-yyyy"
//			let dateString: String = dateFormat.string(from: eventDate!)
//
//			cell.txtdata.text = "\(dateString)"
//
//			let dateFormatter = DateFormatter()
//			dateFormatter.dateFormat = "dd-MMM-yyyy"
//			let date1 = dateFormatter.date(from: dateString)
//
//			dateFormatter.dateFormat = "yyyy-MM-dd"
//			let goodDate = dateFormatter.string(from: date1!)
//			signupModel.dob = goodDate
//
//		}
//
//        self.view.endEditing(true)
//    }
//
//
//// Cancel Button Event
//    func cancelDatePickerPressed(){
//        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! DataCell
//        cell.txtdata.text = ""
//        signupModel.dob = ""
//        self.view.endEditing(true)
//    }
//    
//// Change Date Event
//    func onDatePickerValueChanged(picker: UIDatePicker) {
//        
//        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! DataCell
//        //let picker: UIDatePicker? = (cell.txtdata.inputView as? UIDatePicker)
//        picker.maximumDate = Date()
//        let dateFormat = DateFormatter()
//        let eventDate: Date? = picker.date
//        dateFormat.dateFormat = "dd-MMM-yyyy"
//        let dateString: String = dateFormat.string(from: eventDate!)
//        
//        cell.txtdata.text = "\(dateString)"
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MMM-yyyy"
//        let date1 = dateFormatter.date(from: dateString)
//        
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let goodDate = dateFormatter.string(from: date1!)
//        signupModel.dob = goodDate
//
//    }

}

//===============================================================================================
//===============================================================================================

struct SignupCellIem {
    var imgIcon : UIImage
    var placeholder = ""
    var singupType = SignupFieldType.name
}

//MARK:- Sign up Cells
class DataCell : TableViewCell {
    @IBOutlet var txtdata : TextFiled!
    @IBOutlet var imgIcon : UIImageView!
    
    var signupType: SignupFieldType = .name {
        didSet {
          txtdata.type = signupType
          setKeyBoardType()
        }
    }
    
    func setKeyBoardType() {
        switch signupType {
        case .email:
            txtdata.keyboardType = .emailAddress
        case .mobile :
            txtdata.keyboardType = .phonePad
        default:
            txtdata.keyboardType = .default
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtdata.layer.borderColor = UIColor.lightGray.cgColor
        self.txtdata.layer.borderWidth = 1.0
        self.txtdata.layer.cornerRadius = 5.0
        self.txtdata.spellCheckingType = .no
        self.txtdata.autocorrectionType = .no
    }
}

class GenderCell : TableViewCell {
    @IBOutlet var btnMAle : UIButton!
    @IBOutlet var btnFemale : UIButton!
    
}

class RegisterCell : TableViewCell {
    @IBOutlet var btnRegister : UIButton!
}

class SkipCell : TableViewCell {
    @IBOutlet var btnLoginScreen : UIButton!
    @IBOutlet var btnSkip : UIButton!
}

enum SignupFieldType {
    case name, email, mobile, password, confiPassword, gender, dob
}

class TextFiled: UITextField {
    var type = SignupFieldType.name
}



