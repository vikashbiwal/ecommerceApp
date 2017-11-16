//
//  FilterModel.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 6/28/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation


//MARK:- PRODUCT FILTER : RESPONSE MODEL -

class Filter: Equatable {
   var groupName = ""
   var groupNameDisplay = ""
   var optionType = ""
   var priority = 0
   var id = ""
    var options = [FilterOption]()
    var isProperty = false
    
    convenience init(_ json:[String: Any]) {
        self.init()
        groupName = Converter.toString(json["groupName"])
        groupNameDisplay = Converter.toString(json["groupNameDisplay"])
        optionType = Converter.toString(json["optionType"])
        priority = Converter.toInt(json["priority"])
        
       // subOptions = [FilterOption.init()]
        let aTempArray = json["options"] as! NSArray
        options =  aTempArray.map({ (optionObject) -> FilterOption in
            return FilterOption(optionObject as! [String : Any])
            
        })

    }

    var filerSelected: Bool {
        return !options.filter({$0.selected}).isEmpty
    }
    
    var propertyDetails: PropertyDetail {
        let detail = PropertyDetail()
        detail.propertyKey = groupName
        let selectedOptions = options.filter({$0.selected})
        if !selectedOptions.isEmpty {
            let values = selectedOptions.map({$0.optionNameValue}).joined(separator: ",")
            detail.propertyValue  = values
        }
        detail.isProperty = isProperty
        return detail
    }
    //for comapring two objects
    func equals (compareTo:Filter) -> Bool {
        return self.groupNameDisplay == compareTo.groupNameDisplay
    }
    
    //Equtable Protocol
    static func ==(lhs: Filter, rhs: Filter)-> Bool {
        return lhs.groupNameDisplay == rhs.groupNameDisplay
       // return lhs.id == rhs.id
    }
}

class FilterOption {
    var count = 0
    var optionName = ""
    var optionNameValue = ""
    var totalCount = 0
    var selected = false
    
    convenience init(_ json:[String: Any]) {
        self.init()
        count = Converter.toInt("0")
        totalCount = Converter.toInt(json["totalCount"])
        optionName = Converter.toString(json["optionName"])
        optionNameValue = Converter.toString(json["optionNameValue"])
       
    }
}
//MARK: - PRODUCT FILTER : REQUEST MODEL - NEW
class FilterRequest{
    var filterType = "categoryIdentifier"
    var filterOptions = [PropertyDetail]()
    
    func convertObjectIntoDictionary() -> [String : Any] {
        var requestDict = [String : Any]()
        
        requestDict["filterType"] = self.filterType
        requestDict["propertyDetail"] = PropertyDetail.getFiltersJson(filterOptions: filterOptions)
        
        return requestDict
    }
    
    func setfilterOptions(fromApiParam: String ,andSelectedFilters:[PropertyDetail])-> [String: Any] {
        
        //convert dictionary in to array of property detail object
        var atempfilterOption = [PropertyDetail]()
        
        if !fromApiParam.isEmpty {
            let jsonData = fromApiParam.parseJSONString
            
            let keys = jsonData?.allKeys as! [String]
            
            
            atempfilterOption = keys.map { (key) -> PropertyDetail in
                return PropertyDetail(["propertyKey" : key , "propertyValue" :jsonData?.value(forKey: key) ?? ""  ,"isProperty" : false])
            }
        } //!fromApiParam.isEmpty
        
        
        
        let atempfilterOption1 = andSelectedFilters.map { (detailObj) -> PropertyDetail in
            if detailObj.propertyKey != "minprice" && detailObj.propertyKey != "maxprice" {
                detailObj.isProperty = true
            }
            return detailObj
        }
        filterOptions.removeAll()
        if atempfilterOption.count > 0 {
            filterOptions = atempfilterOption
        }
        if atempfilterOption1.count > 0 {
            filterOptions.append(contentsOf: atempfilterOption1)
        }
        
        // filterOptions = atempfilterOption + atempfilterOption1
        
        return self.convertObjectIntoDictionary()
    }


}


//MARK:- PRODUCT LIST : REQUEST MODEL - NEW
class ProductListRequest {

    var includeDeleted = false
    var pagenumber = 1
    var pageSize = COUNTPERPAGE
    var orderBy = ""
    
    var filterOptions = [PropertyDetail]()
    var flag = "List"
    var uniqueKey = ""
    
    func convertObjectIntoDictionary() -> [String : Any] {
        var requestDict = [String : Any]()
        
        requestDict["includeDeleted"] = self.includeDeleted
        requestDict["pagenumber"] = self.pagenumber
        requestDict["pageSize"] = self.pageSize
        requestDict["orderBy"] = self.orderBy
        
        requestDict["flag"] = self.flag
        requestDict["uniqueKey"] = self.uniqueKey
        requestDict["propertyDetail"] = PropertyDetail.getFiltersJson(filterOptions: filterOptions)
        
        
        
        return requestDict
    }
    
    
    
    //MARK: -
    //[{"param": "sample string 1","paramValue": "sample string 2"},{"param": "sample string 1","paramValue": "sample string 2"}]
    func setfilterOptions(fromApiParam: String ,andSelectedFilters:[PropertyDetail], isSimilarProduct:Bool = false , isPropertyData:Bool = false)-> [String: Any] {
        
        print("isSimilarProduct:\(isSimilarProduct) and isPropertyData:\(isPropertyData)")
        
        //convert dictionary in to array of property detail object
        var atempfilterOption = [PropertyDetail]()
        
        if !fromApiParam.isEmpty {
            let jsonData = fromApiParam.parseJSONString
            
            let keys = jsonData?.allKeys as! [String]
            
            
            atempfilterOption = keys.map { (key) -> PropertyDetail in
                return PropertyDetail(["propertyKey" : key , "propertyValue" :jsonData?.value(forKey: key) ?? ""  ,"isProperty" : isSimilarProduct ? isPropertyData : false])
            }
        } //!fromApiParam.isEmpty
        
        
        
        let atempfilterOption1 = andSelectedFilters.map { (detailObj) -> PropertyDetail in
            if detailObj.propertyKey != "minprice" && detailObj.propertyKey != "maxprice" {
                detailObj.isProperty = true
            }
            return detailObj
        }
        filterOptions.removeAll()
        if atempfilterOption.count > 0 {
            filterOptions = atempfilterOption
        }
        if atempfilterOption1.count > 0 {
            filterOptions.append(contentsOf: atempfilterOption1)
        }
        
       // filterOptions = atempfilterOption + atempfilterOption1
        
        return self.convertObjectIntoDictionary()
    }

}

// filter options
class PropertyDetail {
    
    var propertyKey = ""
    var propertyValue = ""
    var isProperty = false
    
    init() {
        //self.init()
    }
    
    init(_ sortDictionary: [String : Any]) {
        if Converter.toString(sortDictionary["propertyKey"]) != ""{
            propertyKey = Converter.toString(sortDictionary["propertyKey"])
            propertyValue = Converter.toString(sortDictionary["propertyValue"])
            isProperty = Converter.toBool(sortDictionary["isProperty"])
        }
    }
    
    func convertPropertyDetailObjectIntoDictionary() -> [String: Any]{
        var dict = [String : Any]()
        
        dict["propertyKey"] = self.propertyKey
        dict["propertyValue"] = self.propertyKey
        dict["isProperty"] = self.isProperty
        
        return dict
    }
    
    //for comapring two objects
    func equals (compareTo:PropertyDetail) -> Bool {
        return self.propertyKey == compareTo.propertyKey
    }
    
    //convert array of object in to  array of dictionary
    static func getFiltersJson( filterOptions : [PropertyDetail])-> [[String : Any]] {
        return filterOptions.map { filter -> [String : Any] in
            return ["propertyKey" :filter.propertyKey , "propertyValue" : filter.propertyValue ,"isProperty" : filter.isProperty]
        }
        
    }
    
}
class Setting{
    
    class var islikeavailable : Bool{
        return false
    }
    
    init(_ settingDictionary: [String : Any]) {
       // Setting.islikeavailable = Converter.toBool(settingDictionary["islikeavailable"])
        
    }
    
   
}
// MARK:-
extension String
{
    var parseJSONString: AnyObject?
    {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if let jsonData = data
        {
            // Will return an object or nil if JSON decoding fails
            do
            {
                let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                if let jsonResult = message as? NSMutableArray {
                    return jsonResult //Will return the json array output
                } else if let jsonResult = message as? NSMutableDictionary {
                    return jsonResult //Will return the json dictionary output
                } else {
                    return nil
                }
            }
            catch let error as NSError
            {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else
        {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

