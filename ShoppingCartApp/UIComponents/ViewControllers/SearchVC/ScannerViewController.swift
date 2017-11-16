//
//  ViewController.swift
//  QRReaderDemo
//
//  Created by Vikash Kumar on 28/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import  KVAlertView

class ScannerViewController: ParentViewController {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var scannerCompletionBlock: (String)-> Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorizationForCameraAccess()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }

}

//MARK:- IBActions
extension ScannerViewController {
    @IBAction func back_btnClicked(sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func done_btnClicked(sender: UIButton) {
        
    }
}

//MARK:- AVCaptureSession preparation.
extension ScannerViewController {
    //Prepare camera capture session.
    func prepareScanner() {
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var deviceInput: AVCaptureDeviceInput
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let err{
            return print(err.localizedDescription)
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        } else {
            return print("Your device does not support scanning a code from an item. Please use a device with a camera")
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        let scanAreaView = UIView()
        scanAreaView.layer.borderColor = UIColor.red.cgColor
        scanAreaView.backgroundColor = UIColor.clear
        scanAreaView.layer.borderWidth = 2.5
        scanAreaView.frame.size = CGSize(width: 300, height: 250)
        scanAreaView.center = self.view.center
        let scanRect = scanAreaView.frame
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            print(metaDataOutput.availableMetadataObjectTypes)
            metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeUPCECode,
                                                  AVMetadataObjectTypeCode39Code,
                                                  AVMetadataObjectTypeCode39Mod43Code,
                                                  AVMetadataObjectTypeEAN13Code,
                                                  AVMetadataObjectTypeEAN8Code,
                                                  AVMetadataObjectTypeCode93Code,
                                                  AVMetadataObjectTypeCode128Code,
                                                  AVMetadataObjectTypePDF417Code,
                                                  AVMetadataObjectTypeQRCode,
                                                  AVMetadataObjectTypeAztecCode,
                                                  AVMetadataObjectTypeDataMatrixCode,
                                                  AVMetadataObjectTypeITF14Code]
            
        } else  {
            return print("can't add meta data output")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        metaDataOutput.rectOfInterest = previewLayer.metadataOutputRectOfInterest(for: scanRect)
        self.view.addSubview(scanAreaView)
        self.view.bringSubview(toFront: navigationBarView)
    }
    
    //Request authorization for camera access
    func requestAuthorizationForCameraAccess() {
        let deviceType = AVMediaTypeVideo
        let status = AVCaptureDevice.authorizationStatus(forMediaType: deviceType)
        switch status {
        case .authorized:
            prepareScanner()
        case .denied:
            KVAlertView.show(message:"CameraAcceesDenied".localizedString())
            break
            
        default:
            AVCaptureDevice.requestAccess(forMediaType: deviceType, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.prepareScanner()
                    }
                }
            })
        }
    }

}


//AVCatureMetaDataOutput delegate
extension ScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            print(readableObject.stringValue)
            self.navigationController?.dismiss(animated: false, completion: nil)
            let vc = (_appDelegator.tabBarVC.selectedViewController as! UINavigationController).viewControllers.last as! ParentViewController
            ProductDetailVC.showProductDetail(in: vc, productId: "0", product: nil,isFromCart: false, identifier: readableObject.stringValue, shouldShowTab: false)
        }

    }
    
}


