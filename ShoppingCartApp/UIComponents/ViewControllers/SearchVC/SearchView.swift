//
//  SearchView.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 03/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


//MARK:- Search View
class SearchView: ConstrainedView {
    //MARK: IBOutlets
    @IBOutlet weak var searchOptionsView: UIView!
    @IBOutlet weak var searchTextField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sovTrailingSpaceConstrint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var searchResults = [SearchResult]() {
        didSet {
            tableView.reloadData()
            setTableViewHeight()
            if !searchResults.isEmpty {
                searchTextField.resignFirstResponder()
            }
        }
    }
    
    ///change value with true and false for showing and hiding search option view.
    var searchOptionShowing = false {
        didSet {
            self.showHideSearchOptionsView()
        }
    }
    
    //controller's reference on which searchView showing.
    weak var viewController: SearchViewController?
    var  actionBlock: ((SearchItem,NSAttributedString))-> Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sovTrailingSpaceConstrint.constant = -self.frame.width + 20
        self.searchOptionsView.drawShadow(0.2)
        self.searchOptionsView.layer.zPosition = 10
        self.tableView.tableFooterView = UIView()
        setTableViewHeight()
    }
    
    //Show and hide Search options view.
    func showHideSearchOptionsView() {
        self.sovTrailingSpaceConstrint.constant = searchOptionShowing ?   2 : -self.frame.width + 20
        
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    
    func setTableViewHeight() {
        let tblContentHeight = tableView.contentSize.height
        let maxTblHeight = self.frame.height - 64
        
        let height = tblContentHeight > maxTblHeight ? maxTblHeight : tblContentHeight
        tableViewHeightConstraint.constant = height
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
}


//MARK:- Tableview DataSource and Delegate
extension SearchView: UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchResultCell
        let result = searchResults[indexPath.section].items[indexPath.row]
        let attributeString = cell.attributedString(fromHTML: result.htmlString, fontFamily: FontName.REGULARSTYLE1)
        cell.lblTitle.attributedText = attributeString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resultItem = searchResults[indexPath.section].items[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! SearchResultCell
        actionBlock((resultItem,cell.attributedString(fromHTML: resultItem.htmlString, fontFamily: FontName.REGULARSTYLE1)!))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let result = searchResults[section]
        
        if result.title == "Similar Items" {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.groupTableViewBackground
            let lbl = UILabel()
            lbl.font = UIFont(name: FontName.REGULARSTYLE1 + "-Bold", size: 16 * universalWidthRatio)
            lbl.text = result.title.localizedString()
            lbl.frame = CGRect(x: 8, y: 10, width: 0, height: 0)
            lbl.sizeToFit()
            headerView.addSubview(lbl)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let result = searchResults[section]
        if result.title == "Similar Items" {
            return 40
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

//MARK:- SearchReultCell
class SearchResultCell: TableViewCell, HTMLString {
    var _textColor: UIColor {
        return lblTitle.textColor
    }
    var _font: UIFont {
        return self.lblTitle.font
    }
    
}

