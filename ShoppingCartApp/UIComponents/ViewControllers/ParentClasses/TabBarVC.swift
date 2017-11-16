//
//  TabBarVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 11/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        Cart.shared.delegate = self
        self.delegate = self
        if tabBarController?.selectedIndex == 4{
            let navigation1 = tabBarController?.viewControllers?[0] as! UINavigationController
            OpenLoginOrAccount(navigation: navigation1)
        }
        
        _defaultCenter.addObserver(self, selector: #selector(self.setWishListControllerInTabBar), name: NSNotification.Name.FavoriteWithCategoryDidSetValueNotification, object: nil)
    }

    func setWishListControllerInTabBar() {
        let nav = self.viewControllers?[1] as! UINavigationController
        
        if !FirRCManager.shared.isFavoriteWithCategory {
            let sb = UIStoryboard(name: "ProductList", bundle: nil)
            if let productListVC = sb.instantiateViewController(withIdentifier: "ProductListVC") as? ProductListVC {
                let apiParam = "{\"WishlistCategoryId\":\"0\"}"
                productListVC.apiParam = apiParam
                nav.viewControllers = [productListVC]
            }
        } else {
            let sb = UIStoryboard(name: "MyWishbox", bundle: nil)
            if let wishVC = sb.instantiateViewController(withIdentifier: "MyWishboxVC") as? MyWishboxVC {
                nav.viewControllers = [wishVC]
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        tabBarController.navigationController?.popToRootViewController(animated: false)
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
        print(tabBarController.selectedIndex)
        
        _defaultCenter.post(name: NSNotification.Name(rawValue: "TabbarDidChangeTab"), object: nil)
        
        if tabBarController.selectedIndex == 4{
            let navigation1 = viewController as! UINavigationController
            OpenLoginOrAccount(navigation: navigation1)
        }
    }
    
    func OpenLoginOrAccount(navigation:UINavigationController){
        loginFromTabbar = true
        var tmparray = navigation.viewControllers as [Any]
        if !checkUserLoggedIn(){
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let logintVC = sb.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            tmparray.removeAll()
            tmparray.insert(logintVC, at: 0)
            navigation.viewControllers = tmparray as! [UIViewController]
        } else {
            let sb = UIStoryboard(name: "Account", bundle: nil)
            let logintVC = sb.instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
            tmparray.removeAll()
            tmparray.insert(logintVC, at: 0)
            navigation.viewControllers = tmparray as! [UIViewController]
        }
    }

}

//MARK:- CartDelegate
extension TabBarVC : CartDelegate {
	func countDidChangeInCart(itemsCount: Int, quantityCount: Int) {
		let time = DispatchTime.now() + 0.5
		DispatchQueue.main.asyncAfter(deadline: time) {
            self.tabBar.items![2].badgeValue = itemsCount == 0 ? nil : itemsCount.ToString()
		}
	}
}
