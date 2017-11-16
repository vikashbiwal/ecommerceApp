//
//  FeedbackModel.swift
//  ShoppingCartApp
//
//  Created by zoomi on 24/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class FeedbackModel{
    
    var name = ""
    var email = ""
    var contactNo = ""
    var topic = ""
    var comment = ""
    
    func isFeedbackValidModel()-> (Bool, String) {
        
        if name.characters.count == 0{
            return(false,"NAME".localizedString())
            
        } else if email.characters.count == 0{
            return(false,"EMAIL".localizedString())
            
        } else if !email.isValidEmailAddress(){
            return(false,"EMAIL_VALID".localizedString())
            
        }else if contactNo.characters.count == 0{
            return(false,"CONTACTNUMBER".localizedString())
            
        }else if !contactNo.isValidMobileNumber(){
            return(false,"CONTACTNUMBER_VALID".localizedString())
            
        }else if topic.characters.count == 0{
            return(false,"TOPIC".localizedString())
            
        }else if comment.characters.count == 0{
            return(false,"COMMENT".localizedString())
            
        }else{
            
            return (true, "")
        }
        
    }
    
}
