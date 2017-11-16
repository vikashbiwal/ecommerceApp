//
//  CategoryVC.swift
//  ShoppingCartApp
//
//  Created by Jinal Shah on 27/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import UIImageColors
import FirebaseRemoteConfig

class CategoryVC: ParentViewController {
    
    var category: Category!
    var arrCategory = [Category]()
    //var isthirdLevelCategoryExpand: Bool = true
    var categoryCopy: Category!
    var heightOfSection = 150
    var categoryID : String = ""
    var arrHeightOfSection : [[String:Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTblSectionHeader()
        category = nil
        getCategoryList()
        // For ReOrder Category
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)))
        self.tableView.addGestureRecognizer(longpress)
        self.tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0  )
    }
    
    
    func registerTblSectionHeader() {
        let nib =  UINib(nibName: "CategorySectionHeaderView", bundle: Bundle(for: CategoryVC.self))
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "headerView")
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        if FirRCManager.shared.isthirdLevelCategoryExpand{
            _ = self.navigationController?.popViewController(animated: false)
        } else {
            if category.childCategories.count > 0{
                if category.childCategories[0].name == categoryCopy.childCategories[0].name {
                    _ = self.navigationController?.popViewController(animated: false)
                } else {
                    category = categoryCopy
                    self.tableView.reloadData()
                }
 
            }else {
                 _ = self.navigationController?.popViewController(animated: false)
            }
            
        }
    }
    
}

//MARK: - TableView Delegates
extension CategoryVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return category.childCategories.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let child = category.childCategories[section]
        return  child.childCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! TableViewCell
        let subChild = category.childCategories[indexPath.section].childCategories[indexPath.row]
        cell.lblTitle.text = subChild.name.uppercased()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return   category.childCategories[indexPath.section].isOpen ? 40 * universalWidthRatio : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heights = self.arrHeightOfSection[section]["height1"] as! Int
        heights += 30
        heightOfSection = heights
        return CGFloat(heights)
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 * universalWidthRatio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hv = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as! CategorySectionHeaderView
        hv.sectionIndex = section
        hv.tag = section
        hv.delegate = self
        let categoryType = category.childCategories[section]
        let urlString = categoryType.bannerImageUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let sizeUrl = thumbSizeImageUrl(urlString: urlString, size: CGSize(width: hv.imgView.frame.size.width, height: hv.imgView.frame.size.height))
        
        self.showCentralSpinner()
        
        hv.imgView.setImage(url:URL(string: sizeUrl)! , placeholder: #imageLiteral(resourceName: "catPlaceholder")) { img in
            self.hideCentralSpinner()
            if img == nil{
                hv.imgView.image = #imageLiteral(resourceName: "catPlaceholder")
            } else {
                hv.imgView.image = img
                let height = ((img?.size.height)! * screenSize.width) / (img?.size.width)!
                if !(self.arrHeightOfSection[section]["isReload"] as! Bool){
                    let dictHeight = ["height1" : Int(height) , "isReload" : true] as [String : Any]
                    self.arrHeightOfSection[section] = dictHeight
                    let indexSet: IndexSet = [section]
                    self.tableView.reloadSections(indexSet, with: .none)
                }
                
            }
            
        }
        //hv.imgView.setImage(url: URL(string: sizeUrl)!)
        hv.lblTitle.text =  categoryType.name.uppercased()
        hv.contentView.backgroundColor = UIColor.white
        return hv
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subChild = category.childCategories[indexPath.section].childCategories[indexPath.row]
        navigateToProductListing(cate: subChild)
    }
    
//Navigation to Product List    
    func navigateToProductListing(cate:Category!){
        
        let productvc = storyboardProductList.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        productvc.apiParam = cate.apiParam
        productvc.navigationTitle = cate.name
        self.navigationController?.pushViewController(productvc, animated: true)

    }
    
}

extension CategoryVC{
    func getCategoryList() {
        
        let catID = convertToDictionary(text: categoryID)
        
        wsCall.getCategorylist(params: catID!) { (response) in
            if response.isSuccess {
                
                if let json = response.json as? [[String:Any]] {
                    print("category response is => \(json)")
                    self.arrCategory = json.map({ (categoryObject) -> Category in
                        return Category(categoryObject)
                    })
                    self.category = self.arrCategory[0]
                    if self.category.childCategories.count == 0{
                        self.navigateToProductListing(cate: self.category)
                    } else {
                        for _ in 0..<self.category.childCategories.count{
                            let dictHeight = ["height1" : self.heightOfSection , "isReload" : false] as [String : Any]
                            self.arrHeightOfSection.append(dictHeight)
                        }
                        self.lblTitle.text = self.category.name
                        self.tableView.dataSource = self
                        self.tableView.delegate = self
                        self.tableView.reloadData()
                        self.categoryCopy = self.category
                    }
                    
                }
            }
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}

//MARK: - CategorySectionHeaderDelegate Method
extension CategoryVC : CategorySectionHeaderDelegate {
    
    //RoomType Section header view delegate
    func didAddItem(section: Int) {
        
        let cate = category.childCategories[section]
        if !cate.childCategories.isEmpty {
            
            if FirRCManager.shared.isthirdLevelCategoryExpand{
                cate.isOpen = !cate.isOpen
                self.tableView.reloadSections([section], with: .automatic)
            } else {
                category = cate
                self.tableView.reloadData()
            }
            
        } else {    //Navigation to Product List if child categories are not available
            
            navigateToProductListing(cate: cate)
            
        }
        
    }
    
}

//MARK: - ReOrder/ Change Position of Categories
extension CategoryVC {
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationPoint = longPress.location(in: tableView)
        print("location:",locationPoint)
        var indexPath : IndexPath? = nil
        
        let sectionview = self.tableView.hitTest(locationPoint, with: nil)
        if sectionview != nil{
            heightOfSection = Int((sectionview?.frame.size.height)!)
        }
        var i = Int(locationPoint.y / CGFloat(heightOfSection))
        
        if indexPath?.section != i{
            if i > category.childCategories.count - 1{
                i = category.childCategories.count - 1
            }
            indexPath = IndexPath(row: 0, section: i)
        }
        
        struct My {
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
            static var oldCell : UIView? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                let sectionview = self.tableView.hitTest(locationPoint, with: nil)
                let cell = sectionview?.superview
                Path.initialIndexPath = indexPath
                My.cellSnapshot  = snapshotOfCell(cell!)
                Path.oldCell = cell
                var center = cell?.center
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                tableView.addSubview(My.cellSnapshot!)
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationPoint.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationPoint.y
                My.cellSnapshot!.center = center
                let sectionview = self.tableView.hitTest(locationPoint, with: nil)
                if sectionview != nil{
                    heightOfSection = Int((sectionview?.frame.size.height)!)
                }
                var i = Int(locationPoint.y / CGFloat(heightOfSection))
                if indexPath?.section != i{
                    if i > category.childCategories.count - 1{
                        i = category.childCategories.count - 1
                    }
                    print("i :",i)
                    indexPath = IndexPath(row: 0, section: i)
                }
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                    category.childCategories.insert(category.childCategories.remove(at: Path.initialIndexPath!.section), at: (indexPath?.section)!)
                    tableView.moveSection((Path.initialIndexPath?.section)!, toSection: (indexPath?.section)!)
                    
                    //print("Changed",(Path.initialIndexPath?.section)!,(indexPath?.section)!)
                    Path.initialIndexPath = indexPath
                    //categoryCopy = category
                }
                
            }
        default:
            //println(state)
            if Path.initialIndexPath != nil {
                
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    Path.oldCell?.isHidden = false
                    Path.oldCell?.alpha = 0.0
                }
                
                println((Path.initialIndexPath?.section)!,(indexPath?.section)!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    My.cellSnapshot!.center = (Path.oldCell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    Path.oldCell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func snapshotOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
}

