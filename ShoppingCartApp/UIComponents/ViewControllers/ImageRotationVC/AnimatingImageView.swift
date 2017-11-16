//
//  AnimationImage.swift
//  HrAndVrImageRotation
//
//  Created by zoomi mac9 on 10/10/17.
//  Copyright © 2017 AZ. All rights reserved.
//

import Foundation
import UIKit
enum scrollDirection : Int {
    case Hr = 0, Vr = 1
}

class AnimatingImageView: UIImageView {
    var images = [UIImage]()
    
    fileprivate var currentHRIndex = 0
    fileprivate var currentVRIndex = 0
    
    var countHR = 0
    var countVR = 0
    
    var currentDirection = scrollDirection(rawValue: 0)
    
    fileprivate weak var timer: Timer?
    
    var lastPanLoc: CGPoint!
    class Scroll {
        var isScrolling = false
        var scrollCount = 0 {
            didSet {
                completedCount = 0
            }
        }
        var completedCount = 0
        var canScroll: Bool {
            completedCount += 1
            return completedCount <= scrollCount
        }
    }
    
    var scroll: Scroll = Scroll()
    
    var playPauseStateChangeBlockHR: ((Bool)->Void)?
    var playPauseStateChangeBlockVR: ((Bool)->Void)?
    
    var enablePanGesture: Bool = false{
        didSet {
            if enablePanGesture {
                let pangGesutre = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler(gest:)))
                self.addGestureRecognizer(pangGesutre)
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    func startAnimation(_ interval: TimeInterval = 0.5, direction : scrollDirection = .Hr) {
        currentDirection = direction
        changeImage()
        let imgs = self.images
        if  timer == nil, imgs.count > 0{
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timeHandler(timer:)), userInfo: nil, repeats: true)
        }
        playPauseStateChangeBlockHR?(true)

//        if direction == .Hr {
//        }
//        else{
//            playPauseStateChangeBlockVR?(true)
//        }
        
    }
    
    func stopAnimation(_ direction : scrollDirection = .Hr) {
        timer?.invalidate()
        timer = nil
        playPauseStateChangeBlockHR?(false)

//        if direction == .Hr {
//            playPauseStateChangeBlockHR?(false)
//        }
//        else{
//            playPauseStateChangeBlockVR?(false)
//        }
//
        
    }
    
    @objc func timeHandler(timer: Timer?) {
        if currentDirection == scrollDirection.Hr {
            currentHRIndex += 1
        }
        else{
            currentVRIndex += 1
        }
        changeImage()
    }
    
    func changeImage() {
        if scroll.isScrolling && !scroll.canScroll {
            scroll.isScrolling = false
            stopAnimation(currentDirection!)
        }
        let images = self.images
        if images.count  > 0 {
            if currentDirection == scrollDirection.Hr {
                
                if currentHRIndex >= countHR || currentHRIndex < 0{
                    currentHRIndex = 0
                }
                // self.image = images[currentHRIndex]
                
            }
            else{
                
                if currentVRIndex >= countVR || currentVRIndex < 0{
                    currentVRIndex = 0
                }
                //self.image = images[currentVRIndex]
            }
            setImageInImageview()
            
            
        }
    }
    
    deinit {
        //  println("AnimatingImageView deinit")
    }
    
    func setImageInImageview(){
        let str = String(format: "%d.%d.png", currentHRIndex,currentVRIndex)
        print("image name is \(str)")
        let imageIndex = Int((currentVRIndex * countHR) + currentHRIndex)
        self.image = images[imageIndex]
        
    }
}

extension AnimatingImageView {
    
    @objc func panHandler(gest: UIPanGestureRecognizer) {
        let panLocation  = gest.location(in: self)
        let velocity = gest.velocity(in: self)
        func shouldChangeImage()->Bool {
            let panOffset = abs(lastPanLoc.x - panLocation.x)
            return panOffset < 3 ? false : true
        }
        
        if gest.state == .began {
            lastPanLoc = panLocation
            self.stopAnimation(currentDirection!)
            
        } else if gest.state == .changed {
            if shouldChangeImage() {
                let xDisplacement = abs(panLocation.x - lastPanLoc.x)
                let yDisplacement = abs(panLocation.y - lastPanLoc.y)
                
                
                currentDirection =  xDisplacement > yDisplacement ? .Hr : .Vr
                
                if currentDirection == scrollDirection.Hr {
                    if panLocation.x > lastPanLoc.x { //pan direction - left to Right
                        currentHRIndex += 1
                        
                    } else { //pan direction - Right to Left
                        currentHRIndex -= 1
                        if currentHRIndex < 0 {
                            
                            
                            currentHRIndex  = countHR - 1
                        }
                    }
                } //if hr
                else{
                    
                    if panLocation.y < lastPanLoc.y { //pan direction - up to down
                        currentVRIndex += 1
                        
                    } else { //pan direction - down to up
                        currentVRIndex -= 1
                        if currentVRIndex < 0 {
                            
                            
                            currentVRIndex  = countVR - 1
                        }
                    }
                } // else vr
                
                
                
                self.changeImage()
                lastPanLoc = panLocation
            }
            
        } else if gest.state == .ended {
        }
        
    }
    
    
}

