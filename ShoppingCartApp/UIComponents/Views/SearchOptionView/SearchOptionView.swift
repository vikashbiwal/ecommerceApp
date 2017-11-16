//
//  SearchOptionView.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 14/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SearchOptionView: BlurViewDark {

    @IBOutlet var collView: UICollectionView!
    

    enum SearchOptionKey {
        case camera, Audio, BarCode
    }
    var searchOptions  = [SearchOption]()
    var heightConstant = 100 * widthRatio
    var isShowing = false
    weak var presentingView: UIView!
    var actionBlock: (SearchOptionKey, Any)->Void = {_ in}
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUISize()
        self.setOptions()
        self.registerCollectionViewCell()
        self.drawShadow()
    }
    
    func setUISize() {
        let minWidth = min(screenSize.width, screenSize.height)
        let rect = CGRect(x: 0, y: 0, width: minWidth, height: heightConstant)
        self.frame = rect
        
    }
    
    func registerCollectionViewCell() {
        let nib = UINib(nibName: "SearchOptionCollViewCell", bundle: Bundle(for: SearchOptionView.self))
        collView.register(nib, forCellWithReuseIdentifier: "optionCell")
    }
    
    func setOptions() {
        let voiceSearch = SearchOption(title: "Voice Search".localizedString(), icon: "ic_micro_phone_big")
        let cameraSearch = SearchOption(title: "Camera".localizedString(), icon: "ic_camera_big")
        let barCodeSearch = SearchOption(title: "BarCode".localizedString(), icon: "ic_barcode_scan_big")
        searchOptions = [voiceSearch, cameraSearch, barCodeSearch]
    }
    
    func showSearchOptionView() {
    }

}

//Class function
extension SearchOptionView {
   class func loadView()->SearchOptionView {
        let views = Bundle(for: SearchOptionView.self).loadNibNamed("SearchOptionView", owner: nil, options: nil) as! [UIView]
        let sov = views[0] as! SearchOptionView
        return sov
    }
    
    class func showIn(_ view: UIView) {
        

    }
}

//MARK: CollectionView DataSource and Delegate
extension SearchOptionView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! CollectionViewCell
        let option = searchOptions[indexPath.row]
        cell.lblTitle.text = option.title
        cell.imgView.image = UIImage(named: option.icon)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = screenSize.width/CGFloat(searchOptions.count)
        return CGSize(width: size, height: heightConstant)
    }
}




//Search option
struct SearchOption {
    var title = ""
    var icon = ""
    
}
