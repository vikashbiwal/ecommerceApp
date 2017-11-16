 //
//  ProductInfoView.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 25/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ProductInfoView: UIView {

	@IBOutlet weak var tblInfo:UITableView!
	@IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!

	var infoArray = [InfoSection]() {
		didSet {
			self.tblInfo.reloadData()
		}
	}

	var presentList = false {
		didSet {
			if self.presentList {
				self.isHidden = false
			}
			showHideListWithAnimation()
		}
	}

	override func awakeFromNib() {
		tblInfo.estimatedRowHeight = 70 * universalWidthRatio
		tblInfo.rowHeight = UITableViewAutomaticDimension;
	}

	func showHideListWithAnimation() {
		self.backgroundColor = presentList ? UIColor.black.alpha(0.9) : UIColor.clear
		self.tblBottomConstraint.constant = presentList ? 0 : -self.frame.height
		let vAlpha: CGFloat = presentList ? 1.0 : 0.0
		UIView.animate(withDuration: 0.5) {
			self.alpha = vAlpha
			self.layoutIfNeeded()
			if !self.presentList {
				self.isHidden = true
			}
		}
	}

}

extension ProductInfoView: UITableViewDelegate,UITableViewDataSource  {

	func numberOfSections(in tableView: UITableView) -> Int {
		return self.infoArray.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sType = self.infoArray[section].type
		switch sType {
		case .KeyFeature, .Description, .Condition:
			return 1
		case .Specification:
			let array = self.infoArray[section].object as! [ProductProperty]
			return array.count
		}
		
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let sType = self.infoArray[indexPath.section].type
		switch sType {
		case .KeyFeature, .Description, .Condition:
			let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
			//cell.lblTitle.text = self.infoArray[indexPath.section].object as? String
			cell.lblTitle.setHTML(html: (self.infoArray[indexPath.section].object as? String)!)
			cell.lblTitle.textColor = UIColor.white
			cell.selectionStyle = .none
			cell.lblTitle.preferredMaxLayoutWidth = cell.frame.width
			cell.contentView.layoutSubviews()

			return cell

		case .Specification:
			let array = self.infoArray[indexPath.section].object as! [ProductProperty]
			let propertyDtl = array[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: "SpecificationCell") as! SpecificationCell
			cell.selectionStyle = .none
			cell.lblTitle.text = propertyDtl.propertyName
			cell.lblSubTitle.text = propertyDtl.propertyValue
			return cell
		}

	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let lblSectionTitle = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
		lblSectionTitle.text = String(format:"section %d", section)
		//let black = UIColor.black
		//lblSectionTitle.backgroundColor = black.withAlphaComponent(0.8)
		lblSectionTitle.backgroundColor = UIColor.clear
		lblSectionTitle.textColor = UIColor.white
		lblSectionTitle.text = self.infoArray[section].title
		lblSectionTitle.font = UIFont(name: FontName.SANSBOLD, size: (17 * universalWidthRatio))
		return lblSectionTitle
	}

}

extension UILabel {
	func setHTML(html: String) {
		do {
			let attrStr = try NSMutableAttributedString(
				data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
				options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
				documentAttributes: nil)
			//let range = (html as NSString).range(of: html)
			//attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.white , range: range)

			self.attributedText = attrStr;
		} catch {
			self.text = html;
		}
	}
}


class SpecificationCell: TableViewCell {

	override func awakeFromNib() {
		self.lblTitle.borderWithRoundCorner(radius: 0.0, borderWidth: 1.0, color: UIColor.white)
		self.lblSubTitle.borderWithRoundCorner(radius: 0.0, borderWidth: 1.0, color: UIColor.white)


	}
}

