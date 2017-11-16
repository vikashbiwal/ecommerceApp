//
//  SignupViewModel.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 13/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class SignupViewModel {
    var name = ""
    var email = ""
    var mobile = ""
    var passwod = ""
    var confiPassword = ""
    var gender = ""
    var  isAcceptTerm : Bool = true
    var deviceType     = "IOS"
    var instanceId     = ""
    var token          = ""
    
    func isValidModel()-> (Bool, String) {
        if name.characters.count == 0{
            return(false,"NAME".localizedString())
            
        } else if email.characters.count != 0 && !email.isValidEmailAddress(){
            return(false,"EMAIL_VALID".localizedString())
            
        }else if mobile.characters.count == 0{
            return(false,"MOBILE".localizedString())
            
        }else if !mobile.isValidMobileNumber(){
            return(false,"MOBILE_LENGTH".localizedString())
            
        }else if passwod.characters.count == 0{
            return(false,"PASSWORD".localizedString())
            
        }else if passwod.characters.count < 6{
            return(false,"PASSWORD_LENGTH".localizedString())
            
        }else if confiPassword.characters.count == 0{
            return(false,"REENTER_PASSWORD".localizedString())
            
        }else if passwod != confiPassword{
            return(false,"PASSWORD_MATCH".localizedString())
        } else{
            return (true, "Name is required")
        }
        
    }

	/*
	{
	if name.characters.count == 0{
	return(false,"NAME".localizedString())

	} /*else if email.characters.count == 0{
	return(false,"EMAIL".localizedString())

	} */else if email.characters.count > 0 && !email.isValidEmailAddress(){

	return(false,"EMAIL_VALID".localizedString())
	}else if mobile.characters.count == 0{
	return(false,"MOBILE".localizedString())

	}else if !mobile.isValidMobileNumber(){
	return(false,"MOBILE_LENGTH".localizedString())

	}/*else if dob.characters.count == 0{
	return(false,"DOB".localizedString())

	}*/else if passwod.characters.count == 0{
	return(false,"PASSWORD".localizedString())

	}/*else if passwod.characters.count < 6{
	return(false,"PASSWORD_LENGTH".localizedString())

	}*/else if confiPassword.characters.count == 0{
	return(false,"REENTER_PASSWORD".localizedString())

	}else if passwod != confiPassword{
	return(false,"PASSWORD_MATCH".localizedString())
	} else{
	return (true, "Name is required")
	}

	}
	*/

}

//MARK:- API Calls
extension SignupViewModel {

    var signUpAPIParameters: [String : Any] {
        return ["name":name,
                "email" : email,
                "mobile" : mobile,
                "password" : passwod,
                "gender"  : gender,
                "terms_conditions" : isAcceptTerm,
                "deviceType"     : "IOS",
                "instanceId"     : instanceId,
                "token"          : token]
    }
    
    func singup_apiCall( block: @escaping (Bool,String)-> Void) {
        
        wsCall.callSignUp(params: signUpAPIParameters) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [String:Any] {
                    print("SignUP  response is => \(json)")
                    dictUser = User(json)
                    _userDefault.set(json, forKey: AppPreference.userObj)
                    wsCall.setHeaderCustomerId(custId: dictUser.custId)
                }
               block(true,"")
            } else {
               block(false,response.message)
            }
        }
        
    }
}

