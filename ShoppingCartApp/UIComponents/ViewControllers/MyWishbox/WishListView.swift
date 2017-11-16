//
//  WishListView.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 17/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


//MARK:- WishGroupListView

class WishGroupListView: UIView {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var txtGroupName: UITextField!
    @IBOutlet var headerView: UIView!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var saveBtnHeightConstraint:NSLayoutConstraint!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    
    var headerViewExpanded = false {
        didSet {
            setHeaderViewUI()
        }
    }
    
    func setHeaderViewUI() {
        plusButton.setTitle(headerViewExpanded ? "-" : "+", for: .normal)
        self.headerViewHeightConstraint.constant = headerViewExpanded ? 100 : 50
        tableView.separatorStyle = groups.isEmpty ? .none : .singleLine
        if !headerViewExpanded {
            txtGroupName.resignFirstResponder()
        }
    }
    
    var selectedIndex = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.drawShadow(0.7, offSet: CGSize.zero)
        self.layer.zPosition = 10
        tableView.tableFooterView = UIView()
        
        setHeaderViewUI()
    }
    
    var groups = [WishGroup]() {
        didSet {
            saveBtnHeightConstraint.constant = groups.isEmpty ? 0 : 36
            headerViewExpanded = groups.isEmpty
        }
    }
    
    @IBAction func plus_btnClicked(_ sender: UIButton?) {
        headerViewExpanded = !headerViewExpanded
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
}


//MARK:- Tableview DataSource and Delegate
extension WishGroupListView: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.isEmpty ? 1 : groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !groups.isEmpty else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggetionCell") as! TableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let cate = groups[indexPath.row]
        cell.lblTitle.text = cate.title
        cell.button?.isSelected = cate.selected
        cell.button?.tag = indexPath.row

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
            cell.button!.isSelected = !cell.button!.isSelected
            groups.forEach({$0.selected = false})//should be change this line with other option. should not be used for loop every time.
            groups[indexPath.row].selected = cell.button!.isSelected
            
            if selectedIndex >= 0 {
                let preSelectedIndexPath = IndexPath(row: selectedIndex, section: 0)
                tableView.reloadRows(at: [preSelectedIndexPath], with: .automatic)
            }
            selectedIndex = indexPath.row
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return groups.isEmpty ? 150 : 50
    }
    
    func appendNew(group: WishGroup) {
		if groups.count == 0 {
			group.selected = true
			selectedIndex = 0
		}
        groups.insert(group, at: 0)
        if groups.count == 1 {
            plus_btnClicked(nil)
            tableView.reloadData()
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    @IBAction func checkBox_btnClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        groups.forEach({$0.selected = false})
        groups[sender.tag].selected = sender.isSelected
        
        if selectedIndex >= 0 {
            let preSelectedIndexPath = IndexPath(row: selectedIndex, section: 0)
            tableView.reloadRows(at: [preSelectedIndexPath], with: .automatic)
        }
        selectedIndex = sender.tag
    }
}

