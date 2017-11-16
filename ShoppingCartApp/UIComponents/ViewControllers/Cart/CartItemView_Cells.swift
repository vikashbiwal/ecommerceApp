//
//  CartItemView_Cells.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 13/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


//MARK:- ===================AmountCell============================

class AmountCell: CollectionViewCell {
    @IBOutlet var cardView:RoundCornerView!
    
    var corners: (UIRectCorner, CGFloat) = (UIRectCorner.allCorners, 0.0) {
        didSet {
            cardView.radius = corners.1
            cardView.corners = corners.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

//MARK:- ===================CartItemCell============================

class CartItemCell: CollectionViewCell {
    
    @IBOutlet var colorListView: ColorSizeListView!
    @IBOutlet var sizeListView: ColorSizeListView!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var addFavouriteButton: UIButton!
    @IBOutlet var productDetailButton: UIButton!
    @IBOutlet var lblSize: UILabel!
    @IBOutlet var lblSizeTitle: UILabel!
    @IBOutlet var colorListHeight: NSLayoutConstraint!
    @IBOutlet var sizeListHeight: NSLayoutConstraint!
    
    @IBOutlet var charactersticsTblView: UITableView!
    weak var cartVC: CartViewController?
    
    var cartItem: CartItem! {
        didSet {
            setCartItem(info: cartItem)
            charactersticsTblView?.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorListView?.scrollDirection = .vertical
        setQuantityButtonUI()
    }
    
    func setQuantityButtonUI() {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -10 * universalWidthRatio, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(5 * universalWidthRatio, 60 * universalWidthRatio, 0, 0)
    }
    
    func setCartItem(info item: CartItem) {
        lblTitle?.text = item.product.productName
        lblSubTitle?.attributedText = showAttributedPriceString(product: item.product, font: UIFont(name: FontName.SEMIBOLD1, size: 15 * universalWidthRatio)!)
        if let url = URL(string: item.product.productImagePath) {
            imgView?.setImage(url: url)
        } else {
            imgView?.image  = nil
        }
        
        button?.setTitle("Qty : \(item.quantity)", for: .normal)
        
        lblSize?.text =  item.product.productSize
        lblSizeTitle?.text = item.product.size == nil ? "" : "Size : "
        let wishListTitle = item.product.isInWishlist ? "RemoveFromWishlist".localizedString() : "AddToWishlist".localizedString()
        addFavouriteButton?.setTitle(wishListTitle, for: .normal)
        
        colorListView?.product = item.product
        sizeListView?.product = item.product
        
        let sizes = item.product.sizeList
        let colors = item.product.size?.colorList ?? []
        sizeListHeight?.constant = sizes.count > 0 ? 30 : 0
        colorListHeight?.constant = colors.count > 0 ? 30 : 0
        
        colorListView?.backgroundColor = UIColor.clear
        sizeListView?.backgroundColor  = UIColor.clear
    }
    
    func setButtonsTag(index: Int) {
        button?.tag = index
        removeButton?.tag = index
        addFavouriteButton?.tag = index
        productDetailButton?.tag = index
        
    }
}

extension CartItemCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItem.product.characteristic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characteriticCell") as! CharacteristicTblCell
        let item = cartItem.product.characteristic[indexPath.row]
        
        cell.listView.didSelectBlock = cartVC?.sizeColorChangeBlock
        cell.listView.product = cartItem.product
        cell.listView.characteristic = item
        cell.backgroundColor = .white
        cell.listView.backgroundColor = .white
        cell.lblTitle.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = cartItem.product.characteristic[indexPath.row]
        return cartVC?.characteristicTblCellHeight(char: item) ?? 0
    }
}


class CharacteristicTblCell: TableViewCell {
    @IBOutlet var listView: ColorSizeListView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listView.scrollDirection = .vertical
    }
}

//MARK:- ===================GiftPriceCell============================

class GiftPriceCell: CollectionViewCell {
    @IBOutlet var switchBtn: UISwitch!
    
}

//MARK:- ===================ColorSizeListView============================

class ColorSizeListView: UIView {
    @IBInspectable var listViewType: Int = ItemType.color.rawValue
    @IBInspectable var itemHeight: CGFloat = 30
    @IBInspectable var itemWidth: CGFloat = 30
    @IBInspectable var itemFontSize: CGFloat = 15
    
    var collView:UICollectionView!
    
    var showPlusSign = false 
    
    var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            (collView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = scrollDirection
        }
    }
    
    
    var product: ProductDetail?
    
    var characteristic: ProductCharacteristic! {
        didSet {
            characteristicItems = characteristic.list
            setShowPlusEffect()
            collView.reloadData()
        }
    }
    
    var characteristicItems = [PDCharacter]()
    
    var selectedItem: ColorSizeItem?
    
    var didSelectBlock: ((PDCharacter, Product)->Void)?
   
    enum ItemType: Int {
        case color = 1, size = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setCollectionView()
    }
    
    
    func setCollectionView() {
        collView = UICollectionView(frame: self.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collView.dataSource = self
        collView.delegate = self
        collView.collectionViewLayout = UICollectionViewFlowLayout()
        collView.backgroundColor = UIColor.clear
        if let layout = collView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = scrollDirection
        }
        self.addSubview(collView)
        collView.register(UINib(nibName: "ColorSizeCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collView.translatesAutoresizingMaskIntoConstraints = false
        collView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        collView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        collView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        collView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        collView.bounces = false
    }
    
    func setShowPlusEffect() {
        if showPlusSign {
            var allowPlus = false
            var items = [PDCharacter]()
            _ = characteristic.list.reduce(0, { (res, item) -> CGFloat in
                let width = item.itemType == .text ? sizeOf(string: item.value).width : (itemWidth * universalWidthRatio)
                
                let newRes = res + width
                
                if newRes < self.frame.width {
                    items.append(item)
                } else {
                    allowPlus = true
                }
                
                return newRes
            })
            
            if allowPlus {
                let plusChar  = PDCharacter()
                plusChar.productId = "0"
                plusChar.value = "+"
                items.append(plusChar)
                characteristicItems = items
            }
            
        }
    }
}

//MARK: CollectionView DataSource and Delegate
extension ColorSizeListView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characteristicItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColorSizeCell
        let item = characteristicItems[indexPath.row]
        
        cell.lblSeparator.isHidden = true
        cell.lblTitle.isHidden = true
        
        if item.itemType == .image {
            let imgUrl = getImageUrlWithSize(urlString: item.value, size: cell.frame.size)
            cell.imgView.setImage(url: imgUrl)
            
        } else if item.itemType == .color {
            cell.imgView.backgroundColor = UIColor(hexString: item.value)
            
        } else {
            cell.lblTitle.text = item.value
            cell.lblTitle.isHidden = false
            
            if product!.productId.ToString() == item.productId {
                cell.setSize(seleted: true, size: 14 )
            } else {
                cell.setSize(seleted: false, size: 15)
            }
        }
        
        if showPlusSign && indexPath.row == (characteristicItems.count - 1) {
            cell.lblSeparator.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let prod = product {
            let item = characteristicItems[indexPath.row]
            didSelectBlock?(item, prod)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = characteristicItems[indexPath.row]
        let height = itemHeight * universalWidthRatio//self.frame.height
        let width = collectionView.frame.width / 10
        
        if item.itemType == .text {
            let size = sizeOf(string: item.value)
            return CGSize(width: size.width, height: height)
        } else {

            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func sizeOf(string: String)->CGSize {
        let lbl = UILabel()
        lbl.text = string
        lbl.font = UIFont(name: FontName.REGULARSTYLE1, size: itemFontSize * universalWidthRatio)
        lbl.sizeToFit()
        var size = lbl.frame.size
        size.width += 12 //with adding cell's margin
        return size
    }
}


//MARK:-=================================ColorSizeCell=======================================
class ColorSizeCell: CollectionViewCell {
    @IBOutlet var lblSeparator: UILabel!
    
    
    func setColor(selected: Bool) {
        self.imgView.layer.borderColor = selected ?  UIColor.black.cgColor : UIColor.clear.cgColor
        self.imgView.layer.borderWidth = selected ? 1.5 : 0.0
    }
    
    func setSize(seleted: Bool, size: CGFloat) {
        self.lblTitle.font = UIFont(name: (seleted ?  FontName.SANSBOLD : FontName.REGULARSTYLE1), size: (seleted ? size - 1 : size) * universalWidthRatio)
        self.lblTitle.textColor = seleted ? UIColor.black : UIColor.darkGray
    }
}



