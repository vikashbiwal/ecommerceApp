//
//  Webservice+APICalls.swift
//
//
//

import Foundation
import UIKit

let isEnableLiveURL = false

//let localUrl = "http://digitalhotelgroup4.zoomi.in:202/"
//let liveUrl = "http://digitalhotelgroup4.zoomi.in:202/"

////201
//let localUrl = "http://digitalhotelgroup4.zoomi.in:201/"
//let liveUrl = "http://digitalhotelgroup4.zoomi.in:201/"
//
//KRISS
//let localUrl = "http://krissadmin.zoomi.in:81/"
//let liveUrl = "http://krissadmin.zoomi.in:81/"

let localUrl = "http://property.zoomi.in:81/"
let liveUrl = "http://property.zoomi.in:81/"




//205
//let localUrl = "http://digitalhotelgroup4.zoomi.in:205/"
//let liveUrl = "http://digitalhotelgroup4.zoomi.in:205/"


let apiDomainUrl =  isEnableLiveURL ? liveUrl : localUrl
let _baseUrl =  apiDomainUrl
//let _baseUrl =  apiDomainUrl + "Api/"
let _imageUploadUrl = apiDomainUrl + "UploadImage"


let wsCall = WebService()

enum APIName {
    static var GetCategories = "api/Home/CategoryGetList" //GetOffers  CategoryGetList
    static var GetAuthToken = "Authorization"
    static var GetBanner = "api/Home/Banner"
    static var GetProductDetails = "api/Product"
    static var LikeProduct = "api/Product/AddToLikes"
    static var getCartItemList = "api/Order/CartListCnt"
    static var getMyOrderList = "api/Customer/MyOrder"
    static var cancelOrder = "api/Order/OrderCancel"
    static var cancelItem = "api/Order/OrderUpdate"
    static var getDynamicHomeData = "api/Home/DynamicHome"
    static var AddProductToNotify = "api/Product/AddProductNotify"
	static var ProductTimeSave = "api/Product/ProductTimeSave"
	static var getPollList = "api/Question/PollGetList"
	static var getPollQuestion = "api/Question/PollGetQuestion"
    //static var cancelOrder = "api/Order/OrderCancel"
}


extension WebService {
    
    func downloadImage(url: String, block: @escaping WSFileBlock) {
        println("----------------Download Request URL : \(url)--------------------")
        DOWNLOAD_FILE(relPath: url, progress: nil, block: block)
    }

    //Download hotel's panorama images and save them in local storage.
    func downloadPanoramaImage(urlString: String, directory: String = "Documents", block: @escaping (UIImage?)->Void) {
        if let url = URL(string: urlString) {
            let filemanager = FileManager.default
            let fileName = url.lastPathComponent
            let filePath = NSHomeDirectory() + "/\(directory)/images/" + fileName
           
            if filemanager.fileExists(atPath: filePath) {
                if let image = UIImage(contentsOfFile:filePath) {
                    block(image)
                } else {
                    block(nil)
                }
                
            } else  {
                wsCall.downloadImage(url: urlString, block: { (path, finished) in
                    if let filePath = path {
                        if let image = UIImage(contentsOfFile:filePath) {
                            block(image)
                        } else {
                            block(nil)
                        }
                    }
                })
            }
        }
        
    }

    //Get AuthToken.
    func getAuthToken(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.GetAuthToken)---------------------")
        _ = POST_REQUEST(relPath: APIName.GetAuthToken, param: params, block: block)
    }

    //Get categories for home screen.
    func getCategorylist(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.GetCategories)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetCategories, param: params, block: block)
    }

    func getBannerlist(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.GetBanner)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetBanner, param: params, block: block)
    }

    func getProductDetails(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.GetProductDetails)---------------------")
        _ = GET_REQUEST(relPath: APIName.GetProductDetails, param: params, block: block)
    }

    func likeUnlikeProduct(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.LikeProduct)---------------------")
        _ = POST_REQUEST(relPath: APIName.LikeProduct, param: params, block: block)
    }
    func getCartItemList(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.getCartItemList)---------------------")
        _ = GET_REQUEST(relPath: APIName.getCartItemList, param: params, block: block)
    }
    func getMyOrderList(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.getMyOrderList)---------------------")
        _ = GET_REQUEST(relPath: APIName.getMyOrderList, param: params, block: block)
    }

    func cancelOrder(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.cancelOrder)---------------------")
        _ = POST_REQUEST(relPath: APIName.cancelOrder, param: params, block: block)
    }

    func cancelItem(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.cancelItem)---------------------")
        _ = POST_REQUEST(relPath: APIName.cancelItem, param: params, block: block)
    }

    func getDynamicHomeData(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.getDynamicHomeData)---------------------")
        _ = GET_REQUEST(relPath: APIName.getDynamicHomeData, param: params, block: block)
    }

    func addProductToNotify(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------Request API : \(APIName.AddProductToNotify)---------------------")
        _ = POST_REQUEST(relPath: APIName.AddProductToNotify, param: params, block: block)
    }

	func productTimeSave(params: [String : Any]?, block: @escaping ResponseBlock) {
		println("----------------------Request API : \(APIName.ProductTimeSave)---------------------")
		_ = POST_REQUEST(relPath: APIName.ProductTimeSave, param: params, block: block)
	}

	func getPollList(params: [String : Any]?, block: @escaping ResponseBlock) {
		println("----------------------Request API : \(APIName.getPollList)---------------------")
		_ = GET_REQUEST(relPath: APIName.getPollList, param: params, block: block)
	}

	func getPollQuestion(params: [String : Any]?, block: @escaping ResponseBlock) {
		println("----------------------Request API : \(APIName.getPollQuestion)---------------------")
		_ = POST_REQUEST(relPath: APIName.getPollQuestion, param: params, block: block)
	}



}
