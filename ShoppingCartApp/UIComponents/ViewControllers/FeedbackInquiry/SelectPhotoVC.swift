//
//  SelectPhotoVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 22/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SelectPhotoVC: ParentViewController {

    
    @IBOutlet weak var selectPhotoCollectionView: UICollectionView!
    var arrPhotoList: [UIImage] = []
    var numberOfItemInRow: Int {return IS_IPAD ? 8 : 4}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension SelectPhotoVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPhotoList.count
     
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenSize.width - CGFloat(40 + 10 * (numberOfItemInRow - 1)) )/CGFloat(numberOfItemInRow), height:180 * universalWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
      
        let cellPhotoLibrary = collectionView.dequeueReusableCell(withReuseIdentifier:"SelectPhoto", for: indexPath) as! PrePhotoPostPhotoLIbraryCell
        cellPhotoLibrary.awakeFromNib()
        cellPhotoLibrary.photoLibraryImage.image = self.arrPhotoList[indexPath.row]
        
        return cellPhotoLibrary
        
    }

}


class PrePhotoPostPhotoLIbraryCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var photoLibraryImage: UIImageView!
    
    // var selectedPhotos = [UIImageView]()
    
    
    override func awakeFromNib() {
        
        photoLibraryImage.clipsToBounds = true
        photoLibraryImage.contentMode = .scaleAspectFill
        photoLibraryImage.layer.borderColor = UIColor.clear.cgColor
        photoLibraryImage.layer.borderWidth = 1
        photoLibraryImage.layer.cornerRadius = 5
        
    }
}
