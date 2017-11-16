//
//  MyOrderModel.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 11/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class MyOrder {

	var  orderId = ""
	var  displayOrderId = ""
	var  orderStatusId:Int = 0
	var  orderStatus = ""
	var  isDeliveryPickup = false
	var  deliveryPickupDate:String?
	var  price = 0.0
	var  serviceCharge = 0.0
	var  serviceChargePerc:Float = 0.0
	var  gst = 0.0
	var  deliveryCharge = 0.0
	var  discount = 0.0
	var  giftWrapPrice = 0.0
	var  offerCouponcode = ""
	var  offerCouponDiscount = 0.0
	var  giftCouponCode = ""
	var  giftCouponPrice = 0.0
	var  walletPrice = 0.0
	var  totalPrice = 0.0
	var  roundOffPrice = 0.0
	var  userComment = ""
	var  cancelReason = ""
	var  cancelRemarks = ""
	var  cancelDate:String?
	var  orderPlacedDate = ""
	var  orderCompleteDate:String?
	var  courierName = ""
	var  trackingNo = ""
	var  shippingFullname = ""
	var  shippingContactNo = ""
	var  shippingEmail = ""
	var  shippingFullAddress = ""
	var  orderShippingDate:String?
	var  pickUpStore = ""
	var  productList = [MyOrderProduct]()
	var  storeName = ""
	var  paymentStatus = ""
	var  paymentGateway = ""
	var  codFlag = false
	var  isCancelable = false
	var  summary = [AmountSummary]()



	init() {
	}

	init(_ json: [String : Any])  {

		  orderId = Converter.toString(json["orderId"])
		  displayOrderId = Converter.toString(json["displayOrderId"])
		  orderStatusId = Converter.toInt(json["orderStatusId"])
		  orderStatus = Converter.toString(json["orderStatus"])
		  isDeliveryPickup = Converter.toBool(json["isDeliveryPickup"])
		  deliveryPickupDate = Converter.toString(json["deliveryPickupDate"])
		  price = Converter.toDouble(json["price"])
		  serviceCharge = Converter.toDouble(json["serviceCharge"])
		  serviceChargePerc = Converter.toFloat(json["serviceChargePerc"])
		  gst = Converter.toDouble(json["gst"])
		  deliveryCharge = Converter.toDouble(json["deliveryCharge"])
		  discount = Converter.toDouble(json["discount"])
		  giftWrapPrice = Converter.toDouble(json["giftWrapPrice"])
		  offerCouponcode = Converter.toString(json["offerCouponcode"])
		  offerCouponDiscount = Converter.toDouble(json["offerCouponDiscount"])
		  giftCouponCode = Converter.toString(json["giftCouponCode"])
		  giftCouponPrice = Converter.toDouble(json["giftCouponPrice"])
		  walletPrice = Converter.toDouble(json["walletPrice"])
		  totalPrice = Converter.toDouble(json["totalPrice"])
		  roundOffPrice = Converter.toDouble(json["roundOffPrice"])
		  userComment = Converter.toString(json["userComment"])
		  cancelReason = Converter.toString(json["cancelReason"])
		  cancelRemarks = Converter.toString(json["cancelRemarks"])
		  cancelDate = Converter.toString(json["cancelDate"])
		  orderPlacedDate = Converter.toString(json["orderPlacedDate"])
		  orderCompleteDate = Converter.toString(json["orderCompleteDate"])
		  courierName = Converter.toString(json["courierName"])
		  trackingNo = Converter.toString(json["trackingNo"])
		  shippingFullname = Converter.toString(json["shippingFullname"])
		  shippingContactNo = Converter.toString(json["shippingContactNo"])
		  shippingEmail = Converter.toString(json["shippingEmail"])
		  shippingFullAddress = Converter.toString(json["shippingFullAddress"])
		  pickUpStore = Converter.toString(json["pickUpStore"])
		  orderShippingDate = Converter.toString(json["orderShippingDate"])
		  storeName = Converter.toString(json["storeName"])
		  paymentStatus = Converter.toString(json["paymentStatus"])
		  paymentGateway = Converter.toString(json["paymentGateway"])
		  codFlag = Converter.toBool(json["codFlag"])
		  if let isCancel = json["isCancelable"] {
			isCancelable = Converter.toBool(isCancel)
			}

		if let productArray = json["productList"] as? [[String:Any]]
		{
			productList = productArray.map({ (obj) -> MyOrderProduct in
				return MyOrderProduct(obj)
			})
		}

		if let amountArray = json["orderSummary"] as? [[String:Any]]
		{
			summary = amountArray.map({ (obj) -> AmountSummary in
				return AmountSummary(obj)
			})
		}


	}
}

class MyOrderProduct {

	var  orderId = ""
	var  productId = ""
	var  productName = ""
	var  productSubTitle = ""
	var  productImage = ""
	var  size = ""
	var  orderQuantity:Int = 0
	var  productPrice = 0.0
	var  displayPrice = 0.0
	var  offerDiscount = 0.0
	var  isGiftPack = false
	var  review:Int = 0
	var  rating:Int = 0

	init() {
	}

	init(_ json: [String : Any]) {
		self.orderId = Converter.toString(json["orderId"])
		self.productId = Converter.toString(json["productId"])
		self.productName = Converter.toString(json["productName"])
		self.productSubTitle = Converter.toString(json["productSubTitle"])
		self.productImage = Converter.toString(json["productImage"])
		self.productPrice = Converter.toDouble(json["productPrice"])
		self.displayPrice = Converter.toDouble(json["displayPrice"])
		self.offerDiscount = Converter.toDouble(json["offerDiscount"])
		self.isGiftPack = Converter.toBool(json["isGiftPack"])
		self.review = Converter.toInt(json["review"])
		self.rating = Converter.toInt(json["rating"])
		self.size = Converter.toString(json["size"])
		orderQuantity = Converter.toInt(json["orderQuantity"])

	}
}

class AmountSummary {

	var  title = ""
	var  value = 0.0
	var  sortOrder:Int = 0


	init(_ json: [String : Any]) {
		self.title = Converter.toString(json["title"])
		self.value = Converter.toDouble(json["value"])
		self.sortOrder = Converter.toInt(json["sortOrder"])
	}
	
	
}

class PreOrderAmountSummary {
    var  id  = "-1"  // 1 for total price else -1
    var  title = ""
    var  value = 0.0
    var  sortOrder:Int = 0
    
    
    init(_ json: [String : Any]) {
        self.title = Converter.toString(json["title"])
        self.value = Converter.toDouble(json["value"])
        self.sortOrder = Converter.toInt(json["sortOrder"])
        self.id = Converter.toString(json["id"])
    }
    
    
}


