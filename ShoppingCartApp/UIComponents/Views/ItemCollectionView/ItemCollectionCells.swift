//
//  ItemCollectionCells.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 17/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ItemCollectionHRCell: CollectionViewCell {
    @IBOutlet var imgContainerView: UIView!

    @IBInspectable var roundCorner: CGFloat = 0 {
        didSet {
            if isRoundCorner {
                imgContainerView.layer.cornerRadius = roundCorner
                imgContainerView.clipsToBounds = true
            }
        }
    }
    
    var isRoundCorner = false {
        didSet {
            if isRoundCorner {
                imgContainerView.layer.cornerRadius = roundCorner
                imgContainerView.clipsToBounds = true
            }
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
    }
} 

class ItemCollectionHRCellOffer: CollectionViewCell {
	@IBOutlet var imgContainerView: UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}
}

//Banner cell used for showing banner at home screen.
class BannerCollectionCell: CollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class FlashOfferCollectionCell: CollectionViewCell {
	var offer: HomeGroupObject! {
		didSet{
			//offer.timerObserveBlock = {time in
			//  self.lblTitle.text = time
			//}
		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	
}

