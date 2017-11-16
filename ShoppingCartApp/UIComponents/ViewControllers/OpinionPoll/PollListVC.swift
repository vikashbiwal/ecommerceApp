//
//  PollListVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 06/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class PollListVC: ParentViewController {

	var arrList = [PollList]()
	

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
		getPollList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


extension PollListVC: UITableViewDelegate,UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return arrList.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell") as! PollCell
		let poll = arrList[indexPath.row]
		cell.lblTitle.text = poll.name
		let date = serverDateFormator.date(from: poll.endTime)
		if date != nil  {
			cell.lblSubTitle.text = "Expires on " + dateFormator.string(from: date!)
		} else {
			cell.lblSubTitle.text = ""
		}

		cell.selectionStyle = .none
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		/*if arrList[indexPath.row].isSubmitted {
			KVAlertView.show(message: "You have already submitted this poll.")

		} else {*/
			let pollVC = self.storyboardOpinionPoll.instantiateViewController(withIdentifier: "PollQuestionVC") as! PollQuestionVC
			pollVC.pollListID = arrList[indexPath.row].id
			if arrList[indexPath.row].isSubmitted {
				pollVC.isAlreadySubmitted = true
			}
			self.navigationController?.pushViewController(pollVC, animated: true)

		//}



	}
}

extension PollListVC {

	func getPollList()  {

		self.showCentralGraySpinner()
		wsCall.getPollList(params: nil) { (response) in
			if response.isSuccess {
				if let json = response.json as? [[String:Any]] {
					self.arrList = json.map({ (obj) -> PollList in
						return PollList(obj)
					})
					self.tableView.reloadData()
				}
			}
			self.hideCentralGraySpinner()
		}
	}
	
}



