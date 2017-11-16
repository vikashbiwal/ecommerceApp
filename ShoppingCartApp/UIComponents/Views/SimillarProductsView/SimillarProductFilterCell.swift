//
//  SimillarProductFilterCell.swift
//  ShoppingCartApp
//
//  Created by zoomi on 10/10/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class SimillarProductFilterCell: UICollectionViewCell {
    
    @IBOutlet weak var lblProductName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.drawShadow(0.05)
        
    }
}
