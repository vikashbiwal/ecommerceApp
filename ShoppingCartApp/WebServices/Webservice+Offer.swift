//
//  Webservice+Offer.swift
//  ShoppingCartApp
//
//  Created by zoomi on 01/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

extension APIName{
    
    static var GetOffers = "api/Home/GetOffers"
    static var JustForYou = "api/Product/JustForYou"
    static var getProduct360Images = "api/Product/ProductGet360Images"
}

extension WebService{
    
    //Get get product offers.
   
    func getOffers(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------GetOffers Request API : \(APIName.GetOffers)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetOffers, param: params, block: block)
    }
    
    //api/Product/JustForYou
    /* Params: {"includeDeleted": false, "flag": "JustForYou", "orderBy": "Price", "pagenumber": 1, "pageSize": 10, "propertyDetail": []}*/

    func getJustForYouItems(params: [String : Any]?, block: @escaping ResponseBlock) {
        _ = POST_REQUEST(relPath: APIName.JustForYou, param: params, block: block)
    }
 
    /*ProductId=3350  IdentifierKey=as2d5sd */
    func GetProdutImages(params: [String : Any]?, block: @escaping ResponseBlock) {
        _ = GET_REQUEST(relPath: APIName.getProduct360Images, param: params, block: block)
    }

}

