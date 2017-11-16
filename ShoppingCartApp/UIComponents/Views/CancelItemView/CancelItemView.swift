//
//  CancelItemView.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 12/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

class CancelItemView: UIView {

	@IBOutlet weak var lblName: UILabel!
	@IBOutlet weak var btnQty: UIButton!
	@IBOutlet weak var centerView: UIView!
	var qtyToReturn:Int = 1
	var currentItem = MyOrderProduct() {
		didSet {
			self.lblName.text = currentItem.productName
			self.btnQty.setTitle("Quantity: \(qtyToReturn)", for: .normal)
		}
	}
	lazy internal var centralGrayActivityIndicator : CustomActivityIndicatorView = {
		let image : UIImage = UIImage(named: "spinnerIcon_gray")!
		let v = CustomActivityIndicatorView(image: image)
		v.backgroundColor = UIColor.clear
		return v
	}()
	var actionBlock:cancelItemCallback  = { _ in}

	//var callBack

	override func awakeFromNib() {
		super.awakeFromNib()
		self.frame = CGRect.init(x: 0, y:  64, width: screenSize.width, height: screenSize.height - 64)

	}

	override func layoutSubviews() {
		centerView.setRound(corners: .allCorners, radius: 5.0)
	}

	class func instanceFromNib() -> CancelItemView {
		return UINib(nibName: "CancelItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CancelItemView
	}

	func showWithAnimation()   {
		//self.frame = CGRect.init(x: 0, y:  64, width: self.superview!.bounds.width, height: self.superview!.bounds.size.height - 114)
		UIView.animate(withDuration: 0.3, animations: {
			self.backgroundColor = UIColor.black.alpha(0.7)
			self.layoutIfNeeded()
		})
	}


	
}

extension CancelItemView {

	@IBAction func btnCancel_Clicked(sender:UIButton)  {
		self.removeFromSuperview()
	}

	@IBAction func btnOk_Clicked(sender:UIButton)  {
		let apiParam = ["isDeleted":false, "orderId":self.currentItem.orderId, "productId":self.currentItem.productId,"quantity":qtyToReturn] as [String : Any] 

		self.showCentralGraySpinner()
		wsCall.cancelItem(params: apiParam) { (response) in
			if response.isSuccess {
				if let json = response.json as? [String:Any] {
					print("cancelItem response is " ,json)
					let orderObj = MyOrder(json)
					self.actionBlock(orderObj)
					self.removeFromSuperview()
				}
			}
			self.hideCentralGraySpinner()
		}

	}

	@IBAction func btnQty_Clicked(sender:UIButton)  {
		changeQuantity(maxQty: self.currentItem.orderQuantity, sender: sender)
	}

	func changeQuantity(maxQty : Int, sender: UIButton) {

		let rect =  self.convert(sender.bounds, from: sender)

		let listItems = ((1...maxQty).map({"\($0)"}), "\(qtyToReturn)")
		DropDownList.show(in: self, listFrame: rect, listData: listItems) { newQty in
			sender.setTitle("Quantity : \(newQty)", for: .normal)
			self.qtyToReturn = newQty.integerValue!
		}
	}

	func showCentralGraySpinner() {
		centralGrayActivityIndicator.center = self.centerView.center
		self.addSubview(centralGrayActivityIndicator)
		centralGrayActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
		centralGrayActivityIndicator.alpha = 0.0
		self.layoutIfNeeded()
		self.isUserInteractionEnabled = false
		centralGrayActivityIndicator.startAnimating()
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.centralGrayActivityIndicator.alpha = 1.0
		})
	}

	func hideCentralGraySpinner() {
		self.isUserInteractionEnabled = true
		centralGrayActivityIndicator.stopAnimating()
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.centralGrayActivityIndicator.alpha = 0.0
		})
	}


}

extension CancelItemView : UIGestureRecognizerDelegate {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			if touch.view != self.centerView  {
				self.removeFromSuperview()
			}
			super.touchesBegan(touches, with: event)
		}
	}
	
}
