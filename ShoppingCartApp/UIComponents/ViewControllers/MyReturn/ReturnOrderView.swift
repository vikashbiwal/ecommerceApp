//
//  ReturnOrderView.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 18/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ReturnOrderView: UIView,UITextViewDelegate {

    @IBOutlet var btnQty : BorderButton!
    @IBOutlet var headerView : UIView!
    @IBOutlet var btnSelectReason : BorderButton!
    @IBOutlet var textViewReason : UITextView!
	@IBOutlet var lblTitle : UILabel!

    var arrReturnOrderReason : [[String:Any]] = []
    var selectedIndexOfReason = ""
    var orderReturnID = ""
	var title = "Return Order" {
		didSet {
			self.lblTitle.text = title
		}
	}
	var maxQty:Int = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.drawShadow(0.7, offSet: CGSize.zero)
        self.layer.zPosition = 10

        
        textViewReason.layer.borderColor = UIColor.init(colorLiteralRed: 78.0/255.0, green: 78.0/255.0, blue: 78.0/255.0, alpha: 1.0).cgColor;
        //textViewReason.layer.borderColor = UIColor.red.cgColor
        textViewReason.layer.borderWidth = 1.0;
        textViewReason.layer.cornerRadius = 5.0;
        
        
        

    }

//MARK: - Quantity button click event -
    @IBAction func btnQtyClicked(sender:UIButton){
        changeQuantity(maxQty: maxQty, sender: sender)
    }
    
    func changeQuantity(maxQty : Int, sender: UIButton) {
        
        let rect =  self.convert(sender.bounds, from: sender)
        
        let listItems = ((1...maxQty).map({"\($0)"}), "3")
        
        DropDownList.show(in: self, listFrame: rect, listData: listItems) { newQty in
            sender.setTitle("Qty : \(newQty)", for: .normal)
        }
    }
    
    
    @IBAction func btnSelectReasonClicked(_sender:UIButton){
        let arrReason = arrReturnOrderReason.map { (obje) -> String in
            return obje["Reason"] as! String
        }
        changeReason(arrReason1: arrReason, sender: _sender)
        
    }
    
    func changeReason(arrReason1 : [String], sender: UIButton) {
        
        var rect =  self.superview!.superview!.superview!.convert(sender.bounds, from: sender)
        rect.origin.y = rect.origin.y 
        
        let listItems = (arrReason1, selectedIndexOfReason)
        
        DropDownList.show(in: self.superview!.superview!.superview!, listFrame: rect, listData: listItems) { reason in
            sender.setTitle(reason, for: .normal)
            if let selectedIndex = arrReason1.index(of: reason){
                self.orderReturnID = String(describing: self.arrReturnOrderReason[selectedIndex]["orderReturnId"]!)
                self.selectedIndexOfReason = String(selectedIndex)
            }
            
        }
        
    }
    
//MARK: - TextView Delegate -
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            self.endEditing(true)
            return false
        }
        
        return true
        
    }
}
