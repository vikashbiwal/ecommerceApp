//
//  ProductOffer.swift
//  ShoppingCartApp
//
//  Created by zoomi on 01/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class Offer{

	var offerId = ""
	var offerTitle = ""
	var offerCode = ""
	var categoryId = ""
	var productId = ""
	var weekDays = ""
	var offerBanner = ""
	var offerBannerImgUrl: URL? {return URL(string: offerBanner)}
	var startTime = ""
	var endTime = ""
	var discountPerc:Float = 0.0
	var fixedPrice:Float = 0.0
	var isCoupon = false
	var isActive = false
	var offerDesc = ""
	var userId = ""
	var isFlashOffer = false
	var endDate = ""
	var criteria = [OfferCriateria]()
    var entityCriateria = [OfferEntityCriateria]()
	var apiParam = ""
	var secondsOffset = Date()
	var milliSeconds:Int = 0

	var timerObserveBlock: (String)-> Void = {_ in}

	convenience init(_ json: [String : Any]) {
		self.init()

		offerId = Converter.toString(json["offerId"])
		offerTitle = Converter.toString(json["offerTitle"])
		offerCode = Converter.toString(json["offerCode"])
		categoryId = Converter.toString(json["categoryId"])
		productId = Converter.toString(json["productId"])
		weekDays = Converter.toString(json["weekDays"])
		offerBanner = Converter.toString(json["offerBanner"])
		startTime = Converter.toString(json["startTime"])
		endTime = Converter.toString(json["endTime"])
		discountPerc = Converter.toFloat(json["discountPerc"])
		fixedPrice = Converter.toFloat(json["fixedPrice"])
		isCoupon = Converter.toBool(json["isCoupon"])
		isActive = Converter.toBool(json["isActive"])
		offerDesc = Converter.toString(json["offerDesc"])
		userId = Converter.toString(json["userId"])
		endDate = Converter.toString(json["endDate"])
		isFlashOffer = Converter.toBool(json["isFlashOffer"])
		apiParam = Converter.toString(json["apiParam"])
		milliSeconds = Converter.toInt(json["milliseconds"])
		secondsOffset = self.getSecondsFromDate(dateString: endDate)
		let arrCriteria = json["criateria"] as! [[String:Any]]
		criteria = arrCriteria.map({ (dict) -> OfferCriateria in
			return OfferCriateria(dict)
		})
        let arrEntityCriateria = json["entityCriateria"] as! [[String: Any]]
        entityCriateria = arrEntityCriateria.map({ (dict) -> OfferEntityCriateria in
            return OfferEntityCriateria(dict)
        })
		if isFlashOffer{
			self.startOfferEndTimer()
		}
	}
}

extension Offer {

	func getSecondsFromDate (dateString:String) -> Date {
		let date = serverDateFormator.date(from: dateString)
		return date!
	}

	func startOfferEndTimer() {
		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] timer in
			if self.milliSeconds <= 0 {
				timer.invalidate()
				return
			}
			//let str = self.convertTime(miliseconds: self.milliSeconds)
			self.timerObserveBlock(self.convertTime(miliseconds: self.milliSeconds))
			self.milliSeconds = self.milliSeconds-1000
		}
	}

	func convertTime(miliseconds: Int) -> String {

		var seconds: Int = 0
		var minutes: Int = 0
		var hours: Int = 0
		var days: Int = 0
		var secondsTemp: Int = 0
		var minutesTemp: Int = 0
		var hoursTemp: Int = 0

		if miliseconds < 1000 {
			return ""
		} else if miliseconds < 1000 * 60 {
			seconds = miliseconds / 1000
			return "\(seconds)s"
		} else if miliseconds < 1000 * 60 * 60 {
			secondsTemp = miliseconds / 1000
			minutes = secondsTemp / 60
			seconds = (miliseconds - minutes * 60 * 1000) / 1000
			return "\(minutes)m:\(seconds)s"
		} else if miliseconds < 1000 * 60 * 60 * 24 {
			minutesTemp = miliseconds / 1000 / 60
			hours = minutesTemp / 60
			minutes = (miliseconds - hours * 60 * 60 * 1000) / 1000 / 60
			seconds = (miliseconds - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
			return "\(hours)h:\(minutes)m:\(seconds)s"
		} else {
			hoursTemp = miliseconds / 1000 / 60 / 60
			days = hoursTemp / 24
			hours = (miliseconds - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
			minutes = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
			seconds = (miliseconds - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
			return "\(days)d:\(hours)h:\(minutes)m:\(seconds)s"
		}
	}
}



class OfferCriateria{

    var buyQty:Int = 0
    var getQty:Int = 0
    var getDiscPerc:Float = 0.0
    var getDiscPrice:Float = 0.0
    var offercriteriaId = ""
    var message = ""
    
    convenience init(_ json: [String : Any]) {
        self.init()
        buyQty = Converter.toInt(json["buyQty"])
        getQty = Converter.toInt(json["getQty"])
        getDiscPerc = Converter.toFloat(json["getDiscPerc"])
        getDiscPrice = Converter.toFloat(json["getDiscPrice"])
        offercriteriaId = Converter.toString(json["offercriteriaId"])
        message = Converter.toString(json["message"])
    }
    
}

class OfferEntityCriateria{
    
    var entityType = ""
    var entityValue = ""
    
    convenience init(_ json: [String : Any]) {
        self.init()
        
        entityType = Converter.toString(json["entityType"])
        entityValue = Converter.toString(json["entityValue"])
        
        
    }
    
}
