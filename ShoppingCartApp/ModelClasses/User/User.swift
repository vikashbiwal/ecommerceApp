//
//  User.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 14/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class User {
    
    var address = ""
    var anniversaryDate = ""
    var area = ""
    var birthDate = ""
    var city = ""
    var country = ""
    var custId = ""
    var email = ""
    var gender = ""
    var image = ""
    var isActive = ""
    var isGuestUser = ""
    var loyaltyBalance = ""
    var mobile = ""
    var name = ""
    var pinCode = ""
    var socialToken = ""
    var socialId = ""
    var state = ""
    var socialType = ""
    var socialUserID = ""
    var relativePath = ""
    
    
    convenience init(_ json: [String : Any]) {
        self.init()
        
        self.address = Converter.toString(json["address"])
        self.anniversaryDate = Converter.toString(json["anniversaryDate"])
        self.area = Converter.toString(json["area"])
        self.birthDate = Converter.toString(json["birthDate"])
        self.city = Converter.toString(json["city"])
        self.country = Converter.toString(json["country"])
        self.custId = Converter.toString(json["customerId"])
        self.email = Converter.toString(json["email"])
        self.gender = Converter.toString(json["gender"])
        self.image = Converter.toString(json["image"])
        self.isActive = Converter.toString(json["isActive"])
        self.isGuestUser = Converter.toString(json["isGuestUser"])
        self.loyaltyBalance = Converter.toString(json["loyaltyBalance"])
        self.mobile = Converter.toString(json["mobile"])
        self.name = Converter.toString(json["name"])
        self.pinCode = Converter.toString(json["pincode"])
        self.socialId = Converter.toString(json["socialId"])
        self.socialToken = Converter.toString(json["socialToken"])
        self.socialType = Converter.toString(json["socialType"])
        self.socialUserID = Converter.toString(json["socialUserId"])
        self.state = Converter.toString(json["state"])
        self.relativePath = Converter.toString(json["relativeImage"])
        
    }
    
    
}
