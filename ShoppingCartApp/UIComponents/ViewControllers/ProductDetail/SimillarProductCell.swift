//
//  SimillarProductCell.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 23/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SimillarProductCell: UITableViewCell {
	@IBOutlet var itemView: SMProductsItemsView!


    override func awakeFromNib() {
        super.awakeFromNib()
		self.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
