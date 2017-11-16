//
//  WishListGroupListVC.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 11/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
// /

import UIKit
import KVAlertView

typealias WishBox = WishListGroupListVC
extension WishBox {
    //for showing pop used this func.
    class func showWishBox(in vc: ParentViewController, sourceFrame: CGRect, product: Product, completionBlock: ((Bool)->Void)? = nil) {
        let wishVC = vc.storyboardWishListh.instantiateViewController(withIdentifier: "SBID_GroupListVC") as! WishListGroupListVC
        wishVC.product = product
        wishVC.modalPresentationStyle = IS_IPAD ? .popover : .overCurrentContext
        wishVC.popoverPresentationController?.sourceView  = vc.view
        wishVC.popoverPresentationController?.sourceRect = sourceFrame
        wishVC.completionBlock = completionBlock
		let presentingVC = vc.tabBarController ?? vc
        presentingVC.present(wishVC, animated: IS_IPAD, completion: nil)
    }
}

//MARK:- WishListGroupListVC
class WishListGroupListVC: ParentViewController {

    @IBOutlet weak var groupListView: WishGroupListView!
    @IBOutlet weak var listViewVRCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var listWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var listHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var containerView: UIView!
    
    var wishGroupViewModel = WishCategoryViewModel()
    var product: Product!
    var completionBlock: ((Bool)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !IS_IPAD {
            listViewVRCenterConstraint.constant = self.view.center.y + self.groupListView.frame.height
            self.view.alpha = 0
        }
        
        self.showCentralSpinner()
        wishGroupViewModel.getWishListCategories {[weak self] groups  in
            self?.groupListView.groups = groups
            self?.groupListView.tableView.reloadData()
            self?.hideCentralSpinner()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !IS_IPAD {
            showList()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wishGroupViewModel.categoryFetchTask?.cancel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUI()
    }
    
    //Set Initial UI
    func setUI() {
        if IS_IPAD {
            listWidthConstraint.constant = self.view.frame.width
            listHeightConstraint.constant = self.view.frame.height
            self.view.drawShadow(0.8)
        }  else {
            listWidthConstraint.constant = 300 * universalWidthRatio
            listHeightConstraint.constant =   400 * universalWidthRatio
        }
        containerView.frame = self.view.bounds
        tableView.contentSize = self.view.frame.size
    }
    
    
    deinit {
        //print("WishListGroupListVC deinit")
    }
}

//MARK:- Show hide animation for wish group list
extension WishListGroupListVC {
    //Show with animation
    func showList() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7, options: [.curveEaseOut
            
            ], animations:
            {
                self.listViewVRCenterConstraint.constant = 0
                self.view.backgroundColor = UIColor.black.alpha(0.4)
                self.view.alpha = 1
                self.view.layoutIfNeeded()
        })
    }
    
    //Hide with animation
    func hideList() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.9, options: [.curveEaseInOut], animations:
            {
                self.listViewVRCenterConstraint.constant = self.view.center.y + self.groupListView.frame.height
                self.view.backgroundColor = UIColor.clear
                self.view.alpha = 0
                self.view.layoutIfNeeded()
        }) {success in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}

//MARK:- IBActions
extension WishListGroupListVC {
    //Close button action
    @IBAction func close_btnClicked(_ sender: UIButton?) {
        if !IS_IPAD {
            hideList()
        }
    }
    
    //this action call by tapping on select or unSelect button in side the cell.
    @IBAction func cellChoice_btnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    //add new category btn action
    @IBAction func addGroup_btnClicked(_ sender: UIButton) {
        if let newGroupName = groupListView.txtGroupName.text, !newGroupName.isEmpty {
            wishGroupViewModel.addCategory(name: newGroupName) {[weak self] (success, group) in
                if success {
                    self?.groupListView.txtGroupName.text = ""
                    self?.groupListView.appendNew(group: group!)
                } else {
                    
                }
            }
        } else  {
            KVAlertView.show(message: "GroupNameRequired".localizedString())
        }
    }
    
    //call when user tap on save button for adding selected product in selected category.
    @IBAction func saveProduct_buttonClicked(_ sender: UIButton) {
        if let cate = groupListView.groups.filter({$0.selected}).first {
            self.showCentralSpinner()
            wishGroupViewModel.addProductInWishCategory(categoryID: cate.id, productID: product.productId.ToString(), block: {[weak self] success in
                self?.hideCentralSpinner()
                if success {
                    self?.hideList()
                }
				self?.completionBlock?(success)
            })
            
        } else {
            KVAlertView.show(message: "Please select a category to add product.")
        }
    }
}








