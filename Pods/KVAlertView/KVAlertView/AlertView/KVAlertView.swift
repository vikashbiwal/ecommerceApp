//
//  KVAlertView.swift
//  KVAlertView
//
//  Created by Vikash Kumar on 09/06/17.
//  Copyright © 2017 Vikash Kumar. All rights reserved.
//

import UIKit
import AudioToolbox

var viewHeight:CGFloat = 50.0
private var hideDelayTime: TimeInterval = 1.5
private var singleMessageHideDelayTime: TimeInterval = 3.0
private var showAnimationDuration = 0.3
private var hideAnimationDuration = 0.4

public class KVAlertView: UIView {
    let screen = UIScreen.main.bounds
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var roundCornerView: UIView!
    @IBOutlet weak var popupViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblMessage: UILabel!
    
    var message: String = "This is notification message! Thank you." {
        didSet {
         setMessage()
        }
    }
    
    //Public variables
    public var bgColor = UIColor.black//UIColor(colorLiteralRed: 209.0/255.0, green: 215.0/255.0, blue: 231.0/255.0, alpha: 0.8)
    public var textColor: UIColor = UIColor.white
    public var isAllowVibration  = false
    
    //class variables
    static var alertQueue = AlertQueue()
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setUI()
        self.setMessage()
    }
    
    
    fileprivate func setUI() {
        self.frame = CGRect(x: 0.0, y: 0.0, width: screen.size.width, height: viewHeight + 20)
        popupViewTopConstraint.constant = -viewHeight
        self.layoutIfNeeded()

        self.backgroundColor = UIColor.clear
        self.roundCornerView.backgroundColor = bgColor
        self.popupView.backgroundColor = .clear
        self.lblMessage.textColor = textColor
        
        
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.7
        popupView.layer.shadowOffset = CGSize.zero
        popupView.layer.shadowRadius = 2
        popupView.layer.zPosition = 15
    }
    
    fileprivate func setMessage() {
        lblMessage.text = message
    }
    
}



//MARK: Class functions
extension KVAlertView {
   public class func show(message: String) {
        let alert = loadViewFromNib()
        alert.message =  message
        
        alertQueue.enqueue(alert: alert)
        alertQueue.showAlert()
    }
    
    fileprivate class func loadViewFromNib()-> KVAlertView {
        let bundle = Bundle(for: KVAlertView.self)
        let views = bundle.loadNibNamed("KVAlertView", owner: nil, options: nil) as! [UIView]
        let alert = views[0] as! KVAlertView
        return alert
    }
    
}

//MARK: AlertQueue
class AlertQueue {
    var alerts = [KVAlertView]()
    
    var count: Int {return alerts.count}
    
    func enqueue(alert: KVAlertView) {
        alerts.append(alert)
    }
    
    func dequeue()-> KVAlertView? {
        return alerts.isEmpty ? nil : alerts.removeFirst()
    }
    
    var frontAlert: KVAlertView? {return alerts.isEmpty ? nil : alerts.first}
}
    
//action for showing alertview.
extension AlertQueue {
    
    func showAlert() {
        if count == 1 {
            showNextAlertAfter(delay: DispatchTime.now())
        }
    }
    
    
    fileprivate func showNextAlertAfter(delay: DispatchTime) {
        self.showWithAnimation(delay: delay)
    }

    
    fileprivate func showWithAnimation(delay: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if let frontAlert = self.frontAlert {
                let window = UIApplication.shared.delegate?.window!
                window?.addSubview(self.frontAlert!)
                
                let anim = CABasicAnimation(keyPath: "position.y")
                anim.duration = showAnimationDuration
                anim.fromValue = -((viewHeight/2) + 20)
                anim.toValue = (viewHeight/2) + 20
                //anim.delegate = self
                frontAlert.popupView.layer.add(anim, forKey: "showanimation")
                frontAlert.popupViewTopConstraint.constant = 20
                self.hideWithAnimation()
                
                if frontAlert.isAllowVibration {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
    
    
    fileprivate func hideWithAnimation() {
        let delay = DispatchTime.now() + (KVAlertView.alertQueue.count > 1 ? hideDelayTime : singleMessageHideDelayTime)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            let front = self.dequeue()
            if KVAlertView.alertQueue.count > 0 {
                self.showNextAlertAfter(delay: DispatchTime.now())
                
            } else {
                let anim = CABasicAnimation(keyPath: "position.y")
                anim.fromValue = (viewHeight/2) + 20
                anim.duration = hideAnimationDuration
                anim.toValue = -((viewHeight/2) + 20)
                front?.popupView.layer.add(anim, forKey: "Hideanimation")
                front?.popupViewTopConstraint.constant = -(viewHeight + 20)
                
            }
            self.removeFromSuperview(delay: DispatchTime.now() + 0.5, alert: front!)

        }
    }
    
    
    fileprivate func removeFromSuperview(delay: DispatchTime, alert: KVAlertView) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            alert.removeFromSuperview()
        }
    }
    
}


//Userd for set blur effect in a view.
class AlertBlurView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0.0
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubview(toBack: blurEffectView)
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}

