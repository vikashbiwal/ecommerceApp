//
//  CartViewController.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 19/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import KVAlertView

class CartViewController: ParentViewController {
    @IBOutlet var collView: UICollectionView!
    @IBOutlet var buttonContinue: UIButton!
    @IBOutlet var btnEditCart: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var collViewBottomSpace: NSLayoutConstraint!
    
    let productNameFont = UIFont(name: FontName.SEMIBOLD1, size: 13 * universalWidthRatio)
    
    let cartModel = CartViewModel()
    var cartListGetTask: URLSessionTask?
    
    var order: Order?
    
    var isCartEditing: Bool = false {
        didSet {
            let imgName = isCartEditing ? "" : "ic_mode_edit"
            let tilte = isCartEditing ? "Done" : ""
            btnEditCart.setImage(UIImage(named: imgName), for: .normal)
            btnEditCart.setTitle(tilte, for: .normal)
            buttonContinue.isHidden = isCartEditing || Cart.shared.cartItems.isEmpty
            self.collView.reloadData()
            collViewBottomSpace.priority = isCartEditing ? 999 : 997
        }
    }
    
    var giftAmountPerItem = 0.0
    
    enum CartSectionType: Int {
        case productInfo, giftInfo, amountInfo
    }
    
    //struct used for create object of amount for showing in amount summery.
    struct PaymentAmount {
        var amountFor: String
        var amount: String
    }
    
    //array store all items of cart amount summery.
    var cartAmounts: [PaymentAmount]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareUI()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isCartEditing = false
        self.fetchCartItemsAndGiftPackingPrices()
    }
    
    func prepareUI() {
        let menuBtnImgName: String
        let menuAction: Selector
        if let _ = self.navigationController?.viewControllers.first as? CartViewController {
            menuBtnImgName = "ic_menu"
            menuAction = #selector(self.shutterButtonTapped(sender:))
        } else {
            menuBtnImgName = "ic_arrow_left"
            menuAction = #selector(self.parentBackAction(sender:))
        }
        
        btnMenu.setImage(UIImage(named: menuBtnImgName), for: .normal)
        btnMenu.addTarget(self, action: menuAction, for: .touchUpInside)
        buttonContinue.isHidden = true
        collView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 6, right: 0)
    }
    
    
    func fetchCartItemsAndGiftPackingPrices() {
        //get cartlist items
        self.showCentralSpinner()
        cartListGetTask = cartModel.getCartItems {[weak self] (success, code) in
            self?.hideCentralSpinner()
            if let weakSelf = self {
                if success {
                    weakSelf.setCartAmounts()
                    weakSelf.collView.reloadData()
                }
                
                weakSelf.showHideEmptyDataView(InternetAvailable: code != -1009)
            }
        }
        emptyDataView.selectors = [RetrySelctor(observer: self, selector: #selector(self.fetchCartItemsAndGiftPackingPrices))]
    }
    
    
    //prepare Amount summary info
    func setCartAmounts() {
        let productsPrice = RsSymbol + " " + String(format: "%.2f", Cart.shared.totalProductsPrice)
        let gstPrice = RsSymbol + " " + String(format: "%.2f", Cart.shared.totalCartGSTAmount)
        let discountPrice = RsSymbol + " " + String(format: "%.2f", Cart.shared.totalCartDiscount)
        let totalPayblePrice = RsSymbol + " " + String(format: "%.2f", Cart.shared.totalCartAmount)
        
        cartAmounts = [PaymentAmount(amountFor: "Total".localizedString(), amount:  productsPrice),
                       PaymentAmount(amountFor: "Discount".localizedString(), amount: discountPrice),
                       PaymentAmount(amountFor: "GST".localizedString(), amount: gstPrice),
                       PaymentAmount(amountFor: "Net Amount".localizedString(), amount: totalPayblePrice)]
    }
    
    
    //size or color change action block
    lazy var sizeColorChangeBlock: (PDCharacter, Product)->Void = {[weak self]  (newSelectedItem , product) in
        func productIndex()-> Int? {
            for (index, obj) in Cart.shared.cartItems.enumerated() {
                if obj.product.productId == product.productId {
                    return index
                }
            }
            return nil
        }
        
        if let index = productIndex() {
            self?.changeSizeOrColor(of: product.productId.ToString(), newProId: newSelectedItem.productId, index: index)
        }

    }
    
    //Show hide emptyDataView
    func showHideEmptyDataView(InternetAvailable: Bool) {
        let isCartEmpty = Cart.shared.cartItems.isEmpty
        if InternetAvailable {

            if isCartEmpty {
                emptyDataView.show(in: self.view, message: "CartIsEmpty".localizedString())
            } else {
                emptyDataView.remove()
            }

        } else {
            if isCartEmpty {
                emptyDataView.show(in: self.view, message: kInternetDown, buttonTitle: "Try Again", enableRetryOption: true)
            }
        }
        buttonContinue.isHidden = isCartEmpty
        btnEditCart.isHidden = isCartEmpty
    }
    
}

//MARK:- IBActions
extension CartViewController {
    //Size Change button action
    @IBAction func quantityChange_buttonClicked(_ sender: UIButton) {
        let item = Cart.shared.cartItems[sender.tag]
        self.changeQuantity(for: item, sender: sender)
    }

	@IBAction func btnProductDetail_Clicked(_ sender: UIButton) {
		let item = Cart.shared.cartItems[sender.tag]
		ProductDetailVC.showProductDetail(in: self, productId: nil, product: item.product, isFromCart: true,identifier: nil, shouldShowTab: !(self.tabBarController?.tabBar.isHidden)!)
	}

    //Remove Item button action
    @IBAction func removeFromCart_ButtonClicked(_ sender: UIButton) {
        let cartItem = Cart.shared.cartItems[sender.tag]
        self.removeCart(item: cartItem)
    }
    
    
    //Add to favourite button action
    @IBAction func addToFavourite_buttonClicked(_ sender: UIButton) {
        let cartItem = Cart.shared.cartItems[sender.tag]
        addRemoteToFavourit(product: cartItem.product, sender: sender)
    }
    
    @IBAction func edit_buttonClicked(_ sender: UIButton) {
        isCartEditing = !isCartEditing
    }

    
    @IBAction func sendAsGift_switchChange(_ switchBtn: UISwitch) {
        Cart.shared.sendAsGift = switchBtn.isOn
        setCartAmounts()
        collView.reloadData()
    }
    
    @IBAction func continueOrder_buttonClicked(_ sender: UIButton) {
        if !checkUserLoggedIn() {
            if let loginVC = storyboardLogin.instantiateViewController(withIdentifier: "SBID_loginNav") as? UINavigationController {
                let presentingVC = self.tabBarController ?? self
                presentingVC.present(loginVC, animated: true, completion: nil)
            }
        } else {
            let paymentProcess1VC = self.storyboardShoppingCart.instantiateViewController(withIdentifier: "addressAndOfferVC") as! addressVC
            
            if _appDelegator.isViewOrder {
                let orderToPurchase = self.order ?? Order.orderFromCart()
                self.order = orderToPurchase
                paymentProcess1VC.currentOrder =  orderToPurchase

            }else{
                let orderToPurchase = Order.orderFromCart()
                self.order = orderToPurchase
                paymentProcess1VC.currentOrder =  orderToPurchase
            }
            self.tabBarController?.navigationController?.pushViewController(paymentProcess1VC, animated: true)
            
           // let tabbarVC = self.tabBarController ?? self
           // tabbarVC.navigationController?.pushViewController(paymentProcess1VC, animated: true)
        }
    }

    @IBAction func productIcon_btnClicked(_ sender: UIButton) {
        let product = Cart.shared.cartItems[sender.tag].product
        ProductDetailVC.showProductDetail(in: self, productId: nil, product: product, isFromCart: true,identifier: nil, shouldShowTab: !(self.tabBarController?.tabBar.isHidden)!)

    }
}


extension CartViewController {
    //Remove cart item function
    func removeCart(item: CartItem) {
        let productID = item.product.productId.ToString()
        
        //func for remove item from cart
        func removeItem() {
            self.showCentralSpinner()
            self.cartModel.performCartOperation(productId: productID, operation: .DeleteFromCart) { response in
                self.hideCentralSpinner()
                if response.isSuccess {
                    Cart.shared.remove(item: item)
                    self.setCartAmounts()
                    self.collView.reloadData()
                    self.showHideEmptyDataView(InternetAvailable: true)
                }
            }
        }
        
        //show delete confirm alert.
        let alert = UIAlertController(title: "RemoveItem".localizedString(), message: "WantToRemoveItem".localizedString(), preferredStyle: .alert)
        let OK = UIAlertAction(title: "Remove".localizedString(), style: .destructive) { ACTION in
            removeItem()
        }
        
        let NO = UIAlertAction(title: "Cancel".localizedString(), style: .cancel, handler: nil)
        alert.addAction(OK)
        alert.addAction(NO)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Change quantity of a cart item.
    func changeQuantity(for item: CartItem, sender: UIButton) {
       
        let maxQty =  item.product.maxQuantityToPurchase
        guard maxQty > 0 else {return}
       
        let selectedQty = item.quantity.ToString()
        let qtyList = (1...maxQty).map({"\($0)"})
        
        let rect =  self.view.convert(sender.bounds, from: sender)
        let productID = item.product.productId.ToString()
        let listItems = (qtyList, selectedQty)
    
        
        func reloadItems() {
            self.collView.reloadData()
        }
        
        
        
        func callQtyChangeAPI(_ newQty: String) {
            self.showCentralSpinner()
            self.cartModel.performCartOperation(productId: productID, qty: newQty,  operation: .UpdateCart, block: {[weak self] response in
                if let weakSelf = self {
                    weakSelf.hideCentralSpinner()
                    if response.isSuccess {
                        if let json = response.json as? [String : Any] {
                            
                            //update new price, mrp, and GST with changed quantity
                            let displayPrice = Converter.toDouble(json["displayPrice"])
                            let mrp = Converter.toDouble(json["mrp"])
                            let gst = Converter.toDouble(json["gstTax"])
                            
                            item.product.displayPrice = displayPrice
                            item.product.productPrice = mrp
                            item.product.GST = gst
                            item.quantity = newQty.integerValue!
                           
                            sender.setTitle("Qty : \(newQty)", for: .normal)
                            self?.setCartAmounts()
                            reloadItems()
                        }
                    }
                    
                }
            })
        }
        
        func showMoreInputAlert() {
            let alert = UIAlertController(title: "Set Quantity", message: "We have \(maxQty) items in stock.", preferredStyle: .alert)
            alert.addTextField { txtField in
                txtField.placeholder = "Enter Quantity"
                txtField.keyboardType = .numberPad
            }
            
            let actionDone = UIAlertAction(title: "Done".localizedString(), style: .destructive) { action in
                let value = alert.textFields!.first!.text!
                if !value.isEmpty {
                    if value.integerValue! > maxQty {
                        KVAlertView.show(message: "Sorry! We don\'t have that many quantity in the stock.")
                    } else  {
                        callQtyChangeAPI(value)
                    }
                }
            }
            let actionCancel = UIAlertAction(title: "Cancel".localizedString(), style: .cancel, handler: nil)
            alert.addAction(actionDone)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }

        //showing dropdownlist for selecting new quanity.
        DropDownList.show(in: self.view, listFrame: rect, listData: listItems, allowMore: true) { newQty in
            if newQty == "More".localizedString() {
                showMoreInputAlert()
            } else if newQty.integerValue! != item.quantity {
                callQtyChangeAPI(newQty)
            }
        }

    }
    
    //chagne size or color of an cart item.
    func changeSizeOrColor(of preProID: String, newProId: String, index: Int) {
        if preProID == newProId {return}
        self.showCentralSpinner()
        cartModel.replaceCartItem(old: preProID, new: newProId) {[weak self] success in
            self?.hideCentralSpinner()
            let indexPath = IndexPath(item: index, section: 0)
            self?.collView.reloadItems(at: [indexPath])
        }
    }
    
    //Add or remove from wishlist category.
    func addRemoteToFavourit(product: Product, sender: UIButton) {
        if product.isInWishlist {
            WishCategoryViewModel().removeProductFromCategory(productID: product.productId.ToString(), block: { success in
                if success {
                    let wishListTitle = "AddToWishlist".localizedString()
                    sender.setTitle(wishListTitle, for: .normal)
                    product.isInWishlist = false
                }
            })
            
        } else {
            if FirRCManager.shared.isFavoriteWithCategory {
                let sourceFr = sender.convert(sender.frame, to: self.collView)
                WishBox.showWishBox(in: self, sourceFrame: sourceFr, product: product, completionBlock: { success in
                    if success {
                        let wishListTitle = "RemoveFromWishlist".localizedString()
                        sender.setTitle(wishListTitle, for: .normal)
                        product.isInWishlist = true
                    }
                })

            } else {
                WishCategoryViewModel().addProductInWishCategory(categoryID: "", productID: product.productId.ToString(), block: { success in
                    if success {
                        let wishListTitle = "RemoveFromWishlist".localizedString()
                        sender.setTitle(wishListTitle, for: .normal)
                        product.isInWishlist = true
                    }

                })
            }
        }
    }
}

//MARK: CollectionView DataSource and Delegate
extension CartViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isCartEditing ? 1 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isCartEditing {return Cart.shared.cartItems.count}
        
        switch section {
        case CartSectionType.productInfo.rawValue:
            return Cart.shared.cartItems.count
            
        case CartSectionType.giftInfo.rawValue :
            return Cart.shared.cartItems.count > 0 ? 1 : 0
            
        case CartSectionType.amountInfo.rawValue :
            return Cart.shared.cartItems.count > 0 ? (cartAmounts?.count ?? 0) : 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isCartEditing {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editProductCell", for: indexPath) as! CartItemCell
            cell.cartVC = self
        
            let cartItem = Cart.shared.cartItems[indexPath.row]
            cell.cartItem = cartItem
            cell.setButtonsTag(index: indexPath.row)
        
            return cell
        }
        
        switch indexPath.section {
        case CartSectionType.productInfo.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! CartItemCell
            let cartItem = Cart.shared.cartItems[indexPath.row]
            cell.cartItem = cartItem
            cell.setButtonsTag(index: indexPath.row)
            return cell
            
        case CartSectionType.giftInfo.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "giftConfrimCell", for: indexPath) as! GiftPriceCell
            cell.lblTitle.text = "Send as Gift! Add \(RsSymbol) \(Int(Cart.shared.sendAsGiftAmount.rounded()))"
            cell.switchBtn.isOn = Cart.shared.sendAsGift
            return cell
            
        case CartSectionType.amountInfo.rawValue:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amountCell", for: indexPath) as! AmountCell
            switch indexPath.row {
            case 0:
                cell.corners = ([.topLeft, .topRight],  5)
            case 3:
                cell.corners = ([.bottomLeft, .bottomRight],  5)
                
            default:
                cell.corners = (.allCorners,  0)
            }
            
            let payment = cartAmounts![indexPath.row]
            cell.lblTitle.text = payment.amountFor
            cell.lblSubTitle.text = payment.amount
            
            return cell
            
        default :
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var height: CGFloat
        if isCartEditing {
            let pro = Cart.shared.cartItems[indexPath.row].product
            height = editCartItemHeight(for: pro)
            
        } else {
            switch indexPath.section {
            case CartSectionType.productInfo.rawValue:
                let pro = Cart.shared.cartItems[indexPath.row].product
                let titleHeight = pro.productName.height(maxWidth: 245 * universalWidthRatio, font: productNameFont!)
                height = 100 * universalWidthRatio + titleHeight
                
            case CartSectionType.giftInfo.rawValue :
                height = 50 * universalWidthRatio
                
            case CartSectionType.amountInfo.rawValue :
                height = 30 * universalWidthRatio
            default:
                height = 0
            }
        }
        return CGSize(width: collView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat.leastNormalMagnitude)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: CGFloat.leastNormalMagnitude)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  section == CartSectionType.amountInfo.rawValue ? 1 : 5
    }
    
    func editCartItemHeight(for product: Product) -> CGFloat {
        let characteristicTblMargin: CGFloat = 110 * universalWidthRatio
        
        let characteristicTblHeight =     product.characteristic.reduce(0) { (res, char) -> CGFloat in
            return characteristicTblCellHeight(char: char) + res
        }
        
        return characteristicTblMargin  + characteristicTblHeight
    }
    
    func characteristicTblCellHeight(char: ProductCharacteristic)-> CGFloat {
        let itemsInRow = 10
        let rowCount = CGFloat(char.list.count / itemsInRow)
        let rem = char.list.count % itemsInRow
        return  ((rowCount  + (rem > 0 ? 1 : 0)) * 30) + 40
    }
}



