//
//  ViewController.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 08/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit



class HomeViewController: ParentViewController {

	//MARK: IBOutlets
	@IBOutlet var btnSearch: UIButton!
	@IBOutlet var btnCart: UIButton!

	//MARK: Instance Variables

	///top constraint for searchOption view.
	fileprivate var searchViewTopConstraint: NSLayoutConstraint!

	///SearchOptionView. view for showing while user tap on search button.
	fileprivate var searchOptionView: SearchOptionView?

	//MARK: Constants
	let kSectionHRMenuWidth :CGFloat = 60 * universalWidthRatio
	let kSectionHRMenuHeight :CGFloat = 85 * universalWidthRatio
	let kSectionHRMenuLeftSpacing :CGFloat = 27 * universalWidthRatio

	let kSectionBigBannerHeight :CGFloat = 100 * universalWidthRatio
	let kSectionSmallBannerHeight :CGFloat = 100 * universalWidthRatio
	//let kSectionSmallBannerTitleHeight :CGFloat = 120 * universalWidthRatio

	let kSectionVRCategoryHeight :CGFloat = 330 * universalWidthRatio
	let kSectionVRCategoryLeftRightSpacing :CGFloat = 30

	let kNumberOfItemsInRow :CGFloat = 0
	let kItemSpacing:CGFloat = 10
	let kVRtitleSpacing:CGFloat = 30 * universalWidthRatio


	fileprivate var sections = [Section]()
	var mainArray = [DynamicHome]()

	var itemAction: CollectionActionBlock {
		return {[weak self] index, style,object in
			self?.checkNavigationCondition(obj: object!)
		}
	}

	//MARK: View Life Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationBarView.drawShadow()
		self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
		self.congfigureCartButton()
		self.getDynamicList()
        self.view.backgroundColor = UIColor.white
	}

	override func viewWillAppear(_ animated: Bool) {
		if checkUserLoggedIn(){
			getCustomerBalance(block: {success in
				NotificationCenter.default.post(name: NSNotification.Name("refreshTable"), object: nil)
			})
		}
		self.tabBarController?.tabBar.isHidden = false
	}
	//MARK: Navigations

	func checkNavigationCondition(obj:HomeGroupObject)  {

		if !obj.openOfferScreen && obj.openCategoryScreen && obj.apiParam.characters.count > 0 {
			//Category list screen
			self.navigateToCategoryList((obj.apiParam), obj.name)
		}
		else if !obj.openOfferScreen && !obj.openCategoryScreen && obj.apiParam.characters.count > 0 {
			//Product list screen
			self.navigateToProductListing((obj.apiParam), obj.name)
		}
		else if obj.openOfferScreen && !obj.openCategoryScreen  {
			//Offer list screen
			self.navigateToAllOfferScreen(obj.apiParam)
		}
	}



	func navigateToCategoryList(_ apiParam:String , _ title: String) {
		let categoryVc = storyboardCategory.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
		categoryVc.categoryID = apiParam
		self.navigationController?.pushViewController(categoryVc, animated: true)

	}
	func navigateToAllOfferScreen(_ apiParam:String) {
		let offerVC = storyboardOffer.instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
		offerVC.strApiParam = apiParam
		self.navigationController?.pushViewController(offerVC, animated: true)

	} 


	func navigateToProductListing(_ apiParam:String , _ title: String)  {
		let productListvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
		productListvc.apiParam = apiParam
		productListvc.navigationTitle = title
		self.navigationController?.pushViewController(productListvc, animated: true)
	}




	//MARK: Section Update
	func insertSectionAtIndex(sectionIndex:Int)  {
		tableView.beginUpdates()
		tableView.insertSections(NSIndexSet(indexesIn: NSMakeRange(sectionIndex, 1)) as IndexSet, with: .none)
		tableView.endUpdates()
	}

	func calculateSubCategorySectionHeight(array:[HomeGroupObject], numberOfItemsInRow:CGFloat) -> CGFloat {
		let spacing =  kItemSpacing + kSectionVRCategoryLeftRightSpacing
		let height = (screenSize.width - spacing) / numberOfItemsInRow
		let itemCount = CGFloat(array.count) / numberOfItemsInRow
		let sectionSpacing = kItemSpacing * ceil(itemCount)
		let titleSpacing = kVRtitleSpacing * ceil(itemCount)
		print("height is \( height * ceil(itemCount))")
		return (height * ceil(itemCount)) + sectionSpacing + titleSpacing
	}

	func calculateOfferSectionHeight(array:[HomeGroupObject], height:CGFloat) -> CGFloat {
		let spacing = height + kItemSpacing
		let heightNew = spacing * CGFloat(array.count)
		print("OfferSectionHeight height is \( height)")
		print("height in method \(height)")

		return heightNew
	}

	func congfigureCartButton()  {
		if Cart.shared.shortInforCartItems.count > 0 {
			//self.btnCart.isHidden = false
			self.tabBarController?.tabBar.items?[2].badgeValue =  Cart.shared.shortInforCartItems.count.ToString()

		} else {
			self.btnCart.isHidden = true
		}
	}
}


//MARK:- IBActions
extension HomeViewController {
    
    @IBAction func searchBtn_clicked(sender: UIButton) {
    }

	@IBAction func cartBtn_clicked(sender: UIButton) {
			let cartVC = storyboardWishListh.instantiateViewController(withIdentifier: "SBID_CartVC")
			self.navigationController?.pushViewController(cartVC, animated: true)
	}

}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate  {

	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].itemCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = sections[indexPath.section]
		switch section.style {
		case .HRMenu:
			let cell = tableView.dequeueReusableCell(withIdentifier: "HRCategoryCell") as! CategoryHRTblCell
			cell.itemView.categories = section.object as! [HomeGroupObject]
			cell.itemView.itemLeftRightMargin = kSectionHRMenuLeftSpacing
			cell.itemView.itemWidth = kSectionHRMenuWidth
			cell.itemView.groupId = section.groupID
			cell.itemActionBlock = itemAction
			/*if self.arrOtherOffers.count > 0 {
			cell.itemView.isOfferAvalable = true
			}*/
			return cell

		case .HRBigBanners:

			let cell = tableView.dequeueReusableCell(withIdentifier: "hrBannerViewCell") as! HRBannerViewCell
			cell.itemView.banners = section.object as! [HomeGroupObject]
			let homeObj = self.mainArray[indexPath.section]
			cell.itemView.isAutoscroll = homeObj.isAutoRotate
			cell.itemView.autoscrollInterval = homeObj.autoRotateInterval
			cell.itemActionBlock = itemAction

			return cell

		case .VRCategories:
			let cell = tableView.dequeueReusableCell(withIdentifier: "vrCategoryCell") as! CategoryVRTblCell
			cell.itemView.categories = section.object as! [HomeGroupObject]
			cell.itemView.groupId = section.groupID
			cell.itemView.itemHeight = kSectionVRCategoryHeight
			cell.itemView.titleLabelHieght = kVRtitleSpacing
			cell.itemView.numberOfItemsInRow = section.vrItemCount
			cell.itemActionBlock = itemAction
			return cell

		case .HRSmallBanners:
			let cell = tableView.dequeueReusableCell(withIdentifier: "flashOfferTblCell") as! FlashOfferTblCell
			cell.itemView.offers = section.object as! [HomeGroupObject]
			cell.itemView.groupId = section.groupID
			cell.itemView.itemHeight = section.height
			cell.itemView.numberOfItemsInRow = 1
			cell.itemActionBlock = itemAction
			return cell
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		//let sectionStyle = sections[indexPath.section].style
		let section = sections[indexPath.section]


		switch section.style {
		case .VRCategories:
			return self.calculateSubCategorySectionHeight(array: sections[indexPath.section].object as! [HomeGroupObject], numberOfItemsInRow: CGFloat(section.vrItemCount))

		case .HRSmallBanners:
			return self.calculateOfferSectionHeight(array: sections[indexPath.section].object as! [HomeGroupObject],height: sections[indexPath.section].height)

		default:
			return sections[indexPath.section].height
		}

	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		var fView: UITableViewHeaderFooterView
		if let fv = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footerView") {
			fView = fv
		} else {
			fView = UITableViewHeaderFooterView(reuseIdentifier: "footerView")
		}
		fView.contentView.backgroundColor = UIColor.backgroundColor
		return fView
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
}


//MARK:- Section & SectionStyle
fileprivate struct Section {
	var style : DynamicSectionStyle
	var itemCount = 1
	var height: CGFloat = 0
	var object: Any?
	var groupID = ""
	var vrItemCount:Int = 0
}

enum DynamicSectionStyle {
	case HRMenu
	case HRBigBanners, HRSmallBanners
	case VRCategories
}

extension HomeViewController {
	//MARK:- API CALLS

	func getDynamicList() {

		self.showCentralGraySpinner()
		wsCall.getDynamicHomeData(params: nil) { (response) in
			if response.isSuccess {
				if let json = response.json as? [[String:Any]] {
					self.mainArray = json.map({ (object) -> DynamicHome in
						return DynamicHome(object)
					})
					self.configureSections()

				}
			}
			self.hideCentralGraySpinner()
			self.getCartList()
		}
	}

	func configureSections() {
		for homeObj in self.mainArray {
			if (!homeObj.isHorizontal && homeObj.verticalCount > 1) {
				// subcategory view

				if homeObj.groupList.count > 0 {
					let sectionIndex = self.sections.count
					self.sections.append(Section(style: .VRCategories, itemCount: 1, height: self.kSectionBigBannerHeight, object: homeObj.groupList, groupID:homeObj.id, vrItemCount:homeObj.verticalCount))
					self.insertSectionAtIndex(sectionIndex: sectionIndex)
				}

			}
			else if (!homeObj.isHorizontal && homeObj.verticalCount == 1) {
				// offer view
				if homeObj.groupList.count > 0 {
					let sectionIndex = self.sections.count
					self.sections.append(Section(style: .HRSmallBanners, itemCount: 1, height: kSectionSmallBannerHeight, object: homeObj.groupList, groupID:homeObj.id, vrItemCount: 0))
					self.insertSectionAtIndex(sectionIndex: sectionIndex)

					let obj = homeObj.groupList[0]

					if let url = URL(string: obj.image) {
						downloadImage(url: url, block: { (height) in
							print("height in block \(height)")
							var section = self.sections[sectionIndex]
							section.height = height
							self.sections[sectionIndex] = section
							self.tableView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .none)
						})
					}
				}

			}
			else if (homeObj.isHorizontal && !homeObj.isRotateBanner) {
				// main category view
				if homeObj.groupList.count > 0 {
					let sectionIndex = self.sections.count
					self.sections.append(Section(style: .HRMenu, itemCount: 1, height: self.kSectionHRMenuHeight, object: homeObj.groupList, groupID:homeObj.id, vrItemCount: 0))
					self.insertSectionAtIndex(sectionIndex: sectionIndex)
				}

			}
			else if (homeObj.isHorizontal && homeObj.isRotateBanner) {
				// circular view
				if homeObj.groupList.count > 0 {
					let sectionIndex = self.sections.count
					self.sections.append(Section(style: .HRBigBanners, itemCount: 1, height: self.kSectionBigBannerHeight, object: homeObj.groupList, groupID:homeObj.id, vrItemCount: 0))
					self.insertSectionAtIndex(sectionIndex: sectionIndex)

					let obj = homeObj.groupList[0]
					if let url = URL(string: obj.image) {
						downloadImage(url: url, block: { (height) in
							var section = self.sections[sectionIndex]
							section.height = height
							self.sections[sectionIndex] = section
							self.tableView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .none)
						})
					}
				}
			}
		}
	}

	func getCartList()  {
		wsCall.getCartItemList(params: nil) { (response) in
			if response.isSuccess {
				if let json = response.json as? [[String:Any]]
				{
					Cart.shared.shortInforCartItems = json.map({ (object) -> CartItemCount in
						return CartItemCount(productID: object["productId"] as! Int, count: object["quantity"] as! Int)
					})
					self.congfigureCartButton()
					
				}
			}
		}
	}
}



