//
//  MyOrderCell.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 16/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class MyOrderCell: UITableViewCell {
	@IBOutlet weak var lblOrderId:UILabel!
	@IBOutlet weak var lbldate:UILabel!
	@IBOutlet weak var lblStatus:UILabel!
	@IBOutlet weak var lblAmount:UILabel!
	@IBOutlet weak var btnTrackOrder:UIButton!
	//@IBOutlet weak var viewBG:UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
		//viewBG.setRound(corners: .allCorners, radius: 8.0)
    }

	override func layoutSubviews() {
		self.contentView.layoutSubviews()

	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


class OrderDetailCell: UITableViewCell {

	@IBOutlet weak var lblOrderId:UILabel!
	@IBOutlet weak var lbldate:UILabel!
	@IBOutlet weak var lblPrice:UILabel!
	@IBOutlet weak var viewBG:UIView!
	@IBOutlet weak var imgDelivery:UIImageView!



	override func awakeFromNib() {
		super.awakeFromNib()

	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: .allCorners, radius: 8.0)
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

}

class OrderAddressCell: TableViewCell {

	@IBOutlet weak var viewBG:UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
		//self.contentView.layoutSubviews()

	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: .allCorners, radius: 8.0)

	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}

class OrderProductCell: TableViewCell {

	@IBOutlet weak var lblQty:UILabel!
	@IBOutlet weak var lblSize:UILabel!
	@IBOutlet weak var viewBG:UIView!
	@IBOutlet weak var btnCancelItem:UIButton!


	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: .allCorners, radius: 8.0)
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

}

class OrderAmountCell: TableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}

class TrackOrderCell: UITableViewCell {

	@IBOutlet weak var lblDate1:UILabel!
	@IBOutlet weak var lblDate2:UILabel!
	@IBOutlet weak var lblDate3:UILabel!
	@IBOutlet weak var lblStatus1:UILabel!
	@IBOutlet weak var lblStatus2:UILabel!
	@IBOutlet weak var lblStatus3:UILabel!
	@IBOutlet weak var viewPoint1:UIView!
	@IBOutlet weak var viewPoint2:UIView!
	@IBOutlet weak var viewPoint3:UIView!
	@IBOutlet weak var viewLine1:UIView!
	@IBOutlet weak var viewLine2:UIView!


	override func awakeFromNib() {
		super.awakeFromNib()

	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

}

class CancelOrderCell: UITableViewCell {

	@IBOutlet weak var lblDate1:UILabel!
	@IBOutlet weak var lblDate2:UILabel!
	@IBOutlet weak var lblStatus1:UILabel!
	@IBOutlet weak var lblStatus2:UILabel!
	@IBOutlet weak var viewPoint1:UIView!
	@IBOutlet weak var viewPoint2:UIView!
	@IBOutlet weak var viewLine1:UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}

class OrderSummaryCell: TableViewCell {

	@IBOutlet weak var viewBG:UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: [.topLeft, .topRight], radius: 8.0)
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}

class OrderTotalCell: TableViewCell {

	@IBOutlet weak var viewBG:UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}
	/*override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: [.bottomLeft, .bottomRight], radius: 8.0)
	}*/

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}

class PaymentStatusCell: TableViewCell {

	@IBOutlet weak var viewBG:UIView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		viewBG.setRound(corners: .allCorners, radius: 8.0)
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
}
