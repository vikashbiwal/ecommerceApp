//
//  Webservice+SearchAPI.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 05/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

typealias APIParameters = [String : Any]
extension APIName {
    static var globalSearch = "api/Home/GlobalSearch" //GetOffers  CategoryGetList
    
    static var wishCategoryAdd          = "api/Customer/WishlistCategoryAdd"
    static var wishCategoryUpdate       = "api/Customer/WishlistCategoryUpdate"
    static var wishCategoryDelete       = "api/Customer/WishlistCategoryDelete"
    static var wishCategoryGet          = "api/Customer/WishlistCategory"
    static var addProductInWishCategory = "api/Product/AddToWishList"
    
    static var cartOperations           = "api/Order/OrderCartAddUpdate" //api is used to add, remove, and update item in cart, clear or empty cart.
    static var getCartItems             = "api/Order/CartList"
    static var replaceCartProduct       = "api/Order/CartReplaceProduct"
    static var getCartCountInfo         = "api/Order/CartListCnt"
    
}


extension WebService {
    //MARK:- Search API
    func searchItems(params: APIParameters?, block: @escaping ResponseBlock)->URLSessionTask {
        return  GET_REQUEST(relPath: APIName.globalSearch, param: params, block: block)!.task!
    }

    //MARK:- WishList API
   
    func addWishCategory(params: APIParameters?, block: @escaping ResponseBlock) {
       _ = POST_REQUEST(relPath: APIName.wishCategoryAdd, param: params, block: block)
    }
    
    func updateWishCategory(params: APIParameters?, block: @escaping ResponseBlock) {
        _ = POST_REQUEST(relPath: APIName.wishCategoryUpdate, param: params, block: block)
    }
    
    func deleteWishCategory(params: APIParameters?, block: @escaping ResponseBlock) {
        _ = POST_REQUEST(relPath: APIName.wishCategoryDelete, param: params, block: block)
    }
    
    func getWishListCategories(params: APIParameters?, block: @escaping ResponseBlock)->URLSessionTask {
        return  GET_REQUEST(relPath: APIName.wishCategoryGet, param: params, block: block)!.task!
    }

    func addProductInWishCategory(params: APIParameters?, block: @escaping ResponseBlock) {
        _ = POST_REQUEST(relPath: APIName.addProductInWishCategory, param: params, block: block)
    }
    
    
    //MARK:- Cart API
    
    func getCartItems(params: APIParameters?, block: @escaping ResponseBlock)->URLSessionTask {
        return  GET_REQUEST(relPath: APIName.getCartItems, param: params, block: block)!.task!
    }
    
    //api is used to add, remove, and update item in cart and clear cart
    func cartOperations(params: APIParameters, block: @escaping ResponseBlock) {
        _ = POST_REQUEST(relPath: APIName.cartOperations, param: params, block: block)
    }
    
    func replaceCartProduct(params: APIParameters, block: @escaping ResponseBlock) {
        _ = GET_REQUEST(relPath: APIName.replaceCartProduct, param: params, block: block)
    }
    
    //call this api for getting products count in cart along with product ids.
    func getCartProductsCountInfo(params: APIParameters?, block: @escaping ResponseBlock) {
        _ =  GET_REQUEST(relPath: APIName.getCartCountInfo, param: params, block: block)
    }
    
   


}

