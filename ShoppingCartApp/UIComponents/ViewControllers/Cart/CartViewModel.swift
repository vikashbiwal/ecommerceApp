//
//  CartViewModel.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 24/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import KVAlertView

class CartViewModel {
    
    enum CartOperation: String {
        case AddToCart = "CartSave"
        case UpdateCart = "CartUpdate"
        case DeleteFromCart = "CartRemove"
    }
    
    
    //API call for perform AddToCart, RemoveFromCart, ChangeQuantity operations with cart item.
    
    func performCartOperation(productId: String, qty: String = "1", operation: CartOperation, block: @escaping (Response)->Void) {

        let params = ["productId" : productId, "quantity" : qty, "flag" : operation.rawValue]
        wsCall.cartOperations(params: params) { response in
            //Need to handle for chagne quantity event
            if response.isSuccess {
				if operation == .AddToCart {
					Cart.shared.add(item: CartItemCount(productID: productId.integerValue!, count: qty.integerValue!))
				}

            } else {
                KVAlertView.show(message: response.message)
            }
            block(response)
            
        }
    }
    
    
    //API call for get all cart items from server.
    
    func getCartItems(block: @escaping (Bool, Int)-> Void)-> URLSessionTask {
       return wsCall.getCartItems(params: nil) { response in
            if response.isSuccess {
                if let jsonArray = response.json as? [[String : Any]] {
					Cart.shared.removeAll()
                    _ = jsonArray.map({ cItem -> CartItem in
						let item = CartItem(cItem)
						Cart.shared.add(item: item)
						return item
					})
                }
            } else {
            }
           block(response.isSuccess, response.code)
        }
    }
    
    
    //API call for change product in cart.
    
    func replaceCartItem(old oPid: String,  new nPid: String, block: @escaping (Bool)-> Void) {
        let params = ["newProductId": nPid, "prevProductId" : oPid]
        wsCall.replaceCartProduct(params: params) { response in
            if response.isSuccess {
                if let json = response.json as? [String : Any] {
                    let newProduct = ProductDetail(json)
                    Cart.shared.cartItems.filter({$0.product.productId.ToString() == oPid}).first?.product = newProduct
                    
                }
            } else {
                KVAlertView.show(message: response.message)
            }
            block(response.isSuccess)
        }
    }
    
    //Get cart cart item count info with quantity
    func getCartProductsInfo(block: @escaping (Void)->Void) {
        wsCall.getCartProductsCountInfo(params: nil) { response in
            if response.isSuccess {
                if let jsonArr = response.json as? [[String : Any]] {
                    Cart.shared.shortInforCartItems = jsonArr.map({CartItemCount($0)})
                }
            }
            block()
        }
    }
    
    
}


//CartItemCount struct is used to set the badge on tabbar with product count in cart.
struct CartItemCount {
	var count:Int
	var productId: Int

	init (productID: Int, count: Int) {
		self.count = count
		self.productId = productID
	}

    init(_ json: [String : Any]) {
        count = Converter.toInt(json["quantity"])
        productId = Converter.toInt(json["productId"])
    }
}







