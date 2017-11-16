//
//  LoginVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 12/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
/////

import UIKit
import KVAlertView
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn

class LoginVC: ParentViewController {

    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnTwitter: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnLogin: Style1WidthButton!
    @IBOutlet weak var btnForgotPassword: Style1WidthButton!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomTwitterConstraint: NSLayoutConstraint!
    @IBOutlet weak var button_back: UIButton!
    @IBOutlet weak var btnGuest: Style1WidthButton!
    
    var socialUserID = ""
    var socialToken = ""
    var socialType = ""
    var name = ""
    var email = ""
    var profileImagePath = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnLogin.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1, borderColor1: UIColor.darkGray)
        btnFacebook.buttonRoundedCorner(cornerRadius1: 0.5 * btnFacebook.frame.size.width, borderWidth1: 1, borderColor1: .clear)
        btnGoogle.buttonRoundedCorner(cornerRadius1: 0.5 * btnGoogle.frame.size.width, borderWidth1: 1, borderColor1: .clear)
        btnTwitter.buttonRoundedCorner(cornerRadius1: 0.5 * btnTwitter.frame.size.width, borderWidth1: 1, borderColor1: .clear)
        txtUserName.layer.borderColor = UIColor.lightGray.cgColor
        txtPassword.layer.borderColor = UIColor.lightGray.cgColor
        txtUserName.layer.borderWidth = 1.0
        txtPassword.layer.borderWidth = 1.0
        txtUserName.layer.cornerRadius = 5.0
        txtPassword.layer.cornerRadius = 5.0
        if IS_IPAD{
            var vc = containerView.frame
            vc.size.height = 975
            containerView.frame = vc
            self.bottomTwitterConstraint.constant = 80
        } else {
            self.bottomTwitterConstraint.constant = 80
        }
        
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
//        if loginFromTabbar {
//            btnGuest.isHidden = true
//        } else {
//            btnGuest.isHidden = false
//        }
        setBackButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        //containerView.frame = scrollView.bounds

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

    func setBackButtonAction() {
        if let _ = self.tabBarController {
            button_back.setImage(#imageLiteral(resourceName: "ic_menu"), for: .normal)
            button_back.addTarget(self, action: #selector(self.shutterButtonTapped(sender:)), for: .touchUpInside)
            btnGuest.isHidden = true
        } else {
            button_back.setImage(#imageLiteral(resourceName: "ic_arrow_left"), for: .normal)
            button_back.addTarget(self, action: #selector(self.back_buttonClicked(_:)), for: .touchUpInside)
            btnGuest.isHidden = false
        }
    }
   
    @IBAction func btnRegisterClicked(_sender: UIButton){
        let signvc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(signvc, animated: true)
    }
    
    
    @IBAction func btnGuestClicked(_ sender: UIButton) {
        let gvc = self.storyboardLogin.instantiateViewController(withIdentifier:"GuestUserVC") as! GuestUserVC
        self.navigationController?.pushViewController(gvc, animated: true)
    }
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        
        let forgotvc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgotvc, animated: true)
    }
    
    @IBAction func back_buttonClicked(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}



//MARK: KeyBoard Hide or Show or Return Key 
extension LoginVC: UIKeyboardObserver {
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kf.height, right: 0)
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        scrollView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}



//MARK: - Social Login Delegate Methods
extension LoginVC: GIDSignInUIDelegate,GIDSignInDelegate{
    
    @IBAction func btnGoogleClicked(_ sender: UIButton) {
        self.showCentralGraySpinner()
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: - Google Delegate Method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        if let err = error {
            print("Failed to log into Google: ", err)
            self.hideCentralGraySpinner()
            return
        }
        print("Successfully logged into Google", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        self.socialUserID = user.userID                  // For client-side use only!
        self.socialToken = accessToken as String
        self.socialType = "Google"
        self.name = user.profile.name
        self.email = user.profile.email
        self.profileImagePath = user.profile.imageURL(withDimension: 200).absoluteString
        CallLoginApi()
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            
            print("Successfully logged into Firebase with Google", uid)
        })
    }

    
    @IBAction func btnTwitterClicked(_ sender: UIButton) {
        self.showCentralGraySpinner()
        Twitter.sharedInstance().logIn { (session, error) -> Void in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                self.hideCentralGraySpinner()
                return
            }
            self.socialUserID = (session?.userID)!
            self.socialToken = (session?.authToken)!
            self.socialType = "Twitter"
            //self.socialUserName = (session?.userName)!
            
            print("Twitter Credential : \(self.socialUserID) \(self.socialToken)")
            
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
            
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                    return
                } else {
                    if let providerData = Auth.auth().currentUser?.providerData {
                        for item in providerData {
                            print("\(item.providerID)")
                            self.profileImagePath = (item.photoURL?.absoluteString) ?? ""
                            //self.email = item.email!
                            self.name = item.displayName!
                            self.CallLoginApi()
                        }
                    }
                }
                
                print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
                
            })
            
        }

    }
    
    @IBAction func btnFacebookClicked(_ sender: UIButton) {
        
        self.showCentralGraySpinner()
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err)
                self.hideCentralGraySpinner()
                return
            } else if (result?.isCancelled)! {
                print("cancel")
                self.hideCentralGraySpinner()
            } else {
                print(result)
                self.showFacebookEmail()
            }
        }

    }
    
    //MARK: - Facebook Delegate Method
    func showFacebookEmail() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, email, name, first_name, last_name,picture.type(large)"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err?.localizedDescription)
                return
            }
            
            var dictFB = result as! [String:Any]
            print(dictFB)
            if let imageURL = ((dictFB["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                self.profileImagePath = imageURL
            }
            
            self.socialUserID = dictFB["id"]  as! String
            self.socialToken = accessTokenString
            self.socialType = "Facebook"
            self.name = (dictFB["name"]  as? String) ?? ""
            self.email = (dictFB["email"]  as? String) ?? ""
            self.CallLoginApi()
        }
    }

}



//MARK: - Login Button Click and api Call
extension LoginVC{
    @IBAction func btnLoginClicked(_ sender: Style1WidthButton) {
        let (success, errorMessage) = isValidateLogin()
        if success {
            self.email = txtUserName.text!
            self.showCentralGraySpinner()
            CallLoginApi()
        } else {
            KVAlertView.show(message: errorMessage)
        }
    }

    func isValidateLogin()-> (Bool, String){
        if txtUserName.text == ""{
            return (false,"USERNAME".localizedString())
        } else if txtPassword.text == ""{
            return (false,"PASSWORD".localizedString())
        } else {
            return (true,"Success")
        }
    }
    
    func CallLoginApi(){
        
        let isGuestUser : Bool = false
        let dictLogin :[String:Any] = [
            "socialUserId": socialUserID,
            "socialToken" : socialToken,
            "socialType" : socialType,
            "mobile" : "",
            "email" : "",
            "userName" : email,
            "password" : txtPassword.text!,
            "isGuestuser" : isGuestUser,
            "name" : name,
            "image" : profileImagePath,
            "deviceType"       : "IOS",
            "instanceId"       : self.fcmIntanceID,
            "token"            : self.fcmToken]
        
        wsCall.callLogin(params: dictLogin) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [String:Any] {
                    print("SignUP  response is => \(json)")
                    dictUser = User(json)
                     _userDefault.set(json, forKey: AppPreference.userObj)
                    wsCall.setHeaderCustomerId(custId: dictUser.custId)
                   
                }
                self.hideCentralGraySpinner()
                
                if let _ = self.tabBarController {      // Decide Go To Account Screen or Cart Screen
                    let avc = self.storyboardAccount.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
                    self.navigationController?.pushViewController(avc, animated: true)
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)     //For Cart Screen
                }
                
                self.txtUserName.text = ""
                self.txtPassword.text = ""
                getCustomerBalance(block: {success in
                    NotificationCenter.default.post(name: NSNotification.Name("refreshTable"), object: nil)
                })
            } else {
                self.hideCentralGraySpinner()

                KVAlertView.show(message: response.message)
            }
        }
        
    }
}
