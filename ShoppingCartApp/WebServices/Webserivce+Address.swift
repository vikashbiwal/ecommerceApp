//
//  Webserivce+Address.swift
//  ShoppingCartApp
//
//  Created by zoomi on 13/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

extension APIName{
    
    static var GetDeliveryAddress = "api/Customer/GetAddress"
    static var GetPickupAddress = "api/Order/PickUpLocation"
    static var SaveDeliveryAddress = "api/Customer/SaveAddress"
    static var applyGiftCoupon = "api/Home/GetOffersCode"
    static var getShippingCharge = "api/Order/ShippingCharge"
    static var getCustomerBalance = "api/Order/CustomerBalance"
    static var getGiftCoupons = "api/Customer/GiftCoupon"
}

extension WebService{
    
    //get delivery address api
    
    func getDeliveryAddress(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------GetDeliveryAddress Request API : \(APIName.GetDeliveryAddress)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetDeliveryAddress, param: params, block: block)
    }
    
    //get pickup adddress api
    
    func GetPickupAddress(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------GetPickupAddress Request API : \(APIName.GetPickupAddress)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetPickupAddress, param: params, block: block)
    }
    
    
    //save address Api
    
    func saveAddress(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------SaveDeliveryAddress Request API : \(APIName.SaveDeliveryAddress)---------------------")
        _ = POST_REQUEST(relPath: APIName.SaveDeliveryAddress, param: params, block: block)
        
    }
    
    
    // apply gift coupon
    
    func applyGiftCoupon(params: [String : Any]?, block: @escaping ResponseBlock) {
        
        println("----------------------applyGiftCoupon Request API : \(APIName.applyGiftCoupon)---------------------")
        _ = GET_REQUEST(relPath: APIName.applyGiftCoupon, param: params, block: block)

    }
    
    //  get shipping charge
    
    func getShippingCharge(params: [String : Any]?, block: @escaping ResponseBlock){
       
        println("----------------------get shipping charge Request API : \(APIName.getShippingCharge)---------------------")
        _ = GET_REQUEST(relPath: APIName.getShippingCharge, param: params, block: block)
        
    }
    
    // get customer balance
    
    func getCustomerBalance(params: [String : Any]?, block: @escaping ResponseBlock){
        
        println("----------------------get Customer Balance Request API : \(APIName.getCustomerBalance)---------------------")
        _ = GET_REQUEST(relPath: APIName.getCustomerBalance, param: params, block: block)
        
    }
    
    //  get gift coupons
    
    func getGiftCoupons(params: [String : Any]?, block: @escaping ResponseBlock){
        
        println("----------------------get Gift Coupons Request API : \(APIName.getGiftCoupons)---------------------")
        _ = GET_REQUEST(relPath: APIName.getGiftCoupons, param: params, block: block)

    }
}
