//
//  ViewController.swift
//  SpeechRecognizationDemo
//
//  Created by Vikash Kumar on 26/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {


    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var speechView: SpeechView!
    var speechCompletion: (String)->Void = {_ in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechView.requestSpeechAuthorization()
        setSpeechViewBlocks()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWithAnimation()
    }
    func setSpeechViewBlocks() {
        speechView.resultBlock = {[weak self] str in
            if let weekSelf = self {
                weekSelf.lblResult.text = str
                weekSelf.speechCompletion(str)
            }
            
        }
        speechView.errorBlock = {error in
            print(error.localizedDescription)
        }
    }
    
    func showWithAnimation() {
        let ani = CABasicAnimation(keyPath: "transform.scale")
        ani.fromValue = 0.1
        ani.toValue  = 1.0
        ani.duration = 0.3
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        speechView.layer.add(ani, forKey: "scale")
    }
}

//MARK:- IBActions
extension SpeechViewController {
    @IBAction func back_btnClicked(sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func done_btnClicked(sender: UIButton) {
        
    }
}

extension SpeechViewController {
    ///func for recognize live speech. Just tap on Start button and speek, you would see your words as text.
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

