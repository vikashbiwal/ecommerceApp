   //
//  SimillarProductView.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 22/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


class SimillarProductView: UIView {

	var actionBlock:((Product)-> Void)?
    var relatedProductOptionActionBlock:((PDRelatedProductOption)-> Void)?
    var similarProductFilterActionBlock:((PDSimilarProductFilter)-> Void)?
    
	var sectionHeight:CGFloat = 40.0
    var selectedIndex:Int = 0

	@IBOutlet weak var tblProduct: UITableView!
	@IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    
    var currentProduct = Product()
    
    var listRequest = ProductListRequest()  //request object

	var tempArray = [SMSection] ()
	var sectionArray = [SMSection] () {
		didSet {
			let footerHeight = CGFloat(sectionArray.count) * sectionHeight
			tblHeightConstraint.constant = (190 * widthRatio) * CGFloat(sectionArray.count) + footerHeight
			self.tblProduct.reloadData()
            
            // + (40 * widthRatio)
		}
	}
    
    lazy internal var centralGrayActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "spinnerIcon_gray")!
        let v = CustomActivityIndicatorView(image: image)
        v.backgroundColor = UIColor.clear
        return v
    }()

	lazy var clearViewBlock: ()-> Void =  {
		//self.sectionArray = [SMSection] ()
		/*for var i in 0..<self.tblProduct.number {
			let indexPath = IndexPath(row: 0, section: i)
			self.tblProduct.deleteRows(at: [indexPath], with: .none)
		}*/

	}

	var presentList = false {
		didSet {
			if self.presentList {
				self.isHidden = false

				tempArray = sectionArray.map({ (section) -> SMSection in
					return section
				})
				//sectionArray = [SMSection] ()
			}
           showHideListWithAnimation()
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
        tblProduct.register(UINib(nibName:"SimillarProductHeaderView", bundle: nil), forCellReuseIdentifier: "SimillarProductHeaderView")
		tblProduct.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
		viewHeightConstraint.constant = screenSize.height - 113
		tblHeightConstraint.constant = screenSize.height - 113
		tblBottomConstraint.constant = -self.tblProduct.frame.height
		tblProduct.tableFooterView = UIView(frame: .zero)

	}

	override func draw(_ rect: CGRect) {
		super.draw(rect)
	}

	func showHideListWithAnimation() {
		self.backgroundColor = presentList ? UIColor.black.alpha(0.5) : UIColor.clear
		self.tblBottomConstraint.constant = presentList ? 0 : -self.tblProduct.frame.height
		let vAlpha: CGFloat = presentList ? 1.0 : 0.0
		UIView.animate(withDuration: 0.5) {
			self.alpha = vAlpha
			self.layoutIfNeeded()
			if !self.presentList {
				//self.sectionArray = [SMSection] ()
				self.isHidden = true
			} else {
				//self.sectionArray = self.tempArray
			}
		}
	}
}


extension SimillarProductView: UITableViewDelegate, UITableViewDataSource, selectSimilarProductFilterDelegate {

	//MARK:- TABLEVIEW DELEGATE AND DATASOURCE
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionArray.count //+ 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return sectionArray[section].itemCount
        
		
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
            let cell = tableView.dequeueReusableCell(withIdentifier: "SimillarProductCell") as! SimillarProductCell
            cell.itemView.actionBlock = actionBlock
            cell.itemView.relatedProductOptionActionBlock = relatedProductOptionActionBlock
            cell.itemView.similarProductFilterActionBlock = similarProductFilterActionBlock
		//cell.itemView.clearBlock = clearViewBlock
            if sectionArray[indexPath.section].title == "SIMILAR" {
            cell.itemView.collectionView.contentOffset.x = 0
            }
            cell.itemView.collectionView.reloadData()
            cell.itemView.productsArray = sectionArray[indexPath.section].object as! [Any]
            cell.itemView.arrSection = sectionArray
        
            cell.itemView.sectionCount = sectionArray[indexPath.section].sectionCount
        
           if sectionArray[indexPath.section].sectionCount > 1 {
            
            if sectionArray[indexPath.section].title == "RELATED" {
                
                cell.itemView.isSection = true
                
                 cell.itemView.relatedProductOptionArray = sectionArray[indexPath.section].secondObject as! [Any]
            }else{
                cell.itemView.isSection = false
                
                if  sectionArray[indexPath.section].similarFilterObject as? [Any] != nil {
                    
                    cell.itemView.arrSimilarProductFilter = sectionArray[indexPath.section].similarFilterObject as! [Any] as! [PDSimilarProductFilter]
                    cell.itemView.index = selectedIndex
                }
            }
            
            
           }
        
        
            cell.selectionStyle = .none
            return cell
        
		
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       
            return 190 * widthRatio
        
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        

            return sectionHeight
        
		
	}
    
    
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "SimillarProductHeaderView") as! SimillarProductHeaderView
        headerCell.lblProductTitle.backgroundColor = UIColor.clear
        headerCell.lblProductTitle.text = sectionArray[section].title
        headerCell.lblProductTitle.font = UIFont(name: FontName.REGULARSTYLE1, size: (15 * universalWidthRatio))
        headerCell.backgroundColor = UIColor.white
        headerCell.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));
        headerCell.similarproductfilterDelegate = self
        
        headerCell.filterProductCollectionView.isHidden = true
        if headerCell.lblProductTitle.text == "SIMILAR" {
            
            if sectionArray[section].similarFilterObject != nil {
                
                headerCell.arrsimilarProductFilter = sectionArray[section].similarFilterObject as! [PDSimilarProductFilter]
                headerCell.selectedIndex = selectedIndex

                headerCell.filterProductCollectionView.isHidden = false
                headerCell.filterProductCollectionView.reloadData()
            }

        }
        
        return headerCell
        
	}
    
   // filter
    
    
    func filterProductBySimilarProductFilter(similarProductFilterObj: PDSimilarProductFilter, index: Int) {
        
        selectedIndex = index
        
        listRequest.flag = "similar"
        
       self.showCentralGraySpinner()
        
        self.getProductList(param: listRequest.setfilterOptions(fromApiParam: similarProductFilterObj.apiParam ,andSelectedFilters: [],isSimilarProduct: true , isPropertyData: similarProductFilterObj.isPropertyData ))
    }
    
    
    func showCentralGraySpinner() {
        centralGrayActivityIndicator.center = self.tblProduct.center
        self.addSubview(centralGrayActivityIndicator)
        centralGrayActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        centralGrayActivityIndicator.alpha = 0.0
        self.layoutIfNeeded()
        self.isUserInteractionEnabled = false
        centralGrayActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralGrayActivityIndicator.alpha = 1.0
        })
    }
    
    func hideCentralGraySpinner() {
        self.isUserInteractionEnabled = true
        centralGrayActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.centralGrayActivityIndicator.alpha = 0.0
        })
    }
    

    
    
    func getProductList(param : [String:Any]) {
        
       _ = wsCall.getList(params: param) { (response) in
            
            if response.isSuccess {
                
                println("response\(response.isSuccess)")
                
                if let json = response.json as? [[String:Any]] {
                    
                     println("json\(json)")
                    
                    let aTempArray = json.map({ (productListObject) -> Product in
                        return Product(productListObject)
                        
                    })
                    
                     println("aTempArray:::\(aTempArray.count)")
                    
                    
                    let array = self.sectionArray.map({ (obj) -> SMSection in
                        var smObject = obj
                        if (obj.title == "SIMILAR") {
                            
                            if(aTempArray.count <= 10){
                                
                                smObject.sectionCount = 1
                            }else{
                                smObject.sectionCount = 2
                            }
                            
                            smObject.object = aTempArray
                            
                        }
                        
                        return smObject
                    })
                    
                    self.sectionArray = array
                    
                    self.tblProduct.reloadData()
                    
                }
            }
        
            self.hideCentralGraySpinner()
            
        }
        
    }

	/*func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
	return 40
	}
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	let lblSectionTitle = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width-10, height: 40))
	lblSectionTitle.text = String(format:"section %d", section)
	lblSectionTitle.backgroundColor = UIColor.white
	lblSectionTitle.transform = CGAffineTransform(rotationAngle: -(CGFloat)(M_PI));

	return lblSectionTitle
	}*/
}



//MARK:- SMProductsItemsView
class SMProductsItemsView:UIView,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


	var actionBlock:((Product)-> Void)?
    var relatedProductOptionActionBlock:((PDRelatedProductOption)-> Void)?
    var similarProductFilterActionBlock:((PDSimilarProductFilter)-> Void)?
	//var clearBlock:(()-> Void)?
	@IBOutlet weak var collectionView: UICollectionView!
    var arrSimilarProductFilter = [PDSimilarProductFilter]()
    
    var index:Int = 0
    
    var isSection:Bool = false
    
    var sectionCount:Int = 0
    
    var arrSection = [SMSection]()
    
    var relatedProductOptionArray = [Any]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
	var productsArray = [Any]() {
		didSet {
			self.collectionView.reloadData()
		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	//CollectionView DataSource and Delegate
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sectionCount
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        println("Section Array:\(arrSection.count)")
        
        if section == 0 {
            
            if isSection == false {
                
                if arrSimilarProductFilter.count  == 0 {
                    
                     return productsArray.count
                    
                }else{
                    
                    if productsArray.count >= 10 {
                        
                        return 10
                        
                    }else{
                        
                        return productsArray.count
                    }
                }
                
                
            }else{
            
                return productsArray.count
            }
            
            
            
        }else{
            
            if isSection == false {
                
                return 1
            }else{
                return relatedProductOptionArray.count
            }
            
            
        }
		
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SMProductCollectionViewCell", for: indexPath) as! CollectionViewCell
            let product = productsArray[indexPath.row] as! Product
            let imgUrl = getImageUrlWithSize(urlString:( product.productImagePath), size: collectionView.frame.size)
            cell.imgView.setImage(url: imgUrl)
            cell.contentView.borderWithRoundCorner(radius: 0.0, borderWidth: 0.3, color: UIColor.lightGray)
            //cell.imgView.image = UIImage(named: "imgProduct.png")
            cell.lblTitle.text = product.productName
            cell.lblSubTitle.attributedText = showAttributedPriceString(product: product, font: cell.lblSubTitle.font)
            return cell
            
        }else{
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewMoreCell", for: indexPath) as! CollectionViewCell
            
            
            if isSection == false {
                
                print("SIMILAR::")
                
                cell.contentView.borderWithRoundCorner(radius: 0.0, borderWidth: 0.3, color: UIColor.lightGray)
                cell.lblTitle.text = "View More"
                return cell
            }else{
                print("RELATED::")
                let relatedProductOption = relatedProductOptionArray[indexPath.row] as! PDRelatedProductOption
                cell.contentView.borderWithRoundCorner(radius: 0.0, borderWidth: 0.3, color: UIColor.lightGray)
                cell.lblTitle.text = relatedProductOption.name
                return cell
            }
            
            
        }
        
		

	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let product = productsArray[indexPath.row] as! Product
			// self.clearBlock?()
            self.actionBlock?(product)
            
        }else{
            
        
            if isSection == false  {
            
                let similarObj = arrSimilarProductFilter[index]
				//  self.clearBlock?()
                self.similarProductFilterActionBlock?(similarObj)
                    
                
            }else{
                let relatedProductOption = relatedProductOptionArray[indexPath.row] as! PDRelatedProductOption
				//self.clearBlock?()
                self.relatedProductOptionActionBlock?(relatedProductOption)
            }
            
            
            

        }
        
    }

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return  CGSize(width: 160 * widthRatio, height: 190  * widthRatio)
	}
	
}
   
//// MARK:- similar product header cell title
//   
//   class SimillarProductHeaderCell: UITableViewCell {
//    
//    @IBOutlet weak var lblTtile: UILabel!
//    @IBOutlet weak var filterProductCollectionView: UICollectionView!
//    
//    
//   }

