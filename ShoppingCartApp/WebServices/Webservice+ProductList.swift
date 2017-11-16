//
//  Webservice+ProductList.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 7/3/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

extension APIName{
    static var GetList = "api/Product/Getlist"
    static var GetFilter = "api/Product/Filter"
    static var PlaceOrder = "api/Order/PlaceOrder"
    static var clearCart = "api/Order/RemoveCartAll"
    static var setPaymentStatus = "api/Order/SetPaymentStatus"
    static var preOrderSummary = "api/Customer/PreOrderSummary"
}


extension WebService {
    
    //GET PRODUCT LIST
    func getList(params: [String : Any]?, block: @escaping ResponseBlock)->URLSessionTask {
        println("----------------------GetList Request API : \(APIName.GetList)---------------------")
        return POST_REQUEST(relPath: APIName.GetList, param: params, block: block)!.task!
       
    }
    
    //GET PRODUCT FILTERS
    func getFilters(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------FILTER Request API : \(APIName.GetFilter)---------------------")
        _ = POST_REQUEST(relPath: APIName.GetFilter, param: params, block: block)
        
    }
    
    //PLACEORDER -- POST API
    func placeOrder(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------PLACEORDER Request API : \(APIName.PlaceOrder)---------------------")
        _ = POST_REQUEST(relPath: APIName.PlaceOrder, param: params, block: block)
        
    }
    
    //CLEAR CART - GET API
    func removeAllFromCart(params: APIParameters?, block: @escaping ResponseBlock) {
       println("----------------------RemoveCartAll Request API : \(APIName.clearCart)---------------------")
        _ = GET_REQUEST(relPath: APIName.clearCart, param: params, block: block)
        
     }
    
    //SET PAYMENT STATUS
    func setPaymentStatus(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------setPaymentStatus Request API : \(APIName.setPaymentStatus)---------------------")
        _ = POST_REQUEST(relPath: APIName.setPaymentStatus, param: params, block: block)
        
    }
    
    //PRE ORDER SUMMARY - GET API
    func preOrderSummary(params: APIParameters?, block: @escaping ResponseBlock) {
        println("----------------------preOrderSummary Request API : \(APIName.preOrderSummary)---------------------")
        _ = GET_REQUEST(relPath: APIName.preOrderSummary, param: params, block: block)
        
    }
}

