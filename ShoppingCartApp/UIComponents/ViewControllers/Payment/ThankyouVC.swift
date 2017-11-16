//
//  ThankyouVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 8/5/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class ThankyouVC: ParentViewController  {
    
    @IBOutlet weak var lblDisplayOrderId: Style1WidthLabel!
    
    var placeOrderResponse = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationBarView.drawShadow()
        self.tabBarController?.tabBar.isHidden = true
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblDisplayOrderId.text = "Your order ID: " + Converter.toString(placeOrderResponse["displayOrderId"])
   }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

}

extension ThankyouVC {
    @IBAction func btnContinueClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
        if (_appDelegator.tabBarVC) != nil {
            _appDelegator.tabBarVC.selectedIndex = 0  // Or whichever number you like
            _appDelegator.tabBarVC.selectedViewController?.navigationController?.popToRootViewController(animated: false)
            
        }
        
    }
}
