//
//  Webserivce+Account.swift
//  ShoppingCartApp
//
//  Created by zoomi on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

extension APIName{
    
     static var profileUpdate = "api/Customer/ProfileUpdate"
     static var uploadProfileImage = "api/FileUpload/ProfileImage"
    
}

extension WebService{
    
    //Profile Update Api
    func callProfileUpdate(params: [String : Any]?, block: @escaping ResponseBlock) {
        println("----------------------profileUpdate Request API : \(APIName.profileUpdate)---------------------")
        _ = POST_REQUEST(relPath: APIName.profileUpdate, param: params, block: block)
        
    }
    
    func callProfileImageUpload(profileImage: Data, block: @escaping ResponseBlock) {
        
        println("----------------------uploadProfileImage Request API : \(APIName.uploadProfileImage)---------------------")
        UPLOAD_IMAGE(relPath: APIName.uploadProfileImage, imgData: profileImage, param: nil, block: block, progress: nil)
    }
    
}
