//
//  SearchViewModel.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 05/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class SearchViewModel {
    var searchDataTask: URLSessionTask?
    typealias SearchResultBlcok =  ([SearchResult])->Void
   
    func searchItemsWith(text: String, completion: @escaping SearchResultBlcok)  {
        self.searchApiCallingFor(text, completion)
    }
    
}

extension SearchViewModel {
   fileprivate func searchApiCallingFor(_ text: String, _ completion: @escaping SearchResultBlcok) {
        searchDataTask?.cancel()
       
        if text.characters.count >= 3 {
            searchDataTask =  wsCall.searchItems(params: ["SearchText" : text]) { response in
                if response.isSuccess {
                    if let jsonArr = response.json as? [[String : Any]] {
                        let results = self.jsonToSearchResults(jsonArr)
                        completion(results)
                        if results.isEmpty {
                            KVAlertView.show(message: "No item found for '\(text)'")
                        }
                    } else {
                        completion([])
                    }
                } else {
                    //error
                }
            }
        }
    }

    //converting json array to SearchReults
    fileprivate func jsonToSearchResults(_ jsonArr: [[String : Any]])->[SearchResult] {
        let resultArr = jsonArr.map({ SearchItem($0)})
        
        //finding ExactMatch and Similar results.
        let exactMatchItems = resultArr.filter({$0.isExactMatch})
        let similarItems = resultArr.filter({!$0.isExactMatch})
      
        var searchResults = [SearchResult]()
        if !exactMatchItems.isEmpty {
            let result = SearchResult(title: "exactMatch", items: exactMatchItems)
            searchResults.append(result)
        }
        
        if !similarItems.isEmpty {
            let result = SearchResult(title: "Similar Items", items: similarItems)
            searchResults.append(result)
        }
        return searchResults
    }
}

//MARK:- SearchItem
struct SearchItem {
    var apiParameters : String = ""
    var isExactMatch = false
    var productId: String
    var htmlString: String
    
    init(_ json: [String: Any]) {
        apiParameters = Converter.toString(json["apiParam"])
        isExactMatch = Converter.toBool(json["isExcatMatch"])
        productId = Converter.toString(json["productId"])
        htmlString = Converter.toString(json["resultText"])
    }
}

//MARK:- SearchResult
struct SearchResult {
    let title: String
    let items: [SearchItem]
}

