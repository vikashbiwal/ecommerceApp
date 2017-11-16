 //
//  FirbaseRemoteConfigManager.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 17/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

typealias FirRCManager = FirbaseRemoteConfigManager

enum RemoteConfigKey {
    static let giftPricePerQuantityKey      = "gift_price_per_quantity"
    static let giftPricePerWeightKey        = "gift_price_per_weight"
    static let isLikeEnableKey              = "is_like_enable"
    static let isBannerAutoPlay             = "is_banner_auto_play"
    static let isThirdLevelCategoryExpand   = "is_thirdlevelcategory_expand"
    static let isFavoriteWithCategoryKey    = "is_favorite_with_category"
	static let contactUsEmailKey            = "contact_us_email"
	static let contactUsPhonenoKey          = "contact_us_phoneno"
    static let allowedCODKey                = "allow_cod"
    static let allowedOnlinePaymentKey      = "allow_online_payment"
}

 extension NSNotification.Name {
    static let FavoriteWithCategoryDidSetValueNotification = NSNotification.Name(rawValue: "FavoriteWithCategoryDidChangeNotification")
 }
 
class FirbaseRemoteConfigManager {
    static let shared = FirbaseRemoteConfigManager()
    
    var giftPriceForQty = 0.0
    var giftPriceForWeight = 0.0
    var isLikeEnable = false
    var isBannerAutoPlay = false
    var isthirdLevelCategoryExpand = false
    let expirationDuration: TimeInterval = 300.0
	var contactUsEmail = ""
	var contactUsPhoneno = ""
    var isCODavailable = true
    var isPayTMavailable = true

    var isFavoriteWithCategory = false {
        didSet {
                _defaultCenter.post(name: NSNotification.Name.FavoriteWithCategoryDidSetValueNotification, object: nil)
            }
    }

    private init() {
        //
    }
    
    func fetchConfigurations() {
		let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
		RemoteConfig.remoteConfig().configSettings = remoteConfigSettings!
        fetchGiftPrice()
        fetchFavoriteWithCategoryValue()
        fetchIsLikeEnable()
        fetchBannerAutoPlayValue()
        fetchCategoryExpand()
		fetchContactUsEmail()
		fetchContactUsNumber()
        fetchPaymentOptions()
    }
    
    private func fetchGiftPrice() {

        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.giftPricePerQuantityKey : NSNumber(value: 0)])
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.giftPricePerQuantityKey)
            self.giftPriceForQty = value.numberValue?.doubleValue ?? 0.0
        }
    }
    
    private func fetchFavoriteWithCategoryValue() {
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.isFavoriteWithCategoryKey : NSNumber(value: false)])
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.isFavoriteWithCategoryKey)
            self.isFavoriteWithCategory = false//value.boolValue
        }
    }
    
    private func fetchIsLikeEnable() {
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.isLikeEnableKey : NSNumber(value: false)])
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.isLikeEnableKey)
            self.isLikeEnable = value.boolValue
        }

    }
    
   private func fetchBannerAutoPlayValue() {
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.isBannerAutoPlay : NSNumber(value: false)])
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.isBannerAutoPlay)
            self.isBannerAutoPlay = value.boolValue
        }
    }
    
    private func fetchCategoryExpand() {
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.isThirdLevelCategoryExpand : NSNumber(value: false)])
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            if status == .success {
                print("Config fetched!")
                RemoteConfig.remoteConfig().activateFetched()
            } else {
                print("Config not fetched")
                //print("Error \(error!.localizedDescription)")
            }
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.isThirdLevelCategoryExpand)
            self.isthirdLevelCategoryExpand = value.boolValue
        }
    }

	private func fetchContactUsNumber() {

		RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.contactUsPhonenoKey : NSNumber(value: 0)])
		RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
			RemoteConfig.remoteConfig().activateFetched()
			let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.contactUsPhonenoKey)
			self.contactUsPhoneno = value.stringValue!
		}
	}

	private func fetchContactUsEmail() {

		RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.contactUsEmailKey : NSNumber(value: 0)])
		RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
			RemoteConfig.remoteConfig().activateFetched()
			let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.contactUsEmailKey)
			self.contactUsEmail = value.stringValue!
		}
	}
    private func fetchPaymentOptions() {
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.allowedCODKey : NSNumber(value: true)])
        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.allowedOnlinePaymentKey : NSNumber(value: true)])
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: expirationDuration) { (status, error) in
            RemoteConfig.remoteConfig().activateFetched()
            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.allowedCODKey)
            self.isCODavailable = value.boolValue
            
            let value1 = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.allowedOnlinePaymentKey)
            self.isPayTMavailable = value1.boolValue
        }
        
    }
}
