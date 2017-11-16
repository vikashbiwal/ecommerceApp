//
//  ColorAndSizeView.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

typealias ColorSizeActionBlock = (Int,Bool,AnyObject?)-> Void


class ColorAndSizeView: UIView {

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var collectionViewHeightConstant: NSLayoutConstraint!

	var size = 50 * universalWidthRatio
	var actionBlock:ColorSizeActionBlock  = { _ in}
	var previousSelectedCell = -1
	var productID = ""
	var arrColorAndSize = [AnyObject]() {
		didSet {
			collectionView.reloadData()
		}
	}
	var isForColor = false {
		didSet {
			collectionView.reloadData()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.collectionView.register(UINib(nibName: "ColorAndSizeCell", bundle: nil), forCellWithReuseIdentifier: "ColorAndSizeCell")
		self.collectionViewHeightConstant.constant = size
		self.frame = CGRect.init(x: 0, y:  64, width: screenSize.width, height: screenSize.height - 114)
		//self.collectionViewBottomConstraint.constant =  -114
		
	}
	
	class func instanceFromNib() -> ColorAndSizeView {
		return UINib(nibName: "ColorAndSizeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ColorAndSizeView
	}

	override func layoutSubviews() {
		//collectionView.frame = CGRect.init(x: collectionView.frame.origin.x, y:  collectionView.frame.origin.y, width: self.superview!.bounds.width, height: size)

	}

	func showWithAnimation()   {
		//self.frame = CGRect.init(x: 0, y:  64, width: self.superview!.bounds.width, height: self.superview!.bounds.size.height - 114)
		UIView.animate(withDuration: 0.5, animations: {
			self.backgroundColor = UIColor.black.alpha(0.5)
			self.collectionViewBottomConstraint.constant = 0
			self.layoutIfNeeded()
		})
	}

	func hideWithAnimation()  {

		UIView.animate(withDuration: 0.5, animations: {
			//self.frame = CGRect.init(x: 0, y:  self.superview!.bounds.size.height, width: self.superview!.bounds.width, height: self.superview!.bounds.size.height - 114)
			self.backgroundColor = UIColor.clear
			self.collectionViewBottomConstraint.constant = -self.size
		})
	}



}

extension ColorAndSizeView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


	//MARK:- COLLECTIONVIEW DELEGATE AND DATASOURCE

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		//return arrItemImages.count
		return arrColorAndSize.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell : ColorAndSizeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorAndSizeCell", for: indexPath) as! ColorAndSizeCell
		let obj = self.arrColorAndSize[indexPath.row] as! PDCharacter
		if obj.value.characters.first == "#" {
			cell.lblTitle.isHidden = true
			cell.imgView.backgroundColor = UIColor(hexString: obj.value)
			configureCell(productID: obj.productId, cell: cell, index: indexPath.row)

		} else if obj.value.hasPrefix("http") {
			cell.lblTitle.isHidden = true
			let imgUrl = getImageUrlWithSize(urlString: obj.value, size: cell.frame.size)
			cell.imgView.setImage(url: imgUrl)
			configureCell(productID: obj.productId, cell: cell, index: indexPath.row)

		} else {
			cell.lblTitle.isHidden = false
			cell.imgView.isHidden = true
			cell.lblTitle.text = obj.value
			cell.lblTitle.textColor = UIColor.gray
			if self.productID == obj.productId {
				cell.lblTitle.textColor = UIColor.black
				previousSelectedCell = indexPath.row
			}
		}

		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		actionBlock(indexPath.row,self.isForColor,self.arrColorAndSize[indexPath.row])

	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return  CGSize(width:size , height:size )
	}

	func configureCell(productID:String, cell:ColorAndSizeCell, index:Int)  {

		if self.productID == productID {
			cell.imgView.borderWithRoundCorner(radius: 0.0, borderWidth: 3.0, color: UIColor.black)
			previousSelectedCell = index
		}
		else {
			cell.imgView.borderWithRoundCorner(radius: 0.0, borderWidth: 0.0, color: UIColor.black)
		}
	}
}
