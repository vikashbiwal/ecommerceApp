//
//  NewThankyouVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 8/21/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation

let kAddressCellReuse = "addressCell"
let kItemCellReuse = "itemCell"
let ksummaryCellReuse = "summaryCell"

let kThankyouScreen =  "thankyouScreen"

class orderSummary {
    var title = ""
    var amount = ""
    
    init(_ Title : String, _ Amount : String ) {
        title = Title
        amount = Amount
    }
}

class NewThankyouVC: ParentViewController  {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    
   
    
  
    @IBOutlet weak var lblAddressTitle: UILabel!
    
    var placeOrderResponse = [String : Any]()
    
    //it is used for placeorder - current order
    var currentOrder = Order()
    var summaries = [orderSummary]()
    var fulladdress = ""
    
    
    var orderDetailObj = MyOrder() {
        didSet {
            let array =	orderDetailObj.summary.sorted(by: { $0.sortOrder < $1.sortOrder })
            orderDetailObj.summary = array
            getOrderSummary()
            collectionview.reloadSections(NSIndexSet(index: 2) as IndexSet)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationBarView.drawShadow()
        self.tabBarController?.tabBar.isHidden = true
        GetOrderDetails()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fulladdress = currentOrder.selectedAddress.fullAddress
      //  getOrderSummary()
        
        //clear cart
        if currentOrder.paymentGateway == "COD" {
            clearCart()
        }
       
    }
    func clearCart() {
        wsCall.removeAllFromCart(params: nil) { (response) in
             Cart.shared.removeAll()
                
        }
    }
    func getOrderSummary() {
        
        
        let plusStr = RsSymbol + " "  //"+" + RsSymbol + " "
        let minusStr = "-" + RsSymbol + " "
        
        for summaryObj in orderDetailObj.summary {
           // let displayedValue = orderDetailObj.paymentGateway == "Cash on delivery" ? Converter.toString(summaryObj.value.rounded()) : Converter.toString(summaryObj.value)
            
            let displayedValue = Converter.toString(String(format: "%.2f",summaryObj.value))
            
            if summaryObj.title == "Discount" || summaryObj.title == "Paid by Wallet" {
                 summaries.append(orderSummary(summaryObj.title,minusStr + displayedValue))
            }
            else{
                summaries.append(orderSummary(summaryObj.title,plusStr + displayedValue))
            }
            
        }
        
       
    }
    
    func getOrderSummaryFromLocalData() {
        
        var amountpaid = 0.0
        
        let plusStr = RsSymbol + " "  //"+" + RsSymbol + " "
        let minusStr = "-" + RsSymbol + " "
        
        let itemtotal = currentOrder.paymentGateway == "COD" ? Converter.toString(currentOrder.price.rounded()) : Converter.toString(currentOrder.price)
        

        summaries.append(orderSummary("Total",RsSymbol + itemtotal))
        
        amountpaid += Converter.toDouble(itemtotal)
        
        
        if Cart.shared.totalCartDiscount.rounded() > 0 {
            let discount = currentOrder.paymentGateway == "COD" ? Converter.toString(Cart.shared.totalCartDiscount.rounded()) : Converter.toString(Cart.shared.totalCartDiscount)
            summaries.append(orderSummary("Discount",minusStr + discount))  //-
            
            amountpaid -= Converter.toDouble(discount)
        }
        
        if Cart.shared.totalCartGSTAmount.rounded() > 0 {
            let GST = currentOrder.paymentGateway == "COD" ? Converter.toString(Cart.shared.totalCartGSTAmount.rounded()) : Converter.toString(Cart.shared.totalCartGSTAmount)
            summaries.append(orderSummary("GST",plusStr + GST))
            
            amountpaid += Converter.toDouble(GST)
        }
        
        if currentOrder.giftWarpPrice.rounded() > 0 {
            let giftwrapprice = currentOrder.paymentGateway == "COD" ? Converter.toString(currentOrder.giftWarpPrice.rounded()) : Converter.toString(currentOrder.giftWarpPrice)
            summaries.append(orderSummary("Gift wrap",plusStr + giftwrapprice))
            
            amountpaid += Converter.toDouble(giftwrapprice)
        }
        
        if currentOrder.deliveryCharge.rounded() > 0 {
            let charge = currentOrder.paymentGateway == "COD" ? Converter.toString(currentOrder.deliveryCharge.rounded()) : Converter.toString(currentOrder.deliveryCharge)
            summaries.append(orderSummary("Delivery charge",plusStr + charge))
            
            amountpaid += Converter.toDouble(charge)
        }
        
        
       
//        let totalpayable = currentOrder.paymentGateway == "COD" ? Converter.toString(amountpaid.rounded()) : Converter.toString(amountpaid)
//        summaries.append(orderSummary("Total payable",RsSymbol + totalpayable))
        
        
        if currentOrder.walletPrice.rounded() > 0 {
            let wallet = currentOrder.paymentGateway == "COD" ? Converter.toString(currentOrder.walletPrice.rounded()) : Converter.toString(currentOrder.walletPrice)
            summaries.append(orderSummary("Paid From Wallet",minusStr + wallet))  //-
            
            amountpaid -= Converter.toDouble(wallet)
        }
        
        let finalamount = currentOrder.paymentGateway == "COD" ? Converter.toString(amountpaid.rounded()) : Converter.toString(amountpaid)
        summaries.append(orderSummary("Total payable",RsSymbol + finalamount))
        
        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension NewThankyouVC {
    @IBAction func btnContinueshoppingClicked(_ sender: UIButton) {
        
        self.navigationController?.popToRootViewController(animated: false)
        if (_appDelegator.tabBarVC) != nil {
            _appDelegator.tabBarVC.selectedIndex = 0  // Or whichever number you like
            _appDelegator.tabBarVC.selectedViewController?.navigationController?.popToRootViewController(animated: false)
                
        }
            
    }
    @IBAction func btnShareClicked(_ sender: UIButton) {
        
        takeScreenShotandShare(sender)
    }
    
    func takeScreenShotandShare(_ sender: UIButton)  {
        let scrollView = collectionview
            
        let savedContentOffset = scrollView?.contentOffset
        let savedFrame = scrollView?.frame
        
        UIGraphicsBeginImageContext((scrollView?.contentSize)!)
        scrollView?.contentOffset = .zero
        scrollView?.frame = CGRect(x: 0, y: 0, width: (scrollView?.contentSize.width)!, height: (scrollView?.contentSize.height)!)
        scrollView?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        scrollView?.contentOffset = savedContentOffset!
        scrollView?.frame = savedFrame!
            
        if (screenshot != nil) {
            
            let shareString: String = ""
            let shareImage: UIImage? = screenshot
            let shareUrl = URL(string: "http://digitalhotelgroup4.zoomi.in:202")
            let activityItems: [Any] = [shareString, shareImage! , shareUrl ?? ""]
            
            let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
            if IS_IPAD{
                vc.modalPresentationStyle = UIModalPresentationStyle.popover
                vc.popoverPresentationController?.sourceView = sender
                self.present(vc, animated: true, completion: nil)
                
              

            }
            else{
                
                self.present(vc, animated: true, completion: nil)
            }
            
            
        }
        
    }
    
}

//MARK: - COLLECTIONVIEW METHODS -
extension NewThankyouVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {  // shipping/pick up address
            return 1
        }
        else if section == 1 {  // cart items
           return currentOrder.cartItems.count
        }
        else if section == 2 {  //order summary
            return summaries.count
        }
        else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:  //first cell address cell
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kAddressCellReuse, for: indexPath as IndexPath)
            
            let lblThankyou = cell.viewWithTag(10) as! UILabel
            lblThankyou.text = "Thanksfororder".localizedString()
            
            let lblOrderId = cell.viewWithTag(11) as! UILabel
            lblOrderId.text = "Orderid".localizedString() + Converter.toString(placeOrderResponse["displayOrderId"])
            
            let typeofOrderlabel = cell.viewWithTag(12) as! UILabel
            typeofOrderlabel.text = currentOrder.isDeliveryPickup ? "Thankyoudeliveryaddress".localizedString() : "Thankyoupickupaddress".localizedString() //IsDeliveryPickup = true then Shipping
            
            let namelabel = cell.viewWithTag(13) as! UILabel
            namelabel.text = currentOrder.addressname
            
            let addresslabel = cell.viewWithTag(14) as! UILabel
            addresslabel.text = fulladdress
            
            return cell
            
            
            
        case 1:   // cart item cell
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kItemCellReuse, for: indexPath as IndexPath)
            let item = currentOrder.cartItems[indexPath.row]
            
                let namelabel = cell.viewWithTag(10) as! UILabel
                namelabel.text =  item.product.productName
                
                let pricelabel = cell.viewWithTag(12) as! UILabel
                pricelabel.text = String(format: "   %@ %@",RsSymbol,Converter.toString(item.product.productPrice))
                
                let sizendqtylabel = cell.viewWithTag(11) as! UILabel
                let size = item.product.size?.value ?? ""
            
                if size != "" {
                    sizendqtylabel.text = "Size : " + size
                }
                if item.quantity != 0 {
                    sizendqtylabel.text = sizendqtylabel.text! + " Qty : " + Converter.toString(item.quantity)
                }
            
            
            
            return cell
            
            
        default:  //summary cell
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ksummaryCellReuse, for: indexPath as IndexPath)
            let summary = summaries[indexPath.row]
            
            let titlelabel = cell.viewWithTag(10) as! UILabel
            titlelabel.text =  summary.title
            
            let totallabel = cell.viewWithTag(11) as! UILabel
            totallabel.text = summary.amount
            
            return cell
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        var cellHeight:CGFloat = 0.0

        switch indexPath.section {
            case 0: //address cell
               // cellHeight = 141
                let addressheight = calculateHeight(font: UIFont.systemFont(ofSize: 12), width: cellWidth - 20 ,text: fulladdress)
                cellHeight = addressheight + (100 * universalWidthRatio) + (5 * universalWidthRatio)
                break
            case 1: // item cell
                let item = currentOrder.cartItems[indexPath.row]
                let itemnameheight = calculateHeight(font: UIFont.systemFont(ofSize: 15), width: cellWidth - 20 ,text: item.product.productName)
                cellHeight =  itemnameheight + (21 * universalWidthRatio) + (6 * universalWidthRatio)    //46
                break
            default: //summary cell
                cellHeight = 27
                break
        }
        
         return CGSize(width:cellWidth  , height: cellHeight * universalWidthRatio)
    }
    func calculateHeight(font: UIFont, width: CGFloat, text: String) -> CGFloat{
        let calString = text
        
        let textSize = calString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin , attributes: [NSFontAttributeName: font], context: nil)
        return textSize.height + 20 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    }
    
}

extension NewThankyouVC {
    
    func getApiParams() -> [String:Any]  {
        var paramDict = [String:Any]()
        paramDict["OrderId"] = Converter.toString(placeOrderResponse["orderId"])
        return paramDict
    }
    
    func GetOrderDetails()  {
        
        wsCall.getMyOrderList(params: self.getApiParams()) { (response) in
            if response.isSuccess {
                if let json = response.json as? [[String:Any]] {
                    let array = json.map({ (obj) -> MyOrder in
                        return MyOrder(obj)
                    })
                    if !array.isEmpty {
                        self.orderDetailObj = array[0]
                    }
                    
                    
                }
            }
        }
    }
}



