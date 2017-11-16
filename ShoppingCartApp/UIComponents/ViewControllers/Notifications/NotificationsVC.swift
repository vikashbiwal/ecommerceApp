//
//  NotificationsVC.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 03/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class NotificationsVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      self.emptyDataView.show(in: self.view, message: "No notifications available.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
