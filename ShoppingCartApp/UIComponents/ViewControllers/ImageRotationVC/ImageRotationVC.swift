//
//  ImageRotationVC.swift
//  ShoppingCartApp
//
//  Created by Vikash Kumar on 21/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit


//let urlString = "http://digitalhotelgroup4.zoomi.in:202/api/Product/ProductGet360Images?ProductId=3350&IdentifierKey="

class ImageRotationVC: ParentViewController {
    @IBOutlet  var imageView: AnimatingImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblProgress: UILabel!
    
    var images  = [Int : UIImage]()
    var productId = ""
    var product: Product!
    
    var totalImages = 0
    
    var groupCounter = 0 {
        didSet{
            self.setProgress()

            if groupCounter == 0 {
                let imgs = self.images.map({$0.key}).sorted(by: { (v1, v2) -> Bool in
                    return v1 < v2
                }).map({self.images[$0]!})
                
              // let imgs = imgs1.map({$0.imageFlippedForRightToLeftLayoutDirection()})
                
                println(imgs )
                self.imageView.images = imgs
                self.imageView.enablePanGesture = true
                self.play_btnClicked(btnPlay)
                self.hideCentralSpinner()
            }
            
        }
    }
    
    func setProgress() {
        DispatchQueue.main.async {
            let completeDownload: Double = Double(self.totalImages - self.groupCounter)
            let progress = (completeDownload/Double(self.totalImages)) * 100.0
            print("Progress \(progress)")
            
            //self.lblProgress.text! += "\(progress)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        getImages()
        self.imageView.setImage(url: URL(string: product.productImagePath)!)
        // Play/Pause action handler
        imageView.playPauseStateChangeBlockHR = {[weak self] isPlaying in
            let btnTitle = isPlaying ? "Pause" : "Play"
            self?.btnPlay.setTitle(btnTitle, for: .normal)
            self?.btnPlay.isSelected = isPlaying
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.stopAnimation()
    }
    
    @IBAction func play_btnClicked(_ sender: UIButton) {
        sender.isSelected ? imageView.stopAnimation() : imageView.startAnimation()
        //sender.isSelected = !sender.isSelected
    }
    
    deinit {
        println("ImageRotationVC deinit")
    }
}

extension ImageRotationVC {
    func getImages() {//    /*ProductId=3350  IdentifierKey=as2d5sd */

        self.showCentralSpinner(uiInteractionEnable: true)
        let params = ["ProductId": productId, "IdentifierKey":""]
        wsCall.GetProdutImages(params: params) { (response) in
            if response.isSuccess {
                if let json = response.json as? [String : Any] {
                    let imageArray = (json["images"] as? [String]) ?? []
                   
                    let hrCount = Converter.toInt(json["horizontalSize"])
                    let vrCount = Converter.toInt(json["verticleSize"])
                    self.imageView.countHR = hrCount
                    self.imageView.countVR = vrCount
                    
                    self.downloadImages(imagesURls: imageArray)
                }
            } else {
                self.hideCentralSpinner()
            }
        }
        
    }
    
    func downloadImages(imagesURls: [String]) {
        let queue = DispatchQueue(label: "com.azure.downloadImage")
        
        totalImages = imagesURls.count
        groupCounter = imagesURls.count
        
        for (index, urlStr) in imagesURls.enumerated() {
            let downloadItem = DispatchWorkItem(block: {
                self.downloadImage(url: urlStr, index: index)
            })
            queue.sync(execute: downloadItem)
        }
    }
    
    func downloadImage(url: String, index: Int) {
        do {
            if let imgUrl = URL(string: url) {
                let data = try Data(contentsOf: imgUrl)
                
                let image = UIImage(data: data)
                
                self.images[index] = image
            }
        } catch {
            //
        }
      self.groupCounter -= 1 //counter will notify to controller, all images downloads completed or not.

    }
    
}
