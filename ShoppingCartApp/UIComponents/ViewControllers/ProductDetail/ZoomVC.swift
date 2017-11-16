//
//  ZoomVC.swift
//  ShoppingCartApp
//
//  Created by Aklesh Rathaur on 21/07/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit

enum PreviousVC {
	case productDetail
}

class ZoomVC: ParentViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	@IBOutlet weak var collectionView:UICollectionView!
	@IBOutlet weak var pageControl:UIPageControl!


	var imageArray = [AnyObject]()
	var previousVC:PreviousVC = .productDetail
	var currentPageIndex = 0
	var isShowPageControl = true

    override func viewDidLoad() {
        super.viewDidLoad()
		if !isShowPageControl {
			self.pageControl.isHidden = true
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		self.pageControl.numberOfPages = imageArray.count
		let x = CGFloat(currentPageIndex) * self.collectionView.frame.width
		self.collectionView.contentOffset = CGPoint.init(x: x, y: 0)
		self.pageControl.currentPage = currentPageIndex

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func btnBackClicked(_ sender: Any) {
		_ = self.navigationController?.popViewController(animated: false)
	}
    

}

extension ZoomVC {

	//CollectionView DataSource and Delegate
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageArray.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZoomCell", for: indexPath) as! ZoomCell

		switch self.previousVC {
		case PreviousVC.productDetail:
			let imgGallery = self.imageArray[indexPath.row] as! PDImageGallery
			let imageUrl = getImageUrlWithSize(urlString: imgGallery.imagePath, size: self.collectionView.frame.size)
			cell.imgView.setImage(url: imageUrl)
		}
		return cell

	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellSize = collectionView.frame.size
		return CGSize(width: cellSize.width, height: cellSize.height)
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageSide =  self.view.frame.width
		let currentPage = Int(floor((scrollView.contentOffset.x - pageSide / 2) / pageSide) + 1)
		self.pageControl.currentPage = currentPage
	}


}


class ZoomCell: CollectionViewCell,UIScrollViewDelegate {

	@IBOutlet weak var scrollView:UIScrollView!

	override func awakeFromNib() {
		self.configureScrollView()
	}

	func configureScrollView()   {
		
		scrollView.delegate = self
		scrollView.alwaysBounceVertical = false
		scrollView.alwaysBounceHorizontal = false
		scrollView.flashScrollIndicators()
		scrollView.minimumZoomScale = 1.0
		scrollView.maximumZoomScale = 10.0
	}

	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.imgView
	}
}
