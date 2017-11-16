//
//  ItemCollectionView.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 17/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig



typealias CollectionActionBlock = (Int,DynamicSectionStyle,HomeGroupObject?)-> Void

class ItemCollectionView: UIView {
    @IBOutlet var collView: UICollectionView!
    
    //Set Scroll direction of items
    var scrollDirection: UICollectionViewScrollDirection = .vertical {
        didSet {
          (collView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = scrollDirection
        }
    }

    class func loadNib()-> ItemCollectionView {
        let views = Bundle(for: ItemCollectionView.self).loadNibNamed("ItemCollectionView", owner: nil, options: nil) as! [UIView]
        let itemView = views[0] as! ItemCollectionView
        return itemView
    }
    
    func registerCellWith(nibName: String, cellIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: ItemCollectionView.self))
        collView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }

    func reloadItems() {
        collView.reloadData()
    }

    //Intrective Movement setup for collectionview items.
    //User can move any item's position by long pressing and drag it destination position.
    func setIntractiveMovementGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.addGestureRecognizer(longPressGesture)
        
    }
	func removeIntrativeGesture() {
		self.gestureRecognizers?.forEach(self.removeGestureRecognizer)
	}


    //Intrective Movement handler for long press gesture.
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collView.indexPathForItem(at: gesture.location(in: self.collView)) else {
                break
            }
            collView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case UIGestureRecognizerState.changed:
            collView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            collView.endInteractiveMovement()
            
        default:
            collView.cancelInteractiveMovement()
        }
    }

}


//MARK:- ItemContainerView 
/// Create sub classes from ItemContainner class for creating any item listing view using collectionview.
class ItemsContainerView: UIView {
    var itemView: ItemCollectionView!
    
    //Set true if user want to make moveable item in collectionv view.
    var isEnableIntrectiveItemMovement = false {
        didSet {
			 isEnableIntrectiveItemMovement ? itemView.setIntractiveMovementGesture() : itemView.removeIntrativeGesture()
        }
    }

	var actionBlock:CollectionActionBlock  = { _ in}

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeIetmCollView()
    }
    
    func initializeIetmCollView()  {
        itemView = ItemCollectionView.loadNib()
        self.addSubview(itemView)
        itemView.backgroundColor = UIColor.clear
        
        //Set Constraint
        itemView.translatesAutoresizingMaskIntoConstraints = false
        itemView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        itemView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        itemView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        itemView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

//MARK:- HorizontalItemsView // for main category
class HorizontalItemsView: ItemsContainerView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	var itemWidth:CGFloat = 65
	var itemLeftRightMargin:CGFloat = 27
	var groupId = "" {
		didSet {
			self.sortedArray()
		}
	}
    var categories = [HomeGroupObject]()

	func sortedArray()  {
		if (_userDefault.value(forKey: groupId) != nil) {
			let idArray = _userDefault.value(forKey: groupId) as! [String]
			let sorted = categories.flatMap { obj in
					idArray.index(of: obj.id).map { idx in (obj, idx) }
				}.sorted(by: { $0.1 < $1.1 } ).map { $0.0 }
			categories = sorted
			self.itemView.collView.reloadData()
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        itemView.collView.delegate = self
        itemView.collView.dataSource = self
        itemView.scrollDirection = UICollectionViewScrollDirection.horizontal
        itemView.registerCellWith(nibName: "ItemCollectionHRCell", cellIdentifier: "cell")
		itemView.registerCellWith(nibName: "ItemCollectionHRCellOffer", cellIdentifier: "cellOffer")

        self.isEnableIntrectiveItemMovement = true
    }
    
    //CollectionView DataSource and Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cate = categories[indexPath.row]

		/*if cate.id == "offer"  {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellOffer", for: indexPath) as! ItemCollectionHRCellOffer
			cell.imgView.image = UIImage(named:"ic_offer.png")
			return cell
		}
		else {*/
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCollectionHRCell
			cell.isRoundCorner = true

			let imgUrl = getImageUrlWithSize(urlString: cate.image, size: cell.frame.size)
			cell.imgView.setImage(url: imgUrl)
			//cell.imgView.setImage(url: (cate.image?.thumURL)!)
			cell.lblTitle.text = cate.name
			return cell
		//}
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		//let cellWidth = (collectionView.frame.width - 50)/4  //(screenWidth - section and cell spacing)
        return CGSize(width: itemWidth, height: self.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: itemLeftRightMargin, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemLeftRightMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemLeftRightMargin
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = categories.remove(at: sourceIndexPath.item)
        categories.insert(temp, at: destinationIndexPath.item)
		self.saveCategoryIds()
    }

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

			actionBlock(indexPath.row,.HRMenu,categories[indexPath.row])

	}

	func saveCategoryIds() {
		let arr = categories.map { (category) -> String in
			return category.id
		}
		_userDefault.set(arr, forKey: groupId)
	}

}

//MARK:- VerticalItemsView // for subcategory
class VerticalItemsView: ItemsContainerView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	var subCategories = [HomeGroupObject]()
	var categories = [HomeGroupObject]()
	var groupId = "" {
		didSet {
			self.sortedArray()
		}
	}

    var itemHeight:CGFloat = 130
    var numberOfItemsInRow = 2
    var sectionLeftRightMargin:CGFloat = 15
	var titleLabelHieght:CGFloat = 30
    var line_cell_spacing:CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemView.collView.delegate = self
        itemView.collView.dataSource = self
        itemView.scrollDirection = UICollectionViewScrollDirection.vertical
		itemView.collView.isScrollEnabled = false
        itemView.registerCellWith(nibName: "ItemCollectionHRCell", cellIdentifier: "cell")
        self.isEnableIntrectiveItemMovement = true

    }
	func sortedArray()  {
		if (_userDefault.value(forKey: groupId) != nil) {
			let idArray = _userDefault.value(forKey: groupId) as! [String]
			let sorted = categories.flatMap { obj in
				idArray.index(of: obj.id).map { idx in (obj, idx) }
				}.sorted(by: { $0.1 < $1.1 } ).map { $0.0 }
			subCategories = sorted
			self.itemView.collView.reloadData()
		}
		else {
			subCategories = categories
		}
	}

    //CollectionView DataSource and Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ItemCollectionHRCell
        let cate = subCategories[indexPath.row]
		cell.isRoundCorner = true
		let imgUrl = getImageUrlWithSize(urlString: cate.image, size: cell.frame.size)
		cell.imgView.setImage(url:imgUrl)
		//cell.imgView.setImage(url:(cate.mobileBannerImgUrl)!)
		cell.lblTitle.text = cate.name

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = (sectionLeftRightMargin * 2) + line_cell_spacing * CGFloat(numberOfItemsInRow - 1)
        let cellWidth = (collectionView.frame.width - spacing) / CGFloat(numberOfItemsInRow)  
        return CGSize(width: cellWidth, height: cellWidth + titleLabelHieght)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: sectionLeftRightMargin, bottom: 0, right: sectionLeftRightMargin)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return line_cell_spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return line_cell_spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let temp = subCategories.remove(at: sourceIndexPath.item)
        subCategories.insert(temp, at: destinationIndexPath.item)
		self.saveCategoryIds()
    }
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		actionBlock(indexPath.row, .VRCategories,subCategories[indexPath.row])
	}

	func saveCategoryIds() {
		let arr = subCategories.map { (category) -> String in
			return category.id
		}
		_userDefault.set(arr, forKey: groupId)
	}

}

//MARK:- OfferListView // for vertical banner (with timer/offer)
class OfferListView: ItemsContainerView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	var offers = [HomeGroupObject]()
	var groupId = "" {
		didSet {
			self.sortedArray()
		}
	}
	var offersCollArray = [HomeGroupObject]() {
		didSet {
			self.itemView.collView.reloadData()
		}
	}
	var itemHeight:CGFloat = 180
	var numberOfItemsInRow = 1
	var sectionLeftRightMargin:CGFloat = 10
	var line_cell_spacing:CGFloat = 3


	override func awakeFromNib() {
		super.awakeFromNib()
		itemView.registerCellWith(nibName: "FlashOfferCollectionCell", cellIdentifier: "cell")
		itemView.collView.delegate = self
		itemView.collView.dataSource = self
		itemView.scrollDirection = UICollectionViewScrollDirection.vertical
		itemView.collView.isPagingEnabled = false
		self.isEnableIntrectiveItemMovement = true
	}

	func sortedArray()  {
		if (_userDefault.value(forKey: groupId) != nil) {
			let idArray = _userDefault.value(forKey: groupId) as! [String]
			let sorted = offers.flatMap { obj in
				idArray.index(of: obj.id).map { idx in (obj, idx) }
				}.sorted(by: { $0.1 < $1.1 } ).map { $0.0 }
			offersCollArray = sorted
		}
		else {
			offersCollArray = offers
		}
	}


	//CollectionView DataSource and Delegate
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return offersCollArray.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FlashOfferCollectionCell
		let offer = offersCollArray[indexPath.row]
		cell.offer = offer
		let imgUrl = getImageUrlWithSize(urlString: offer.image, size: cell.frame.size)
		cell.imgView.setImage(url:imgUrl)
		//cell.imgView.setImage(url:(offer.offerBannerImgUrl)!)
        cell.lblTitle.text = offer.name
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: itemHeight)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: sectionLeftRightMargin, bottom: 0, right: sectionLeftRightMargin)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return line_cell_spacing
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return line_cell_spacing
	}

	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

		let temp = offersCollArray.remove(at: sourceIndexPath.item)
		offersCollArray.insert(temp, at: destinationIndexPath.item)
		self.saveOfferIds()
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		actionBlock(indexPath.row, .HRSmallBanners,offersCollArray[indexPath.row])
	}

	func saveOfferIds() {
		let arr = offersCollArray.map { (offer) -> String in
			return offer.id
		}
		_userDefault.set(arr, forKey: groupId)
	}


}

//MARK:- HRBannerView View
protocol BannerScrollDelegate {
	func btnBanner_Clicked(sender:UIButton)
}

class HomeBannerView: UIView {

	@IBOutlet weak var imgBanner: UIImageView!
	@IBOutlet weak var button: UIButton!
	var delegate: BannerScrollDelegate!


	/*init(frame: CGRect, andTag tag: Int?) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}*/


	class func instanceFromNib() -> HomeBannerView {
		return UINib(nibName: "HomeBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeBannerView
	}


	@IBAction func btnBanner_Clicked(_ sender: UIButton) {
		self.delegate.btnBanner_Clicked(sender:sender)
	}
	
}

// for horizontal banner (circular)
class HRBannerView:UIView,BannerScrollDelegate  {
	@IBOutlet var pagerView: UIPageControl!
	var scrollView: UIScrollView!
	var lastContentOffset = CGPoint(x: 0.0, y: 0.0)
	var collArray = [HomeGroupObject]()
	var width:CGFloat = 0.0
	var timer:Timer!
	var isAutoscroll = false
	var autoscrollInterval:Int = 0
	var actionBlock:CollectionActionBlock  = { _ in}


	var banners = [HomeGroupObject]() {
		didSet {
			pagerView.numberOfPages = banners.count
			self.updateBannerArray()
		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		scrollView = UIScrollView()
		scrollView.isPagingEnabled = true
		scrollView.delegate = self
		scrollView.showsHorizontalScrollIndicator = false
		self.addSubview(scrollView)
		self.bringSubview(toFront:pagerView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		width = self.frame.width
		scrollView.frame =  CGRect(x: 0, y: 0, width: width, height: self.frame.height)
		for view in scrollView.subviews {
			view.removeFromSuperview()
		}
		self.clearTimer()
		self.addBannerInScrollView()
	}

	func clearTimer()  {
		if timer != nil {
			timer.invalidate()
			timer = nil
		}
	}

	func fetchfirebaseRemoteConfig() {
        if isAutoscroll {
            self.startCircularTimer()
        } else {
            self.clearTimer()
        }

	}

	func getBannerView(index:Int) -> HomeBannerView {
		var homebannerView: HomeBannerView!
		homebannerView =  HomeBannerView.instanceFromNib()
		//homebannerView.frame = CGRect.init(x: CGFloat(index) * self.frame.width, y: 0, width: self.frame.width, height: self.frame.height)
		homebannerView.frame = CGRect.init(x: CGFloat(index) * width, y: 0, width: width, height: self.frame.height  )
		homebannerView.button.tag = index
		homebannerView.delegate = self
		return homebannerView
	}

	func addBannerInScrollView()  {
		for  i in 0..<collArray.count {
			let bannerView = self.getBannerView(index:i)
			let banner = collArray[i]
			let imgUrl = getImageUrlWithSize(urlString: banner.image, size: bannerView.frame.size)
			bannerView.imgBanner.setImage(url:imgUrl)
			//bannerView.imgBanner.setImage(url:(banner.mobileBannerImgUrl)!)
			scrollView.addSubview(bannerView)
		}
		scrollView.contentSize = CGSize.init(width: CGFloat(collArray.count) * width, height: 50)

		if collArray.count > 1 {
			self.moveToFirst()
			self.fetchfirebaseRemoteConfig()
		}
	}

	func btnBanner_Clicked(sender: UIButton) {
		actionBlock(sender.tag, .HRBigBanners,collArray[sender.tag])
	}

	func updateBannerArray()  {
		collArray.removeAll()
		if banners.count > 0 {
			let firstBanner = banners[0]
			let lastBanner = banners.last
			collArray.append(lastBanner!)
			collArray.append(contentsOf: banners)
			collArray.append(firstBanner)
		} else {
			collArray = banners
		}
		//self.addBannerInScrollView()
	}


	func moveToFirst()  {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
			self.lastContentOffset = CGPoint(x: CGFloat(1) * self.width, y: 0)
			//self.scrollView.setContentOffset(CGPoint(x: CGFloat(1) * self.width, y: 0), animated: false)
			//print("moveToFirst ")
			//print("lastContentOffset => %@  ",self.lastContentOffset)
			let x = CGFloat(1) * self.width
			self.scrollView.contentOffset = CGPoint(x: x, y: 0)
			//print("scrollViewOffset => %@  ",x)
			//print("**********************\n")

			self.pagerView.currentPage = 0
		}
	}

	func moveToLast()  {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
			//self.scrollView.setContentOffset(CGPoint(x: CGFloat(self.pagerView.numberOfPages) * self.width, y: 0), animated: false)
			self.lastContentOffset = self.scrollView.contentOffset;
			let x = CGFloat(self.pagerView.numberOfPages) * self.width
			self.scrollView.contentOffset = CGPoint(x: x, y: 0)
			self.pagerView.currentPage = self.pagerView.numberOfPages - 1
		}
	}

	func moveToNext()  {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
			UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
				self.lastContentOffset = self.scrollView.contentOffset;
				//print("moveToNext ")
				//print("lastContentOffset => %@  ",self.lastContentOffset)
				let x = self.scrollView.contentOffset.x + self.width as CGFloat
				//print("scrollViewOffset => %@  ",x)
				//print("**********************\n")

				self.scrollView.contentOffset = CGPoint(x: x, y: 0)
				self.updatePager(offset:x)
			}, completion: nil)
		}
	}

}

extension HRBannerView : UIScrollViewDelegate {


	func startCircularTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.autoscrollInterval), repeats: true) { [unowned self] timer in
			self.moveToNext()
		}
		RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
	}

	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		//self.lastContentOffset = scrollView.contentOffset;
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		//self.lastContentOffset = scrollView.contentOffset;
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.updatePager(offset:scrollView.contentOffset.x)
	}

	func updatePager(offset:CGFloat)  {
		//let pageSide =  self.frame.width
		let pageSide =  self.width
		let currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
		//print("updatePager => %@  = %@ ",self.lastContentOffset.x ,currentPage , offset)
		//print("**********************\n")


		if (self.lastContentOffset.x < offset) {
			if currentPage+1 == self.collArray.count {
				//print("moveToFirst if part")
				//print("**********************\n")
				self.moveToFirst()

			}else {
				//print("moveToFirst else part")
				//print("**********************\n")
				self.pagerView.currentPage = currentPage - 1
			}

		} else if (self.lastContentOffset.x > offset) {
			if currentPage == 0{
				//print("moveToLast if part")
				//print("**********************\n")
				self.moveToLast()
			}else {
				//print("moveToLast if part")
				//print("**********************\n")
				self.pagerView.currentPage = currentPage - 1
			}
		}
		else {
			//print("circular out of range. and offser is => \(offset)")
		}
	}

}





