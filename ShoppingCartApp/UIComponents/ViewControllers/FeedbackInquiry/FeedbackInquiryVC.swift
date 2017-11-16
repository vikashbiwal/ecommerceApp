//
//  FeedbackInquiryVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 20/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Foundation


class FeedbackInquiryVC: ParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)

        // Do any additional setup after loading the view.
    }
    
    // MARK:- btn back pressed
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

    // MARK:- btn add feedback inquiry pressed
    
    
    @IBAction func btnAddFeedbackInquiryPressed(_ sender: UIButton) {
        
        let controller = storyboardFeedbackInquiry.instantiateViewController(withIdentifier: "AddFeedbackInquiryVC") as! AddFeedbackInquiryVC
        self.present(controller, animated: true, completion: nil)
    }


}

extension FeedbackInquiryVC : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackInquiryCell") as! FeedbackInquiryCell
        
        
        if indexPath.row == 1 {
            //cell.lblTopicWithTitle.text = "What is Product."
            let yourAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)]
            let yourOtherAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            
            let partOne = NSMutableAttributedString(string: "[This is an example] ", attributes: yourAttributes)
            let partTwo = NSMutableAttributedString(string: "for the combination of Attributed String!", attributes: yourOtherAttributes)
            
            let combination = NSMutableAttributedString()
            
            combination.append(partOne)
            combination.append(partTwo)
            
            cell.lblTopicWithTitle.attributedText = combination
            
        }else if indexPath.row == 2{
            cell.lblTopicWithTitle.text = "What is Product feedback."
        }else if indexPath.row == 3{
            cell.lblTopicWithTitle.text = "What is Product feedback inquiry."
        }else if indexPath.row == 4{
            cell.lblTopicWithTitle.text = "What is Product feedback inquiry.What is Product feedback inquiry."
        }else if indexPath.row == 5{
            cell.lblTopicWithTitle.text = "What is Product feedback inquiry.What is Product feedback inquiry.What is Product feedback inquiry."
        }else if indexPath.row == 6{
            cell.lblTopicWithTitle.text = "What is Product feedback inquiry."
        }else if indexPath.row == 7{
            cell.lblTopicWithTitle.text = "What is Product feedback inquiry.What is Product feedback inquiry."
        }else if indexPath.row == 8{
            cell.lblTopicWithTitle.text = "What is Product."
        }else if indexPath.row == 9{
            cell.lblTopicWithTitle.text = "What is Product feedback."
        }
       
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.rowHeight
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }

    
    
}


 // MARK: - Feedback Inquiry Cell

class FeedbackInquiryCell: UITableViewCell {
    
    @IBOutlet weak var lblTopicWithTitle: Style1WidthLabel!
    @IBOutlet weak var lblDate: Style1WidthLabel!
    @IBOutlet weak var lblComment: Style1WidthLabel!
    
}


