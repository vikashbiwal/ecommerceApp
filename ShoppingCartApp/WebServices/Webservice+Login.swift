//
//  Webservice+Login.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 14/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

extension APIName{
    static var SignUpApi = "api/Customer/SignUp"
    static var LoginApi = "api/Customer/SignIn"
    static var ForgotApi = "api/Customer/ForgotPassword"
    static var LogoutApi = "api/Customer/SignOut"
    static var LoyaltyApi = "api/Customer/LoyaltyHistory"
    static var WalletHistoryApi = "api/Customer/WalletHistory"
    static var WalletPurchaseApi = "api/Customer/WalletPurchase"
    //static var GetFilter = "api/Product/Filter"
}


extension WebService {
    
    //SignUp Api
    func callSignUp(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------SignUp Request API : \(APIName.SignUpApi)---------------------")
        _ = POST_REQUEST(relPath: APIName.SignUpApi, param: params, block: block)
        
    }

    func callLogin(params: [String : Any]?, block: @escaping ResponseBlock) {
         println("----------------------Login Request API : \(APIName.LoginApi)---------------------")
        _ = POST_REQUEST(relPath: APIName.LoginApi, param: params, block: block)
        
    }
    
    func callForgotPassword(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Forgot Request API : \(APIName.ForgotApi)---------------------")
        _ = GET_REQUEST(relPath: APIName.ForgotApi, param: params, block: block)
    }
    
    func callLogout(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Logout Request API : \(APIName.LogoutApi)---------------------")
        _ = POST_REQUEST(relPath: APIName.LogoutApi, param: params, block: block)
        
    }
    
    func callLoyalty(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Loyalty History Request API : \(APIName.LoyaltyApi)---------------------")
        _ = GET_REQUEST(relPath: APIName.LoyaltyApi, param: params, block: block)
    }
    
    func callWalletHistory(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Wallet History Request API : \(APIName.WalletHistoryApi)---------------------")
        _ = GET_REQUEST(relPath: APIName.WalletHistoryApi, param: params, block: block)
    }
    
    func callWalletPurchase(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Wallet Purchase Request API : \(APIName.WalletPurchaseApi)---------------------")
        _ = GET_REQUEST(relPath: APIName.WalletPurchaseApi, param: params, block: block)
    }
}
