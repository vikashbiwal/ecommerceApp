//
//  OfferInfoDetailVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 03/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol OfferDetailVCDelegate : class{
    
    func moveToNextScreen(productId: String, apiparam: String ,title: String)
    
}


class OfferInfoDetailVC: ParentViewController{
    
    @IBOutlet weak var lblOfferTtile: WidthLabel!
    var productOfferObj: Offer!
    
    weak var delegate: OfferDetailVCDelegate?
    
    @IBOutlet weak var containerView: UIView!
    var arrOfferDetail: [[String:Any]] = []
    
    @IBOutlet weak var tblOfferDetail: UITableView!
    
    @IBOutlet weak var viewBottomConst: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBottomConst.constant = -567*universalWidthRatio
        
        self.view.backgroundColor = UIColor.clear
        
        print("product offer object:\(productOfferObj.offerTitle)")
        
        if !productOfferObj.offerTitle.isEmpty {
           
            lblOfferTtile.text = productOfferObj.offerTitle
          
        }
        
        
       if !productOfferObj.offerCode.isEmpty {
        
        arrOfferDetail.append(["OfferTitle":"Offer Code: ", "offerDetail":productOfferObj.offerCode])
        }
        
        if !productOfferObj.offerDesc.isEmpty {
            
            arrOfferDetail.append(["OfferTitle":"Description: ", "offerDescription":productOfferObj.offerDesc])
        }

        
        if !productOfferObj.weekDays.isEmpty {
            
           let arrDaysId = productOfferObj.weekDays.components(separatedBy: ",")
            
            var arrDays: [String] = []
            
            for strId in arrDaysId {
                
               let strDayId = self.dayName(fromDayId: Int(strId)!)
                
                arrDays.append(strDayId)
                
            }
            
            if arrDays.count > 6 {
                arrOfferDetail.append(["OfferTitle":"Applicable On: ", "offerDetail":"All Days"])
                
            }else{
                var strDays = ""
                
                strDays += (arrDays as NSArray).componentsJoined(by: ",")
                arrOfferDetail.append(["OfferTitle":"Applicable On: ", "offerDetail":strDays])
                
            }
            
           
        }else{
             arrOfferDetail.append(["OfferTitle":"Applicable On: ", "offerDetail":"All Days"])
        }
        
        
        if !productOfferObj.startTime.isEmpty && !productOfferObj.endTime.isEmpty{
            
            
            if productOfferObj.startTime != "00:00:00" && productOfferObj.endTime != "00:00:00" {
                
                let arrStartTime = productOfferObj.startTime.components(separatedBy: ":")
                let arrEndTime = productOfferObj.endTime.components(separatedBy: ":")
                
                arrOfferDetail.append(["OfferTitle":"Happy Hour: ", "offerDetail":String(format: "%@ To %@",String(format: "%@:%@", arrStartTime[0],arrStartTime[1]),String(format: "%@:%@", arrEndTime[0],arrEndTime[1]))])
            }
            
            
        }
        
        if productOfferObj.entityCriateria.count != 0 {
            
            for offerEntityCriteria in productOfferObj.entityCriateria {
                
                 arrOfferDetail.append(["OfferTitle":offerEntityCriteria.entityType.appending(":"), "offerDetail":offerEntityCriteria.entityValue])
                
            }

        }
        
        
        if !productOfferObj.endDate.isEmpty{
           
            let dateF = DateFormatter()
            dateF.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let firstDate = dateF.date(from: productOfferObj.endDate)
            dateF.dateFormat = "dd-MMM-yyyy"
            let newDateString = dateF.string(from: firstDate!)
            
            arrOfferDetail.append(["OfferTitle":"Valid up to: ", "offerDetail":String(format: "%@", newDateString)])
        }
        
        
        if productOfferObj.criteria.count != 0 {
            
            print("productOfferObj.criteria.count\(productOfferObj.criteria.count)")
            
            var strCriteria = ""
            
            let bulletPoint: String = "\u{2022}"
            
            for (index,offerCriteria) in productOfferObj.criteria.enumerated() {
                print("\(index) = \(offerCriteria.message)")
                
                if index == 0 {
                    
                    strCriteria = strCriteria.appending("Criteria: \n\(bulletPoint) \(offerCriteria.message)\n")
                }else{
                    
                    if index == productOfferObj.criteria.count-1 {
                        
                        strCriteria = strCriteria.appending("\(bulletPoint) \(offerCriteria.message)")
                    }else{
                        strCriteria = strCriteria.appending("\(bulletPoint) \(offerCriteria.message)\n")
                    }
                    
                    
                }
            }
            
            
//            for offerCriteria in productOfferObj.criteria {
//                
//            strCriteria = strCriteria.appending("\(offerCriteria.message)\n\(bulletPoint) ")
//                
//            }
//            
//            print("strCriteria:\(strCriteria)")
            
            
            arrOfferDetail.append(["OfferTitle":"Criteria: ", "offerDetail":strCriteria])
            
        }
        
        containerView.drawShadow(0.7, offSet: CGSize(width: 0, height: 0) )
        
        containerView.layer.zPosition = 20
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            if(IS_IPAD){
                self.viewBottomConst.constant = self.view.frame.height/3
                
            }else{
                self.viewBottomConst.constant = 55
            }
            
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            self.view.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    @IBAction func btnApplyPromoClicked(_ sender: Any) {
        
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
                self.viewBottomConst.constant = -567*universalWidthRatio
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                self.view.layoutIfNeeded()
            }) { (success) in
                self.dismiss(animated: false, completion: { () -> Void in
                    
                    self.delegate?.moveToNextScreen(productId: self.productOfferObj.productId, apiparam: self.productOfferObj.apiParam, title: self.productOfferObj.offerTitle)
                    
                    
                })
            }
                    
        
    }
    
     //MARK: bold with regular in single label method
    
    func labelWithDiffStyleFont(startRange: Int, endRange: Int, stringValue: String, cell: offerDetailCell) ->  NSMutableAttributedString {
        
        let myMutableString = NSMutableAttributedString(
            string: stringValue,
            attributes: [:])
        
        myMutableString.setAttributes([NSFontAttributeName : UIFont(name: FontName.SANSBOLD, size: (cell.lblOfferTitle.font.pointSize)) ?? UIFont()], range: NSRange(location:startRange,length:endRange))
        
        return myMutableString
        
    }

    //MARK: applicable days method

    
    func dayName(fromDayId dayID: Int) -> String {
        var dayName: String = ""
        switch dayID {
        case 0:
            dayName = "Sunday"
            break
        case 1:
            dayName = "Monday"
            break
        case 2:
            dayName = "Tuesday"
            break
        case 3:
            dayName = "Wednesday"
            break
        case 4:
            dayName = "Thursday"
            break
        case 5:
            dayName = "Friday"
            break
        case 6:
            dayName = "Saturday"
            break
        default:
                break
            
        }
     
        return dayName
    }
    
     //MARK: button close clicked
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            self.viewBottomConst.constant = -567*universalWidthRatio
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.dismiss(animated: false, completion: nil)
        }
    }

   

}

extension OfferInfoDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    //MARK: TABLEVIEW DELEGATE AND DATASOURCE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrOfferDetail.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 33
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
            let cellIdentifier = "offerDetailCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! offerDetailCell
            
            let dic = arrOfferDetail[indexPath.section]
        
        
        if indexPath.section == 1  {
            
            if dic["offerDescription"] != nil {
                
                cell.lblOfferDetail.text = dic["offerDescription"] as? String
                cell.lblOfferDetail.textColor = UIColor.darkGray
            }else{
                
                cell.lblOfferTitle.text = dic["OfferTitle"] as? String
                
                cell.lblOfferDetail.text = dic["offerDetail"] as? String
            }
            
        }else{
            
            if dic["OfferTitle"] as! String == "Criteria: "{
                
                let strOfferTitle: NSString = dic["offerDetail"] as! String as NSString
                
                let attributedString = NSMutableAttributedString(string: strOfferTitle as String, attributes: [NSFontAttributeName: UIFont(name: FontName.REGULARSTYLE1, size: (16 * universalWidthRatio)) ?? UIFont()])
                
                let boldFontAttribute = [NSFontAttributeName: UIFont(name: FontName.SANSBOLD, size: (16 * universalWidthRatio)) ?? UIFont()]
                
                attributedString.addAttributes(boldFontAttribute, range: strOfferTitle.range(of: "Criteria:"))
                
                cell.lblOfferDetail.attributedText = attributedString
                
            }else{
            
                cell.lblOfferTitle.text = dic["OfferTitle"] as? String
                
                cell.lblOfferDetail.text =  dic["offerDetail"] as? String
            }
            
            
        }
        
        
        
        return cell

        
        
    }

}

//MARK: offer detail cell


class offerDetailCell: UITableViewCell {
    
    
    @IBOutlet weak var lblSeparator: UILabel!
    
    @IBOutlet weak var lblOfferTitle: WidthLabel!
    
    @IBOutlet weak var lblOfferDetail: WidthLabel!
    
    @IBOutlet weak var lblOfferSecondaryDetail: WidthLabel!
}
