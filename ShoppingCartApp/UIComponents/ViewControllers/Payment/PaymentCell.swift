//
//  PaymentCell.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 7/21/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {
    
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   

}

class summaryCell: CollectionViewCell {
    @IBOutlet weak var totalLabel: UILabel!
}

class PreOrderSummaryCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}
