//
//  JsonResponseLocalStorage.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 21/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation


class LocalStorage {
    
    class func writeJson(object: Any, forKey key: String) {
    
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = documentDirectory.appending("/LocalData.plist")

        let fileManager = FileManager.default
        
        if(!fileManager.fileExists(atPath: path)){
         
            if let bundlePath = Bundle.main.path(forResource:"LocalData" , ofType: "plist"){
                let result = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle file myData.plist is -> \(result?.description)")
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }catch{
                    print("copy failure.")
                }
            }else{
                print("file LocalData.plist not found.")
            }
            
        }else{
            
            print("file myData.plist already exits at path.")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: Bundle.main.path(forResource:"LocalData" , ofType: "plist")!)
       
        
        resultDictionary?.setObject(object, forKey: key as NSCopying)
        
        print("load myData.plist is ->\(resultDictionary?.description)")
        print("bundle path ->\(path)")
        
        resultDictionary?.write(toFile: path, atomically: true)
        
    }
    
    
    class func readJson(for Key: String) -> Any? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.appending("/LocalData.plist")
        let json = NSDictionary(contentsOfFile: path)
        return json?[Key]
   }
    
}
