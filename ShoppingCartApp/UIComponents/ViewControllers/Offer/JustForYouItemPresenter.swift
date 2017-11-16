//
//  JustForYouItemPresenter.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 15/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


protocol ProductListView: class {
    func startLoading()
    func finishLoading()
    func didRecieveItems(products:[Product], offers: [Offer])
    func didRecevieErrorWith(message: String)
}


class JustForYouItemPresenter {
    weak var listView: ProductListView?
    var loadMore = LoadMore()
    var canLoadMore = true
    
    init(listView: ProductListView) {
        self.listView = listView
    }
    
    func loadJustForYouItems() {
        
        if !loadMore.isLoading && !canLoadMore {return}
        loadMore.isLoading = true
        
        let params =  ["includeDeleted": false,
                       "flag": "JustForYou",
                       "orderBy": "Price",
                       "pagenumber": loadMore.offset.ToString(),
                       "pageSize": loadMore.limit.ToString(),
                       "propertyDetail": []
            ] as [String : Any]
        
        listView?.startLoading()
        wsCall.getJustForYouItems(params: params) { response in
            if response.isSuccess {
                self.loadMore.isLoading = false
                
                if let json = response.json as? [String : Any] {
                    var offerItmes: [Offer] = []
                    var products: [Product] = []
                    
                    //Just for you product items
                    if let justforYouJsonItems = json["justforYoulist"] as? [[String : Any]] {
                        products = justforYouJsonItems.map({Product($0)})
                    }
                    
                    //just for you offer items
                    if let offerJsonItem = json["offerList"] as? [[String : Any]] {
                        offerItmes = offerJsonItem.map({Offer($0)})
                    }
                    
                    //notify listview with new items
                    self.listView?.didRecieveItems(products: products, offers: offerItmes)
                    
                    //increase page count for load next page items
                    self.loadMore.offset += 1
                    self.canLoadMore = !products.isEmpty
                }
            } else {
                self.listView?.didRecevieErrorWith(message: response.message)
            }
            
            self.listView?.finishLoading()
        }
        
    }
}
