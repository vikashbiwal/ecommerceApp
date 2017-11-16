//
//  PollCells.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 06/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class PollCell: UITableViewCell {
	@IBOutlet weak var lblTitle:UILabel!
	@IBOutlet weak var lblSubTitle:UILabel!
	@IBOutlet weak var bgView:UIView!
	//@IBOutlet weak var viewBG:UIView!


	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
		self.bgView.setRound(corners: .allCorners, radius: 5.0)
		self .bgView.layer.borderColor = UIColor.lightGray.cgColor


	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class SingleSelectionCell: TableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class MultySelectionCell: TableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class SingleLineTextCell: TableViewCell {

	@IBOutlet weak var txtAnswer:UITextField!
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class MultiLineTextCell: TableViewCell {

	@IBOutlet weak var txtAnswer:UITextView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class ImageOptionCell: TableViewCell {

	@IBOutlet weak var collectionView:UICollectionView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class SingleImageCollectionViewCell: CollectionViewCell {

	@IBOutlet weak var imgSelect:UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

}

class MultiImageCollectionViewCell: CollectionViewCell {

	@IBOutlet weak var imgSelect:UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
}

class RatingOptionCell: TableViewCell {

	@IBOutlet weak var ratingView:FloatRatingView!

	override func awakeFromNib() {
		super.awakeFromNib()
		ratingView.backgroundColor = UIColor.clear
		ratingView.contentMode = UIViewContentMode.scaleAspectFit
		ratingView.type = .wholeRatings
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class DropDownSelectionCell: TableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class SwitchCell: TableViewCell {

	@IBOutlet weak var switchOnOff:UISwitch!


	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func layoutSubviews() {
		self.contentView.layoutSubviews()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}

class RatingSmilyCell: TableViewCell {

	@IBOutlet weak var stackView:UIStackView!


	override func awakeFromNib() {
		super.awakeFromNib()
		}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
}
