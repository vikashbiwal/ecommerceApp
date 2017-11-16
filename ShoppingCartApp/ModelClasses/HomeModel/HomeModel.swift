//
//  HomeModel.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 13/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class DynamicHome {

	var id = ""
	var groupName = ""
	var isHorizontal = false
	var verticalCount:Int = 0
	var isRotateBanner = false
	var isAutoRotate = false
	var autoRotateInterval:Int = 0
	var sortOrder:Int = 0
	var groupList = [HomeGroupObject]()

	init(_ json:[String:Any]) {

		 id = Converter.toString(json["homeGroupId"])
		 groupName = Converter.toString(json["groupName"])
		 isHorizontal = Converter.toBool(json["isHorizontal"])
		 verticalCount = Converter.toInt(json["verticalCount"])
		 isRotateBanner = Converter.toBool(json["isRotateBanner"])
		 isAutoRotate = Converter.toBool(json["isAutoRotate"])
		 autoRotateInterval = Converter.toInt(json["autoRotateInterval"])
		 sortOrder = Converter.toInt(json["sortOrder"])
		 let groupArray = json["groupData"] as! [[String:Any]]
		 groupList = groupArray.map({ (json) -> HomeGroupObject in
			return HomeGroupObject(json)
		 })
	}
}

class HomeGroupObject {

	var id = ""
	var homeGroupId:Int = 0
	var name = ""
	var image = ""
	var openOfferScreen = false
	var openCategoryScreen = false
	var apiParam = ""

	init(_ json:[String:Any]) {

		id = Converter.toString(json["homeDataId"])
		homeGroupId = Converter.toInt(json["homeGroupId"])
		name = Converter.toString(json["dataName"])
		image = Converter.toString(json["dataImage"])
		apiParam = Converter.toString(json["apiParam"])
		openOfferScreen = Converter.toBool(json["openOfferScreen"])
		openCategoryScreen = Converter.toBool(json["openCategoryScreen"])

	}
}


