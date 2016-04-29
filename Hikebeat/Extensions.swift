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
    
    func animateConstraintWithDuration(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, options: UIViewAnimationOptions = [], completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay:delay, options:options, animations: { [weak self] in
            self?.layoutIfNeeded() ?? ()
            }, completion: completion)
    }
    
    struct Constants {
        static let ExternalBorderName = "externalBorder"
    }
    
    func addExternalBorder(borderWidth: CGFloat = 2.0, borderColor: UIColor = UIColor.whiteColor()) -> CALayer {
        let externalBorder = CALayer()
        externalBorder.frame = CGRectMake(-borderWidth, -borderWidth, frame.size.width + 2 * borderWidth, frame.size.height + 2 * borderWidth)
        externalBorder.borderColor = borderColor.CGColor
        externalBorder.borderWidth = borderWidth
        externalBorder.name = Constants.ExternalBorderName
        
        layer.insertSublayer(externalBorder, atIndex: 0)
        layer.masksToBounds = false
        
        return externalBorder
    }
    
    func removeExternalBorders() {
        layer.sublayers?.filter() { $0.name == Constants.ExternalBorderName }.forEach() {
            $0.removeFromSuperlayer()
        }
    }
    
    func removeExternalBorder(externalBorder: CALayer) {
        guard externalBorder == Constants.ExternalBorderName else { return }
        externalBorder.removeFromSuperlayer()
    }

}

extension UIColor {
    public convenience init?(hexStringWithAlpha: String) {
        let r, g, b, a: CGFloat
        
        var start = hexStringWithAlpha.startIndex
        
        if hexStringWithAlpha.hasPrefix("#") {
            start = hexStringWithAlpha.startIndex.advancedBy(1)
        }
        
        let hexColor = hexStringWithAlpha.substringFromIndex(start)
        
        if hexColor.characters.count == 8 {
            let scanner = NSScanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexLongLong(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        
        return nil
    }

    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        
        var start = hexString.startIndex
        
        if hexString.hasPrefix("#") {
            start = hexString.startIndex.advancedBy(1)
        }
        
        let hexColor = hexString.substringFromIndex(start)
        
        if hexColor.characters.count == 6 {
            let scanner = NSScanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexLongLong(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }
        
        return nil
    }

}


extension CAGradientLayer {
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = UIColor(red: (15/255.0), green: (118/255.0), blue: (128/255.0), alpha: 1)
        let bottomColor = UIColor(red: (84/255.0), green: (187/255.0), blue: (187/255.0), alpha: 1)
        
        let gradientColors: Array <AnyObject> = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}