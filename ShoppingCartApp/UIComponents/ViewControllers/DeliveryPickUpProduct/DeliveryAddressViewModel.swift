//
//  DeliveryAddressViewModel.swift
//  ShoppingCartApp
//
//  Created by zoomi on 14/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class AddressViewModel {
    
   public var address = Address()
    
    func isValidAddressModel() -> (Bool, String)  {
        
        if address.name.characters.count == 0 {
            return(false,"NAME".localizedString())
            
        }else if address.contactNo.characters.count == 0 {
             return(false,"CONTACTNUMBER".localizedString())
            
        }else if !address.contactNo.isValidMobileNumber() {
            return(false,"CONTACTNUMBER_VALID".localizedString())
            
        }else if address.email.characters.count == 0 {
            return(false,"EMAILADDRESS".localizedString())
            
        }else if !address.email.isValidEmailAddress() {
            return(false,"EMAIL_ADDRESS_VALID".localizedString())
            
        }else if address.address.characters.count == 0 {
            return(false,"ADDRESS".localizedString())
            
        }else if address.city.characters.count == 0 {
            return(false,"CITY".localizedString())
            
        }else if address.state.characters.count == 0 {
            return(false,"STATE".localizedString())
            
        }else if address.country.characters.count == 0 {
            return(false,"COUNTRY".localizedString())
            
        }else if address.pincode.characters.count == 0 {
            return(false,"PINCODE".localizedString())
            
        }else if address.pincode.isValidPincode() {
            return(false,"PINCODE_VALID".localizedString())
            
        }else{
            return (true, "")
        }
        
    }
}


extension AddressViewModel{
    
    var addressApi: [String : Any] {
        
         return ["addressId":Converter.toInt(address.id),
                 "fullname":address.name,
                 "email":address.email,
                 "contactNo":address.contactNo,
                 "address":address.address,
                // "locality":address.locality,
                 "city":address.city,
                 "state":address.state,
                 "country":address.country,
                 "pincode":address.pincode,
                 //"lat":0,
                 //"long":0,
                 "isBillingAddress":true,
                 "isActive":address.isActive,
                 "isDefault":address.isDefault]
        
    }
    
    func saveAddress_apiCall( block: @escaping (Bool, Address?)-> Void) {
        
        print("addressApi:\(addressApi)")
        
        wsCall.saveAddress(params: addressApi) { (response) in
            if response.isSuccess {
                
                print("response.json\(response.code)")
                
                if let json = response.json as? [String:Any] {
                    
                    print("address response is => \(json)")
                    
                    let addressObj = Address(forDelivery: json)
                    
                    block(response.isSuccess, addressObj)

                }
            } else{
                    block(response.isSuccess, nil)
            }
        }
    }
    
    
}
