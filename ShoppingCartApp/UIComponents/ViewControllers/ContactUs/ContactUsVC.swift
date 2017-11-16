//
//  ContactUsVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 24/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class ContactUsVC: ParentViewController {
    
    @IBOutlet weak var tblContactUs: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        

        // Do any additional setup after loading the view.
    }
    @IBAction func btnEmailAddressPressed(_ sender: UIButton) {
        
        let indexPath = NSIndexPath(row: 0, section: 0) //wallet
        
        let cell = self.tblContactUs.cellForRow(at: indexPath as IndexPath) as? contactUsAddressCell
        
        
        openEmail((cell?.lblEmail.text)!, subject: "", messageBody: "", controller: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension ContactUsVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
    // MARK: tableview delegate and datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        if !checkUserLoggedIn() {
//            
//            return 2
//        }else{
            return 2
       // }

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return 1
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect (x:0, y: 0, width:10, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
        
        
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {

            return UITableViewAutomaticDimension
        }else if indexPath.section == 1{
            return 250
        }else{
            return 50
        }
    
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            return 161
        }else if indexPath.section == 1{
            return 250
        }else{
            return 50
        }
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
       if indexPath.section == 0 {
            let cellIdentifier = "contactUsAddressCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! contactUsAddressCell
        
            return cell
            
       }else if indexPath.section == 1{
        
        let cellIdentifier = "mapCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! mapCell
        
            return cell

       }else if indexPath.section == 2{
        
        let cellIdentifier = "FeedbackCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FeedbackCell
        
        return cell
        
       }else{
        
        let cellIdentifier = "inquiryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! inquiryCell
        
        return cell
        }
        
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if indexPath.section == 2 {
            
                if !checkUserLoggedIn() {
                    if let loginVC = storyboardLogin.instantiateViewController(withIdentifier: "SBID_loginNav") as? UINavigationController {
                        let presentingVC = self.tabBarController ?? self
                        presentingVC.present(loginVC, animated: true, completion: nil)
                    }
                } else {
                    
//                    let controller = storyboardcontactUs.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
//                    self.present(controller, animated: true, completion: nil)
                    
                    let controller = storyboardFeedbackInquiry.instantiateViewController(withIdentifier: "FeedbackInquiryVC") as! FeedbackInquiryVC
                    self.navigationController?.pushViewController(controller, animated: true)
                }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }


}

class contactUsAddressCell: UITableViewCell {
    
    @IBOutlet weak var lblEmail: WidthLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
        self.drawShadow(0.05)
        
    }
    
    
}

class mapCell: UITableViewCell {
    
    @IBOutlet weak var addressMapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
        self.drawShadow(0.05)
        
        addressMapView.mapType = MKMapType.standard
        
        addressMapView.isUserInteractionEnabled = false
        
        // 2)
        let location = CLLocationCoordinate2D(latitude: 23.0227,longitude: 72.5709)
        
        // 3)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        addressMapView.setRegion(region, animated: true)
        
        // 4)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Retail Store"
        annotation.subtitle = "Ahmedabad"
        addressMapView.addAnnotation(annotation)
        _ = [addressMapView .selectAnnotation(annotation, animated: true)]
        
    }

    
}


class FeedbackCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
        self.drawShadow(0.05)
        
    }

}

class inquiryCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
        self.drawShadow(0.05)
        
    }
    
}
