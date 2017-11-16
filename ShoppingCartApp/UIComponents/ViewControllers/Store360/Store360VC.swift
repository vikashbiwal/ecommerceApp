//
//  Store360VC.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 28/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import WebKit

class Store360VC: ParentViewController {
    var webView: WKWebView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let webConfiguration = WKWebViewConfiguration()
        let webFrame = CGRect(x: 0, y: 64, width: screenSize.width, height: screenSize.height - 64)
        webView = WKWebView(frame: webFrame, configuration: webConfiguration)
        self.view.addSubview(webView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = URL(string: "http://azuredigiwalks.com/explore/relience_trends_ecommerce/index.html") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
