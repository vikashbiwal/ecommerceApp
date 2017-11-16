//
//  EmptyDataView.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 02/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


struct RetrySelctor {
    let observer: UIViewController
    let selector: Selector
}

class EmptyDataView: UIView {

    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var button: UIButton!
    
    var selectors: [RetrySelctor] = []
    
    var enableRetryOption = false {
        didSet {
            button?.isHidden = !enableRetryOption
        }
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func show(in view: UIView, message: String, buttonTitle: String = "", enableRetryOption: Bool = false) {
        self.lblMessage.text = message
        self.button.setTitle(buttonTitle, for: .normal)
        self.enableRetryOption = enableRetryOption
        view.addSubview(self)
    }
    
    func remove() {
        self.removeFromSuperview()
    }
    
    @IBAction func retry_btnClicked(_ sender: UIButton) {
        selectors.forEach { retrySelector in
           retrySelector.observer.perform(retrySelector.selector)
        }
    
    }
    
    //call this func for loading empty data view.
    class func loadFromNib()-> EmptyDataView {
        let views = Bundle(for: EmptyDataView.self).loadNibNamed("EmptyDataView", owner: nil, options: nil) as! [UIView]
        let view = views[0] as! EmptyDataView
        view.frame = CGRect(x: 0, y: 64, width: screenSize.width, height: screenSize.height - 64)
        return view
    }
    

}
