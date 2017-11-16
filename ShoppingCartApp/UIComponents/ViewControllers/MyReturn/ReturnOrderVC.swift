//
//  ReturnOrderVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 17/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

enum ReturnOrderType {
	case returnOrder
	case cancelOrder
	case cancelItem
}


typealias ReturnBox = ReturnOrderVC
extension ReturnBox {
    //for showing pop used this func.
	class func showReturnBox(in vc: ParentViewController, sourceFrame: CGRect,viewDisplayType: ReturnOrderType, completionBlock: (([String:Any])->Void)? = nil) {
        let returnVC = vc.storyboardMyReturn.instantiateViewController(withIdentifier: "ReturnOrderVC") as! ReturnOrderVC
        returnVC.viewType = viewDisplayType
        returnVC.modalPresentationStyle = IS_IPAD ? .popover : .overCurrentContext
        returnVC.popoverPresentationController?.sourceView  = vc.view
        returnVC.popoverPresentationController?.sourceRect = sourceFrame
        returnVC.completionBlock = completionBlock
        let presentingVC = vc.tabBarController ?? vc
        presentingVC.present(returnVC, animated: IS_IPAD, completion: nil)
    }
}



class ReturnOrderVC: ParentViewController {
    
    @IBOutlet weak var returnView: ReturnOrderView!
    @IBOutlet weak var listViewVRCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var listWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var listHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topConstraintOfQty: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfQty: NSLayoutConstraint!
    @IBOutlet weak var topConstraintForReason: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!
    
	var completionBlock: (([String:Any])->Void)?
    var isKeyBoardOpen : Bool = false
    var isFromCancelOrder1 : Bool = false
	var viewType:ReturnOrderType = .cancelOrder
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if !IS_IPAD {
            listViewVRCenterConstraint.constant = self.view.center.y + self.returnView.frame.height
            self.view.alpha = 0
        }
		setupViewAndDataArray()

    }

	func setupViewAndDataArray()  {

		switch viewType {
		case ReturnOrderType.cancelOrder:
			topConstraintOfQty.constant = 0
			heightConstraintOfQty.constant = 0
			topConstraintForReason.constant = 8
			returnView.btnQty.isHidden = true
			returnView.title = "Cancel Order"
			setCancelOrderArray()
			
		case ReturnOrderType.cancelItem:
			topConstraintOfQty.constant = 8
			heightConstraintOfQty.constant = 24
			topConstraintForReason.constant = 15
			returnView.btnQty.isHidden = false
			returnView.title = "Cancel Item"
			returnView.maxQty = 10
			setCancelOrderArray()

		case ReturnOrderType.returnOrder:
			topConstraintOfQty.constant = 8
			heightConstraintOfQty.constant = 24
			topConstraintForReason.constant = 15
			returnView.btnQty.isHidden = false
			returnView.maxQty = 10
			setReturnOrderArray()

		}
  
		/*if isFromCancelOrder1{
			topConstraintOfQty.constant = 0
			heightConstraintOfQty.constant = 0
			topConstraintForReason.constant = 8
			returnView.btnQty.isHidden = true
			setCancelOrderArray()

		} else {
			topConstraintOfQty.constant = 8
			heightConstraintOfQty.constant = 24
			topConstraintForReason.constant = 15
			returnView.btnQty.isHidden = false
			setReturnOrderArray()
		}*/
	}

	func setCancelOrderArray()  {

		var reasonArray = [[String:Any]]()
		reasonArray.append(["orderReturnId":9, "Reason": "My order is still not accepted."])
		reasonArray.append(["orderReturnId":10, "Reason": "I found better product on your App."])
		reasonArray.append(["orderReturnId":11, "Reason": "I found better price on other App."])
		reasonArray.append(["orderReturnId":12, "Reason":"Other"])
		returnView.arrReturnOrderReason = reasonArray
		returnView.orderReturnID = "0"

	}

	func setReturnOrderArray()  {

		var reasonArray = [[String:Any]]()
		reasonArray.append(["orderReturnId":13, "Reason": "Item is damaged or broken"])
		reasonArray.append(["orderReturnId":14, "Reason": "Item is expired"])
		reasonArray.append(["orderReturnId":15, "Reason": "Item is missing"])
		reasonArray.append(["orderReturnId":16, "Reason":"Wrong item is delivered"])
		reasonArray.append(["orderReturnId":17, "Reason":"Item is not same as described on site"])
		reasonArray.append(["orderReturnId":18, "Reason":"Other"])
		returnView.arrReturnOrderReason = reasonArray
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !IS_IPAD {
            showList()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUI()
    }
    
    //Set Initial UI
    func setUI() {
        if IS_IPAD {
            listWidthConstraint.constant = self.view.frame.width
            listHeightConstraint.constant = self.view.frame.height
            self.view.drawShadow(0.8)
        }  else {
            listWidthConstraint.constant = 300 
            listHeightConstraint.constant =   330 
        }
        containerView.frame = self.view.bounds
        tableView.contentSize = self.view.frame.size
    }
    
}


//MARK:- Show hide animation for return view
extension ReturnOrderVC {
    //Show with animation
    func showList() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7, options: [.curveEaseOut
                        
            ], animations:
            {
                self.listViewVRCenterConstraint.constant = 0
                self.view.backgroundColor = UIColor.black.alpha(0.4)
                self.view.alpha = 1
                self.view.layoutIfNeeded()
        })
    }
    
    //Hide with animation
    func hideList() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.9, options: [.curveEaseInOut], animations:
            {
                self.listViewVRCenterConstraint.constant = self.view.center.y + self.returnView.frame.height
                self.view.backgroundColor = UIColor.clear
                self.view.alpha = 0
                self.view.layoutIfNeeded()
        }) {success in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}


//MARK:- IBActions
extension ReturnOrderVC {
    //Close button action
    @IBAction func close1_btnClicked(_ sender: UIButton?) {
        if !IS_IPAD {
            hideList()
        }
    }
    
    //this action call by tapping on select or unSelect button in side the cell.
    
    @IBAction func btnSubmitClicked(_sender: UIButton?){
		print("btnSubmitClicked")
		//print("return id =>", self.returnView.orderReturnID)
		//print("textViewReason text is =>", self.returnView.textViewReason.text)


		switch viewType {
		case ReturnOrderType.cancelOrder:
			self.proceedCancelOrder()
			
		case ReturnOrderType.cancelItem:
			print("ReturnOrderType.cancelItem:")

		case ReturnOrderType.returnOrder:
			print("ReturnOrderType.returnOrder:")
		}

    }

	func proceedCancelOrder()  {
		let returnId = Converter.toInt(self.returnView.orderReturnID)

		switch returnId {
		case 0:
			KVAlertView.show(message: "Please select reason.")
			return
		case 12:
			let trimmedString = self.returnView.textViewReason.text.trimmingCharacters(in: .whitespacesAndNewlines)
			if trimmedString.characters.count == 0 {
				KVAlertView.show(message: "Please enter reason.")
				return
			} else {
				self.dismissCancelOrderView()
			}
		default:
			self.dismissCancelOrderView()

		}
	}

	func dismissCancelOrderView()  {
		let dict  = ["CancelReasonId":self.returnView.orderReturnID,"Remarks":self.returnView.textViewReason.text] as [String : Any]
		completionBlock!(dict)
		self.dismiss(animated: true, completion: nil)
	}
    
}

extension ReturnOrderVC:UIKeyboardObserver{
    func keyboardWillShow(nf: NSNotification) {
        if let kFrame = nf.userInfo?[UIKeyboardFrameEndUserInfoKey] {
            if let kf = kFrame as? CGRect {
                tableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: kf.height, right: 0)
                if !isKeyBoardOpen{
                    returnView.frame.origin.y -= 120
                    isKeyBoardOpen = true
                }
            }
        }
    }
    
    func keyboardWillHide(nf: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 170, left: 0, bottom: 0, right: 0)
        if isKeyBoardOpen{
           returnView.frame.origin.y += 120
            isKeyBoardOpen = false
        }
        
    }
}

