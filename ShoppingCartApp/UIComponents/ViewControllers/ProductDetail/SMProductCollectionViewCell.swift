//
//  SMProductCollectionViewCell.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SMProductCollectionViewCell: CollectionViewCell {
	override func awakeFromNib() {
		super.awakeFromNib()
		self.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));

	}
    
}


