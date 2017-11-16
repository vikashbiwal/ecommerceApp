//
//  orderModel.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 8/17/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

/*
 
 {
 "isDeliveryPickup": true,
 "branchId": 1,
 "deliveryPickupDate": "2017-08-05T09:37:45",
 "price": 2.0,
 "serviceChargePerc": 3.0,
 "deliveryCharge": 4.0,
 "giftWarpPrice": 5.0,
 "offerCouponcode": "sample string 6",
 "offerCouponDiscount": 7.0,
 "walletPrice": 8,
 "shippingFullname": "sample string 9",
 "shippingEmail": "sample string 10",
 "shippingContactNo": "sample string 11",
 "shippingAddress": "sample string 12",
 "shippingCity": "sample string 13",
 "shippingState": "sample string 14",
 "shippingPincode": "sample string 15",
 "userComment": "sample string 16",
 "platform": "sample string 17",
 "osVersion": "sample string 18",
 "paymentGateway": "sample string 19",
 "paymentType": "sample string 20",
 "paymentStatus": 52
 }
 */

class Order {
    
    var isDeliveryPickup = false  // IsDeliveryPickup = true then Shipping
   
    var branchId = 0
    var deliveryPickupDate = "" //2017-08-05T09:37:45
    var price = 0.0
    
    var serviceChargePerc = 0.0  //not decided yet. may be you will get in home page API or set in firebase
    var deliveryCharge = 0.0
    
    var giftWarpPrice = 0.0
    var offerCouponCode = ""    //pending because related changes in shopping cart screen  are pending
    var offerCouponDiscount = 0.0  //pending because related changes in shopping cart screen  are pending
    
    var walletPrice = 0.0
    var shippingFullname = ""
    var shippingEmail = ""
    var shippingContactNo = ""
    var shippingAddress = ""
    var shippingCity = ""
    var shippingState = ""
    var shippingPincode = ""
    var userComment = ""
    var platform = "IOS"
    var osVersion = systemVersion
    
    var paymentGateway = "PayTM" // right now its static , because we itegrate PayTM only
    var paymentType = ""
    var paymentStatus = 52
    
    
    // it is only showing purpose DONT SEND IT IN REQUEST..
    var displayPrice: Double {
        return price  +  deliveryCharge - walletPrice
    }
    
    // cart item is used on thankyou screen 
    var cartItems = [CartItem]()
    
    // show pickup or delvier address on thank you screen
    var selectedAddress = Address()
    var addressname = ""  // username or store name
    
    
    
    // address screen view order require parameter
    
    var arrOrderShippingCharge:[ShippingCharge] = []
    var selectedOrderDelivery:Int = 0
    var totalWalletBalance: Float = 0.0
    var usedWalletBalance: Float = 0.0
    var deliveryAddress: Address?
    var pickupAddress: Address?

    
    class func orderFromCart()-> Order {
        
        print("create new order object")
        
        let order = Order()
        let cart = Cart.shared
        order.price =  cart.totalCartAmount               //  cart.totalProductsPrice
        order.giftWarpPrice = cart.sendAsGiftAmount
        order.cartItems = cart.cartItems
        // order.serviceChargePerc =
        return order
    }
    
    
    func addressDate(strDate: String)-> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd MMM yyyy"
        let shippingDate = dateFormatter.date(from: (strDate))!
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        let changeDate = dateFormatter.string(from: shippingDate)
        
        return changeDate
        
    }
    
    func convertOrderIntoDictionary() -> [String : Any] {
        var requestDict = [String : Any]()
        
        requestDict["isDeliveryPickup"] = self.isDeliveryPickup
        requestDict["branchId"] = self.branchId
        requestDict["deliveryPickupDate"] = self.deliveryPickupDate != "" ? addressDate(strDate: self.deliveryPickupDate):""
        requestDict["price"] = self.price
        
        requestDict["serviceChargePerc"] = self.serviceChargePerc
        requestDict["deliveryCharge"] = self.deliveryCharge
        
        requestDict["giftWarpPrice"] = self.giftWarpPrice
        requestDict["offerCouponCode"] = self.offerCouponCode
        requestDict["offerCouponDiscount"] = self.offerCouponDiscount
        
        requestDict["walletPrice"] = self.walletPrice
        
        requestDict["shippingFullname"] = self.shippingFullname
        requestDict["shippingEmail"] = self.shippingEmail
        requestDict["shippingContactNo"] = self.shippingContactNo
        requestDict["shippingAddress"] = self.shippingAddress
        requestDict["shippingCity"] = self.shippingCity
        requestDict["shippingState"] = self.shippingState
        requestDict["userComment"] = self.userComment
        requestDict["platform"] = self.platform
        requestDict["osVersion"] = self.osVersion
        
        requestDict["paymentGateway"] = self.paymentGateway
        requestDict["paymentType"] = self.paymentType
        requestDict["paymentStatus"] = self.paymentStatus
        
        
        return requestDict
    }
    
    
}
