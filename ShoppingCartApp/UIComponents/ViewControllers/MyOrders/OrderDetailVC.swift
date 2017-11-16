//
//  OrderDetailVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 18/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

typealias cancelItemCallback = (MyOrder)-> Void


class OrderDetailVC: ParentViewController {

	var orderDetailObj = MyOrder() {
		didSet {
		let array =	orderDetailObj.summary.sorted(by: { $0.sortOrder < $1.sortOrder })
			orderDetailObj.summary = array
		}
	}
	var orderId = ""
	fileprivate var arrSection = [Section]()
	var previousIndex:Int = 0
	var listActionBlock:(MyOrder,Int) -> Void = { _ in }

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.estimatedRowHeight = 40
		tableView.rowHeight = UITableViewAutomaticDimension
		if orderId.characters.count > 0 {
			GetOrderList()
		} else {
			configureSectionArray()
		}
    }
	
	var cancelItemCallbackAction:cancelItemCallback {
		return { [weak self] object in
			print("cancelItemCallbackAction called ***********************")
			self?.orderDetailObj = object
			self?.arrSection.removeAll()
			self?.tableView.reloadData()
			self?.configureSectionArray()

			self?.listActionBlock(object,(self?.previousIndex)!)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	func configureSectionArray()  {
		let orderDetailSection = Section(style: .OrderDetail, itemCount: 1)
		let addressSection = Section(style: .Address, itemCount: 1)

		var trackOrderSection:Section
		if orderDetailObj.orderStatusId == OrderStatus.canceled {
			trackOrderSection = Section(style: .CancelOrder, itemCount: 1)
		} else {
			trackOrderSection = Section(style: .TrackOrder, itemCount: 1)

        }

		let itemsSection = Section(style: .OrderItems, itemCount: orderDetailObj.productList.count)
		let paymentMethodSection = Section(style: .PaymentMethod, itemCount: 1)

		let count = orderDetailObj.summary.count > 1 ? orderDetailObj.summary.count - 1 : orderDetailObj.summary.count
		let SummarySection = Section(style: .AmountSummary, itemCount:count)
		self.arrSection = [orderDetailSection,addressSection,trackOrderSection,itemsSection,SummarySection,paymentMethodSection]
		self.tableView.reloadData()

	}

}

extension OrderDetailVC {

	fileprivate struct Section {
		var style : SectionStyle
		var itemCount = 1
	}

	enum SectionStyle {
		case OrderDetail
		case Address, TrackOrder, CancelOrder
		case OrderItems, AmountSummary, PaymentMethod
	}
}

extension OrderDetailVC: UITableViewDelegate,UITableViewDataSource
{
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.arrSection.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.arrSection[section].itemCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let style = self.arrSection[indexPath.section].style

		switch style {
		case .OrderDetail:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell") as! OrderDetailCell
			cell.lblOrderId.text = orderDetailObj.displayOrderId
			let date1 = serverDateFormator.date(from: orderDetailObj.orderPlacedDate)
			cell.lbldate.text = dateFormator.string(from: date1!)
			cell.lblPrice.text = String(format: "%@ %.2f",RsSymbol, orderDetailObj.totalPrice)
			if !self.orderDetailObj.isDeliveryPickup {
				cell.imgDelivery.image = UIImage(named: "ic_pickup")
			}
			cell.selectionStyle = .none
			return cell

		case .Address:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderAddressCell") as! OrderAddressCell
			cell.selectionStyle = .none
			if orderDetailObj.isDeliveryPickup {
				cell.lblTitle.text = "\(orderDetailObj.shippingFullname)\n\(orderDetailObj.shippingContactNo)"
				cell.lblSubTitle.text = "\(orderDetailObj.shippingFullAddress)"

			} else {
				cell.lblTitle.text = "\(orderDetailObj.storeName)"
				cell.lblSubTitle.text = "\(orderDetailObj.pickUpStore)"
			}
			return cell

		case .TrackOrder:
			let cell = tableView.dequeueReusableCell(withIdentifier: "TrackOrderCell") as! TrackOrderCell
			self.configureTrackOrderCell(cell: cell)
			cell.selectionStyle = .none
			return cell

		case .CancelOrder:
			let cell = tableView.dequeueReusableCell(withIdentifier: "CancelOrderCell") as! CancelOrderCell
			self.configureCancelCell(cell: cell)
			cell.selectionStyle = .none
			return cell

		case .OrderItems:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell") as! OrderProductCell
			self.configureItemCell(cell: cell, index: indexPath.row)
			cell.selectionStyle = .none
			return cell
 
		case .AmountSummary:
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderAmountCell") as! OrderAmountCell
			let summaryObj = orderDetailObj.summary[indexPath.row]
			cell.lblTitle.text = summaryObj.title
			cell.lblSubTitle.text = String(format: "%@ %.2f",RsSymbol, summaryObj.value)
			cell.selectionStyle = .none
			return cell

		case .PaymentMethod:
			let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentStatusCell") as! PaymentStatusCell
			cell.lblTitle.text = orderDetailObj.paymentGateway
			//cell.lblSubTitle.text = orderDetailObj.paymentStatus
			cell.selectionStyle = .none
			return cell

		/*default:
			return cell*/
		}

	}


	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		let style = self.arrSection[section].style
		if style == .AmountSummary {
			return 44 * universalWidthRatio
		}
		return CGFloat.leastNormalMagnitude
	}
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let style = self.arrSection[section].style
		if style == .AmountSummary {
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTotalCell") as! OrderTotalCell
			var fr = cell.frame
			fr.size.width = tableView.frame.width
			cell.viewBG.frame = fr
			let summaryObj = orderDetailObj.summary.last!
			cell.lblTitle.text = summaryObj.title
			cell.lblSubTitle.text = String(format: "%@ %.2f",RsSymbol, summaryObj.value)
			cell.viewBG.setRound(corners: [.bottomLeft, .bottomRight], radius: 8.0)
			cell.contentView.layoutIfNeeded()
			return cell.contentView
		}
		return nil
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let style = self.arrSection[section].style
		if style == .AmountSummary {
			return 44 * universalWidthRatio
		}
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let style = self.arrSection[section].style
		if style == .AmountSummary {
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderSummaryCell") as! OrderSummaryCell
			var fr = cell.frame
			fr.size.width = tableView.frame.width
			cell.viewBG.frame = fr

			cell.viewBG.setRound(corners: [.topLeft, .topRight], radius: 8.0)
			cell.contentView.layoutIfNeeded()

			return cell.contentView
		}
		return nil

	}

	func configureItemCell(cell:OrderProductCell, index:Int)   {
		let orderItem = orderDetailObj.productList[index]
		cell.btnCancelItem.tag = index
		if !self.orderDetailObj.isCancelable {
			cell.btnCancelItem.isHidden = true
		}
		cell.lblTitle.text = orderItem.productName
		cell.lblSubTitle.text = String(format: "%@ %.2f",RsSymbol, orderItem.productPrice)
		cell.lblQty.text = orderItem.orderQuantity.ToString()
		cell.lblSize.text = orderItem.size
		let imgUrl = getImageUrlWithSize(urlString: orderItem.productImage, size: cell.frame.size)
		cell.imgView.setImage(url: imgUrl)
	}

	func configureCancelCell(cell:CancelOrderCell)   {
		let startDate = serverDateFormator.date(from: orderDetailObj.orderPlacedDate)
		cell.lblDate1.text = dateFormator.string(from: startDate!)

		let cancelDate = serverDateFormator.date(from: orderDetailObj.cancelDate!)
		cell.lblDate2.text = cancelDate != nil ? dateFormator.string(from: cancelDate!) : ""

		cell.lblStatus1.text = "Order placed"
		cell.lblStatus2.text = "Order cancelled"

	}

	func configureTrackOrderCell(cell:TrackOrderCell)   {

		let startDate = serverDateFormator.date(from: orderDetailObj.orderPlacedDate)
		cell.lblDate1.text = dateFormator.string(from: startDate!)

		let ship_pickup_Date = orderDetailObj.isDeliveryPickup ? serverDateFormator.date(from: orderDetailObj.orderShippingDate!) : serverDateFormator.date(from: orderDetailObj.deliveryPickupDate!)

		cell.lblDate2.text = ship_pickup_Date != nil ? dateFormator.string(from: ship_pickup_Date!) : ""

		let completeDate = serverDateFormator.date(from: orderDetailObj.orderCompleteDate!)
		cell.lblDate3.text = completeDate != nil ? dateFormator.string(from: completeDate!) : ""

		cell.lblStatus1.text = "Order placed"
		cell.lblStatus2.text = orderDetailObj.isDeliveryPickup ? "Order shipped" : "Ready to pickup"
		cell.lblStatus3.text = "Order completed"

		switch orderDetailObj.orderStatusId {
		case OrderStatus.completed:
			cell.viewPoint2.backgroundColor = UIColor.green
			cell.viewPoint3.backgroundColor = UIColor.green
			cell.viewLine1.backgroundColor = UIColor.green
			cell.viewLine2.backgroundColor = UIColor.green

		case OrderStatus.shipped_pickup:
			cell.viewPoint2.backgroundColor = UIColor.green
			cell.viewLine1.backgroundColor = UIColor.green

		default:
			break

		}

	}
	
}

extension OrderDetailVC {

	@IBAction func btnCancel_Item_Clicked(sender:UIButton)  {

		/*ReturnBox.showReturnBox(in: self, sourceFrame: self.view.frame,viewDisplayType: .cancelItem) { obje in
			//print("return id =>", obje["CancelReasonId"]!)
			//print("textViewReason text is =>", obje["Remarks"]!)
			/*var param = obje
			param["OrderID"] = orderObj.orderId
			wsCall.cancelOrder(params: param, block: { (response) in
				if response.isSuccess {
					if let json = response.json as? [[String:Any]] {
						let orderObj = MyOrder(json[0])
						self.arrOrder[sender.tag] = orderObj
						let indexPath = NSIndexPath(row: sender.tag, section: 0)
						self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)
					}
				}
			})*/
		}*/

		let cancelItemView = CancelItemView.instanceFromNib()
		cancelItemView.currentItem = self.orderDetailObj.productList[sender.tag] as MyOrderProduct
		cancelItemView.actionBlock = self.cancelItemCallbackAction
		self.view.addSubview(cancelItemView)
		cancelItemView.showWithAnimation()

	}

}

extension OrderDetailVC {
	// Api calls

	func GetOrderList()  {

		let paramDict = ["OrderId":self.orderId]
		self.showCentralGraySpinner()
		wsCall.getMyOrderList(params: paramDict) { (response) in
			if response.isSuccess {
				if let json = response.json as? [[String:Any]] {
					print("json called")
					if json.count > 0 {
						self.orderDetailObj = MyOrder(json[0])
						self.configureSectionArray()
					}
				}
			}
			self.hideCentralGraySpinner()
		}
	}
}
