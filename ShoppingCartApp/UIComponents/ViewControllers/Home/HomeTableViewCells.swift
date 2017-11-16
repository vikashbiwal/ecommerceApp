//
//  HomeTableViewCells.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 17/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class CategoryHRTblCell: TableViewCell {
    
    @IBOutlet var itemView: HorizontalItemsView!
	var itemActionBlock: CollectionActionBlock = {_ in} {
		didSet {
			itemView.actionBlock = itemActionBlock
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class CategoryVRTblCell: TableViewCell {
    
    @IBOutlet var itemView: VerticalItemsView!
	var itemActionBlock: CollectionActionBlock = {_ in} {
		didSet {
			itemView.actionBlock = itemActionBlock
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
	
    
}



class FlashOfferTblCell: TableViewCell {

	@IBOutlet var itemView: OfferListView!
	var itemActionBlock: CollectionActionBlock = {_ in} {
		didSet {
			itemView.actionBlock = itemActionBlock
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}
}
class HRBannerViewCell: TableViewCell {

	@IBOutlet var itemView: HRBannerView!
	var itemActionBlock: CollectionActionBlock = {_ in} {
		didSet {
			itemView.actionBlock = itemActionBlock
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}
}




