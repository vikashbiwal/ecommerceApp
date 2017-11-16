    //
    //  Debouncer.swift
    //  ShoppingCartApp
    //
    //  Created by Vikash Kumar on 07/07/17.
    //  Copyright © 2017 Vikash Kumar. All rights reserved.
    //
    
    import Foundation
    
    
    class Debouncer: NSObject {
        var callback: (() -> ())
        var delay: Double
        weak var timer: Timer?
        
        init(delay: Double, callback: @escaping (() -> ())) {
            self.delay = delay
            self.callback = callback
        }
        
        func call() {
            timer?.invalidate()
            let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(Debouncer.fireNow), userInfo: nil, repeats: false)
            timer = nextTimer
        }
        
        func fireNow() {
            self.callback()
        }
    }
