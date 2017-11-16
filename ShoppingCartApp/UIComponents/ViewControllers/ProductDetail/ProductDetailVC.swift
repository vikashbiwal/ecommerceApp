//
//  ProductDetailVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 21/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView
import MessageUI


extension ProductDetailVC {
	//for showing pop used this func.
    class func showProductDetail(in vc: ParentViewController, productId: String?, product:Product?, isFromCart:Bool, identifier:String?, shouldShowTab:Bool) {

		let productDetailVC = vc.storyboardProductDetail.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
		productDetailVC.isFromCart = isFromCart
		productDetailVC.shouldShowTab = shouldShowTab
		if let productObj = product {
			productDetailVC.productListObj = productObj
		}
		if let productID = productId {
			productDetailVC.productId = productID
		}
        if let identifierStr = identifier {
            productDetailVC.identifier = identifierStr
        }
		    let nav =  vc.navigationController   // issue occur when we cancel order from payment screen.
			nav?.pushViewController(productDetailVC, animated: true)
	}
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}

struct SMSection {
	var title = ""
	var itemCount = 1
	var object: Any?
    var sectionCount:Int = 1
    var secondObject:Any?
    var similarFilterObject:Any?
}

enum InfoSectionType {
	case KeyFeature,Specification,Description,Condition
}

struct InfoSection {
	var title = ""
	var itemCount = 1
	var object: Any?
	var type:InfoSectionType
}

class ProductDetailVC: ParentViewController{

	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var viewBlink: UIView!
	@IBOutlet weak var viewBlinkSubview: UIView!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var bottomView: BottomView!
	@IBOutlet weak var btnLike: UIButton!
	@IBOutlet weak var btnCart:MIBadgeButton!
	@IBOutlet weak var btnWishList: UIButton!
	@IBOutlet weak var lblPrice: UILabel!
	@IBOutlet weak var pageContol: UIPageControl!
	@IBOutlet weak var btnSMProduct: UIButton!
	@IBOutlet weak var btnAddtoCart: UIButton!
	@IBOutlet weak var btnInfo: UIButton!
	@IBOutlet weak var btnBuyNow: UIButton!
    @IBOutlet weak var btn360: UIButton!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var lblLikeCount: UILabel!
	@IBOutlet weak var simillarProductView: SimillarProductView!
	@IBOutlet weak var productInfoView: ProductInfoView!
	@IBOutlet weak var smProdutViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var productInfoViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var btnSMProductWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var viewDetails: UIView!
	var colorView:ColorAndSizeView? = nil
	var isFromZoomImage = false

	var currentProduct = Product()
	var productListObj:Product?
    var cartModel = CartViewModel()
    var identifier = ""
	var productId = ""
	var currentColorIndex:Int = -1
	var isFromCart = false
	var shouldShowTab = false
	
	var bottomViewActionBlock:(Int,Bool,AnyObject?) ->(Void) = { _ in }


	lazy var smProductActionBlock: (Product)-> Void =  { [weak self] (product) in
		//self?.showCentralGraySpinner()
		self?.currentProduct = product
		self?.setUpProductListObject()
		self?.setSMProducttoDefault()
        self?.setBottomCollectionViewtoDefault()
        
	}
    
    lazy var smRelatedProductOptionActionBlock: (PDRelatedProductOption)-> Void = { [weak self] (pdrelatedproductoption) in
        
        self?.setSMProducttoDefault()
        
        let storyboardProductList = UIStoryboard(name: "ProductList", bundle: Bundle(for: ParentViewController.self))
        let productListvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        productListvc.apiParam = pdrelatedproductoption.apiParam
        productListvc.navigationTitle = pdrelatedproductoption.name
        self?.navigationController?.pushViewController(productListvc, animated: true)

    }
    
    lazy var similarProductFilterActionBlock: (PDSimilarProductFilter)-> Void = { [weak self] (pdsimilarproductfilter) in
        
        self?.setSMProducttoDefault()
        
        let storyboardProductList = UIStoryboard(name: "ProductList", bundle: Bundle(for: ParentViewController.self))
        let productListvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        productListvc.strSimilarProductFilter = "true"
        productListvc.isPropertyData = pdsimilarproductfilter.isPropertyData
        productListvc.apiParam = pdsimilarproductfilter.apiParam
        productListvc.navigationTitle = "Similar Product"
        self?.navigationController?.pushViewController(productListvc, animated: true)
        
    }

	var colorSizeClickAction:ColorSizeActionBlock {
		return { [weak self] index,isColor,object in

			let obj = object as! PDCharacter
			self?.productId = obj.productId
			self?.getProductDetails()
			self?.setColortoDefault()
		}
	}
    
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		self.btnCart.badgeEdgeInsets = UIEdgeInsetsMake(8, 0, 0, 10)
		simillarProductView.actionBlock = smProductActionBlock
        simillarProductView.relatedProductOptionActionBlock = smRelatedProductOptionActionBlock
        simillarProductView.similarProductFilterActionBlock = similarProductFilterActionBlock
		self.checkPreviousProduct()
		self.setupLayout()
		self.addGesture()
		 bottomViewActionBlock = {  [weak self] index,  isSelected, objc  in
			print("index is \(index)")
			self?.setSMProducttoDefault()
			self?.setInfotoDefault()
			if isSelected {
				self?.setColortoDefault()

			} else {
				self?.showColorAndSizeView(array:(self?.currentProduct.characteristic[index].list)!)
			}
		}
		bottomView.actionBlock = bottomViewActionBlock
	}


	override func viewWillAppear(_ animated: Bool) {
		self.configureBadgeCount()
		self.tabBarController?.tabBar.isHidden = true
		self.btnAddtoCart.contentHorizontalAlignment = .center
		_appDelegator.productId = self.productId
		if !isFromZoomImage {
			self.saveProductViewTime(flag: true)
		} else {
			isFromZoomImage = false
		}

	}

	override func viewWillDisappear(_ animated: Bool) {
		_appDelegator.productId = "0"
		if !isFromZoomImage {
			self.saveProductViewTime(flag: false)
		} 
	}

	func addGesture()  {
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
		gestureRecognizer.delegate = self
		gestureRecognizer.cancelsTouchesInView = false
		self.productInfoView.addGestureRecognizer(gestureRecognizer)
	}

	func handleTap(gestureRecognizer: UIGestureRecognizer) {
		self.setInfotoDefault()

	}

	func checkPreviousProduct()  {
		if productListObj != nil  {
			currentProduct = productListObj!
			self.configureGallery()
			productListObj = nil
			self.setUpProductListObject()
		} else {
			self.getProductDetails()
		}

	}

	func configureBadgeCount()  {
		if Cart.shared.shortInforCartItems.count > 0{
			self.btnCart.badgeString = Cart.shared.shortInforCartItems.count.ToString()
		}
	}

	func setUpProductListObject()  {
		self.lblTitle.text = currentProduct.productName
		productId = currentProduct.productId.ToString()
		self.configureGallery()
		self.getProductDetails()
		self.configureLike()
		self.configureWishlist()
		self.configurePrice()
	}

	func updateProductWithSizeObject(size:PDSize)  {

		self.currentProduct.allowedQuantity = size.allowedQuantity
		self.currentProduct.isInWishlist = size.isWishlist
		self.currentProduct.maxPrice = size.maxPrice
		self.currentProduct.productId = size.productId.integerValue ?? self.currentProduct.productId
		self.currentProduct.displayPrice = Double(size.displayPrice)
		self.currentProduct.productName = size.productName
		self.lblTitle.text = self.currentProduct.productName

		/*if let list = self.currentProduct.size?.colorList, list.count > 0 {
			self.btnColor.isHidden = false
		} else {
			self.btnColor.isHidden = true
		}*/

		self.configureWishlist()
		self.configurePrice()

	}

	fileprivate var pageSize: CGSize {

		let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
		layout.itemSize = CGSize(width: 300 * widthRatio, height: 500 * widthRatio)

		var pageSize = CGSize(width: layout.itemSize.width , height: layout.itemSize.height )
		if layout.scrollDirection == .horizontal {
			pageSize.width += layout.minimumLineSpacing
		} else {
			pageSize.height += layout.minimumLineSpacing
		}
		return pageSize
	}

	fileprivate func setupLayout() {
		let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
		layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)
	}

	func setView(view: UIView, hidden: Bool) {
		UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: { _ in
			view.isHidden = hidden
		}, completion: nil)
	}

	func reloadSMProductView() {

		var sectionArray = [SMSection]()
		if self.currentProduct.relatedProduct.count > 0 {
            
            if self.currentProduct.relatedProductOption.count > 0 {
               // let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct, sectionCount: 2, secondObject: self.currentProduct.relatedProductOption)
                
                let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct, sectionCount: 2, secondObject: self.currentProduct.relatedProductOption, similarFilterObject: nil)

               // let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct)
                sectionArray.append(section)
            
            } else {
                //let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct)
               // let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct, sectionCount: 1, secondObject: nil)
                
                 let section = SMSection(title: "RELATED", itemCount: 1, object: self.currentProduct.relatedProduct, sectionCount: 1, secondObject: nil, similarFilterObject: nil)
                sectionArray.append(section)
                
            }
			
		}

		if self.currentProduct.smProduct.count > 0 {
            
            
            var count:Int = 1
            
            if self.currentProduct.smProduct.count > 10 {
                
                count = 2
            
            }
            
            if self.currentProduct.similarProductFilter.count > 0 {
                
                self.currentProduct.similarProductFilter.sort(by: { (firstObj: PDSimilarProductFilter, secondObj: PDSimilarProductFilter) -> Bool in
                    
                    firstObj.priority < secondObj.priority
                })
                
                let similarProductFilterObj = self.currentProduct.similarProductFilter[0]
                
                self.simillarProductView.filterProductBySimilarProductFilter(similarProductFilterObj: similarProductFilterObj, index: 0)
                
                let section = SMSection(title: "SIMILAR", itemCount: 1, object: self.currentProduct.smProduct,sectionCount: count, secondObject: nil, similarFilterObject: self.currentProduct.similarProductFilter)
                
                sectionArray.append(section)
            }else{
                let section = SMSection(title: "SIMILAR", itemCount: 1, object: self.currentProduct.smProduct,sectionCount: 1, secondObject: nil, similarFilterObject: nil)
                
                sectionArray.append(section)
            }
            
            
		}

		if sectionArray.count > 0{
			self.simillarProductView.sectionArray = sectionArray
		}

	}

	func reloadGallerySection()  {
		self.pageContol.numberOfPages = self.currentProduct.imageGallery.count
		self.collectionView.reloadData()
		if self.currentProduct.imageGallery.count > 0 {
			self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
			                                  at: .top,
			                                  animated: false)
		}
	}

	func configureWishlist()  {
		if self.currentProduct.isInWishlist {
			self.btnWishList.isSelected = true
		}
		else {
			self.btnWishList.isSelected = false
		}

	}

	func configureGallery()   {
		let imageModel = PDImageGallery.init(imagePath: self.currentProduct.productImagePath)
		self.currentProduct.imageGallery.append(imageModel)
		self.collectionView.reloadData()
	}


	func configurePrice()   {
		self.lblPrice.attributedText = showAttributedPriceString(product: self.currentProduct, font: self.lblPrice.font)
		if currentProduct.isPriceRange {  //show + price like 99 +
			btnAddtoCart.setTitle(" INQUIRY ", for: .normal)
			btnAddtoCart.setTitle(" INQUIRY ", for: .selected)
			btnBuyNow.isHidden = true
		}
		else{
			btnAddtoCart.setTitle(" ADD TO CART ", for: .normal)
			btnAddtoCart.setTitle(" ADD TO CART ", for: .selected)
			btnBuyNow.isHidden = false
		}
	}

	func configureCharacteristics()  {
		if currentProduct.characteristic.count > 0 {

			if currentProduct.characteristic.count == 1 {
				let frame = CGRect(x: 0, y: 0, width: (stackView.frame.width - 5) / 2, height: stackView.frame.height)
				bottomView.frame = frame
				stackView.distribution = .fillEqually
			} else if currentProduct.characteristic.count >= 2 {
				let width = (stackView.frame.width / 3) * 2
				let frame = CGRect(x: 0, y: 0, width: width, height: stackView.frame.height)
				bottomView.frame = frame
				stackView.distribution = .equalSpacing
			}
			bottomView.isHidden = false
			bottomView.characteristic = self.currentProduct.characteristic
			bottomView.collectionView.reloadData()
		} else {
			bottomView.isHidden = true
		}

	}

	func configureLike()  {
		self.lblLikeCount.text = self.currentProduct.likeCnt > 0 ? self.currentProduct.likeCnt.ToString() : ""
		if self.currentProduct.isLike {
			self.btnLike.isSelected = true
		}
		else {
			self.btnLike.isSelected = false
		}
	}
	func configureInfoView() {
		self.productInfoView.infoArray = self.configureInfoViewDetails()
	}

	func configureBottomView() {
		/*if self.currentProduct.sizeList.count == 0{
			self.btnSize.isHidden = true
			self.btnColor.isHidden = true
		} else {
			self.btnSize.isHidden = false
			self.btnColor.isHidden = false
		}*/

		if self.currentProduct.smProduct.count == 0 && self.currentProduct.relatedProduct.count == 0 {
			self.btnSMProductWidthConstraint.constant = 0
		} else {
			self.btnSMProductWidthConstraint.constant = 50
		}
	}

	func configureNotifyMe() {
		if self.currentProduct.allowedQuantity <= 0 {
			self.btnAddtoCart.setTitle(" NOTIFY ME ", for: .normal)
			self.btnAddtoCart.setTitle(" NOTIFY ME ", for: .selected)
			self.btnBuyNow.isHidden = true
		}
	}

	func configureInfoViewDetails()-> [InfoSection]  {

		var arrayDescription = [InfoSection]()

		//self.currentProduct.keyFeatures = "dfhdsgfhgvdhjsgvhdsghjdsgsghjsaghjsghghfsghjfsghjdsghjdsgshjfsdghjsdghjdsghjdsgdhjsghjdgjh"
		if self.currentProduct.keyFeatures.characters.count > 0 {
			let section = InfoSection(title: "KeyFeatures", itemCount: 1, object: self.currentProduct.keyFeatures, type:.KeyFeature)
			arrayDescription.append(section)
		}

		if self.currentProduct.propertyList.count > 0{
			let allGroups = Set(self.currentProduct.propertyList.map{ $0.groupName})
			for groupName in allGroups {
				let array = self.currentProduct.propertyList.filter({ (property) -> Bool in
					return property.groupName == groupName
				})

				let section = InfoSection(title: groupName, itemCount: 1, object: array, type:.Specification)
				arrayDescription.append(section)
			}
		}
		//self.currentProduct.description = "dfhdsgfhgvdhjsgvhdsghjdsgsghjsaghjsghghfsghjfsghjdsghjdsgshjfsdghjsdghjdsghjdsgdhjsghjdgjh"
		if self.currentProduct.description.characters.count > 0 {
			let section = InfoSection(title: "Description", itemCount: 1, object: self.currentProduct.description, type:.Description)
			arrayDescription.append(section)
		}

		//self.currentProduct.legalDisclaimer = "dfhdsgfhgvdhjsgvhdsghjdsgsghjsaghjsghghfsghjfsghjdsghjdsgshjfsdghjsdghjdsghjdsgdhjsghjdgjh"
		if self.currentProduct.legalDisclaimer.characters.count > 0 {
			let section = InfoSection(title: "Conditions & Disclaimer", itemCount: 1, object: self.currentProduct.legalDisclaimer, type:.Description)
			arrayDescription.append(section)
		}
		return arrayDescription
	}

	func showHideTabBar()  {
		if !isFromCart || (isFromCart && shouldShowTab){
			self.tabBarController?.tabBar.isHidden = false
		}
	}

	func push_PopToCartVC()   {

		if isFromCart {
			self.showHideTabBar()
			self.navigationController?.popViewController(animated: false)
		} else {
			let cartVC = self.storyboardWishListh.instantiateViewController(withIdentifier: "SBID_CartVC")
			self.navigationController?.pushViewController(cartVC, animated: true)
		}

	}

}


extension ProductDetailVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	// MARK: - Card Collection Delegate & DataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentProduct.imageGallery.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
			let imgUrl = getImageUrlWithSize(urlString: self.currentProduct.imageGallery[indexPath.row].imagePath, size: collectionView.frame.size)
			cell.imgView.setImage(url: imgUrl)
			return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

			let vc = storyboardProductDetail.instantiateViewController(withIdentifier: "ZoomVC") as! ZoomVC
			vc.imageArray = self.currentProduct.imageGallery
			vc.previousVC = .productDetail
			vc.currentPageIndex = indexPath.row
			isFromZoomImage = true
			self.navigationController?.pushViewController(vc, animated: false)
	}

	// MARK: - UIScrollViewDelegate

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
		let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
		let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
		self.pageContol.currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
		//currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
	}
}

extension ProductDetailVC:UIActionSheetDelegate,MFMailComposeViewControllerDelegate {

	//MARK: - IBActions

	@IBAction func btnBack_Clicked(_ sender: Any) {

		self.showHideTabBar()
		_ = self.navigationController?.popViewController(animated: true)
	}

	@IBAction func btnLikeClicked(_ sender: Any) {
		self.currentProduct.likeProduct { (success) in
			self.currentProduct.likeCnt = self.currentProduct.isLike == true ? self.currentProduct.likeCnt - 1: self.currentProduct.likeCnt + 1
			self.currentProduct.isLike = self.currentProduct.isLike == true ? false: true
			self.configureLike()
		}
	}
	
	@IBAction func btnWishClicked(_ sender: UIButton) {

		if self.currentProduct.isInWishlist {
           WishCategoryViewModel().removeProductFromCategory(productID: currentProduct.productId.ToString(), block: { success in
			if success {
				self.currentProduct.isInWishlist = false
				self.btnWishList.isSelected = self.currentProduct.isInWishlist
			}
		})
		} else {
			if FirRCManager.shared.isFavoriteWithCategory {
				WishBox.showWishBox(in: self, sourceFrame: sender.frame , product: self.currentProduct) { success in
					if success {
						self.currentProduct.isInWishlist = true
						self.btnWishList.isSelected = self.currentProduct.isInWishlist
					}
				}
			} else {
				WishCategoryViewModel().addProductInWishCategory(productID: currentProduct.productId.ToString(), block: { success in
					if success {
						self.currentProduct.isInWishlist = true
						self.btnWishList.isSelected = self.currentProduct.isInWishlist
					}
				})
			}
		}

	}

	@IBAction func btnCartClicked(_ sender: Any) {
		if Cart.shared.shortInforCartItems.count > 0 {
			//let cartVC = storyboardWishListh.instantiateViewController(withIdentifier: "SBID_CartVC")
			//self.navigationController?.pushViewController(cartVC, animated: true)
			self.push_PopToCartVC()
		} else {
			KVAlertView.show(message: "Your cart is empty.")
		}
	}

	@IBAction func btnShareClicked(_ sender: UIButton) {

		var shareText = "\(self.currentProduct.productName) \n"
		if let size = self.currentProduct.size {
			shareText = shareText + "Size => \(size.value) \n"
		}
		shareText = shareText + "Image => \(self.currentProduct.productImagePath)"

		if IS_IPAD {
			let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
			vc.popoverPresentationController?.sourceView = self.view
			if let frame = sender.superview?.convert(sender.frame, to: nil) {
				vc.popoverPresentationController?.sourceRect = frame
			} else {
				vc.popoverPresentationController?.sourceRect = sender.frame
			}
			//let Y = sender.frame.origin.y + (sender.superview?.frame.origin.y)!
			//frame?.origin.y = Y
			present(vc, animated: true, completion: nil)

		} else {
			let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
			present(vc, animated: true, completion: nil)
		}
	}	

	//MARK:- Bottom bar actions
	@IBAction func btnSimillarProductClicked(_ sender: Any) {

		if !self.btnSMProduct.isSelected {
			self.btnSMProduct.isSelected = true
			self.btnSMProduct.backgroundColor = PDCOLOR
			self.setInfotoDefault()
			self.setColortoDefault()
			self.setBottomCollectionViewtoDefault()

			if self.currentProduct.smProduct.count > 0 || self.currentProduct.relatedProduct.count > 0 {
				smProdutViewBottomConstraint.constant = 0
				self.view.layoutIfNeeded()
				simillarProductView.presentList = true
			}

		} else {
			self.setSMProducttoDefault()
		}
	}

	@IBAction func btnInfoClicked(_ sender: Any) {
		if !self.btnInfo.isSelected {
			self.btnInfo.isSelected = true
			self.btnInfo.backgroundColor = PDCOLOR
			self.setSMProducttoDefault()
			self.setColortoDefault()
			self.setBottomCollectionViewtoDefault()
			productInfoViewBottomConstraint.constant = 0
			self.view.layoutIfNeeded()
			productInfoView.presentList = true

		} else {
			self.setInfotoDefault()
		}
	}


	@IBAction func btnAddToCartClicked(_ sender: Any) {

		
		if self.currentProduct.isPriceRange {

			let alert = UIAlertController.init(title: "INQUIRY", message: "", preferredStyle: .actionSheet)
			alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction.init(title: "Call", style: .default, handler: { (action) in
				 let url = URL(string: "tel://\(FirRCManager.shared.contactUsPhoneno)")
					if UIApplication.shared.canOpenURL(url!) {
						UIApplication.shared.open(url!, options: [:], completionHandler: nil)
					} else {
					KVAlertView.show(message: "Can not make call at this time.")
				}

			}))
			alert.addAction(UIAlertAction.init(title: "Send Email", style: .default, handler: { (action) in
				if !MFMailComposeViewController.canSendMail(){
					KVAlertView.show(message: "Mail services are not available")
					return
				} else {
					let composeVC = MFMailComposeViewController()
					composeVC.mailComposeDelegate = self
					composeVC.setToRecipients([FirRCManager.shared.contactUsEmail])
					composeVC.setSubject("Hello!")
					self.present(composeVC, animated: true, completion: nil)
				}

			}))
			present(alert, animated: true, completion: nil)

		} else {
				if self.currentProduct.allowedQuantity > 0 {
					if !Cart.shared.productExistInCart(id: self.currentProduct.productId) {
					self.showCentralGraySpinner()
					self.cartModel.performCartOperation(productId: self.currentProduct.productId.ToString(), operation: .AddToCart) { response in
						if response.isSuccess {
							self.configureBadgeCount()
							KVAlertView.show(message: "Item is added in cart.")
						}
					self.hideCentralGraySpinner()
					}
				} else {
						KVAlertView.show(message: "Item is already in cart.")
				}
			} else {
					self.showCentralGraySpinner()
					self.currentProduct.notifyProduct(successBlock: { (success) in
						self.hideCentralGraySpinner()
					})
					//KVAlertView.show(message: "OUTOFSTOCKMSG".localizedString())
			}

		}

	}



	func mailComposeController(_ controller: MFMailComposeViewController,
	                           didFinishWith result: MFMailComposeResult, error: Error?) {

		switch result {
		case .failed:
			KVAlertView.show(message: "Error occured while sending mail.")

		case .sent:
			KVAlertView.show(message: "Mail sent.")
		default:
			print("")
		}
		controller.dismiss(animated: true, completion: nil)
	}

	@IBAction func btnBuyNowClicked(_ sender: Any) {
		if !Cart.shared.productExistInCart(id: self.currentProduct.productId) {
			if self.currentProduct.allowedQuantity > 0{
				self.cartModel.performCartOperation(productId: self.currentProduct.productId.ToString(), operation: .AddToCart) { response in
					if response.isSuccess {
						self.configureBadgeCount()
						//let cartVC = self.storyboardWishListh.instantiateViewController(withIdentifier: "SBID_CartVC")
						//self.navigationController?.pushViewController(cartVC, animated: true)
						self.push_PopToCartVC()
					} }
			} else {
				KVAlertView.show(message: "OUTOFSTOCKMSG".localizedString())
			}
		} else {
			//let cartVC = storyboardWishListh.instantiateViewController(withIdentifier: "SBID_CartVC")
			//self.navigationController?.pushViewController(cartVC, animated: true)
			self.push_PopToCartVC()
		}
	}
    @IBAction func btn360Clicked(_ sender: Any) {
        let irVC = self.storyboardOffer.instantiateViewController(withIdentifier: "ImageRotationVC") as! ImageRotationVC
        irVC.productId  = self.currentProduct.productId.ToString()
        irVC.product = self.currentProduct
        self.navigationController?.pushViewController(irVC, animated: true)
    }


}

extension ProductDetailVC {

	func showColorAndSizeView(array:[AnyObject])   {

		if self.colorView != nil {
			self.colorView?.hideWithAnimation()
			self.colorView?.removeFromSuperview()
			self.colorView = nil
		}
		colorView = ColorAndSizeView.instanceFromNib()
		colorView?.arrColorAndSize = array
		colorView?.isForColor = true
		colorView?.actionBlock = self.colorSizeClickAction
		colorView?.productID = currentProduct.productId.ToString()
		self.view.addSubview(colorView!)
		self.view.bringSubview(toFront: self.stackView)
		colorView?.showWithAnimation()
	}

	func setColortoDefault() {

		if self.colorView != nil {
			self.colorView?.hideWithAnimation()
			self.colorView?.removeFromSuperview()
			self.colorView = nil
		}
		self.bottomView.previosIndex = -1
	}

	func setBottomCollectionViewtoDefault() {

		self.bottomView.previosIndex = -1
		self.bottomView.collectionView.reloadData()
	}

	func setSMProducttoDefault() {
		self.btnSMProduct.isSelected = false
		self.btnSMProduct.backgroundColor = UIColor.backgroundColor
		smProdutViewBottomConstraint.constant = 0
		self.view.layoutIfNeeded()
		simillarProductView.presentList = false

	}

	func setInfotoDefault() {
		self.btnInfo.isSelected = false
		self.btnInfo.backgroundColor = UIColor.backgroundColor
		productInfoViewBottomConstraint.constant = 0
		self.view.layoutIfNeeded()
		productInfoView.presentList = false

	}
}

extension ProductDetailVC {

	//MARK:- API CALLS

	func getProductDetails() {
		//	//http://digitalhotelgroup4.zoomi.in:202/api/Product?productId=9204

		self.startBlinking()
		self.showCentralGraySpinner()
		let apiParam = ["productId" : self.productId,"identifierKey" : self.identifier]
        
        //let apiParam = ["productId" : "1044","identifierKey" : self.identifier]

		wsCall.getProductDetails(params: apiParam) { (response) in
			if response.isSuccess {
				if let json = response.json as? [String:Any] {
					print("product response is \(json)")
					self.currentProduct = Product.init(json)
					self.lblTitle.text = self.currentProduct.productName
					self.reloadSMProductView()
					self.stackView.isUserInteractionEnabled = true
					self.reloadGallerySection()
					self.configureLike()
					self.configureWishlist()
					self.configurePrice()
					self.configureInfoView()
					self.configureCharacteristics()
					self.configureBottomView()
					self.configureNotifyMe()
					 self.stopBlinkAnimation()

                    //if 360 available then show button else no need to show it By: shraddha
                    self.btn360.isHidden = true
                    if  self.verifyUrl(urlString: self.currentProduct.product3dview) {
                        self.btn360.isHidden = false
                    }
				}
			}
			self.hideCentralGraySpinner()
		}
	}

	func saveProductViewTime(flag:Bool) {

		let apiParam = ["productId" : self.productId,"flag" :flag] as [String : Any]
		wsCall.productTimeSave(params: apiParam) { (response) in
			if response.isSuccess {

				}
			}
		}
}

extension ProductDetailVC : UIGestureRecognizerDelegate {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if touch.view == self.colorView  {
				self.setColortoDefault()
				self.setBottomCollectionViewtoDefault()
			}
			else if touch.view == self.simillarProductView  {
				self.setSMProducttoDefault()
			}
		super.touchesBegan(touches, with: event)
	}
	}

	func startBlinking() {

		self.viewBlink.isHidden = false
		self.viewBlinkSubview.alpha = 0.6
		//self.viewBlink.backgroundColor = UIColor.white
		UIView.animate(withDuration: 0.7, delay: 0.0, options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {() -> Void in
			self.viewBlinkSubview.alpha = 0.0
			//self.viewBlink.backgroundColor = UIColor.backgroundColor
			print("animation continue")

		}, completion: {(_ finished: Bool) -> Void in
				print("animation finished")
		})
	}

	func stopBlinkAnimation()  {
		self.viewBlinkSubview.layer.removeAllAnimations()
		self.viewBlinkSubview.layoutIfNeeded()
		self.viewBlink.isHidden = true
	}

}

