//
//  EditAccountModel.swift
//  ShoppingCartApp
//
//  Created by zoomi on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation


class EditAccountModel {
    
    var customerId = 0
    var firstName = ""
    var lastName = ""
    var email = ""
    var mobile = ""
    var gender = ""
    var dob = ""
    var address = ""
    var Image = ""
    var isActive = true
    var isGuestUser = true
    var password = ""
    var relativeImage = ""
    
    
     func isAccountValidModel()-> (Bool, String) {
        
        if firstName.characters.count == 0{
            return(false,"NAME".localizedString())
            
        } else if email.characters.count == 0{
            return(false,"EMAIL".localizedString())
            
        }else if !email.isValidEmailAddress(){
            return(false,"EMAIL_VALID".localizedString())
            
        }/*else if email.characters.count > 0 && !email.isValidEmailAddress(){
            return(false,"EMAIL_VALID".localizedString())
            
        }*/else if mobile.characters.count == 0{
            return(false,"MOBILE".localizedString())
            
        }else if !mobile.isValidMobileNumber(){
            return(false,"MOBILE_LENGTH".localizedString())
            
        }else if dob.characters.count == 0{
            return(false,"DOB".localizedString())
            
        }else{
            
            return (true, "")
        }
        
    }
    
}


extension EditAccountModel{
    
    var EditAccountApiParam: [String : Any]{
        
        return ["customerId":customerId,
                "name":firstName,
                "email":email,
                "mobile":mobile,
                "gender":gender,
                "dob":dob,
                "isActive":true,
                "Image":relativeImage
        ]
    }
    
    func profileUpdate_apiCall( block: @escaping (Bool)-> Void) {
        
        print("EditAccountApiParam:\(EditAccountApiParam)")
        
        wsCall.callProfileUpdate(params: EditAccountApiParam) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [String:Any] {
                    print("SignUP  response is => \(json)")
                    dictUser = User(json)
                    _userDefault.set(json, forKey: AppPreference.userObj)

                }
                block(true)
            } else {
                block(false)
            }
        }
        
    }
    
}
