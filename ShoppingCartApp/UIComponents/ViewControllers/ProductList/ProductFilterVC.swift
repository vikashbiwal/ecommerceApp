//
//  ProductFilterVC.swift
//  ShoppingCartApp
//
//  Created by zoomi mac9 on 6/28/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

let kTopCellReuse = "topCell"
let kColorCellReuse = "colorCell"
let kSelectionCellReuse = "selectionCell"
let kPriceCellReuse = "priceCell"


class ProductFilterVC: ParentViewController {

    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var topCollectionViewHeight: NSLayoutConstraint!
    
    
    var filters = [Filter]()
    var currentFilter = Filter()
    
    
    var topFilterIndex = Int()
    
    
    var filterRequest = FilterRequest()  //request object
    var minPrice = 0
    var maxPrice = 0
    
   
    var sliderlowerValue = _appDelegator.selectedMinPrcie
    var sliderupperValue = _appDelegator.selectedMaxPrcie
    var isPriceChanged = false
    
    
    var apiParam = String()// here , it is  forwarded  from product list
    var selectedFilterOptions = [PropertyDetail]() // this will fill from productlist
    var aTempSelectedFilterOptions = [PropertyDetail]()  //assign selectedfilteroption in it initaly then modified it accorig to selection and pass it to product list on click of apply
    var actionBlockForApply: ([PropertyDetail])-> Void = {_ in}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarView.drawShadow()
       // self.view.backgroundColor = UIColor.clear
        
        // Do any additional setup after loading the view.
        reloadFiltersFromListOnScreen()
        
        let btnclear = footerView.viewWithTag(100) as! UIButton
        btnclear .setTitle("CLEARTITLE".localizedString(), for: .normal)
        
        let btnapply = footerView.viewWithTag(101) as! UIButton
        btnapply .setTitle("APPLYTITLE".localizedString(), for: .normal)
       
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch: UITouch = touches.first as UITouch!
        
        if (touch.view is UICollectionView){
            
        }
        else{
            self.dismiss(animated: true, completion: nil)
           
        }
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //set dynemic height of top collectionv view
    func dynemicHeightOfTopCollectionView() {
        
        //dynamically set height of topcollectionview
        let bwidth = screenSize.width/4
        let bheight = bwidth/2.5
        
        let numberofrow =  ceil(Float(filters.count) / Float(4))
        
        let linespace = 2 * (numberofrow - 1)
        
        topCollectionViewHeight.constant =  CGFloat((numberofrow * Float(bheight)) + linespace)
    }
    

    

}
//MARK: - COLLECTIONVIEW METHODS -
extension ProductFilterVC : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView{
             return filters.count
        }
        else{
            if currentFilter.optionType ==  "range"{ //price
                return 1
            }
            else {
                return currentFilter.options.count
            }
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == topCollectionView {  //top collection view
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kTopCellReuse, for: indexPath as IndexPath)
            
            let namelabel = cell.viewWithTag(10) as! UILabel
            let  filterObj = filters[indexPath.row]
            namelabel.text =  filterObj.groupNameDisplay
            
            if topFilterIndex == indexPath.row {
                cell.backgroundColor = UIColor.init(hexString: "#AEB0B3") //selected cell
                namelabel.textColor = .white
            }
            else{
                cell.backgroundColor = UIColor.init(hexString: "#D0D1D2")
                namelabel.textColor = .black
            }
            
            return cell
        }
        else{  //bottom collectionview
            let filterOptions = currentFilter.options
            var optionname = String()
            if currentFilter.optionType != "range" {
                optionname = filterOptions[indexPath.row].optionName
            }
            switch currentFilter.optionType {
                
                case "color":
                    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kColorCellReuse, for: indexPath as IndexPath)
                   // cell.backgroundColor = UIColor.init(hexString: optionname)
                    
                    let hexstring = optionname
                    if hexstring.characters.first == "#"{
                        if hexstring == "#ffffff" {
                            cell.borderWithRoundCorner(radius: 0.0, borderWidth: 1, color: .black)
                           
                        }
                        cell.backgroundColor = UIColor.init(hexString: hexstring)
                    } //hex color
                    else{
                        let urlString = hexstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let sizeUrl = String(format: "%@?w=%d&h=%d",urlString,Int((cell.frame.size.width)*2),Int((cell.frame.size.height)*2))
                        (cell.viewWithTag(100) as! UIImageView).setImage(url: URL(string: sizeUrl)!, placeholder: UIImage(), completion: { (img) in
                                    (cell.viewWithTag(100) as! UIImageView).image = img
                         })
                        

                    }
                    
                    
                    if  filterOptions[indexPath.row].selected{
                        cell.borderWithRoundCorner(radius: 5, borderWidth: 1, color: UIColor.darkGray)
                        (cell.viewWithTag(101) as! UIImageView).isHidden = false
                        
                    }
                    else{
                        cell.borderWithRoundCorner(radius: 5, borderWidth: 1, color: .black)
                        (cell.viewWithTag(101) as! UIImageView).isHidden = true
                    }
                    return cell
                case "range":
                    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kPriceCellReuse, for: indexPath as IndexPath)
                    
                    
                    let priceslider : RangeSlider = cell.contentView.viewWithTag(100) as! RangeSlider
                    
                    priceslider.maximumValue = Double(self.maxPrice) > 0.0 ? Double(self.maxPrice) : 0.1
                    priceslider.minimumValue = Double(self.minPrice)
                   
                    priceslider.lowerValue = Double(self.sliderlowerValue)
                    priceslider.upperValue = Double(self.sliderupperValue)
                    
                    let minLabel : UILabel = cell.contentView.viewWithTag(101) as! UILabel
                    let maxLabel : UILabel = cell.contentView.viewWithTag(102) as! UILabel
                    
                    minLabel.text = String(format: "%@ %@",RsSymbol,Converter.toString(self.minPrice) )
                    maxLabel.text = String(format: "%@ %@",RsSymbol,Converter.toString(self.maxPrice) )
                    
                    priceslider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
                    return cell
                default:  //check box
                    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: kSelectionCellReuse, for: indexPath as IndexPath) as! FilterCheckBoxCellCollectionViewCell
                   // cell.backgroundColor =  UIColor.red
                    cell.optionName.text = optionname
                    if  filterOptions[indexPath.row].selected{
                        cell.optionImageView.image = #imageLiteral(resourceName: "selectedoption")
                    }
                    else{
                        cell.optionImageView.image = #imageLiteral(resourceName: "round")
                    }
                    return cell
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == topCollectionView {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else{
            return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath as IndexPath)
            let titlelabel = headerView.viewWithTag(111) as! UILabel //title of header
            titlelabel.text = currentFilter.groupNameDisplay
            return headerView
            
            
//        case UICollectionElementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath as IndexPath)
//            let btnclear = footerView.viewWithTag(100) as! UIButton
//            btnclear .setTitle("CLEARTITLE".localizedString(), for: .normal)
//            
//            let btnapply = footerView.viewWithTag(101) as! UIButton
//            btnapply .setTitle("APPLYTITLE".localizedString(), for: .normal)
//            return footerView
        default:
            fatalError("Unexpected element kind")
            //assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == topCollectionView {
            let cellWidth = (collectionView.frame.width - 6) / 4  //show 4 button
            
            let numberofrow =  ceil(Float(filters.count) / Float(4))
            let itemHeight =  (collectionView.frame.height - CGFloat(numberofrow))/CGFloat(numberofrow) // show 2 row
            return CGSize(width: cellWidth , height:CGFloat(itemHeight))
        }
        else{
            var cellWidth = (collectionView.frame.width - 6) / 4  //show 4 button
            var cellHeight =  (collectionView.frame.height - 2)/2 // show 2 row
            
           switch currentFilter.optionType {  //
                case "color":
                    cellHeight = 40.0
                    cellWidth = 40.0
                case "range":
                    cellHeight = 76.0
                    cellWidth = collectionView.bounds.width - 20
                default:  //check box
                    cellWidth = collectionView.frame.width
                    cellHeight = 30
                    
                }
            if currentFilter.optionType == "color"{
                return CGSize(width:CGFloat(cellWidth) * universalWidthRatio , height: CGFloat(cellHeight) * universalWidthRatio)
            }
            else{
               return CGSize(width:CGFloat(cellWidth) , height: CGFloat(cellHeight) * universalWidthRatio)
            }
           
            
        } //else
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if collectionView == topCollectionView {
            
            topFilterIndex = indexPath.row
            //save selected filter before changeing current filter
            if currentFilter.filerSelected{
                
                saveSelectedFilterOption()
                
            }
            
            currentFilter = filters[indexPath.row]
            
            //call API on filter selection
            filterRequest.filterType = currentFilter.groupName
           // getFilters(param: filterRequest.convertObjectIntoDictionary())
            self.getFilters(param: filterRequest.setfilterOptions(fromApiParam: apiParam ,andSelectedFilters: aTempSelectedFilterOptions))
           
            
        }
        else{  //bottom collection view
            
             let filterOptions = currentFilter.options
            switch currentFilter.optionType {  //
                
                    case "color": //multi selection color
                               if  filterOptions[indexPath.row].selected == true{
                                    filterOptions[indexPath.row].selected = false
                                }
                               else{
                                    filterOptions[indexPath.row].selected = true
                               }
                               bottomCollectionView.reloadData()
                                break
                        
                    case "range":
                                break
                    case "category":  //single selection
                        
                        //make all option un selected
                        if  filterOptions[indexPath.row].selected == true{
                            filterOptions[indexPath.row].selected = false
                        }
                        else{
                            let selectedOptions = filterOptions.filter({$0.selected})
                            if !selectedOptions.isEmpty {
                                selectedOptions[0].selected = false
                            }
                            
                            filterOptions[indexPath.row].selected = true
                        }
                       
                       bottomCollectionView.reloadData()
                                break
                    default:  //check box multi selection
                        if  filterOptions[indexPath.row].selected == true{
                            filterOptions[indexPath.row].selected = false
                        }
                        else{
                            filterOptions[indexPath.row].selected = true
                        }
                        bottomCollectionView.reloadData()
                        
                            break
            }
           
        }
    }
   
    
   
}

//MARK: - IBACTION METHODS -
extension ProductFilterVC {
    
    @IBAction func btnClearClicked(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)

        reloadFiltersFromListOnScreen()
    }
    @IBAction func btnApplyClicked(_ sender: UIButton) {
      
        saveSelectedFilterOption()
        actionBlockForApply(self.aTempSelectedFilterOptions)
        self.dismiss(animated: true, completion: nil)
     }
    
    func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
        isPriceChanged = true
        
        self.sliderlowerValue = Int(rangeSlider.lowerValue)
        self.sliderupperValue = Int(rangeSlider.upperValue)
        
       
    }

    
}

//MARK: - FILTER API
extension ProductFilterVC{
    
    
    func getFilters(param : [String:Any]) {
        if currentFilter.optionType != "range" {  //selected top filter is price then no need to call filter API
            
            print("headers are => \(wsCall.headers)")
            print("param are => \(param)")
            
            self.showCentralGraySpinner()
            
            wsCall.getFilters(params: param){ (response) in
                if response.isSuccess {
                    
                    if let json = response.json as? [String:Any] {
                        print("FILTER  response is => \(json)")
                        self.maxPrice = Converter.toInt(json["maxPrice"])
                        self.minPrice = Converter.toInt(json["minPrice"])
                        let aTempArray = json["filterOptions"] as! [[String:Any]]
                        
                        //create price filter manually
                        
                        
                        let pricefilter = Filter.init(["groupName":"Price","groupNameDisplay":"Price","priority":0,"optionType":"range","options":[]])
                        
                        let aTempFilters = aTempArray.map({ (filterObject) -> Filter in
                
                            return Filter(filterObject)
                            
                        })
                        if self.filters.isEmpty {
                            self.filters = aTempFilters
                        }
                        else{   //show filters which we get first time , show no filter found if no data in it
                            
                            if self.filters.contains(pricefilter){ self.filters.removeElement(pricefilter)}
                            
                            aTempFilters.filter({self.filters.contains($0)}).forEach({ filter in
                                self.filters.removeElement(filter)
                                self.filters.append(filter)
                            })
                            
                            self.filters += aTempFilters.filter({!self.filters.contains($0)})
                        }
                        
                        
                        //add price- range filter
                        if self.maxPrice > 0  && self.maxPrice != self.minPrice { //price filter is available
                            if !self.filters.contains(pricefilter) { self.filters.append(pricefilter) }
                            
                            if self.sliderupperValue == 0 {
                                self.sliderupperValue = self.maxPrice
                            }
                            
                            if self.sliderlowerValue == 0 {
                                self.sliderlowerValue = self.minPrice
                            }
                            
                        }
                        else{  //price filter is not available
                            self.sliderlowerValue = 0
                            self.sliderupperValue = 0
                        }
                        
                        let firstfilter = self.filters.filter({ (filter) -> Bool in
                            return filter.options.count > 0
                        }).first
                        
                        if firstfilter != nil{
                            self.currentFilter = self.filters.filter({ (filter) -> Bool in
                                return filter.options.count > 0
                            }).first!
                        }
                        
                        self.setSelectedOptionsInCurrentlFilter()
                  
                        
                    }
                }
                self.hideCentralGraySpinner()
            }

        }  //if
        else{
            self.dynemicHeightOfTopCollectionView()
            self.topCollectionView.reloadData()
            self.bottomCollectionView.reloadData()
        }
    }  //getFilters
    
    // this method will call after getfilter api is called and response will receive
    func setSelectedOptionsInCurrentlFilter()  {
        
        
        let index = aTempSelectedFilterOptions.index(where: { (propertyDetail) -> Bool in
            propertyDetail.equals(compareTo: currentFilter.propertyDetails)
        })
        
        if index != nil{ // filter is already selected
            let selectedFilter = aTempSelectedFilterOptions[index!]
            let selectedOptions = selectedFilter.propertyValue.components(separatedBy: ",")
            
            for currentopion in currentFilter.options {
                for selectedOption in selectedOptions {
                    if currentopion.optionNameValue == selectedOption{
                        currentopion.selected = true
                    }
                }
            }
            
        } //index != nil
        
        self.dynemicHeightOfTopCollectionView()
        self.topCollectionView.reloadData()
        self.bottomCollectionView.reloadData()
        
       // currentFilter.options = [FilterOption]()
        if currentFilter.options.count == 0 {
            //show no filter found image
            self.noFilterAvailable()
        }
        else{
            removeNoResultFoundImage(fromView: self.bottomCollectionView)
            self.bottomCollectionView.isHidden = false
        }
        
    }
    func noFilterAvailable(){
        removeNoResultFoundImage(fromView: self.bottomCollectionView)
        self.bottomCollectionView.isHidden = true
        let msg = "No" + currentFilter.groupNameDisplay + "Found!"
        showNoResultFoundImage(onView: self.bottomCollectionView,withText : msg)
    }
    func reloadFiltersFromListOnScreen()  {
        
        aTempSelectedFilterOptions = selectedFilterOptions
        self.sliderlowerValue = _appDelegator.selectedMinPrcie
        self.sliderupperValue = _appDelegator.selectedMaxPrcie
        
       // filterRequest.filterOptions = aTempSelectedFilterOptions
       // getFilters(param: filterRequest.convertObjectIntoDictionary())
        
        self.getFilters(param: filterRequest.setfilterOptions(fromApiParam: apiParam ,andSelectedFilters: aTempSelectedFilterOptions))
        
    }
    func saveSelectedFilterOption() {
        
        if  self.isPriceChanged {  //price
            
            _appDelegator.selectedMaxPrcie = self.sliderupperValue
            _appDelegator.selectedMinPrcie = self.sliderlowerValue
            
            let minpriceobj = PropertyDetail(["propertyKey":"minprice","propertyValue":_appDelegator.selectedMinPrcie,"isProperty":false])
            let maxpriceobj = PropertyDetail(["propertyKey":"maxprice","propertyValue":_appDelegator.selectedMaxPrcie,"isProperty":false])
            
            let minindex = aTempSelectedFilterOptions.index(where: { (propertyDetail) -> Bool in
                propertyDetail.equals(compareTo: minpriceobj)
            })
            
            if minindex != nil { //replace
                aTempSelectedFilterOptions[minindex!] = minpriceobj
            }
            else{ //add new
                aTempSelectedFilterOptions.append(minpriceobj)
            }
            
            let maxindex = aTempSelectedFilterOptions.index(where: { (propertyDetail) -> Bool in
                propertyDetail.equals(compareTo: maxpriceobj)
            })
            
            if maxindex != nil { //replace
                aTempSelectedFilterOptions[maxindex!] = maxpriceobj
            }
            else{ //add new
                aTempSelectedFilterOptions.append(maxpriceobj)
            }
            
           /* if minindex != nil && maxindex != nil{
                
                aTempSelectedFilterOptions.remove(at: minindex!)
                aTempSelectedFilterOptions.remove(at: maxindex!)
            }

            aTempSelectedFilterOptions.append(minpriceobj)
            aTempSelectedFilterOptions.append(maxpriceobj)*/
        }
        else{
            
            let index = aTempSelectedFilterOptions.index(where: { (propertyDetail) -> Bool in
                propertyDetail.equals(compareTo: currentFilter.propertyDetails)
            })
            
            
            if aTempSelectedFilterOptions.filter( {$0 .equals(compareTo: currentFilter.propertyDetails)}).map({ $0 }).first != nil{
                
                aTempSelectedFilterOptions.remove(at: index!)
            }
            if currentFilter.filerSelected {
                aTempSelectedFilterOptions.append(currentFilter.propertyDetails)
            }
        }
        
        
     
    }
    /* var propertyDetails: PropertyDetail {
     var detail = PropertyDetail()
     detail.propertyKey = groupName
     let selectedOptions = options.filter({$0.selected})
     if !selectedOptions.isEmpty {
     let values = selectedOptions.map({$0.optionNameValue}).joined(separator: ",")
     detail.propertyValue  = values
     }
     return detail
     }*/
    

   
}


