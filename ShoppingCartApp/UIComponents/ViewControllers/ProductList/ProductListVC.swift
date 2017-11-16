//
//  ProductListVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 6/19/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import QuartzCore
import KVAlertView
import FirebaseRemoteConfig

let kCellReuse = "productListCell"
let kSingleCellReuse = "singleListCell"


class ProductListVC: ParentViewController,CAAnimationDelegate {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    @IBOutlet weak var btnLeft: UIButton!
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionviewTopConstraint: NSLayoutConstraint!
    
    var getListTask: URLSessionTask?
    var navigationTitle : String?
    var itemPerRow = 1  //2 = grid view, 1 = list view
    var currentPageNumber = 1
    var canLoadMore = true
    var products = [Product]()
    var listRequest = ProductListRequest()  //request object
    var strSimilarProductFilter = ""
    var isPropertyData = false
    
    
    
    var apiParam = ""// we will get it when listing will open from category, offer, banner etc...
    var filterPropertyDetails = [PropertyDetail]() // we will get it when we select filter from filter screen.
    var isFromSearch = false
    
    var presentSortBy = SortBy([:])
    let queue = DispatchQueue.global(qos: .default)
    
    var cartModel = CartViewModel()
    var iscollectionviewshouldrelaod = false
    
    var islikeavailable = false
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationBarView.drawShadow()
        btnGrid.setImage(UIImage(named: "gridIcon"), for: .normal)  //by default show list view
        self.islikeavailable = FirRCManager.shared.isLikeEnable
        setBackButtonAction()
        
        //localize string
        self.btnFilter.setTitle("FILTERTITLE".localizedString(), for: .normal)
        self.btnSort.setTitle("SORTBYTITLE".localizedString(), for: .normal)
        self.lblTitle.text = navigationTitle ?? "LISTNAVTITLE".localizedString()
        
        self.listRequest.orderBy = "Popular"
        listCollectionView.dataSource = self
        self.refreshCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tabBarController?.selectedIndex == 1 && !FirRCManager.shared.isFavoriteWithCategory { // from wish list - main controller on tab bar
            self.iscollectionviewshouldrelaod = true
            setBackButtonAction()
            self.refreshCollectionView()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _appDelegator.selectedMaxPrcie = 0
        _appDelegator.selectedMinPrcie = 0
        
        getListTask?.cancel()
    }
    func loadProductList() {
        listRequest.pagenumber = self.currentPageNumber
        
       
        
        //temp check it
        //apiParam = "{\"CategoryId\":\"1\",\"BrandId\":\"1\",\"Identifier\":\"abc\"}"
      //  apiParam = "{\"categoryId\":201}"
        if wsCall.networkManager.isReachable{
            emptyDataView.remove()
            
            if strSimilarProductFilter == "true" {
                
                listRequest.flag = "similar"
                
                 self.getProductList(param: listRequest.setfilterOptions(fromApiParam: apiParam ,andSelectedFilters: [],isSimilarProduct: true , isPropertyData: isPropertyData ))
            }else{
                 self.getProductList(param: listRequest.setfilterOptions(fromApiParam: apiParam ,andSelectedFilters: filterPropertyDetails))
            }
            
           
        }
        else{
            
            emptyDataView.show(in: self.view, message: "OFFLINEMSG".localizedString())
        }
        
        
    }
    
    func registerCollectionViewCell() {
        let nib = UINib(nibName: "ProductListCell", bundle: nil)
        listCollectionView.register(nib, forCellWithReuseIdentifier: kCellReuse)
    }
    
    
    
    func createSortByView()
    {
        var sortByView: ProductListSortByView!
        sortByView =  ProductListSortByView.instanceFromNib()
        
        sortByView.frame =  UIScreen.main.bounds
        sortByView.tranparentView.frame = sortByView.frame
        
        // sortByView.centerView.frame = btnSort.frame
        let sViewFrame = btnSort.superview?.frame
        
        let sortButtonFrame = btnSort.frame
        let centerviewframe = sortByView.centerView.frame
        
        let ypoint = (sViewFrame?.origin.y)! + sortButtonFrame.origin.y + sortButtonFrame.size.height
        sortByView.centerView.frame = CGRect(x: sortButtonFrame.origin.x, y: ypoint, width: sortButtonFrame.size.width, height: centerviewframe.size.height)
        
        sortByView.sortByListView.frame = sortByView.centerView.frame
        
        self.view.addSubview(sortByView)
        
        //sort by value is static from mobile side
       // islikeavailable
        sortByView.sorItems = [SortBy.init(["sortBy":"Popular","sortId":"1","sortValue":"Popular"]),SortBy.init(["sortBy":"New Arrival","sortId":"2","sortValue":"newarrival"]),SortBy.init(["sortBy":"Price - High To Low","sortId":"3","sortValue":"Price"]),SortBy.init(["sortBy":"Price - Low To High","sortId":"4","sortValue":"-Price"])]
                               //,SortBy.init(["sortBy":"Likes","sortId":"5","sortValue":"likes"]),SortBy.init(["sortBy":"My Favorite","sortId":"6","sortValue":"Wishlist"]) ]
        
        if self.islikeavailable {
            sortByView.sorItems.append(SortBy.init(["sortBy":"Likes","sortId":"5","sortValue":"likes"]))
        }
        sortByView.sorItems.append(SortBy.init(["sortBy":"My Favorite","sortId":"6","sortValue":"Wishlist"]))
        
        
        if presentSortBy.sortBy != "" {
            sortByView.presentSortBy = self.presentSortBy
        }
        else{
            self.presentSortBy = sortByView.sorItems[0]
            sortByView.presentSortBy = sortByView.sorItems[0]
        }
        
        
        sortByView.actionBlock = {(sortObj) in
            //TODO-
            self.iscollectionviewshouldrelaod = true
            self.presentSortBy = sortObj
            self.listRequest.orderBy = sortObj.sortValue
            sortByView.removeFromSuperview()
            self.refreshCollectionView()
        }
    }
    
    
}

//MARK:- IBActions
extension ProductListVC {
    @IBAction func btnGridClicked(_ sender: UIButton) {
        if itemPerRow == 2 {
            itemPerRow = 1
            btnGrid.setImage(UIImage(named: "gridIcon"), for: .normal)
            
        }
        else{
            itemPerRow = 2
            btnGrid.setImage(UIImage(named: "listIcon"), for: .normal)
            
        }
        
        self.listCollectionView.setContentOffset(CGPoint.zero, animated: false)
        self.listCollectionView .reloadData()
        
    }
    
    @IBAction func btnSortByClicked(_ sender: UIButton) {
        createSortByView()
    }
    
    @IBAction func btnFilterClicked(_ sender: UIButton) {
        let vc = self.storyboardProductList.instantiateViewController(withIdentifier: "FilterVC") as! ProductFilterVC
        vc.modalPresentationStyle = .overFullScreen
        vc.selectedFilterOptions = self.filterPropertyDetails //only selected filterd    //
        vc.apiParam = self.apiParam
        vc.actionBlockForApply = { (filterOptions) in
            self.iscollectionviewshouldrelaod = true
            self.filterPropertyDetails = filterOptions
            self.refreshCollectionView()
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    func reloadsinglecell(_ sender: UIButton)  {
        var indexs = [IndexPath]()
        indexs.append(IndexPath(row: sender.tag, section: 0))
        self.listCollectionView .reloadItems(at: indexs)
    }
    @IBAction func btnWishListClicked(_ sender: UIButton) {
        let fr = sender.convert(sender.frame, to: self.listCollectionView)
        let product = self.products[sender.tag]
       /* WishBox.showWishBox(in: self, sourceFrame: fr , product: product){ sucess in
            product.isWishlist = true
            var indexs = [IndexPath]()
            indexs.append(IndexPath(row: sender.tag, section: 0))
            self.listCollectionView .reloadItems(at: indexs)
            
        }*/
        
            
            if product.isInWishlist {
                WishCategoryViewModel().removeProductFromCategory(productID: product.productId.ToString(), block: { success in
                    if success {
                        product.isInWishlist = false
                        sender.isSelected = product.isInWishlist
                        self.reloadsinglecell(sender)
                    }
                })
            } else {
                
                if FirRCManager.shared.isFavoriteWithCategory {
                    WishBox.showWishBox(in: self, sourceFrame: fr , product: product) { success in
                        if success {
                            product.isInWishlist = true
                            sender.isSelected = product.isInWishlist
                            self.reloadsinglecell(sender)
                        }
                    }
                } else {
                    WishCategoryViewModel().addProductInWishCategory(productID: product.productId.ToString(), block: { success in
                        if success {
                            product.isInWishlist = true
                            sender.isSelected = product.isInWishlist
                            self.reloadsinglecell(sender)
                        }
 
                    })
                }
            }
      
        
    }
    
    @IBAction func btnLikeClicked(_ sender: UIButton) {
        //like module will add here
        let product = self.products[sender.tag]
        product.likeProduct { (success) in
            product.likeCnt = product.isLike ? product.likeCnt - 1: product.likeCnt + 1
            product.isLike = !product.isLike
            sender.isSelected = product.isLike
            self.reloadsinglecell(sender)
        }
    }
    
    
    //cell button clicked action
  //  func btnAddToCartClicked(sender:UIButton){
    func btnAddToCartClicked(sender:UIButton){
        let product = self.products[sender.tag]
        if product.isInCart {
            KVAlertView.show(message: "ItemAlreadyInCart".localizedString())
        } else {
            if product.allowedQuantity > 0{ //
               /* addAnimation(onIndexPath: IndexPath.init(row: sender.tag, section: 0)) {
                    self.cartModel.performCartOperation(productId: product.productId.ToString(), operation: .AddToCart) { succes in
                        sender.isSelected = !sender.isSelected
                        if succes {
                            //show animation
                        }
                    }
                }*/
                
               
                    self.cartModel.performCartOperation(productId: product.productId.ToString(), operation: .AddToCart) { response in
                        sender.isSelected = !sender.isSelected
                        if response.isSuccess {
                            //show animation
                            self.addAnimation(onIndexPath: IndexPath.init(row: sender.tag, section: 0)) {}
                        }
                    }
                
            }
            else{  //allowedquantity ==0 meand product is out of stock
               // KVAlertView.show(message: "OUTOFSTOCKMSG".localizedString())
                self.showCentralGraySpinner()
                product.notifyProduct(successBlock: { (success) in
                    self.hideCentralGraySpinner()
                })
                
               
            }
            
        }
        
    }
    
    func addAnimation(onIndexPath:IndexPath,block: (Void)->Void){
        
        let cell: ProductListCell? = listCollectionView.cellForItem(at: onIndexPath) as? ProductListCell
        
        // grab the imageview using cell
        let imgV: UIImageView? = cell?.productImage
        
      

        // get the exact location of image - START POINT
        let attributes: UICollectionViewLayoutAttributes? = self.listCollectionView?.layoutAttributesForItem(at: onIndexPath)
        let imgviewframe = CGRect(x: (attributes?.frame.origin.x)! , y: (attributes?.frame.origin.y)! , width: (imgV?.frame.size.width)!, height: (imgV?.frame.size.height)!)
        var rect: CGRect? = self.listCollectionView?.convert(imgviewframe, to: self.listCollectionView?.superview)
        
        rect?.origin.x += (rect?.size.width)!/2
        rect?.origin.y += (rect?.size.height)!/2
        
        
        // tab-bar right side item frame-point = END POINT
        
        guard let view = self.tabBarController?.tabBar.items?[2].value(forKey: "view") as? UIView else
        {
            return
        }
        
        let screen = UIScreen.main.bounds
        let tabrect = view.frame
        
        let endPoint = CGPoint(x: tabrect.origin.x + tabrect.size.width / 2, y: (screen.size.height - 50) + tabrect.origin.y)
        
        addToCartAnimation(onimage: imgV!, rect: rect!,endPoint:endPoint, onView:(self.tabBarController?.view)!) { sucess in
            self.perform(#selector(self.removeanimationview), with: nil, afterDelay: 0.65)
            block()
        }
        
        
        
    }
    //remove annimated view - add to cart
    func removeanimationview() {
        let animatedView: UIImageView? = (self.tabBarController?.view.viewWithTag(9595) as? UIImageView)
        if ((animatedView?.layer) != nil) {
            animatedView?.layer.opacity = 0
            animatedView?.removeFromSuperview()
        }
    }
    
    
    
    
    func addToCart(product : Product){
        if !CartProducts.sharedInstance.isProductInCart(product: product) {
            
            CartProducts.sharedInstance.addProductInCart(product: product)
            
            self.tabBarController?.tabBar.items?[2].badgeValue = Converter.toString(setCartBadge())
//             let alertView = showAlertWithoutDelegate(title: "", message: "Item added to your cart.")
//             self.present(alertView, animated: true, completion: nil)
        }
    }
    
    
    func setBackButtonAction() {
        
        
        if self.tabBarController?.selectedIndex == 1 && !FirRCManager.shared.isFavoriteWithCategory { //from wish list
            if isFromSearch {
                btnLeft.setImage(#imageLiteral(resourceName: "ic_arrow_left"), for: .normal)
                btnLeft.addTarget(self, action: #selector(self.parentBackAction(sender:)), for: .touchUpInside)
                self.topView.isHidden = false
            }
            else{
                btnLeft.setImage(#imageLiteral(resourceName: "ic_menu"), for: .normal)
                btnLeft.addTarget(self, action: #selector(self.shutterButtonTapped(sender:)), for: .touchUpInside)
                self.topView.isHidden = true
            }
           
            
           
        } else {
            btnLeft.setImage(#imageLiteral(resourceName: "ic_arrow_left"), for: .normal)
            btnLeft.addTarget(self, action: #selector(self.parentBackAction(sender:)), for: .touchUpInside)
            self.topView.isHidden = false
           
           
        }
        topViewHeightConstraint.constant = self.topView.isHidden ? 0 : 55 * universalWidthRatio
        if topViewHeightConstraint.constant == 0.0 {
            btnSort.isHidden = true
            btnGrid.isHidden = true
            btnFilter.isHidden = true
        }
        else{
            btnSort.isHidden = false
            btnGrid.isHidden = false
            btnFilter.isHidden = false
        }
        collectionviewTopConstraint.constant = self.topView.isHidden ? 5 : -9
        
    }
    
}

//MARK:- collection view delegate and datasource
extension ProductListVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.products.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        var footerHeight = Float(50)
        
        
        if !self.canLoadMore || self.currentPageNumber == 1{
            footerHeight = Float(0)
        }
        
        let size = CGSize(width: self.view.frame.size.width, height: CGFloat(footerHeight))
        return size
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath as IndexPath)
            
            footerView.backgroundColor = UIColor.white;
            return footerView
        default:
            fatalError("Unexpected element kind")
            //assert(false, "Unexpected element kind")
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if itemPerRow == 2 {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuse, for: indexPath as IndexPath) as! ProductListCell
            cell.itemPerRow = itemPerRow
            reloadProductCell(cell: cell, indexPath: indexPath)
            return cell    // Create UICollectionViewCell
        }
        else{
            //singleCell
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kSingleCellReuse, for: indexPath as IndexPath) as! ProductListCell
            cell.itemPerRow = itemPerRow
            reloadProductCell(cell: cell, indexPath: indexPath)
            return cell    // Create UICollectionViewCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = self.products[indexPath.row]
		ProductDetailVC.showProductDetail(in: self, productId: nil, product: product,isFromCart: false, identifier: nil, shouldShowTab: false)

		//ProductDetailVC.showProductDetail(in: self, productId: product.productId.ToString())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth = (collectionView.frame.width - 40) / CGFloat(itemPerRow)  //(screenWidth - section and cell spacing)
        
        var itemHeight =  0
        if itemPerRow == 1{
            cellWidth = (collectionView.frame.width - 30) / CGFloat(itemPerRow)
            if IS_IPAD{
                itemHeight = 126
            } else {
                itemHeight =  126 //130
            }
            
        }
        else{
            if IS_IPAD{
                cellWidth = (collectionView.frame.width - 50) / 3
            }
            itemHeight = 230  //height for iphone 7
            
        }
        
        return CGSize(width: cellWidth , height:CGFloat(itemHeight) * universalWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
}

//MARK:- PRODUCTLIST API CALL -
extension ProductListVC {
    
    //Show hide emptyDataView
    func showHideEmptyDataView() {
        let isProductEmpty = self.products.count != 0 ? false : true
        if isProductEmpty {
            emptyDataView.show(in: self.view, message: "CartIsEmpty".localizedString())
        } else {
            emptyDataView.remove()
        }
        
        self.topView.isHidden = isProductEmpty
       
    }
    
    func getProductList(param : [String:Any]) {
        //  print("\nheaders are => \(wsCall.headers)")
        //  print("\nparam are => \(param)")
        
        if self.currentPageNumber == 1{
            self.showCentralGraySpinner()
        }
        
     getListTask = wsCall.getList(params: param) { (response) in
        
            if response.isSuccess {
                self.topView.isHidden = false
                self.view.backgroundColor = UIColor.backgroundColor
                self.queue.async(execute: {() -> Void in
                    // get data in respone
                    self.canLoadMore = false
                    
                    if self.currentPageNumber == 1 {
                        self.products.removeAll()
                    }
                    
                    if let json = response.json as? [[String:Any]]
                    {
                        // print("productlist  response is => \(json)")
                        let aTempArray = json.map({ (productListObject) -> Product in
                            return Product(productListObject)
                            
                        })
                        let resultcount = self.products.count
                        if aTempArray.count > 0{
                            
                            if self.products.count == 0{ //insert
                                self.products = aTempArray
                            }
                            else{  //append
                                self.products += aTempArray
                            }
                            
                            if aTempArray.count == COUNTPERPAGE{
                                self.canLoadMore = true
                            }
                        }
                        
                        let main = DispatchQueue.main
                        main.sync(execute: {() -> Void in
                            //update your view interface with fetched data
                            if self.iscollectionviewshouldrelaod { //reload collection view
                                   self.listCollectionView.reloadData()
                            }
                            else{  //insert item in colleciton view
                                if self.canLoadMore {
                                    var indexs = [IndexPath]()
                                    
                                    self.listCollectionView.performBatchUpdates({
                                        
                                        var i = resultcount
                                        while( i < resultcount + aTempArray.count){
                                            
                                            indexs.append(IndexPath(row: i, section: 0))
                                            i += 1
                                        }
                                        
                                        if !indexs.isEmpty{
                                            self.listCollectionView.insertItems(at: indexs)
                                        }
                                    }, completion: nil)
                                    
                                    
                                }
                                else {
                                   // self.listCollectionView.collectionViewLayout.invalidateLayout()
                                    self.listCollectionView.reloadData()
                                }
                            } //insert item in colleciton view
                         
                           
                            
                            
                            if self.products.count == 0 {
                                //add no result found image
                                //first remove previously added view then show new one again
                                removeNoResultFoundImage(fromView: self.view)
                                showNoResultFoundImage(onView: self.view,withText : "No Products Found!")
                                
                                //by default top view is visiable
                                self.topView.isHidden = false
                                if self.filterPropertyDetails.count == 0 {
                                    //hide top view
                                    self.topView.isHidden = true
                                }
                                
                                
                            }
                            else{
                                //remove no result found view
                                removeNoResultFoundImage(fromView: self.view)
                                if self.currentPageNumber == 1{
                                    self.listCollectionView.setContentOffset(CGPoint.zero, animated: false)
                                }
                                
                            }
                            
                        })
                        
                        
                    }
                    
                    
                    
                    
                })
                
                
            } //sucess
            else{ //failer
                if response.code == 422 { //comming soon image
                    removeNoResultFoundImage(fromView: self.view)
                    self.topView.isHidden = true
                    showNoResultFoundImage(onView: self.view,withText : "",noDataImg: #imageLiteral(resourceName: "commingsoon"))
                    self.view.backgroundColor = .white
                }
            }
        
        
            self.hideCentralGraySpinner()
        }
        
        
    }
    
}

//MARK:- RELOAD COLLECTIONVIEW CELL METHOD -
extension ProductListVC {
    //MARK: - show value on cell
    func reloadProductCell(cell : ProductListCell, indexPath:IndexPath)
    {
        let product = self.products[indexPath.row]
        cell.product = product
        cell.nameLabel.text = product.productName
        cell.brandNameLabel.text = product.brandName
        cell.pricelabel.attributedText =   showAttributedPriceString(product: product, font: cell.pricelabel.font)
        
        //brnad label height according to font size
        let namesize: CGSize = product.productName.boundingRect(with: CGSize(width: cell.nameLabel.frame.width, height: cell.nameLabel.frame.height), options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: cell.nameLabel.font], context:NSStringDrawingContext() ).size as CGSize
        if cell.nameHeightConstraint != nil {
            cell.nameHeightConstraint.constant = namesize.height
        }
        
        let brandsize: CGSize = product.brandName.boundingRect(with: CGSize(width: cell.brandNameLabel.frame.width, height: cell.brandNameLabel.frame.height), options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: cell.brandNameLabel.font], context:NSStringDrawingContext() ).size as CGSize
        if cell.brandNameHeightConstraint != nil {
            cell.brandNameHeightConstraint.constant = brandsize.height
        }
        
        let pricesize: CGSize = cell.pricelabel.text!.boundingRect(with: CGSize(width: cell.pricelabel.frame.width, height: cell.pricelabel.frame.height), options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: cell.pricelabel.font], context:NSStringDrawingContext() ).size as CGSize
        if cell.priceHeightConstraint != nil {
            cell.priceHeightConstraint.constant = pricesize.height
        }
        
        if product.isNewArrival == true{
            cell.offerView.isHidden = false
            cell.offerbgImage.image = #imageLiteral(resourceName: "newbadge")
            cell.offLabelHeightConstraint.constant = 0
            cell.offerLabelHeightConstraint.constant = 30
            cell.offerLabel.text = "NEW"
            // cell.offerView.backgroundColor = UIColor(red: 177.0/255.0, green: 212.0/255.0, blue: 144.0/255.0, alpha: 1)
        }
        else if product.discountPerc > 0{
            cell.offerView.isHidden = false
            cell.offerbgImage.image = #imageLiteral(resourceName: "offerBadge")
            cell.offLabelHeightConstraint.constant = 15
            cell.offerLabelHeightConstraint.constant = 15
            cell.offerLabel.text = String(format: "%@%@", Converter.toString(product.discountPerc) ,"%")
            // cell.offerView.backgroundColor = UIColor.red
        }
        else{
            cell.offerView.isHidden = true
        }
        
        
        
        cell.btnAddToCart.tag = indexPath.row
        cell.btnAddToCart.addTarget(self, action: #selector(btnAddToCartClicked(sender:)), for: .touchUpInside)
        
        cell.btnWishList.tag = indexPath.row
        if self.islikeavailable {
            //work as like
            if product.isLike {
                //addToCart ic_PD_Fav_Fill
              cell.btnWishList.setImage(#imageLiteral(resourceName: "ic_PD_Fav_Fill"), for: .normal)
            }
            else{
                cell.btnWishList.setImage(#imageLiteral(resourceName: "ic_PD_Fav"), for: .normal)
            }
            
            cell.btnWishList.addTarget(self, action: #selector(btnLikeClicked(_:)), for: .touchUpInside)
            
        }
        else{
            //wish list
            if product.isInWishlist { //added in wishlist
               cell.btnWishList.setImage(#imageLiteral(resourceName: "ic_favorite_fill"), for: .normal)
            }
            else{
                cell.btnWishList.setImage(#imageLiteral(resourceName: "favoriteicon"), for: .normal)
            }
            cell.btnWishList.addTarget(self, action: #selector(btnWishListClicked(_:)), for: .touchUpInside)
        }
        
        
        cell.productImage.image = nil
        let urlString = product.productImagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let sizeUrl = thumbSizeImageUrl(urlString: urlString, size: CGSize(width: cell.productImage.frame.size.width - 15, height: cell.productImage.frame.size.height - 15))
        
        cell.showCentralSpinner()
        cell.productImage.setImage(url: URL(string: sizeUrl)!, placeholder: UIImage()) { img in
            cell.hideCentralSpinner()
            cell.productImage.image = img
        }
        
        //hide cart button if price is range or like 99+
        if product.isPriceRange {  //show + price like 99 +
            cell.btnAddToCart.isHidden = true
        }
        else{
            cell.btnAddToCart.isHidden = false
        }
        
        
        
        if indexPath.row == self.products.count - 1
        { //last row then reload data
            self.lunchReload()
        }
        
    }
    //MARK: - Reload more -
    func lunchReload(){
        if self.canLoadMore {
            print("currentPageNumber ::\(currentPageNumber)")
            currentPageNumber = currentPageNumber + 1
            self.iscollectionviewshouldrelaod = false
            self.loadProductList()
        }
    }
    // refresh  collection view with page index = 1
    func refreshCollectionView() {
        
        currentPageNumber = 1
        self.products.removeAll()
        self.loadProductList()
        
    }
    
//    //MARK: Firebase remote config
//    func firebaseRemoteConfig() {
//        self.showCentralGraySpinner()
//        RemoteConfig.remoteConfig().setDefaults([RemoteConfigKey.isLikeEnableKey : NSNumber(value: 0)])
//        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
//            RemoteConfig.remoteConfig().activateFetched()
//            let value = RemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKey.isLikeEnableKey)
//            self.islikeavailable = value.boolValue
//            self.hideCentralGraySpinner()
//            self.refreshCollectionView()
//            
//        }
//    }
    
}


