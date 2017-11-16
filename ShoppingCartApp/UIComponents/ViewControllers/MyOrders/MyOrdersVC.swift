//
//  MyOrdersVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 09/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

enum OrderStatus {
	static var canceled:Int = 4
	static var pending:Int = 1
	static var shipped_pickup:Int = 2
	static var completed:Int = 3
}

class MyOrdersVC: ParentViewController {

	var pageNumber:Int = 1
	var canLoadMore = true
	var arrOrder = [MyOrder]()
	var listActionBlock:((MyOrder,Int) -> Void)!

	func setlistActionBlock() {
		listActionBlock = { [weak self] (order, index) in
			self?.arrOrder[index] = order
			let indexPath = NSIndexPath(row: index, section: 0)
			self?.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.none)

		}

	}

    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
		tableView.estimatedRowHeight = 40
		tableView.rowHeight = UITableViewAutomaticDimension
		self.setlistActionBlock()
		self.GetOrderList()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func btnCancel_Reorder_Clicked(sender:UIButton)  {
		print("sender tag is \(sender.tag)")
		let orderObj = arrOrder[sender.tag]
		if orderObj.orderStatusId != OrderStatus.pending {
			if Cart.shared.cartItems.count > 0 {
				let alert = UIAlertController(title: "Reorder!", message: "Are you sure, you want to discard cart?", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in

				}))
				alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in

				}))
				self.present(alert, animated: true, completion: nil)
			} else {

			}

		} else {
			ReturnBox.showReturnBox(in: self, sourceFrame: self.view.frame, viewDisplayType: .cancelOrder) { obje in
				//print("return id =>", obje["CancelReasonId"]!)
				//print("textViewReason text is =>", obje["Remarks"]!)
				var param = obje
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
				})
			}
		}
	}


}

extension MyOrdersVC: UITableViewDelegate,UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.arrOrder.count
		//return 2
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderCell") as! MyOrderCell
		let order = self.arrOrder[indexPath.row]
		cell.lblOrderId.text = "Order # " + order.displayOrderId
		let date1 = serverDateFormator.date(from: order.orderPlacedDate)
		cell.lbldate.text = dateFormator.string(from: date1!)
		cell.lblAmount.text = String(format: "%@ %.2f",RsSymbol, order.totalPrice)
		cell.lblStatus.text = order.orderStatus
		cell.btnTrackOrder.tag = indexPath.row
		if order.isCancelable {
			cell.btnTrackOrder.setTitle("Cancel order", for: .normal)
			cell.btnTrackOrder.setTitleColor(UIColor.red, for: .normal)
		} else{
			cell.btnTrackOrder.isHidden = true
		}

		switch order.orderStatusId {

		case OrderStatus.completed :
			cell.lblStatus.textColor = UIColor.green
			//cell.btnTrackOrder.setTitle("Reorder", for: .normal)
			//cell.btnTrackOrder.setTitleColor(UIColor.darkGray, for: .normal)

		case OrderStatus.canceled :
			cell.lblStatus.textColor = UIColor.red
			//cell.btnTrackOrder.setTitle("Reorder", for: .normal)
			//cell.btnTrackOrder.setTitleColor(UIColor.darkGray, for: .normal)

		case OrderStatus.pending :
			cell.lblStatus.textColor = UIColor.orange
			//cell.btnTrackOrder.setTitle("Cancel order", for: .normal)
			//cell.btnTrackOrder.setTitleColor(UIColor.red, for: .normal)

		default:
			cell.lblStatus.textColor = UIColor.orange
			//cell.btnTrackOrder.setTitle("Reorder", for: .normal)
			//cell.btnTrackOrder.setTitleColor(UIColor.darkGray, for: .normal)
		}

		if self.canLoadMore && indexPath.row == self.arrOrder.count-1 {
			self.GetOrderList()
		}
		cell.selectionStyle = .none
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let orderDetailVC = storyboardMyOrders.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
		orderDetailVC.orderDetailObj = self.arrOrder[indexPath.row]
		orderDetailVC.previousIndex = indexPath.row
		orderDetailVC.listActionBlock = listActionBlock
		self.navigationController?.pushViewController(orderDetailVC, animated: true)

	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
}

extension MyOrdersVC {

	func getApiParams() -> [String:Any]  {
		var paramDict = [String:Any]()
		paramDict["OrderId"] = "0"
		paramDict["PageNumber"] = pageNumber
		paramDict["PageSize"] = COUNTPERPAGE
		paramDict["StatusId"] = "0"
		return paramDict
	}

	func GetOrderList()  {

		self.showCentralGraySpinner()
		wsCall.getMyOrderList(params: self.getApiParams()) { (response) in
			if response.isSuccess {
				if let json = response.json as? [[String:Any]] {
					let array = json.map({ (obj) -> MyOrder in
						return MyOrder(obj)
					})
					if  array.count == COUNTPERPAGE {
						self.canLoadMore = true
						self.pageNumber = self.pageNumber + 1
					} else {
						self.canLoadMore = false
					}
					self.arrOrder.append(contentsOf: array)
					self.tableView.reloadData()

				}
			}
			self.hideCentralGraySpinner()
		}
	}
}
