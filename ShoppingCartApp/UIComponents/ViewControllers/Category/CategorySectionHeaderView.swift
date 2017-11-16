//
//  CategorySectionHeaderView.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 04/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol CategorySectionHeaderDelegate: class{
    func didAddItem(section:Int)
    func removeItem(section:Int)
}

extension CategorySectionHeaderDelegate{
    func didAddItem(section:Int){}
    func removeItem(section:Int){}
}
class CategorySectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var hideLabelBottomConstraint : NSLayoutConstraint!
    weak var delegate:CategorySectionHeaderDelegate?
    var sectionIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func btnCategorySectionClicked(sender:UIButton){
        delegate?.didAddItem(section: sectionIndex)
    }
    
    func stepperViewOpen() {
       // self.lblTitle.isHidden = true
       // self.hideLabelBottomConstraint.constant = 5

//        UIView.animate(withDuration: 0.5, animations: {
//            self.layoutIfNeeded()
//        }, completion: { (finish) in
//            println("opener isFinish \(finish)")
//        })
    }
    
    func stepperViewClose() {
        //self.lblTitle.isHidden = false
        //self.hideLabelBottomConstraint.constant = 37

//        UIView.animate(withDuration: 0.5, animations: {
//            self.layoutIfNeeded()
//        }, completion: { (finish) in
//            println("closing isFinish \(finish)")
//        })
        
    }

}
