//
//  Loyalty.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class Loyalty {
    
    var displayOrderId = ""
    var loyaltyPoints = ""
    var date = ""
    var availableLoyaltyPoints = ""

    
    convenience init(_ json: [String : Any]) {
        self.init()
        
        self.displayOrderId = Converter.toString(json["displayOrderId"])
        self.loyaltyPoints = Converter.toString(json["loyaltyPoints"])
        self.date = Converter.toString(json["loyaltyHistoryDate"])
        self.availableLoyaltyPoints = Converter.toString(json["availableLoyaltyPoints"])
        
        
    }
    
    
}
