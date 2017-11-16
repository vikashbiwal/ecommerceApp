//
//  WishGroupListViewModel.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 13/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//
//
import Foundation

class WishCategoryViewModel {
    //used for cancel fetching task
    var categoryFetchTask: URLSessionTask?
    
    
    //Add wish category API call
    func addCategory(name: String, block: @escaping (Bool, WishGroup?)->Void) {
        let params = ["wishlistCategoryName" : name]
        wsCall.addWishCategory(params: params) { response in
            if response.isSuccess {
                if let json = response.json as? [String : Any] {
                    let gr = WishGroup(json)
                    block(response.isSuccess, gr)
                } else {
                    block(response.isSuccess, nil)
                }
            } else {
                block(response.isSuccess, nil)
            }
        }
    }
    
    //Update wish category API call
    func updateCategory(id: String, title: String, block: @escaping (Bool)->Void) {
        let params = ["wishlistCategoryName" : title, "categoryId": id]
        
        wsCall.updateWishCategory(params: params) { response in
            block(response.isSuccess)
        }
    }

    
    //Delete wish category API call
    func deleteCategory(id: String,  block: @escaping (Bool)-> Void) {
        let params = ["categoryId" : id]
        wsCall.deleteWishCategory(params: params) { response in
            if response.isSuccess {
                
            } else {
                
            }
            block(response.isSuccess)
        }
    }
    
    //Get wish categories API call
    func getWishListCategories(block: @escaping ([WishGroup])->Void) {
       categoryFetchTask = wsCall.getWishListCategories(params: nil) { response in
            if response.isSuccess {
                if let jsonArr = response.json as? [[String : Any]] {
                    let groups = jsonArr.map({WishGroup($0)})
                    block(groups)
                } else {
                    block([])
                }
            } else {
                block([])
            }

        } 
    }
    
    //Save product in wish category API call.
   private func saveProductInWisthCategory(categoryId: String, productId: String, block: @escaping (Bool)-> Void) {
        let params = ["productId" : productId, "wishlistCategoryId" : categoryId]
        wsCall.addProductInWishCategory(params: params) { response in
            if response.isSuccess {
                
            } else {
                
            }
            block(response.isSuccess)
        }
    }
    
    func addProductInWishCategory(categoryID: String = "0", productID: String, block: @escaping (Bool)-> Void) {
        saveProductInWisthCategory(categoryId: categoryID, productId: productID, block: block)
    }
    
    func removeProductFromCategory(productID: String, block: @escaping (Bool)-> Void) {
        saveProductInWisthCategory(categoryId: "", productId: productID, block: block)
    }
}





//==================================================================================================
//MARK:- WishGroup
//==================================================================================================

class WishGroup: Equatable {
    var id = ""
    var title = ""
    var products = [Product]()
    var saveCounts = 0
    var imgUrl = ""
    var selected = false
    
    var apiParams = ""
    
    convenience init(_ json: [String : Any]) {
        self.init()
        id = Converter.toString(json["wishlistCategoryId"])
        title = Converter.toString(json["wishlistCategoryName"])
        saveCounts = Converter.toInt(json["wishlistSaveCount"])
        imgUrl = Converter.toString(json["categoryImage"])
        apiParams = Converter.toString(json["apiParam"])
    }
    
    static func ==(lsh: WishGroup, rhs: WishGroup)-> Bool {
        return lsh.id == rhs.id
    }
}
