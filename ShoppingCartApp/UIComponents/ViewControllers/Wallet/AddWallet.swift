//
//  AddWallet.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 24/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class AddWallet: ParentViewController {

    @IBOutlet weak var moneyCollectionView: UICollectionView!
    @IBOutlet weak var txtAmt: UITextField!
    @IBOutlet weak var btnTotalWalletAmt: BorderButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnTotalWalletAmt.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1.0, borderColor1: .clear)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


//MARK: - COLLECTIONVIEW METHODS -
extension AddWallet : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "walletCell", for: indexPath as IndexPath)
        
        
        return cell
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        switch kind {
//            
//        case UICollectionElementKindSectionHeader:
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath as IndexPath)
//            let titlelabel = headerView.viewWithTag(111) as! UILabel //title of header
//            titlelabel.text = currentFilter.groupNameDisplay
//            return headerView
//            
//            
//        case UICollectionElementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath as IndexPath)
//            return footerView
//        default:
//            fatalError("Unexpected element kind")
//            //assert(false, "Unexpected element kind")
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (collectionView.frame.width - 6) / 4  //show 4 button
        let numberofrow =  10/4
        //let numberofrow =  ceil(Float(filters.count) / Float(4))
        let itemHeight =  (collectionView.frame.height - CGFloat(numberofrow))/CGFloat(numberofrow) // show 2 row
        return CGSize(width: cellWidth , height:CGFloat(itemHeight))
    }
}



class MoneyCell : CollectionViewCell{
    @IBOutlet var btnMoney : UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnMoney.buttonRoundedCorner(cornerRadius1: 10, borderWidth1: 1.0, borderColor1: .clear)
    }
}
