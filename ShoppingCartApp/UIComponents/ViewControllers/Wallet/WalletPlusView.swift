//
//  WalletPlusView.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 05/08/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class WalletPlusView: UIView {

    @IBOutlet weak var tranparentView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var tbWalletPlus: UITableView!
    
    //var presentSortBy = SortBy([:])
    var actionBlock: (String)-> Void = {_ in}
    
    //var arrItem : [String] = []
    var arrItem = [String]() {
        didSet {
            tbWalletPlus.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tbWalletPlus.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        
    }
    
    //Touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch = touches.first as UITouch!
        
        if (touch.view is UITableView){
            
        }
        else{
            self.removeFromSuperview()
        }
    }


    class func instanceFromNib() -> WalletPlusView {
        return UINib(nibName: "WalletPlusView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WalletPlusView
    }
}


extension WalletPlusView : UITableViewDataSource, UITableViewDelegate{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrItem.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as UITableViewCell
        
        //let sortbyObj = self.sorItems[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.font = UIFont(name: FontName.REGULARSTYLE1, size: ((cell.textLabel?.font.pointSize)! * universalWidthRatio))
        cell.contentView.isUserInteractionEnabled = true
        cell.textLabel?.text = self.arrItem[indexPath.row]
        
        return cell
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // self.presentSortBy = self.sorItems[indexPath.row]
        
        actionBlock(self.arrItem[indexPath.row])
    }
    
    
}
