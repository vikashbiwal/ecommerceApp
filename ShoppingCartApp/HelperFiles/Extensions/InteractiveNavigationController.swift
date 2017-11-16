//
//  InterectiveNavigationController.swift
//  BookMyHotel
//
//  Created by Vikash Kumar on 16/02/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class InteractiveNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf: InteractiveNavigationController? = self
        self.interactivePopGestureRecognizer?.delegate = weakSelf!
        self.delegate = weakSelf!
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        if self.viewControllers.count > 1{
            return true
        }else{
            return false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
                if viewController is HomeViewController {
                    self.interactivePopGestureRecognizer!.isEnabled = false
                }else{
                    self.interactivePopGestureRecognizer!.isEnabled = true
                }
    }
    
}
