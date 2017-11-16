//
//  ProductListSortByView.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 6/27/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

class ProductListSortByView: UIView {
    
    @IBOutlet weak var tranparentView: UIView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var sortByListView: UITableView!
    
    var presentSortBy = SortBy([:])   
    var actionBlock: (SortBy)-> Void = {_ in}
    
    var sorItems = [SortBy]() {
        didSet {
          sortByListView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sortByListView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
       
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

}

extension  ProductListSortByView {
    class func instanceFromNib() -> ProductListSortByView {
        return UINib(nibName: "ProductListSortByView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProductListSortByView
    }
}

extension ProductListSortByView : UITableViewDataSource, UITableViewDelegate{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return sorItems.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath) as UITableViewCell
        
        let sortbyObj = self.sorItems[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        
        
        if sortbyObj.sortValue == self.presentSortBy.sortValue{
            
            cell.textLabel?.font = UIFont(name: FontName.SANSBOLD, size: ((cell.textLabel?.font.pointSize)! * universalWidthRatio))
        }
        else{
           cell.textLabel?.font = UIFont(name: FontName.REGULARSTYLE1, size: ((cell.textLabel?.font.pointSize)! * universalWidthRatio))
        }

        
        
        cell.contentView.isUserInteractionEnabled = true
        
        
        cell.textLabel?.text = Converter.toString(sortbyObj.sortBy)
        
        return cell
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentSortBy = self.sorItems[indexPath.row]
        
        actionBlock(self.presentSortBy)
    }
    
    
}
