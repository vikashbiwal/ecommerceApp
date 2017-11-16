//
//  Product.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 20/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import Foundation
import KVAlertView

//MARK: - PRODUCT  : RESPONSE MODEL -
typealias ProductLikeBlock = (_ success: Bool) -> ()
typealias ProductDetail = Product

struct  CharacteristicItem {
    var identifier = ""
    var productID = ""
    var value = ""
    
    enum ItemType {
        case image, color, text
    }
    
    var itemType: ItemType {
        return .text
    }
    
    init(_ json: [String : String]) {
        identifier = Converter.toString(json["identifierKey"])
        productID = Converter.toString(json["productId"])
        value = Converter.toString(json["value"])
    }
}

struct Characteristic {
    var title = ""
    var items = [CharacteristicItem]()
    
    init(_ json: [String : Any]) {
        title = Converter.toString(json["characteristicName"])
        
        if let list = json["list"] as? [[String : String]] {
            items = list.map({CharacteristicItem($0)})
        }
    }
}

class Product {
    var  productId = 0
    var  productName = ""
    var  productSubTitle = ""
    var  brandName = ""
    var  productImagePath = ""
    var  isSponsored = false
    var  isNewArrival = false
    var  isInWishlist = false
    var  rating = 0.0
    var  review = 0
    var  identifierKey = ""
    var  promotionId = ""
    var  selectedsize = ""
    var  stockQuantity = 0
    var  allowedQuantity = 0
    var  multipleSize = ""
    var  multipleColor = ""
    var  keyFeatures = ""
    var  description = ""
    var  legalDisclaimer = ""
    var  selectedcolor = ""
    
    var  isLike = false
    var  likeCnt = 0
    
    var productPrice = 0.0
    var displayPrice = 0.0
    var maxPrice = 0.0
    var discountPerc = 0.0
    var GST = 0.0

	var smProduct = [Product]()
	var relatedProduct = [Product]()
	var sizeList:[PDSize] = []
	var imageGallery = [PDImageGallery]()
	var propertyList = [ProductProperty]()
	var isPriceRange = false
	var characteristic = [ProductCharacteristic]()
    var product3dview = ""
    var productSize = ""
    
    var relatedProductOption = [PDRelatedProductOption]()
    var similarProductFilter = [PDSimilarProductFilter]()
    
	init() {
	}

     init(_ json: [String : Any]) {
        self.productId = Converter.toInt(json["productId"])
        self.productName = Converter.toString(json["productName"])
        self.productSubTitle = Converter.toString(json["productSubTitle"])
        self.productPrice = Converter.toDouble(json["mrp"])
        self.displayPrice = Converter.toDouble(json["displayPrice"])
        self.brandName = Converter.toString(json["brandName"])
        self.discountPerc = Converter.toDouble(json["discountPerc"])
        self.isSponsored = Converter.toBool(json["isSponsored"])
        
        self.isNewArrival = Converter.toBool(json["isNewArrival"])
        self.isInWishlist = Converter.toBool(json["isWishlist"])
        self.rating = Converter.toDouble(json["rating"])
        self.review = Converter.toInt(json["review"])
        self.identifierKey = Converter.toString(json["identifierKey"])
        self.promotionId = Converter.toString(json["promotionId"])
        
        self.stockQuantity = Converter.toInt(json["stockQuantity"])
        self.allowedQuantity = Converter.toInt(json["allowedQuantity"])
        self.productImagePath = Converter.toString(json["productImagePath"])
        
        
        self.maxPrice = Converter.toDouble(json["maxPrice"])
        self.multipleSize = Converter.toString(json["multipleSize"])
        self.multipleColor = Converter.toString(json["multipleColor"])
        self.isLike = Converter.toBool(json["isLike"])
        self.likeCnt = Converter.toInt(json["likeCnt"])
        self.description = Converter.toString(json["description"])
        self.keyFeatures = Converter.toString(json["keyFeatures"])
        self.legalDisclaimer = Converter.toString(json["legalDisclaimer"])
        self.GST = Converter.toDouble(json["gstTax"])
        
        self.product3dview = Converter.toString(json["product3dview"])
        
        self.selectedsize = Converter.toString(json["size"])
        self.selectedcolor = Converter.toString(json["color"])
        self.productSize = Converter.toString(json["size"])
        
		if let smProductArr = json["similarProduct"] as? [[String:Any]]{
			self.smProduct = smProductArr.map({ (obj) -> Product in
				return Product(obj)
			})
		}

		if let relatedProductArr = json["relatedProducts"] as? [[String:Any]]{
			self.relatedProduct = relatedProductArr.map({ (obj) -> Product in
				return Product(obj)
			})
		}
        
        if let relatedProductOptionArr = json["relatedProductOption"] as? [[String:Any]]{
            self.relatedProductOption = relatedProductOptionArr.map({ (obj) -> PDRelatedProductOption in
                return PDRelatedProductOption(obj)
            })
        }
        
        if let similarProductFilterArr = json["similarProductFilter"] as? [[String:Any]]{
            self.similarProductFilter = similarProductFilterArr.map({ (obj) -> PDSimilarProductFilter in
                return PDSimilarProductFilter(obj)
            })
        }

		if let sizeArr = json["sizeList"] as? [[String:Any]] {
			self.sizeList = sizeArr.map({ (obj) -> PDSize in
				return PDSize(obj)
			})
		}

		if let imageArr = json["gallaryImages"] as? [[String:Any]]{
			self.imageGallery = imageArr.map({ (obj) -> PDImageGallery in
				return PDImageGallery(obj)
			})
		}

		if let propertyArr = json["property"] as? [[String:Any]]{
			self.propertyList = propertyArr.map({ (obj) -> ProductProperty in
				return ProductProperty(obj)
			})
		}

		if let characters = json["productCharacteristic"] as? [[String:Any]]{
			self.characteristic = characters.map({ (obj) -> ProductCharacteristic in
				return ProductCharacteristic(obj)
			})
		}

		if self.maxPrice == -1 || self.displayPrice < self.maxPrice {  //show + price like 99 +
			isPriceRange = true
		} else {
			isPriceRange = false
		}
    
        
	}

	var size: PDSize? {
		return sizeList.filter({$0.productId == productId.ToString()}).first
	}

	var color: PDColor? {
		return size?.colorList.filter({$0.productId == productId.ToString()}).first
	}


	func likeProduct(successBlock:@escaping ProductLikeBlock)  {
		let apiParam = ["productId" : self.productId]
		wsCall.likeUnlikeProduct(params: apiParam) { (response) in
            successBlock(response.isSuccess)
		}
	}

	func notifyProduct(successBlock:@escaping ProductLikeBlock)  {
		let apiParam = ["productId" : self.productId]
		wsCall.addProductToNotify(params: apiParam) { (response) in
			print("response is \(response)")
			successBlock(response.isSuccess)
			KVAlertView.show(message: "\(response.message)")
		}
	}
    
    var canAddInCart : Bool {
        return allowedQuantity > 0 
    }
    
    var maxQuantityToPurchase: Int {
        return allowedQuantity
    }

	var isInCart: Bool {
		return Cart.shared.productExistInCart(id: productId)
	}
}

// MARK:- RelatedProductOption

class PDRelatedProductOption {
    
    var relatedProductOptionId = ""
    var name = ""
    var counts:Int = 0
    var apiParam = ""
    var displaytext = ""
    
    convenience init(_ json:[String:Any]) {
        self.init()
        
        relatedProductOptionId = Converter.toString(json["id"])
        name = Converter.toString(json["name"])
        counts = Converter.toInt(json["counts"])
        apiParam = Converter.toString(json["apiParam"])
        displaytext = Converter.toString(json["displaytext"])
    }
    
    
}

// MARK:- similarProductFilter

class PDSimilarProductFilter {
    
    var similarProductFilterId = ""
    var similarBy = ""
    var priority:Int = 0
    var isPropertyData = false
    var apiParam = ""
    
    convenience init(_ json:[String:Any]) {
        self.init()
        
        similarProductFilterId = Converter.toString(json["id"])
        similarBy = Converter.toString(json["similarBy"])
        priority = Converter.toInt(json["priority"])
        isPropertyData = Converter.toBool(json["isPropertyData"])
        apiParam = Converter.toString(json["apiParam"])
       
    }
    
}



//MARK:- Banner
class Banner {
    var id = ""
    var imgUrlString = ""
    var imgUrl: URL? {return URL(string: imgUrlString)}
	var mobileBannerImage = ""
	var mobileBannerImgUrl: URL? {return URL(string: mobileBannerImage)}
	var bannerText = ""
	var redirectUrl = ""
	var apiParam = ""
	var isOfferBanner = false
	var isActive = false
	var isFullBanner = false

	convenience init(_ json:[String:Any]) {
		self.init()
		 id = Converter.toString(json["bannerId"])
		 imgUrlString = Converter.toString(json["bannerImage"])
		 mobileBannerImage = Converter.toString(json["mobileBannerImage"])
		 bannerText = Converter.toString(json["bannerText"])
		 redirectUrl = Converter.toString(json["redirectUrl"])
		 apiParam = Converter.toString(json["apiParam"])
		 isOfferBanner = Converter.toBool(json["isOfferBanner"])
		 isActive = Converter.toBool(json["isActive"])
		 isFullBanner = Converter.toBool(json["isFullBanner"])
	}



	/*
	"bannerId": 1,
	"bannerImage": "sample string 2",
	"mobileBannerImage": "sample string 3",
	"bannerText": "sample string 4",
	"redirectUrl": "sample string 5",
	"apiParam": "sample string 6",
	"isOfferBanner": true,
	"isActive": true,
	"isFullBanner": true
	*/
}

//MARK: -Size model -
struct ProductSize {
    var size = ""
    var productID = ""
    
    init(_ sizeDictionary: [String : Any]) {
        size = Converter.toString(sizeDictionary["size"])
        productID = Converter.toString(sizeDictionary["productid"])
    }
    
}

//MARK: - color model -
struct ProductColor {
    var colorCode = ""
    var productID = ""


    
    init(_ colorDictionary: [String : Any]) {
        colorCode = Converter.toString(colorDictionary["hexcolor"]) 
        productID = Converter.toString(colorDictionary["productid"])
    }
    
}

//MARK: - SORT BY MODEL -
struct SortBy{
   var sortBy = ""
   var sortId = ""
   var sortValue = ""
    
    init(_ sortDictionary: [String : Any]) {
        sortBy = Converter.toString(sortDictionary["sortBy"])
        sortId = Converter.toString(sortDictionary["sortId"])
        sortValue = Converter.toString(sortDictionary["sortValue"])
    }
}


//MARK:- THIS IS FOR PRODUCT ADDED IN TO CART -
class CartProducts {
    
    static let sharedInstance: CartProducts = CartProducts()
    var products = [Product]() // product which are added in to the cart
    
    
    func isProductInCart(product: Product) -> Bool {
        
               
      //  let predicate = NSPredicate(format: "productId == %i", product.productId)
        
       let product =  products.filter{($0.productId == product.productId)}
        
    if product.count > 0 {
            
            return true
            
            
        }
        
        return  false
        
    }
    
    
    func addProductInCart(product:Product) {
        
        products.append(product)
        
    }
    
    func removeProductInCart(product:Product){
        
        var currentIndex:Int = 0
        
        for (index, element) in products.enumerated() {
            
            let index1 = product.productId as NSNumber
            let index2 = element.productId as NSNumber
            
            
            if index1.int64Value == index2.int64Value{
                
                currentIndex = index
                break
            }
            
        }
        
        products.remove(at: currentIndex)
        
    }
    
    
    func editProductInCart(product: Product){
        
        
    }
    
    func getListOfAddToCartProduct() -> [Product]  {
        return products
    }
    
    
    
    func setCart(withProducts: [Product]) {
        
        products = withProducts
    }
}

class ProductCharacteristic {

	var name = ""
	var list = [PDCharacter]()

    init() {
        //
    }
	init(_ json: [String : Any]) {
		name = Converter.toString(json["characteristicName"])
		if let itemList = json["list"] as? [[String:Any]] {
			list = itemList.map({ (obj) -> PDCharacter in
				return PDCharacter(obj)
			})
		}
	}
    
}

class PDCharacter {

	var identifierKey = ""
	var productId = ""
	var value = ""
	
    enum ItemType {
        case image, color, text
    }
    
    var itemType: ItemType {
        guard let char = value.characters.first else {return .text}
        
        if char == "#" {
            return .color
        } else if value.hasPrefix("http") {
            return .image
        } else {
            return .text
        }
    }

    init() {
        //
    }
	init(_ sortDictionary: [String : Any]) {
		identifierKey = Converter.toString(sortDictionary["identifierKey"])
		productId = Converter.toString(sortDictionary["productId"])
		value = Converter.toString(sortDictionary["value"])
	}
	
}



