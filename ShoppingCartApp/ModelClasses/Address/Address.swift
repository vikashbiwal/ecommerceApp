//
//  Address.swift
//  ShoppingCartApp
//
//  Created by zoomi on 12/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class Address{
    
    var id = ""
    var name = ""
    var fullAddress = ""
    var address = ""
    var area = ""
    var city = ""
    var state = ""
    var country = ""
    var pincode = ""
    var lat = ""
    var long = ""
    var email = ""
    var contactNo = ""
    var locality = ""
    var isBillingAddress = false
    var isActive = false
    var isDefault = false
    var pickupDate = ""
    var changePickUpDate = ""
    
   
    convenience init(forBranch json: [String : Any]) {
        self.init()
        
        
        id = Converter.toString(json["branchId"])
        name = Converter.toString(json["branchName"])
        fullAddress = Converter.toString(json["fullAddress"])
        address = Converter.toString(json["address"])
        area = Converter.toString(json["area"])
        city = Converter.toString(json["city"])
        state = Converter.toString(json["state"])
        country = Converter.toString(json["country"])
        pincode = Converter.toString(json["pincode"])
        lat = Converter.toString(json["lat"])
        long = Converter.toString(json["long"])
        pickupDate = Converter.toString(json["pickupDate"])
        
    }
    
    
    convenience init(forDelivery json: [String : Any]) {
        self.init()
        id = Converter.toString(json["addressId"])
        name = Converter.toString(json["fullname"])
        email = Converter.toString(json["email"])
        contactNo = Converter.toString(json["contactNo"])
        fullAddress =  Converter.toString(json["fullAddres"])
        address =  Converter.toString(json["address"])
       // locality = Converter.toString(json["locality"])
        city = Converter.toString(json["city"])
        state = Converter.toString(json["state"])
        pincode = Converter.toString(json["pincode"])
        country = Converter.toString(json["country"])
       // lat = Converter.toString(json["lat"])
       // long = Converter.toString(json["long"])
        isBillingAddress = Converter.toBool(json["isBillingAddress"])
        isActive = Converter.toBool(json["isActive"])
        isDefault = Converter.toBool(json["isDefault"])
        
        
    }

    
   
    
}


class ShippingCharge{
    
    var shippingChargeId = ""
    var shippingTypeId = ""
    var shippingType = ""
    var expectedShippingDate = ""
    var shippingCharge:Float = 0.0
    var isActive:Bool = false
    var changeExpectedShippingDate = ""
    
    
    convenience init(json: [String : Any]){
        self.init()
        
        shippingChargeId = Converter.toString(json["shippingChargeId"])
        shippingTypeId = Converter.toString(json["shippingTypeId"])
        shippingType = Converter.toString(json["shippingType"])
        expectedShippingDate = Converter.toString(json["expectedShippingDate"])
        shippingCharge = Converter.toFloat(json["shippingCharge"])

        
    }
    
}


class CustomerBalance{
    
    var giftCouponList = [GiftCouponList]()
    var walletBalance = ""
    var loyaltyBalance = ""
    var isActive:Bool = false
    
    convenience init(json: [String : Any]){
        
        self.init()
    
//        let arrGiftCouponList = json["giftCoupons"] as! [[String : Any]]
//        
//       giftCouponList = arrGiftCouponList.map { (dict) -> GiftCouponList in
//            
//            return GiftCouponList(json: dict)
//        }
        
        walletBalance = Converter.toString(json["walletBalance"])
       // loyaltyBalance = Converter.toString(json["loyaltyBalance"])
        
    }
}


class GiftCouponList{
    
    var giftCouponId = ""
    var giftCoupon = ""
    var price:Float = 0.0
    var startDate = ""
    var endDate = ""
    var createdDate = ""
    var isActive = false
    var isSelected = false
    
    
    convenience init(json: [String : Any]){
        
        self.init()
        
        giftCouponId = Converter.toString(json["giftCouponId"])
        giftCoupon = Converter.toString(json["giftCoupon"])
        price = Converter.toFloat(json["price"])
        startDate = Converter.toString(json["startDate"])
        endDate = Converter.toString(json["endDate"])
        createdDate = Converter.toString(json["createdDate"])
        isActive = Converter.toBool(json["isActive"])
        
    }
    
    
    
}
