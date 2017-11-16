//
//  BottomCollectionView.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 28/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class BottomView: UIView {

	@IBOutlet weak var collectionView: UICollectionView!
	var characteristic = [ProductCharacteristic]()
	var actionBlock:(Int,Bool,AnyObject?) -> (Void) = { _ in }
	var previosIndex = -1
	override func awakeFromNib() {
		super.awakeFromNib()
		//self.collectionView.register(UINib(nibName: "ColorAndSizeCell", bundle: nil), forCellWithReuseIdentifier: "ColorAndSizeCell")

	}
}

extension BottomView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	// MARK: - Card Collection Delegate & DataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
			return self.characteristic.count
		}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCell", for: indexPath) as! CollectionViewCell
			let characterObj = self.characteristic[indexPath.row]
			cell.lblTitle.text = characterObj.name.uppercased()
			cell.lblTitle.backgroundColor = UIColor.backgroundColor
			cell.lblTitle.textColor = PDCOLOR
			return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		if previosIndex == indexPath.row {

			let indexPath = IndexPath(row: previosIndex, section: indexPath.section)
			collectionView.reloadItems(at: [indexPath])
			actionBlock(indexPath.row,true,nil)
			previosIndex = -1

		} else {
			if previosIndex >= 0 {
				let indexPath = IndexPath(row: previosIndex, section: indexPath.section)
				collectionView.reloadItems(at: [indexPath])
			}
			previosIndex = indexPath.row
			let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
			cell.lblTitle.backgroundColor = PDCOLOR
			cell.lblTitle.textColor = UIColor.white
			actionBlock(indexPath.row,false,nil)
			//self.btnInfo.backgroundColor = PDCOLOR
		}

	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			if self.characteristic.count == 1 {
				return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
			} else {
				let width = (collectionView.frame.width - 5 ) / 2
				return CGSize(width: width, height: collectionView.frame.height)
			}

		
	}
}
