//
//  ProductListCell.swift
//  FashionListDemo
//
//  Created by zoomi mac9 on 6/19/17.
//  Copyright © 2017 AZ. All rights reserved.
//

import UIKit

let isOffline = true
let RsSymbol = "\u{20B9}"


class ProductListCell: CollectionViewCell, IndicatorLoader{

    @IBOutlet weak var pricelabel: UILabel!
    
    @IBOutlet weak var bottolView: UIView!
    @IBOutlet weak var sizeView: UIView!
    
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var roundedBGView: UIView!
    @IBOutlet weak var offerLabel: UILabel!
    
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var brandNameLabel: UILabel!
    
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnWishList: UIButton!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var offerbgImage: UIImageView!
    
    //IndicatorLoader Protocol's property
    var centralIndicatorView = CustomActivityIndicatorView (image: UIImage(named: spinnerIcon)!)
    var indicatorContainerView: UIView {return productImage}

    
    
    @IBOutlet weak var offLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottolViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sizeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var brandNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottolViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sizeViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottolViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sizeviewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceTopConstraint: NSLayoutConstraint!

    
   // var itemPerRow : Int = 0
    var itemPerRow : Int!{
        didSet{
            
        }
    }
    var product = Product()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        offerView.layer.zPosition = 3
        roundedBGView.layer.cornerRadius = 6.0
        roundedBGView.layer.masksToBounds = true
     }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // print("CELL LAYOUT \n")
        showColorSize(product: product)
    }
    
    func showColorSize(product : Product)
    {
        // print("Passed value is: \(itemPerRow)")
        self.bottolView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done - remove all previously added views
        self.sizeView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done - remove all previously added views
        
       // print("COLOR SIZE VIEW \n")
        
        var heightConstant = Int()
        if !IS_IPAD{
            heightConstant = 15
        }
        else{
            heightConstant = 24
        }
        
        //  let viewheight = cell.bottolView.frame.size.height < CGFloat(heightConstant) ? CGFloat(heightConstant) : cell.bottolView.frame.size.height
        let viewheight  = IS_IPAD ? 24 : 15
        
        //color view's own frame
        let colorx = 0.0
        let colory = 0.0
        let colorww = self.bottolView.frame.size.width
        let colorhh = viewheight
        
        //size view's own framee
        let sizex = 0.0
        let sizey = 0.0
        let sizeww = self.sizeView.frame.size.width
        let sizehh = viewheight
        
        
        
        //color or size box y position
        let yy = 0.0
        let xx = 0.0
        
        let colorboxsize = Double(Double(sizehh) - 2 * yy) < 12.0 ? 12.0 : Double(Double(sizehh) - 2 * yy)
        let sizeboxsize = colorboxsize
        
        
        // use reusable componenet of color
        let aTempArray = !product.multipleColor.isEmpty ? product.multipleColor.components(separatedBy: ",") : []
        
        let colors = aTempArray.map { (value : String) -> ProductColor in
            return ProductColor(["hexcolor":value,"productid":""])
        }
        
        //hard coded color
//        let colors = [ ProductColor.init(["hexcolor":"#d11d66","productid":""]) , ProductColor.init(["hexcolor":"#591eb0","productid":""]),ProductColor.init(["hexcolor":"#ffffff","productid":""]),ProductColor.init(["hexcolor":"#e0a91f","productid":""]),ProductColor.init(["hexcolor":"#d11d66","productid":""])]
        
        let aTempsizeArray = !product.multipleSize.isEmpty ? product.multipleSize.components(separatedBy: ",") : []
        
        let sizeArray = aTempsizeArray.map { (value : String) -> ProductSize in
            return ProductSize(["size":value,"productid":""])
        }
       // sizeArray.removeAll()
        
        
        if itemPerRow == 1 { //1 row
            // hide color or size view according to data available from API response
            if colors.isEmpty {
                bottolViewHeightConstraint.constant = 0
                sizeviewTopConstraint.constant = 0
            }
            else{
                bottolViewHeightConstraint.constant = 20
                sizeviewTopConstraint.constant = 5
                
            }
            
            if sizeArray.isEmpty {
                sizeViewHeightConstraint.constant = 0
                priceTopConstraint.constant = 0
            }
            else{
                sizeViewHeightConstraint.constant = 20
                priceTopConstraint.constant = 6
            }
            
        }
        else{  //grid view
            let viewheight = self.frame.size.width - 20
            if colors.isEmpty && !sizeArray.isEmpty{
                bottolViewWidthConstraint.constant = 0
                sizeViewWidthConstraint.constant = viewheight
            }
            else if !colors.isEmpty && sizeArray.isEmpty{
                sizeViewWidthConstraint.constant = 0
                bottolViewWidthConstraint.constant = viewheight
            }
            else{
                sizeViewWidthConstraint.constant = viewheight/2
                bottolViewWidthConstraint.constant = viewheight/2
            }
            
            if bottolViewTopConstraint != nil {
                 bottolViewTopConstraint.constant =  IS_IPAD ?  13 :  3
            }
            
 
        }
       
       
        
        //dynamic color from API
        let colorview = ColorView.init(x: Float(xx), y:Float(yy), width:Float(colorboxsize) , height:Float(colorboxsize) , space: 3.0, moreCount: 3) //color box height and width
        colorview.frame = CGRect(x: CGFloat(colorx), y: CGFloat(colory), width: CGFloat(colorww), height: CGFloat(colorhh))  //colorview's frame
        colorview.backgroundColor = UIColor.clear
        colorview.isUserInteractionEnabled = false
        colorview.selectedcolor = product.selectedcolor
        colorview.generateColorView(colors)
        self.bottolView.addSubview(colorview)
        
        //reusable size view
        //dynamic size from API
        let sview = SizeView(x: Float(xx), y: Float(yy), width: Float(sizeboxsize + 3), height: Float(sizeboxsize ), space: 1, moreCount: 3) //size box height and width
        sview.frame = CGRect(x: CGFloat(sizex), y: CGFloat(sizey), width: CGFloat(sizeww), height: CGFloat(sizehh))  //size view frame
        sview.backgroundColor = .clear
        sview.isUserInteractionEnabled = false
        sview.selectedsize = product.selectedsize
        sview.generateSizeView(sizeArray, itemperrow: itemPerRow)
        sview.baseView.backgroundColor =  .clear //.darkGray
        self.sizeView.addSubview(sview)

        
        //hard coded size
       /* let sizeArray = [ProductSize.init(["size":"S","productid":""]) , ProductSize.init(["size":"M","productid":""]),ProductSize.init(["size":"L","productid":""]),ProductSize.init(["size":"XL","productid":""]),ProductSize.init(["size":"XXL","productid":""]),ProductSize.init(["size":"5XL","productid":""])]
        
        let sview = SizeView(x: Float(xx), y: Float(yy), width: Float(sizeboxsize + 7), height: Float(sizeboxsize), space: 1, moreCount: 3) //size box height and width
        sview.frame = CGRect(x: CGFloat(sizex), y: CGFloat(sizey), width: CGFloat(sizeww), height: CGFloat(sizehh))  //size view frame
        sview.backgroundColor = .clear
        sview.generateSizeView(sizeArray, itemperrow: itemPerRow)
        sview.baseView.backgroundColor = .lightGray
        self.sizeView.addSubview(sview)*/

        
        
        if bottolViewHeightConstraint.constant != 0{
            self.bottolViewHeightConstraint.constant = sview.contentSize.height
           // self.sizeViewHeightConstraint.constant = self.bottolViewHeightConstraint.constant
        }
       
        if sizeViewHeightConstraint.constant != 0{
            self.sizeViewHeightConstraint.constant = sview.contentSize.height
        }
      
        
        //bottol view top constraint
     /*   if bottolViewTopConstraint != nil {
            if bottolViewHeightConstraint.constant != 0 {
                bottolViewTopConstraint.constant =  IS_IPAD ?  13 :  6
            }
            else{
                bottolViewTopConstraint.constant = 0
            }
        }
        if sizeviewTopConstraint != nil {
            if sizeViewHeightConstraint.constant != 0 {
                sizeviewTopConstraint.constant =  IS_IPAD ?  13 : UIScreen.main.isPhone6Plus ? 3 : 6
            }
            else{
                 sizeviewTopConstraint.constant = 0
            }
        }

        if priceTopConstraint != nil {
            if bottolViewHeightConstraint.constant != 0 && sizeViewHeightConstraint.constant != 0 {
                priceTopConstraint.constant =  IS_IPAD ?  13 : UIScreen.main.isPhone6 ? 6 : 6
            }
            else{
                priceTopConstraint.constant =  IS_IPAD ?  13 : UIScreen.main.isPhone6 ? 6 : 20
            }
        }*/
        
        //iphone 7 pricetopconstraint = 6, iphone 6s + sizeviewtop constraint = 3

        
        self.layoutIfNeeded()
    }
    
    

}


//MARK: - Reuseable view for color code -
class ColorView : UIScrollView {
    
    //property
    var itemX : Float
    var itemY : Float
    var itemHeight : Float
    var itemWidth : Float
    var itemSpace : Float
    let itemHSpace = 1
    var moreItemCount = 0 // 0 means no need to show +(more) button
    var selectedcolor = ""
   // var containerView : UIView
    
    
    //initializer
    init(x:Float,y:Float,width:Float,height:Float,space:Float,moreCount:Int ) { //,sview:UIView) {
        self.itemX = x
        self.itemY = y
        self.itemWidth =  width  //Float(width * Float(universalWidthRatio))
        self.itemHeight = height  //Float(height * Float(universalWidthRatio))
        self.itemSpace = space
        self.moreItemCount = moreCount
       // self.containerView = sview
        super.init(frame: CGRect.zero)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
   
    
    //method  which add color item on view
    func generateColorView(_ colors:[ProductColor]){
    
       var totalcount = colors.count
        
       var buttonshowncount = Int( floor(Double(self.frame.size.width) / Double(itemWidth + itemSpace) ))
        
        var  count = 0
        if buttonshowncount > totalcount { //no need to show more + buttn
            buttonshowncount = totalcount
            count = buttonshowncount
        }
        else{ //show more button
            count = buttonshowncount - 1 // - 1 for showing more button
        }

        
     
        

        var i = 0
       //color button
        while i < count {
            let color = colors[i]
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x:Int(itemX), y: Int(itemY), width: Int(itemWidth), height:Int(itemHeight))
            
            let hexstring = color.colorCode
            if hexstring.characters.first == "#"{
               /* if hexstring == "#ffffff" {
                    button.borderWithRoundCorner(radius: 0.0, borderWidth: 1, color: .black)
                    button.frame = CGRect(x:Int(itemX), y: Int(itemY), width: Int(itemWidth), height:Int(itemHeight))
                }*/
            } //hex color
            else{
                let urlString = hexstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let sizeUrl = String(format: "%@?w=%d&h=%d",urlString,Int((button.frame.size.width)*2),Int((button.frame.size.height)*2))
                
               button.setImage(url: URL(string: sizeUrl)!, placeholder: UIImage(), completion: { (img) in
                button.setImage(img, for: .normal)
               })
            }//image in color
            
            //show selected color
            if hexstring == selectedcolor  || hexstring == "#ffffff" {
                button.borderWithRoundCorner(radius: 0.0, borderWidth: 1, color: .black)
            }
           
            button.backgroundColor = UIColor.init(hexString: hexstring)
            // button.addTarget(self, action:Selector(""), for: .touchUpInside)
            self.addSubview(button)
            itemX += itemWidth + itemSpace
            
            
            i += 1
            
        }
        
        //show + button if color is more than moreItemCount
        if totalcount > buttonshowncount || count == buttonshowncount - 1 {
         
       // if moreItemCount != 0 && colors.count > moreItemCount  && ( i < colors.count  && i == count) {
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x:Int(itemX), y: Int(itemY), width: Int(itemWidth), height:Int(itemHeight))
            button.backgroundColor = UIColor.clear
            button.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            button.setTitle("+", for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            // button.addTarget(self, action:Selector(""), for: .touchUpInside)
            self.addSubview(button)
            itemX += itemWidth + itemSpace
            
        }

        
       
        var scrollwidth = Double(itemX + itemWidth + itemSpace)
        
        if Double(self.frame.size.width) <= scrollwidth {
            scrollwidth = Double(self.frame.size.width)
        }
        
        self.contentSize = CGSize(width:scrollwidth, height: Double(2 * itemY + itemHeight))

        
       // self.contentSize = CGSize(width: Double(itemX + itemWidth + itemSpace), height: Double(itemY + itemHeight))
        
        
    }

    
}

//MARK:- reusable Size View -
class SizeView : UIScrollView {
    
    //property
    var itemX : Float
    var itemY : Float
    var itemHeight : Float
    var itemWidth : Float
    var itemSpace : Float
    let itemHSpace = 1
    var moreItemCount = 0 // 0 means no need to show +(more) button
    var selectedsize = ""
    // var containerView : UIView
    
    var baseView = UIView()
    
    
    
    //initializer
    init(x:Float,y:Float,width:Float,height:Float,space:Float,moreCount:Int ) { //,sview:UIView) {
        self.itemX = x
        self.itemY = y
        self.itemWidth = width //Float(width * Float(universalWidthRatio))
        self.itemHeight = height//Float(height * Float(universalWidthRatio))
        self.itemSpace = space
        self.moreItemCount = moreCount
        // self.containerView = sview
        super.init(frame: CGRect.zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createBaseView()  {
        baseView = UIView(frame: CGRect(x: CGFloat(itemX), y: CGFloat(itemY), width: CGFloat(itemWidth), height: CGFloat(itemHeight)))
        self.addSubview(baseView)
    }
    
    
    //method  which add color item on view
   // func generateSizeView(_ sizes:[ProductSize], itemperrow: Int)
    func generateSizeView(_ sizes:[ProductSize], itemperrow: Int){
        
        createBaseView()
    
        
        var totalcount = sizes.count
        
        var buttonshowncount = Int( floor(Double(self.frame.size.width) / Double(itemWidth + itemSpace) ))
        
        var  count = 0
        if buttonshowncount > totalcount { //no need to show more + buttn
            buttonshowncount = totalcount
            count = buttonshowncount
        }
        else{ //show more button
            count = buttonshowncount - 1 // - 1 for showing more button
        }
        
        
        var i = 0
        
        
        
        //color button
        while i < count {
            let size = sizes[i]
            
            let button = Style1WidthButton()    //UIButton(type: .custom)
            button.frame = CGRect(x:Int(itemX), y: Int(0), width: Int(itemWidth), height:Int(itemHeight))
            button.backgroundColor = UIColor.white
            button.setTitle("  " + size.size + " ", for: .normal)
            button.setTitleColor(.darkGray, for: .normal)
            button.titleFont = UIFont(name: FontName.REGULARSTYLE1, size: 10 * universalWidthRatio)!
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            // button.titleLabel?.adjustsFontSizeToFitWidth = true
            // button.addTarget(self, action:Selector(""), for: .touchUpInside)
            if i == 0  {  //&& itemperrow == 1  {
                button.setTitle(size.size , for: .normal)
                if count == 1 {
                    button.contentHorizontalAlignment = .center
                }
                else{
                    button.contentHorizontalAlignment = .left
                }
                
            }
            else{
                button.setTitle(" " + size.size + " ", for: .normal)
                button.contentHorizontalAlignment = .center
            }
            
            let boundingRect = size.size.boundingRect(with: CGSize(width:100 , height: Int(itemHeight)),
                                                      options: .usesLineFragmentOrigin,
                                                      attributes: [NSFontAttributeName: button.titleFont],
                                                      context: nil)
            var buttonframe =  button.frame
            if i == 0 && itemperrow == 1  {
                
                buttonframe.size.width = CGFloat(Int(boundingRect.width) + 10)
                
            }
            else{
                
                buttonframe.size.width = CGFloat((Float(itemWidth) > Float(boundingRect.width + 10 )) ? Float(itemWidth) :Float( boundingRect.width + 10))
                
            }
            button.frame = buttonframe
            
            //selected size logic
            if size.size == selectedsize {
                //set attributed text
                //                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: (button.titleLabel?.text)!)
                //                attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, attrString.length))
                //                attrString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.darkGray, range: NSMakeRange(0, attrString.length))
                //                button.setAttributedTitle(attrString , for: .normal)
                button.titleFont = UIFont(name: FontName.SANSBOLD, size: 12 * universalWidthRatio)!
                
                
                
                
            }
            
            baseView.addSubview(button)
            
            //add vertical label between 2 button
            if i != totalcount - 1{
                let vrStart : Float = 3
                let vrLabel = UILabel(frame: CGRect(x:Int(button.frame.origin.x + button.frame.size.width), y:Int(vrStart), width:1, height:Int(itemHeight - vrStart) ))
                vrLabel.backgroundColor = .darkGray
                //vrLabel.translatesAutoresizingMaskIntoConstraints = false
                baseView.addSubview(vrLabel)
            }
            
            ////logic end here
            
            itemX += Float(buttonframe.size.width) + itemSpace
            
            
            i += 1
        }
        
        
        //show + button if color is more than moreItemCount
         if totalcount > buttonshowncount || count == buttonshowncount - 1 {
       // if moreItemCount != 0 && sizes.count > moreItemCount && ( i < sizes.count  && i == count) {
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x:Int(itemX), y: Int(itemY), width: Int(itemWidth), height:Int(itemHeight))
            button.backgroundColor = UIColor.white
            button.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            button.setTitle("+", for: .normal)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            // button.addTarget(self, action:Selector(""), for: .touchUpInside)
            baseView.addSubview(button)
            itemX += itemWidth + itemSpace
            
        }
        
        var bframe = baseView.frame
        bframe.size.width = CGFloat(itemX - (itemWidth + itemSpace) )
        baseView.frame = bframe
        
        var scrollwidth = Double(itemX + itemWidth + itemSpace)
        
        if Double(self.frame.size.width) <= scrollwidth {
            scrollwidth = Double(self.frame.size.width)
        }
       
        self.contentSize = CGSize(width:scrollwidth, height: Double(itemY + itemHeight))
        
        
        
    }
    
    
}

extension UIScreen {
    
    var isPhone4: Bool {
        return self.nativeBounds.size.height == 960;
    }
    
    var isPhone5: Bool {
        return self.nativeBounds.size.height == 1136;
    }
    
    var isPhone6: Bool {
        return self.nativeBounds.size.height == 1334;
    }
    
    var isPhone6Plus: Bool {
        return self.nativeBounds.size.height == 2208;
    }
    
    
}

/*class Pro {
   var colors = [ProductColor]()
    
    init(json : [String : Any]) {
        
        if let jcolors =  json["colors"] as? [[String : Any]] {
            colors = jcolors.map({ (jcolor) -> ProductColor in
                return ProductColor(jcolor)
            })
        }
    }
}*/
