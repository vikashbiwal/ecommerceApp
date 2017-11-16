//
//  Wallet.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 22/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class Wallet{

    var displayOrderId = ""
    var walletPrice = ""
    var date = ""
    var availableWalletBalance = ""
    
    
    convenience init(_ json: [String : Any]) {
        self.init()
        
        self.displayOrderId = Converter.toString(json["displayOrderId"])
        self.walletPrice = Converter.toString(json["walletPrice"])
        self.date = Converter.toString(json["walletHistoryDate"])
        self.availableWalletBalance = Converter.toString(json["availableWalletBalance"])
                
    }
}
