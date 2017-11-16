//
//  ProductCategory.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 15/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

protocol Expandable {
    var isOpen: Bool {get set}
}

//MARK- Category
class Category: Expandable,NSCopying {
	var id = ""
	var name = ""
	var imgUrlString = ""
	var bannerImageUrlString = ""
	var identifier = ""
	var parentCategoryName = ""
	var parentCategoryId = ""
	var IsSpecialCategory  = false
	var childCategories = [Category]()
	var image: Media?
	var apiParam = ""


	convenience init(_ json: [String : Any]) {
		self.init()

		self.id = Converter.toString(json["categoryId"])
		self.name = Converter.toString(json["categoryName"])
		self.imgUrlString = Converter.toString(json["categoryImage"])
		self.bannerImageUrlString = Converter.toString(json["categoryBanner"])
		self.identifier = Converter.toString(json["identifierKey"])
		self.parentCategoryName = Converter.toString(json["parentCategoryName"])
		self.apiParam = Converter.toString(json["apiParam"])
		self.parentCategoryId = Converter.toString(json["parentCategoryId"])
		self.IsSpecialCategory = Converter.toBool(json["isSpecialCategory"])
		image = Media(thumURL: URL(string: Converter.toString(json["categoryImage"])),
		              original: URL(string: Converter.toString(json["categoryBanner"])))

		if json["childCategories"] != nil {
			let childArray = json["childCategories"] as! [[String:Any]]
			self.childCategories = childArray.map({ (json) -> Category in
				return Category(json)
			})
		}

	}
	func copy(with zone: NSZone? = nil) -> Any {
		let copy = Category()
		return copy
	}

	var isOpen = false
}




