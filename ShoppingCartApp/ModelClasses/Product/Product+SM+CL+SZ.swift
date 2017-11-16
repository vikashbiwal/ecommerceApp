//
//  Product+SM+CL+SZ.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 18/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

protocol ColorSizeItem {
    var productId: String {get set}
    var value: String {get set}
}

class PDColor: ColorSizeItem {
	
	var productId = ""
	var identifierKey = ""
	var value = ""
    var hasImage: Bool {
         return value.characters.first != "#" //if value doesn't have color code.
    }
   
	convenience init(_ json:[String:Any]) {
        self.init()
        
		self.productId = Converter.toString(json["productId"])
		self.identifierKey = Converter.toString(json["identifierKey"])
		self.value = Converter.toString(json["value"])
	}
}


class PDSize: ColorSizeItem {

	var productId = ""
	var identifierKey = ""
	var value = ""
	var productName = ""
	var price:Float = 0
	var outoffStock:Int = 0
	var discount:Float = 0.0
	var displayPrice:Float = 0
	var allowedQuantity = 0
	var maxPrice = 0.0
	var isWishlist = false

	var colorList = [PDColor]()


	convenience init(_ json:[String:Any]) {
        self.init()
        
		self.productId = Converter.toString(json["productId"])
		self.identifierKey = Converter.toString(json["identifierKey"])
		self.value = Converter.toString(json["value"])
		self.productName = Converter.toString(json["productName"])
		self.price = Converter.toFloat(json["price"])
		self.outoffStock = Converter.toInt(json["outoffStock"])
		self.allowedQuantity = Converter.toInt(json["allowedQuantity"])
		self.maxPrice = Converter.toDouble(json["maxprice"])
		self.isWishlist = Converter.toBool(json["isWishlist"])
		self.discount = Converter.toFloat(json["discount"])
		self.displayPrice = Converter.toFloat(json["displayPrice"])
		let colorArray = json["colorList"] as! [[String:Any]]
		self.colorList = colorArray.map({ (obj) -> PDColor in
			return PDColor(obj)
		})
	}
}

class PDImageGallery {

	var productId = ""
	var imagePath = ""
	var isDefaultImage = false

	init(_ json:[String:Any]) {

		self.productId = Converter.toString(json["productId"])
		self.imagePath = Converter.toString(json["imagePath"])
		self.isDefaultImage = Converter.toBool(json["isDefaultImage"])
	}

	init(imagePath:String) {
		self.productId = "0"
		self.imagePath = imagePath
		self.isDefaultImage = false
	}
}



class ProductProperty {

	var id = ""
	var productId = ""
	var groupName = ""
	var propertyName = ""
	var propertyValue = ""
	var propertyUnit = ""
	var sortOrder:Int = 0

	init(_ json:[String:Any]) {
		self.id = Converter.toString(json["productId"])
		self.productId = Converter.toString(json["productId"])
		self.groupName = Converter.toString(json["groupName"])
		self.propertyName = Converter.toString(json["propertyName"])
		self.propertyValue = Converter.toString(json["propertyValue"])
		self.propertyUnit = Converter.toString(json["propertyUnit"])
		self.sortOrder = Converter.toInt(json["sortOrder"])

	}
}


/*class ProductDetail: Product {

	var smProduct:[Product]?
	var relatedProduct:[Product]?
	var sizeList:[PDSize] = []
	var imageGallery:[PDImageGallery]?
	var propertyList = [ProductProperty]()

	 override init() {
		super.init()
	 }
	
	 override init(_ json:[String:Any]) {
		super.init(json)
		if let smProductArr = json["similarProduct"] as? [[String:Any]]{
				self.smProduct = smProductArr.map({ (obj) -> Product in
					return Product(obj)
				})
		}

		if let relatedProductArr = json["relatedProducts"] as? [[String:Any]]{
				self.relatedProduct = relatedProductArr.map({ (obj) -> Product in
					return Product(obj)
				})
		}

		if let sizeArr = json["sizeList"] as? [[String:Any]] {
			self.sizeList = sizeArr.map({ (obj) -> PDSize in
				return PDSize(obj)
			})
		}

		if let imageArr = json["gallaryImages"] as? [[String:Any]]{
				self.imageGallery = imageArr.map({ (obj) -> PDImageGallery in
					return PDImageGallery(obj)
				})
		}

		if let propertyArr = json["property"] as? [[String:Any]]{
				self.propertyList = propertyArr.map({ (obj) -> ProductProperty in
					return ProductProperty(obj)
				})
		}
	}

    
    var size: PDSize {
        return sizeList.filter({$0.productId == productId.ToString()}).first!
    }

    var color: PDColor! {
        return size.colorList.filter({$0.productId == productId.ToString()}).first!
    }
}*/
