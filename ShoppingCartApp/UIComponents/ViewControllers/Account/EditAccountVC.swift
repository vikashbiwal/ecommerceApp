//
//  EditAccountVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class EditAccountVC: ParentViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var arrPlaceHolderName : [String] = []
    var arrImage : [UIImage] = []
    var selectedGender = "M"
    
    @IBOutlet weak var accountBlurImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var btnSelectProfileImg: UIButton!
    
    var imageData : Data!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var editAccountModel = EditAccountModel()
    
    var selectedDate:String = ""
    
    var isBirthDate:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
       // self.activityIndicator.isHidden = false
        
        profileImage.layer.cornerRadius = 5.0
        profileImage.layer.masksToBounds = true
        
        if UserDefaults.standard.value(forKey: AppPreference.userObj) != nil{
            let userJson = UserDefaults.standard.value(forKey: AppPreference.userObj) as! [String : Any]
            dictUser = User(userJson)
        }
        
       
        if !dictUser.image.isEmpty {
            
            
            let imgUrl = getImageUrlWithSize(urlString: (dictUser.image), size:  self.accountBlurImage.frame.size)
            
            print("imgUrl:\(imgUrl)")
            
            self.accountBlurImage.setImage(url: imgUrl, placeholder: UIImage(), completion: {
                (img) in
                
                if img != nil {
                    
                    
                    self.accountBlurImage.image=self.bluredImage(view: self.view)
                    
                    
                }
            })
            
            let imgUrl2 = getImageUrlWithSize(urlString: (dictUser.image), size:  self.profileImage.frame.size)
            
            
            self.profileImage.setImage(url: imgUrl2, placeholder: UIImage(), completion: {
                (img) in
                
                if img != nil {
                    
                    //self.hideProfileCentralGraySpinner()
                    // self.showCentralSpinner()
                    
                    self.profileImage.image = img
                    
                }else{
                    
                    self.profileImage.image = UIImage.init(named: "ic_account")
                }
            })
        }else{
            
            //self.activityIndicator.isHidden = true
            self.accountBlurImage.backgroundColor = UIColor.lightGray
            
           // self.viewNoImage.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            
            self.accountBlurImage.layer.borderColor = UIColor.white.cgColor
            self.accountBlurImage.contentMode = .scaleAspectFill
            self.accountBlurImage.layer.borderWidth = 1.0
        }
        
        if !dictUser.gender.isEmpty || dictUser.gender != "" {
             selectedGender = dictUser.gender
        }
        
       

        
        print("dictUser.image:\(dictUser.image)")
        
        editAccountModel.customerId = Converter.toInt(dictUser.custId)
        editAccountModel.Image = dictUser.image
        editAccountModel.firstName = dictUser.name
        editAccountModel.email = dictUser.email
        editAccountModel.mobile = dictUser.mobile
        editAccountModel.dob = dictUser.birthDate
        editAccountModel.gender = selectedGender
        editAccountModel.relativeImage = dictUser.relativePath
        
      //  self.accountBlurImage.image=self.bluredImage(view: self.view)
        
        if(!editAccountModel.dob.isEmpty || editAccountModel.dob != ""){
            
            let dateF = DateFormatter()
            dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let firstDate = dateF.date(from: editAccountModel.dob)
            dateF.dateFormat = "dd-MMM-yyyy"
            let newDateString = dateF.string(from: firstDate!)
            selectedDate = newDateString
            
        }
        
        tableView.layer.cornerRadius = 7.0
        tableView.layer.masksToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditAccountVC.dismissKeyboard))
        tableView.addGestureRecognizer(tap)
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    
    //MARK: - Blur Effect to UIImageView
    func snapShotImage() -> UIImage {
        UIGraphicsBeginImageContext(accountBlurImage.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.accountBlurImage.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
        
        return UIImage()
    }
    
    
    func bluredImage(view:UIView, radius:CGFloat = 2) -> UIImage {
        let image = self.snapShotImage()
        
        if let source = image.cgImage {
            let context = CIContext(options: nil)
            let inputImage = CIImage(cgImage: source)
            
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter?.setDefaults()
            clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
            
            if let clampedImage = clampFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                let explosureFilter = CIFilter(name: "CIExposureAdjust")
                explosureFilter?.setValue(clampedImage, forKey: kCIInputImageKey)
                explosureFilter?.setValue(-1.0, forKey: kCIInputEVKey)
                
                if let explosureImage = explosureFilter?.value(forKey: kCIOutputImageKey) as? CIImage {
                    let filter = CIFilter(name: "CIGaussianBlur")
                    filter?.setValue(explosureImage, forKey: kCIInputImageKey)
                    filter?.setValue("\(radius)", forKey:kCIInputRadiusKey)
                    
                    if let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
                        let bounds = accountBlurImage.bounds
                        let cgImage = context.createCGImage(result, from: bounds)
                        let returnImage = UIImage(cgImage: cgImage!)
                        return returnImage
                    }
                }
            }
        }
        return UIImage()
    }

    
    @IBAction func btnBackClicked(_ sender: Any) {
        
        _appDelegator.isBackToAccountScreen = true
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnUpdateAccountClicked(_ sender: Any) {
        
        
        if(imageData != nil){
        
            
            
            let (success, errorMessage) = editAccountModel.isAccountValidModel()
            if success {
                
                self.showCentralGraySpinner()
                uploadImageOnServer(imageData1: imageData as Data)
                
            } else {
                KVAlertView.show(message: errorMessage)
            }

            
        
        }else{
            
            let (success, errorMessage) = editAccountModel.isAccountValidModel()
            if success {
                
                
                self.showCentralGraySpinner()
                editAccountModel.profileUpdate_apiCall(block: { success in
                    
                    self.hideCentralGraySpinner()
                    
                    
                    if (success == true){
                        
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    
                })
            } else {
                KVAlertView.show(message: errorMessage)
            }

            
        }
        
        
    }
    
    @IBAction func btnSelectUserProfilePhoto(_ sender: UIButton) {
        
        // Initialize Alert Controller
        let alertController = UIAlertController(title: "Choose Image", message: "", preferredStyle: .actionSheet)
        
        // Initialize Actions
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) -> Void in
            println("Camera.")
            self.useCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) { (action) -> Void in
            println("Gallery.")
            self.usePhotoPicker(sender: sender)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            println("Cancel.")
            
        }
        
        // Add Actions
        alertController.addAction(cameraAction)
        alertController.addAction(gallaryAction)
        alertController.addAction(cancelAction)
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func useCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.allowsEditing = true
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            //let alertView  = showAlert("Profile", delegate: delegate, message: "You have no Camera...")
        }
    }
    
    func usePhotoPicker(sender: UIButton){
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        
        if IS_IPAD{
            picker.popoverPresentationController?.sourceView = self.view
            picker.popoverPresentationController?.sourceRect = sender.frame;
        }
        
        present(picker, animated: true, completion: nil)
        //picker.popoverPresentationController?.barButtonItem = sender
    }
    
    // MARK: - upload profile image
    
    func uploadImageOnServer(imageData1 : Data){
        
        
        wsCall.callProfileImageUpload(profileImage: imageData1) { (response) in
            if response.isSuccess {
                if let json = response.json as? [String:Any] {
                    
                    print("json\(json)")
                    
                    self.editAccountModel.relativeImage = json["relativePath"] as! String
                    
                    self.editAccountModel.profileUpdate_apiCall(block: { success in
                        
                    self.hideCentralGraySpinner()
                        
                        
                        if (success == true){
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                        
                    })

                    
                    
                }
            }
            
        }
        
        
    }
    
    //MARK: - ImagePicker Controller Delegate Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
             self.accountBlurImage.image = chosenImage
            
            self.profileImage.image = chosenImage
            
            self.accountBlurImage.image=self.bluredImage(view: self.view)
            
            imageData = UIImageJPEGRepresentation(chosenImage, 0.7) as Data!
        
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    

}

extension EditAccountVC{
    
    @IBAction func textFiledTextChanged(_ tf: AccountTextFiled) {
        switch tf.type {
        case .name:
            editAccountModel.firstName = tf.text!
        case .mobile:
            editAccountModel.mobile = tf.text!
        case .email:
            editAccountModel.email = tf.text!
        case .dob:
            editAccountModel.dob = tf.text!
       
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let tf = textField as! AccountTextFiled
        
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
        case .email:
            if tf.text!.characters.count >= 100{
                return false
            }
            break
       
            default:
            break
        }
        return true
    }
    @IBAction func textFiledbeginChanged(_ tf: AccountTextFiled) {
       
        switch tf.type {
        case .dob:
            setDatePickerView(txtField: tf)
            break
            
        default:
            break
        }
    }

    //MARK: SetDatePicker
    func setDatePickerView(txtField:AccountTextFiled){
        
        
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(onDatePickerValueChanged(picker:)), for: .valueChanged)
        txtField.inputView = datePickerView
        
        // datepicker toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor.init(colorLiteralRed: 210.0/255.0, green: 213.0/255.0, blue: 219.0/255.0, alpha: 1.0)
        toolBar.isTranslucent = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(EditAccountVC.cancelDatePickerPressed))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(EditAccountVC.doneDatePickerPressed))
        
        // if you remove the space element, the "done" button will be left aligned
        // you can add more items if you want
        toolBar.setItems([cancelButton,space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        txtField.inputAccessoryView = toolBar
        
    }
    
    // Done Button Event
    func doneDatePickerPressed(){

		let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountDataCell
		if cell.txtdata.text?.characters.count == 0 {
			let picker: UIDatePicker? = (cell.txtdata.inputView as? UIDatePicker)
			picker?.maximumDate = Date()
			let dateFormat = DateFormatter()
			let eventDate: Date? = picker?.date
			dateFormat.dateFormat = "dd-MM-yyyy"
			let dateString: String = dateFormat.string(from: eventDate!)

			cell.txtdata.text = "\(dateString)"
			dateFormat.dateFormat = "yyyy-MM-dd"
			let dateString2: String = dateFormat.string(from: eventDate!)

			editAccountModel.dob = dateString2

		}


        isBirthDate = true

        self.view.endEditing(true)
    }
    
    
    // Cancel Button Event
    func cancelDatePickerPressed(){
        
        if isBirthDate == false {
            
            let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountDataCell
            
            if selectedDate != "" {

                cell.txtdata.text = selectedDate
                editAccountModel.dob = selectedDate
            }else{
                cell.txtdata.text = ""
                editAccountModel.dob = ""
            }

        }
        
        self.view.endEditing(true)
    }
    
    // Change Date Event
    func onDatePickerValueChanged(picker: UIDatePicker) {
        
        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountDataCell
        //let picker: UIDatePicker? = (cell.txtdata.inputView as? UIDatePicker)
        picker.maximumDate = Date()
        let dateFormat = DateFormatter()
        let eventDate: Date? = picker.date
        dateFormat.dateFormat = "dd-MMM-yyyy"
        let dateString: String = dateFormat.string(from: eventDate!)
        
        cell.txtdata.text = "\(dateString)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let date1 = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let goodDate = dateFormatter.string(from: date1!)
        editAccountModel.dob = goodDate
        
    }
    
}

//===============================================================================================
//===============================================================================================


//MARK: KeyBoard Hide or Show or Return Key
extension EditAccountVC: UIKeyboardObserver{
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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


extension EditAccountVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
       /* if indexPath.row == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! AccountDataCell
            
            cell.imgIcon.image = #imageLiteral(resourceName: "ic_dateOfBirth")
            cell.txtdata.placeholder = "DOB"
            cell.accountType = AccountFieldType.dob
            
            if(!editAccountModel.dob.isEmpty || editAccountModel.dob != ""){
                
                let dateF = DateFormatter()
                dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let firstDate = dateF.date(from: editAccountModel.dob)
                dateF.dateFormat = "dd-MMM-yyyy"
                let newDateString = dateF.string(from: firstDate!)
                 cell.txtdata.text = newDateString
                
            }
            
            let datePicker = UIDatePicker()
            datePicker.date = Date()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(self.dateTextField), for: .valueChanged)
            cell.txtdata.inputView = datePicker
            
            return cell
            
        }else*/ if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "genderCell") as! AccountGenderCell
            
             if(!editAccountModel.gender.isEmpty || editAccountModel.gender != ""){
                
                selectedGender = editAccountModel.gender
                
                if selectedGender == "M" {
                    
                    cell.btnMAle.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
                    cell.btnFemale.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
                    
                }else{
                 
                    cell.btnFemale.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
                    cell.btnMAle.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
                }
                
                
             }else{
                
                selectedGender = "M"
                
                cell.btnMAle.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
                cell.btnFemale.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
            }
            
            
            cell.btnMAle.addTarget(self, action: #selector(btnMaleClicked(_sender:)), for: .touchUpInside)
            cell.btnFemale.addTarget(self, action: #selector(btnFemaleClicked(_sender:)), for: .touchUpInside)
            return cell
            
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell") as! AccountRegisterCell
            cell.btnRegister.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1, borderColor1: UIColor.darkGray)
           // cell.btnRegister.addTarget(self, action: #selector(signup_btnClicked(_:)), for: .touchUpInside)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! AccountDataCell
           // let cellItem = AccountCellItems[indexPath.row]
            
            if indexPath.row == 0 {
                cell.imgIcon.image = #imageLiteral(resourceName: "ic_username")
                cell.txtdata.placeholder = "Name"
                cell.accountType = AccountFieldType.name
                
                if(!editAccountModel.firstName.isEmpty){
                    
                    cell.txtdata.text = editAccountModel.firstName
                }
                
            }else if(indexPath.row == 1){
            
                cell.imgIcon.image = #imageLiteral(resourceName: "ic_email")
                cell.txtdata.placeholder = "Email"
                cell.accountType = AccountFieldType.email
                
                if(!editAccountModel.email.isEmpty || editAccountModel.email != ""){
                    
                    cell.txtdata.text = editAccountModel.email
                }
            
            }else if(indexPath.row == 2){
                
                
                cell.imgIcon.image = #imageLiteral(resourceName: "ic_mobile")
                cell.txtdata.placeholder = "Mobile Number"
                cell.accountType = AccountFieldType.mobile
                
                if(!editAccountModel.mobile.isEmpty || editAccountModel.mobile != ""){
                    
                    cell.txtdata.text = editAccountModel.mobile
                }
                
            }
            
                       
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4{
            if IS_IPAD{
                return 105  * universalWidthRatio
            } else {
                return 80 * universalWidthRatio
            }
            
        } else {
            return 50 * universalWidthRatio
        }
        
    }
    
    //MARK: - Open DatePicker for Date Of Birth Field
    func dateTextField(_ sender: Any) {
        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountDataCell
        let picker: UIDatePicker? = (cell.txtdata.inputView as? UIDatePicker)
        picker?.maximumDate = Date()
        let dateFormat = DateFormatter()
        let eventDate: Date? = picker?.date
        dateFormat.dateFormat = "dd-MM-yyyy"
        let dateString: String = dateFormat.string(from: eventDate!)
        
        cell.txtdata.text = "\(dateString)"
        dateFormat.dateFormat = "yyyy-MM-dd"
        let dateString2: String = dateFormat.string(from: eventDate!)
        
        editAccountModel.dob = dateString2
    }
    
    //MARK: - Gender Button Event
    
    @IBAction func btnMaleClicked(_sender:UIButton){
        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountGenderCell
        _sender.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
        cell.btnFemale.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
        selectedGender = "M"
        editAccountModel.gender = selectedGender
        
    }
    
    @IBAction func btnFemaleClicked(_sender:UIButton){
        let cell = tableView.cellForRow(at:IndexPath(row: 3, section: 0)) as! AccountGenderCell
        _sender.setImage(#imageLiteral(resourceName: "ic_genderSelect"), for: .normal)
        cell.btnMAle.setImage(#imageLiteral(resourceName: "ic_gendernotSelect"), for: .normal)
        selectedGender = "F"
        editAccountModel.gender = selectedGender
    }

}

//===============================================================================================
//===============================================================================================

struct AccountCellIem {
    var imgIcon : UIImage
    var placeholder = ""
    var accountFieldType = AccountFieldType.name
    var value = ""
}

// MARK:- account Cell

class AccountDataCell : TableViewCell {
    
    @IBOutlet var txtdata : AccountTextFiled!
    @IBOutlet var imgIcon : UIImageView!
    
    var accountType: AccountFieldType = .name {
        didSet {
            txtdata.type = accountType
            setKeyBoardType()
        }
    }
    
    func setKeyBoardType() {
        
        let tooBar: UIToolbar = UIToolbar()
        tooBar.backgroundColor = UIColor.init(red: 209.0/255.0, green: 210.0/255.0, blue: 212.0/255.0, alpha: 1.0)
        tooBar.tintColor = UIColor.darkGray
        tooBar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(AccountDataCell.donePressed))]
        tooBar.sizeToFit()

        
        switch accountType {
        case .email:
            txtdata.keyboardType = .emailAddress
        case .mobile :
            txtdata.keyboardType = .phonePad
            txtdata.inputAccessoryView = tooBar
        default:
            txtdata.keyboardType = .default
        }
    }
    
    func donePressed () {
        txtdata.resignFirstResponder()
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


class AccountGenderCell : TableViewCell {
    @IBOutlet var btnMAle : UIButton!
    @IBOutlet var btnFemale : UIButton!
    
}

class AccountRegisterCell : TableViewCell {
    @IBOutlet var btnRegister : UIButton!
}

enum AccountFieldType {
    case name, email, mobile, profileImage, gender, dob
}

class AccountTextFiled: UITextField {
    var type = AccountFieldType.name
}
