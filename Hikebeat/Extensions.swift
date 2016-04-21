//
//  Extensions.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/21/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0,forever: Bool = false, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI)
        rotateAnimation.duration = duration
        
        if(forever){
            rotateAnimation.repeatCount = HUGE
        }
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}