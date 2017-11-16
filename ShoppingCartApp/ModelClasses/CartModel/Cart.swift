//
//  Cart.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 25/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation



//MARK:- CartItem
///Class that represent a single product in cart with quantity, discount, TAX amounts.

class CartItem: Equatable {
    var product: ProductDetail
    var quantity = 0
    
    init(_ json: [String : Any]) {
        product = ProductDetail(json)
        quantity = Converter.toInt(json["quantity"])
    }
    
    //calculated price :  ProductPrice * Product Quntity in Cart
    var totalPrice : Double {
        return product.productPrice //* Double(quantity)
    }
    
    //total GST Amount  productPrice * productGST% * product quantity of cartItem.
    var totalGSTAmount: Double {
        return product.GST  //* Double(quantity)
    }
    
    var totalDiscount: Double {
        return product.productPrice - product.displayPrice
    }
    
    static func ==(lhs: CartItem, rhs: CartItem)-> Bool {
        return lhs.product.productId == rhs.product.productId
    }
}


//MARK:- Cart
protocol CartDelegate: class {
    func countDidChangeInCart(itemsCount: Int, quantityCount: Int)
}

///Cart: Class that represent singletone CART for appliaction.
class Cart {
    static let shared = Cart()
    
    var cartItems = [CartItem]()
    
    var shortInforCartItems = [CartItemCount]()
    
    var sendAsGiftAmount : Double {
        let qty = cartItems.reduce(0) {  $0 + $1.quantity }
        return FirRCManager.shared.giftPriceForQty * Double(qty)

//        if sendAsGift {
//        }
//        else{
//            return 0.0
//        }
        
    }
    
    var sendAsGift = false
    
    weak var delegate: CartDelegate?
    
    //Calculate cart's total price.
    var totalProductsPrice: Double {
        return cartItems.reduce(0) {$0 + $1.totalPrice}
    }
    
    //Calculate total GST amount
    var totalCartGSTAmount: Double {
        return cartItems.reduce(0) {$0 + $1.totalGSTAmount}
    }
    
    //Calculate total discount amount
    var totalCartDiscount: Double {
        return cartItems.reduce(0) {$0 + $1.totalDiscount}
    }
    
    //Calculate total cart amount
    var totalCartAmount: Double {
        return totalProductsPrice  +  totalCartGSTAmount - totalCartDiscount + (sendAsGift ? sendAsGiftAmount : 0)
    }
    
    
    var totalProductsQuantity: Int {
        return shortInforCartItems.map({$0.count}).reduce(0, {$0 + $1})
    }
    
    func add(item: CartItem) {
        cartItems.append(item)
        let cartCountItem = CartItemCount(productID: item.product.productId, count: item.quantity)
        shortInforCartItems.append(cartCountItem)
        
        delegate?.countDidChangeInCart(itemsCount: shortInforCartItems.count, quantityCount: totalProductsQuantity)
    }
    
    func add(item: CartItemCount) {
        shortInforCartItems.append(item)
        delegate?.countDidChangeInCart(itemsCount: shortInforCartItems.count, quantityCount: totalProductsQuantity)
    }
    
    func remove(item: CartItem) {
        Cart.shared.cartItems.removeElement(item)
        
        for (index, obj) in shortInforCartItems.enumerated() {
            if obj.productId == item.product.productId {
                shortInforCartItems.remove(at: index)
                break
            }
        }
        
        delegate?.countDidChangeInCart(itemsCount: shortInforCartItems.count, quantityCount: totalProductsQuantity)
    }
    
    func removeAll() {
        cartItems.removeAll()
        shortInforCartItems.removeAll()
        delegate?.countDidChangeInCart(itemsCount: 0, quantityCount: 0)
    }
    
    func productExistInCart(id: Int)-> Bool {
        return !shortInforCartItems.filter({$0.productId == id}).isEmpty
    }
}


