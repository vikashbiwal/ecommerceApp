//
//  ImageCaching.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 01/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


extension UIImageView {
    
    func setImage(url: URL, placeholder: UIImage? = nil, completion:((UIImage?)->Void)? = nil)  {
        self.image = placeholder
        ImageCache.downloadImage(from: url) {image in
            DispatchQueue.main.async {
                if let img = image {
                    self.image = img
                }
                completion?(image)
            }
        }
    }
}

extension UIButton {
    func setImage(url: URL, placeholder: UIImage? = nil, completion:((UIImage?)->Void)? = nil)  {
        self.setImage(placeholder, for: .normal)
        ImageCache.downloadImage(from: url) {image in
            DispatchQueue.main.async {
                if let img = image {
                    self.setImage(img, for: .normal)
                }
                completion?(image)
            }
        }
    }
    
    func setBackgroundImage(url: URL, placeholder: UIImage? = nil, completion:((UIImage?)->Void)? = nil) {
        self.setBackgroundImage(placeholder, for: .normal)
        ImageCache.downloadImage(from: url) {image in
            DispatchQueue.main.async {
                if let img = image {
                    self.setBackgroundImage(img, for: .normal)
                }
                completion?(image)
            }
        }
        
    }
}

//ImageCache
class ImageCache {
    static let sharedCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "ImageStorageCache"
        cache.countLimit = 1000
        cache.totalCostLimit = 100*1024*1024
        return cache
    }()
    
    
   class func downloadImage(from url: URL, completion:@escaping ((UIImage?)->Void)) {
        if let image = ImageCache.sharedCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            completion(image)
        } else {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let _ = error {
                    //print(err.localizedDescription)
                    completion(nil)
                } else {
                    if let data = data {
                        if let image = UIImage(data: data) {
                            ImageCache.sharedCache.setObject(image, forKey: url.absoluteString as AnyObject, cost: data.count)
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                }
            }).resume()
        }
    }
    
}
