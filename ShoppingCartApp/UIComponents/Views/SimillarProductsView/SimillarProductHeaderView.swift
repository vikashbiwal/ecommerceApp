//
//  SimillarProductHeaderView.swift
//  ShoppingCartApp
//
//  Created by zoomi on 10/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

protocol selectSimilarProductFilterDelegate: class {
    
    func filterProductBySimilarProductFilter(similarProductFilterObj: PDSimilarProductFilter, index: Int)
    
}


class SimillarProductHeaderView: UITableViewCell {

    @IBOutlet weak var filterProductCollectionView: UICollectionView!
    @IBOutlet weak var lblProductTitle: UILabel!
    var selectedIndex:Int = 0
    var arrsimilarProductFilter = [PDSimilarProductFilter]()
    
    weak var similarproductfilterDelegate: selectSimilarProductFilterDelegate?
    
    
   // let arrFilterProduct = ["Brand","Categuary","New Brand","New Categuary","New Categuary and brand","NewCateguaryCateguaryCateguaryandbrand"]
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        print("similarProductFilter->\(arrsimilarProductFilter)")
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filterProductCollectionView.register(UINib(nibName: "SimillarProductFilterCell", bundle: nil), forCellWithReuseIdentifier: "SimillarProductFilterCell")
    }

}




//MARK:- SMProductsItemsView
extension SimillarProductHeaderView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    //CollectionView DataSource and Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrsimilarProductFilter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimillarProductFilterCell", for: indexPath) as! SimillarProductFilterCell
        
        cell.lblProductName.adjustsFontSizeToFitWidth = true
        
        if selectedIndex == indexPath.row {
            
            cell.backgroundColor = PDCOLOR
            cell.lblProductName.textColor = UIColor.white
        }else{
            
            cell.backgroundColor = UIColor.backgroundColor
            cell.lblProductName.textColor = PDCOLOR
        }
        
       
        cell.lblProductName.font = UIFont(name: FontName.REGULARSTYLE1, size: (15 * universalWidthRatio))
        
        let similarFilterObj = arrsimilarProductFilter[indexPath.row]
        
        cell.lblProductName.text = similarFilterObj.similarBy
        
     
       
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
         let similarFilterObj = arrsimilarProductFilter[indexPath.row]
        
        let strResize = "   "+similarFilterObj.similarBy+"   "
        
        let size: CGSize = strResize.size(attributes: [NSFontAttributeName: UIFont(name: FontName.REGULARSTYLE1, size: (15 * universalWidthRatio)) ?? UIFont()])
        return CGSize(width: size.width , height: filterProductCollectionView.bounds.size.height)
    }
    
    
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
//    {
//        // NOTE: here is where we say we want cells to use the width of the collection view
//        let requiredWidth = collectionView.bounds.size.width
//        
//        // NOTE: here is where we ask our sizing cell to compute what height it needs
//        let targetSize = CGSize(width: requiredWidth, height: 0)
//        /// NOTE: populate the sizing cell's contents so it can compute accurately
//        self.SimillarProductFilterCell.label.text = arrFilterProduct[indexPath.row]
//        let adequateSize = self.SimillarProductFilterCell.preferredLayoutSizeFittingSize(targetSize)
//        return adequateSize
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let product = productsArray[indexPath.row] as! Product
//        self.clearBlock?()
//        self.actionBlock?(product)
        
        selectedIndex = indexPath.row
                
        filterProductCollectionView.reloadData()
        
        let similarFilterObj = arrsimilarProductFilter[indexPath.row]
        
        similarproductfilterDelegate?.filterProductBySimilarProductFilter(similarProductFilterObj: similarFilterObj, index: selectedIndex)
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return  CGSize(width: 160 * widthRatio, height: 190  * widthRatio)
//    }
    
}
