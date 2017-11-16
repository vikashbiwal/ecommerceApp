//
//  OfferVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 29/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import UIImageColors




class OfferVC: ParentViewController, OfferDetailVCDelegate{

    @IBOutlet weak var tblOffer: UITableView!
    
    var strApiParam:String = ""
    
    var arrOffers = [Offer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarView.drawShadow()
        
        self.getOffers()

        tblOffer.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        
    }
    
   
    // MARK - back to home screen
    
    @IBAction func btnBackToHomeScreenPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    // MARK - button Offer info clicked
    
    @IBAction func btnOfferInfoClicked(_ sender: UIButton) {
        
        let offerInfoDetailVC = storyboardOffer.instantiateViewController(withIdentifier: "OfferInfoDetailVC") as! OfferInfoDetailVC
        offerInfoDetailVC.productOfferObj = self.arrOffers[sender.tag]
        offerInfoDetailVC.modalPresentationStyle = .overFullScreen
        offerInfoDetailVC.delegate = self
        self.present(offerInfoDetailVC, animated: false, completion: nil)
        
    }
    
    // MARK - Move To Next Screen
    
    func moveToNextScreen(productId: String, apiparam: String , title: String){
        
        if productId == "0" {
            
            let productvc = self.storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
            productvc.apiParam = apiparam
            productvc.navigationTitle = title
            self.navigationController?.pushViewController(productvc, animated: true)

            
        }else{
            let productdetailvc = self.storyboardProductDetail.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            self.navigationController?.pushViewController(productdetailvc, animated: true)
        }
    }

}



// MARK: - Tableview Delegate and DataSource

extension OfferVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return arrOffers.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "OfferCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! OfferTblCell
                
        let offer = self.arrOffers[indexPath.row]
        cell.btnInfo.tag = indexPath.row
        
        if !offer.offerBanner.isEmpty {
            
            let imgUrl = getImageUrlWithSize(urlString: (offer.offerBanner), size:  cell.imgView.frame.size)
            
            print("imgUrl:\(imgUrl)")
            
            cell.imgView.setImage(url: imgUrl, placeholder: UIImage(), completion: {
                (img) in
                
                if let image = img {
                    cell.imgView.image = image
                    cell.setInfoTintColor()
                    
                }
            })
        }
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150 * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let offer = self.arrOffers[indexPath.row]
        
        self.moveToNextScreen(productId: offer.productId, apiparam: offer.apiParam, title: offer.offerTitle)
    }
    
}


// MARK: - get offers api call

extension OfferVC{
    
    func getOffers() {
        
        self.showCentralGraySpinner()
        
        wsCall.getOffers(params: nil) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    
                    print("offers response is => \(json)")
                    
                    self.hideCentralGraySpinner()
                    
                    self.arrOffers = json.map({ (object) -> Offer in
                    
                    return Offer(object)
                        
                    }).filter({ (po) -> Bool in
                        
                    return !po.isFlashOffer && po.isActive
                        
                    })
                    
                    if self.arrOffers.count > 0{
                        removeNoResultFoundImage(fromView: self.view)
                        self.tblOffer.isHidden = false
                        self.tblOffer.reloadData()
                    }else{
                       self.tblOffer.isHidden = true
                        removeNoResultFoundImage(fromView: self.view)
                        showNoResultFoundImage(onView: self.view,withText : "No Offer Found!")
                    }
                    
                    
                    
                }
            }
            
        }
        
    }
}


//
class OfferTblCell: TableViewCell {
    @IBOutlet var btnInfo: UIButton!
    
    func setOffer(offer: Offer) {
        if !offer.offerBanner.isEmpty {
            
            let imgUrl = getImageUrlWithSize(urlString: (offer.offerBanner), size:  self.imgView.frame.size)
            
            print("imgUrl:\(imgUrl)")
            
            self.imgView.setImage(url: imgUrl, placeholder: UIImage(), completion: {
                (img) in
                
                if let image = img {
                    self.imgView.image = image
                    self.setInfoTintColor()
                }
            })
        }

    }
    
    func setInfoTintColor() {
        self.imgView.image?.getColors(completionHandler: { (colors) in
            self.btnInfo.tintColor = colors.secondary
        })
    }

}
