//
//  AddFeedbackInquiryVC.swift
//  ShoppingCartApp
//
//  Created by zoomi on 20/09/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import KVAlertView

class AddFeedbackInquiryVC: ParentViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var arrPhotoList: [UIImage] = []
    
    var imageData : Data!
    var numberOfItemInRow: Int {return IS_IPAD ? 8 : 4}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -  btn camera pressed

    @IBAction func btnCameraPressed(_ sender: UIButton) {
        
        print("self.arrPhotoList.count:->\(self.arrPhotoList.count)")
        
        if self.arrPhotoList.count > 3 {
            KVAlertView.show(message:"You can upload maximum 4 photos.")
            return
        }
        
        let alertController = UIAlertController(title: "Choose Image", message: "", preferredStyle: .actionSheet)
        
        // Initialize Actions
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) -> Void in
            println("Camera.")
             self.useCamera()
        }
        
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default) { (action) -> Void in
            println("Gallery.")
//            let controller = self.storyboardFeedbackInquiry.instantiateViewController(withIdentifier: "SelectPhotoVC") as! SelectPhotoVC
//            self.present(controller, animated: true, completion: nil)
            self.usePhotoPicker(sender: sender)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            println("Cancel.")
        }
        
        // Add Actions
        alertController.addAction(cameraAction)
        alertController.addAction(gallaryAction)
        alertController.addAction(cancelAction)
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.bounds
        }
        // Present Alert Controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - use camera method
    
    func useCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        } else {
            //let alertView  = showAlert("Profile", delegate: delegate, message: "You have no Camera...")
        }
    }
    
    // MARK: - use photo method
    
    func usePhotoPicker(sender: UIButton){
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .popover
        
        if IS_IPAD{
            picker.popoverPresentationController?.sourceView = self.view
            picker.popoverPresentationController?.sourceRect = sender.frame;
        }
        
        present(picker, animated: true, completion: nil)
        //picker.popoverPresentationController?.barButtonItem = sender
    }
    
    //MARK: - ImagePicker Controller Delegate Method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            print("self.arrPhotoList before:\(self.arrPhotoList.count)")
            
            self.arrPhotoList.append(chosenImage)
            
            print("self.arrPhotoList after:\(self.arrPhotoList.count)")
            
            imageData = UIImageJPEGRepresentation(chosenImage, 0.7) as Data!
            
        }
        dismiss(animated: true, completion: {
        
//            let controller = self.storyboardFeedbackInquiry.instantiateViewController(withIdentifier: "SelectPhotoVC") as! SelectPhotoVC
//            controller.arrPhotoList = self.arrPhotoList
//            self.present(controller, animated: true, completion: nil)
            
            self.tableView.reloadData()
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - btn audio comment pressed
   
    @IBAction func btnAudioCommentPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func btnDeletePhotoPressed(_ sender: UIButton) {
        
        self.arrPhotoList.remove(at: sender.tag)
        
        self.tableView.reloadData()
        
    }
    
    
    @IBAction func btnTopicPressed(_ sender: BorderButton) {
        
        let rect =  self.view.convert(sender.bounds, from: sender)
     
        let listItems = (["World Wide Developer Conference Videos","NSHipster","Ray Wenderlich","iOS Goodies","Additional Resources"], "World Wide Developer Conference Videos")
        DropDownList.show(in: self.view, listFrame: rect, listData: listItems) { topic in
            sender.setTitle(topic, for: .normal)
        }
    }

}


extension AddFeedbackInquiryVC : UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    // MARK: - tablview datasource and delegate method
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        if self.arrPhotoList.count == 0{
            return 4
        }else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 && self.arrPhotoList.count == 0{
            return 0.00001
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect (x:0, y: 0, width:10, height: 10))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 132
        }else if indexPath.section == 3 {
            return 92
        }else if indexPath.section == 4 {
            return 100
        }else {
           return 70
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section == 0 {
            let cellIdentifier = "TopicCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddFeedbackInquiryCell
            
            return cell
            
        }else if indexPath.section == 1{
            
            let cellIdentifier = "TiltleCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddFeedbackInquiryCell
            
            return cell
            
        }else if indexPath.section == 3{
            
            let cellIdentifier = "AudioCommentCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddFeedbackInquiryCell
            
            return cell
            
        }else if indexPath.section == 4{
            
            let cellIdentifier = "PickerPhotoCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddFeedbackInquiryCell
            
            if self.arrPhotoList.count > 0 {
                
                cell.selectPhotoCollectionView.reloadData()
            }
            
            return cell
            
        }else{
            
            let cellIdentifier = "CommentCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! AddFeedbackInquiryCell
            
            cell.txtvComment.layer.cornerRadius = 5.0
            cell.txtvComment.layer.masksToBounds = true
            
            cell.txtvComment.layer.borderWidth = 0.5
            cell.txtvComment.layer.borderColor =  UIColor.init(red: 204.0/255.0, green:204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
            
            return cell
            
        }
        
    }
    
    
    // MARK: - collectionview datasource and delegate method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrPhotoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenSize.width - CGFloat(40 + 10 * (numberOfItemInRow - 1)) )/CGFloat(numberOfItemInRow), height:180 * universalWidthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellPhotoLibrary = collectionView.dequeueReusableCell(withReuseIdentifier:"CameraCell", for: indexPath) as! PhotoCell
        cellPhotoLibrary.photoImageView.image = self.arrPhotoList[indexPath.row]
        cellPhotoLibrary.btnDeletePhoto.tag = indexPath.row
        return cellPhotoLibrary
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
    
        
    }

    
}

// MARK- : add feedback inquiry cell

class AddFeedbackInquiryCell: UITableViewCell {
    
    @IBOutlet weak var txtTitle: WidthTextField!
    @IBOutlet weak var txtvComment: WidthTextView!
    @IBOutlet weak var btnTopic: BorderButton!
    
   
    @IBOutlet weak var selectPhotoCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius=8
      //  self.drawShadow(0.05)
        
       

        
    }
}

// MARK- : photo cell

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var btnDeletePhoto: UIButton!
    
}
