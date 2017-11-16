//
//  JustForYouVC.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 14/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class JustForYouVC: ParentViewController {
    var listPresenter: JustForYouItemPresenter!
    var offers = [Offer]()
    var products = [Product]()
    var cartModel = CartViewModel()
    
    enum JFYSection {
        case offers, products
    }
   
    var sections: [JFYSection] {
        var sections = [JFYSection]()
        if !offers.isEmpty {
            sections.append(.offers)
        }
        
        if !products.isEmpty {
           sections.append(.products)
        }

        return sections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listPresenter = JustForYouItemPresenter(listView: self)
        listPresenter.loadJustForYouItems()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

}

//MARK:- Product LIstView Protocol conforming
extension JustForYouVC : ProductListView {
    func startLoading() {
        self.showCentralSpinner()
    }
    
    func finishLoading() {
        self.hideCentralSpinner()
    }
    
    func didRecieveItems(products: [Product], offers: [Offer]) {
        if listPresenter.loadMore.offset == 1 {
            self.offers = offers
            self.products = products
            self.tableView.reloadData()
        } else {
            var currntLastRowIndex = self.products.count-1
            let indexPaths = products.map({ _ -> IndexPath in
                currntLastRowIndex += 1
                let path = IndexPath(row:currntLastRowIndex, section: self.sections.count-1)
                return path
            })
            self.products += products
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
        self.hideCentralSpinner()
    }
    
    func didRecevieErrorWith(message: String) {
        println(message)
    }
}

//MARK:- IBActinos
extension JustForYouVC {
    //Cart Btn Action
    @IBAction func btnCart_clicked(_ sender: UIButton) {
        let product = products[sender.tag]
        let proID = product.productId.ToString()
        
        if !Cart.shared.productExistInCart(id: product.productId) {
            cartModel.performCartOperation(productId: proID, operation: .AddToCart) { response in
                if response.isSuccess {
                    KVAlertView.show(message: "Item is added in cart.")
                }
            }

        } else {
            KVAlertView.show(message: "ItemAlreadyInCart".localizedString())
        }
    }
    
    //Favorite Button Action
    @IBAction func btnFavorite_clicked(_ sender: UIButton) {
        let product = products[sender.tag]
        if product.isInWishlist {//remove from wishlist if already exist.
            WishCategoryViewModel().removeProductFromCategory(productID: product.productId.ToString(), block: { success in
                if success {
                    product.isInWishlist = false
                    sender.isSelected = product.isInWishlist
                }
            })
            
        } else {
            if FirRCManager.shared.isFavoriteWithCategory { //show wishbox form if favoriteWithCategory is enable.
                let fr = sender.convert(sender.frame, to: self.tableView)
                WishBox.showWishBox(in: self, sourceFrame: fr , product: product) { success in
                    if success {
                        product.isInWishlist = true
                        sender.isSelected = product.isInWishlist
                    }
                }
            } else {
                WishCategoryViewModel().addProductInWishCategory(productID: product.productId.ToString(), block: { success in
                    if success {
                        product.isInWishlist = true
                        sender.isSelected = product.isInWishlist
                    }
                })
            }
        }
    }
    
    //Like button Action
    @IBAction func btnLike_Clicked(_ sender: UIButton) {
        let product = self.products[sender.tag]
        product.likeProduct { success in
            if success {
                product.likeCnt = product.isLike ? product.likeCnt - 1: product.likeCnt + 1
                product.isLike = !product.isLike
                sender.isSelected = product.isLike
            }
        }
    }

    //Offer button action
    @IBAction func btnOfferInfo_clicked(_ sender: UIButton) {
        let offerInfoDetailVC = storyboardOffer.instantiateViewController(withIdentifier: "OfferInfoDetailVC") as! OfferInfoDetailVC
        offerInfoDetailVC.productOfferObj = self.offers[sender.tag]
        offerInfoDetailVC.modalPresentationStyle = .overFullScreen
        weak var weakSelf = self
        offerInfoDetailVC.delegate = weakSelf
        self.present(offerInfoDetailVC, animated: false, completion: nil)
    }

}

//MARK:- OfferDetailVCDelegate
extension JustForYouVC: OfferDetailVCDelegate {
    func moveToNextScreen(productId: String, apiparam: String ,title: String) {
        if productId == "0" {
            let productvc = self.storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
            productvc.apiParam = apiparam
            productvc.navigationTitle = title
            self.navigationController?.pushViewController(productvc, animated: true)
        }else{
            let productdetailvc = self.storyboardProductDetail.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            self.navigationController?.pushViewController(productdetailvc, animated: true)
        }

    }

}

//MARK:- TableView DataSource and Delegate
extension JustForYouVC: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .offers:
            return offers.count
        case .products:
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let jfSection = sections[indexPath.section]
       
        if jfSection == .offers {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell") as! OfferTblCell
            let offer = offers[indexPath.row]
            cell.setOffer(offer: offer)
            cell.btnInfo.tag = indexPath.row
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell") as! ProductTblCell
            let product = products[indexPath.row]
            cell.set(product: product)
            cell.setButtonTag(with: indexPath.row)
           
            weak var weakSelf = self
            let likeSelector = FirRCManager.shared.isLikeEnable ? #selector(self.btnLike_Clicked(_:)) : #selector(self.btnFavorite_clicked(_:))
            cell.setBtnLikeTarget(weakSelf!, selector: likeSelector)
           
            if indexPath.row == products.count-1 {
                self.listPresenter.loadJustForYouItems()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .offers:
            let offer = offers[indexPath.row]
            self.moveToNextScreen(productId: offer.productId, apiparam: offer.apiParam, title: offer.offerTitle)
        case .products:
            let product = self.products[indexPath.row]
            ProductDetailVC.showProductDetail(in: self, productId: nil,
                                              product: product,isFromCart: false,
                                              identifier: nil, shouldShowTab: false)
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sections[indexPath.section] == .offers ? 130 : 135) * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}



//MARK:- ProductTblCell
class ProductTblCell: TableViewCell {
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblBrandName: UILabel!
    @IBOutlet var imgProduct: UIImageView!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnCart: UIButton!
    
    @IBOutlet var offerView: UIView!
    @IBOutlet var offerBgImage: UIImageView!
    @IBOutlet var offerLabel: UILabel!
    
    @IBOutlet var colorsView: ColorSizeListView!
    @IBOutlet var sizesView: ColorSizeListView!
    @IBOutlet var colorViewHeight: NSLayoutConstraint!
    @IBOutlet var sizeViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorsView.backgroundColor = UIColor.clear
        sizesView.backgroundColor = UIColor.clear
        //self.layoutIfNeeded()
        self.setLikeBtnBehaviour()
    }
    
    func set(product: Product) {
        lblProductName.text = product.productName
        lblBrandName.text = product.brandName
        lblPrice.attributedText = showAttributedPriceString(product: product, font: lblPrice.font)
        
        //set discount or offer view info
        if product.isNewArrival {
            offerView.isHidden = false
            offerBgImage.image = #imageLiteral(resourceName: "newbadge")
            offerLabel.text = "NEW"
        } else if product.discountPerc > 0{
            offerView.isHidden = false
            offerBgImage.image = #imageLiteral(resourceName: "offerBadge")
            offerLabel.text = String(format: "%@%@", product.discountPerc.ToString() ,"% OFF")
        } else {
            offerView.isHidden = true
        }
        
        btnLike.isSelected = FirRCManager.shared.isLikeEnable ? product.isLike : product.isInWishlist
        //set product image
        let urlString = product.productImagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let sizeUrl = thumbSizeImageUrl(urlString: urlString, size: CGSize(width: imgProduct.frame.size.width - 15, height: imgProduct.frame.size.height - 15))
        imgProduct.setImage(url: URL(string: sizeUrl)!)
        
        setSizeAndColorViews(for: product)
        
    }
    
    //Set button's tag
    func setButtonTag(with rowIndex: Int) {
        self.btnCart.tag = rowIndex
        self.btnLike.tag = rowIndex
    }
    
    //Setting like button's behaviour.
    func setLikeBtnBehaviour() {
        if FirRCManager.shared.isLikeEnable {
            // like
            btnLike.setImage(#imageLiteral(resourceName: "ic_PD_Fav"), for: .normal)
            btnLike.setImage(#imageLiteral(resourceName: "ic_PD_Fav_Fill"), for: .selected)
        } else {
            //wish list
            btnLike.setImage(#imageLiteral(resourceName: "ic_favorite_fill"), for: .normal)
            btnLike.setImage(#imageLiteral(resourceName: "favoriteicon"), for: .selected)
        }
    }
   
    //Setting Like button Target
    func setBtnLikeTarget(_ target: AnyHashable,  selector: Selector) {
        btnLike.allTargets.forEach { (target) in
            btnLike.removeTarget(target, action: nil, for: .touchUpInside)
        }
        btnLike.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    //set colors and sizes of product
    private func setSizeAndColorViews(for product: Product) {
        let colors = product.multipleColor.isEmpty ? [] : product.multipleColor.components(separatedBy: ",").map {colorString -> PDCharacter in
            let color = PDCharacter()
            color.productId = "-0"//product.productId.ToString()
            color.value = colorString
            return color
        }
        

        let sizes = product.multipleSize.isEmpty ? [] : product.multipleSize.components(separatedBy: ",").map {colorString -> PDCharacter in
            let size = PDCharacter()
            size.productId = "-0"//product.productId.ToString()
            size.value = colorString
            return size
        }
        
        colorsView.showPlusSign = true
        sizesView.showPlusSign = true
        
        let colorChar = ProductCharacteristic()
        colorChar.name = ""
        colorChar.list = colors
        colorsView.product = product
        colorsView.characteristic = colorChar
        
        let sizeChar = ProductCharacteristic()
        sizeChar.name = ""
        sizeChar.list = sizes 
        sizesView.product = product
        sizesView.characteristic = sizeChar
        
       
        colorViewHeight.constant = colors.isEmpty ? 0 : (20 * universalWidthRatio)
        sizeViewHeight.constant = sizes.isEmpty ? 0 : (20 * universalWidthRatio)
    }
    
}





