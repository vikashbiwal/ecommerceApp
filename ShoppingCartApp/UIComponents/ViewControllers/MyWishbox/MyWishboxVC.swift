//
//  MyWishboxVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 19/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
///

import UIKit
import KVAlertView
import UIImageColors

class MyWishboxVC: ParentViewController {
    
    @IBOutlet weak var collView: UICollectionView!
    
    var numberOfItemInRow: Int {return IS_IPAD ? 3 : 2}
    
    var wishListViewModel = WishCategoryViewModel()
    var wishGroups = [WishGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 59, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.showCentralSpinner()
        wishListViewModel.getWishListCategories {[weak self] groups in
            if let weakSelf = self {
                
                weakSelf.wishGroups = groups
                weakSelf.collView.reloadData()
                weakSelf.hideCentralSpinner()
                weakSelf.showHideEmptyDataView()
            }
            
        }
    }
    
    func showHideEmptyDataView() {
        if wishGroups.isEmpty {
            emptyDataView.show(in: self.view, message: "No item in wishlist.")
        } else {
            emptyDataView.remove()
        }
    }
    
    //Show alert action for update category
    func showEditAlert(for group: WishGroup) {
        let alert = UIAlertController(title: "UpdateCategory".localizedString(), message: nil, preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.text = group.title
        }
        
        alert.addAction(UIAlertAction(title: "Save".localizedString(), style: .default) {al in
            let newTitle = alert.textFields![0].text!
            self.wishListViewModel.updateCategory(id: group.id, title: newTitle, block: {[weak self] success in
                if success {
                    group.title = newTitle
                    self?.collView.reloadData()
                }
            })
        })
        

        //Delete category confirm alert
        func deleteConfirmAction() {
            let alertCon = UIAlertController(title: "Are you sure you want to delete '\(group.title)' ?", message: nil, preferredStyle: .alert)
            alertCon.addAction(UIAlertAction(title: "Yes", style: .default) {alert in
                //Delete api call
                self.wishListViewModel.deleteCategory(id: group.id, block: { [weak self] success in
                    if success {
                        self?.wishGroups.removeElement(group)
                        self?.collView.reloadData()
                        self?.showHideEmptyDataView()
                    }
                })
            })
            alertCon.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertCon, animated: true, completion: nil)
        }
        
		alert.addAction(UIAlertAction(title: "Delete".localizedString(), style: .destructive) {alert in
			deleteConfirmAction()
		})

		alert.addAction(UIAlertAction(title: "Cancel".localizedString(), style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
    }

    //MARK:- IBActions
    @IBAction func edit_buttonClicked(_ sender: UIButton) {
        let group = wishGroups[sender.tag]
        self.showEditAlert(for: group)
    }
}


// MARK: - CollectionView Delegate and DataSource
extension MyWishboxVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wishGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wishListItemCell", for: indexPath as IndexPath) as! WishListItemCell
        let group = wishGroups[indexPath.row]
        cell.setInfo(for: group)
        cell.button.tag = indexPath.row
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = wishGroups[indexPath.row]
        if group.saveCounts > 0 {
            let productvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
            productvc.apiParam = group.apiParams
            productvc.navigationTitle = group.title
            self.navigationController?.pushViewController(productvc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenSize.width - CGFloat(40 + 10 * (numberOfItemInRow - 1)) )/CGFloat(numberOfItemInRow), height:180 * universalWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    }
    
}

//MARK:- WhishListItemCell
class WishListItemCell: CollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblSubTitle.backgroundColor = UIColor.random()
    }
    
    func setInfo(for group: WishGroup) {
        self.lblTitle.text = group.title
        self.lblSubTitle.text = group.saveCounts.ToString() + " Saves"
        if let url = URL(string: group.imgUrl) {
            self.imgView.setImage(url: url)
        } else {
            self.imgView.image  = UIImage(named: "")
        }
    }
}


