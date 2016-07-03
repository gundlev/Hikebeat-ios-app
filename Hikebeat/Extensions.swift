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

    // MARK: - Frame
    
    /**
     Redefines the height of the view
     
     :param: height The new value for the view's height
     */
    func setHeight(height: CGFloat) {
        
        var frame: CGRect = self.frame
        frame.size.height = height
        
        self.frame = frame
    }
    
    /**
     Redefines the width of the view
     
     :param: width The new value for the view's width
     */
    func setWidth(width: CGFloat) {
        
        var frame: CGRect = self.frame
        frame.size.width = width
        
        self.frame = frame
    }
    
    /**
     Redefines X position of the view
     
     :param: x The new x-coordinate of the view's origin point
     */
    func setX(x: CGFloat) {
        
        var frame: CGRect = self.frame
        frame.origin.x = x
        
        self.frame = frame
    }
    
    /**
     Redefines Y position of the view
     
     :param: y The new y-coordinate of the view's origin point
     */
    func setY(y: CGFloat) {
        
        var frame: CGRect = self.frame
        frame.origin.y = y
        
        self.frame = frame
    }
    
}

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
                          /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
                                                /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
                                                                      /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
                                                                                            /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
                                                                                                                  /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
                         
                                                                                                                                        /* iPhone 6 */        "iPhone7,2": "iPhone 6",
                                                                                                                                                              /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
                                                                                                                                                                                    /* iPhone 6S */       "iPhone8,1": "iPhone 6S",
                                                                                                                                                                                                          /* iPhone 6S Plus */  "iPhone8,2": "iPhone 6S Plus",
                                                                             
                                                                                                                                                                                                                    
                                                                   "iPhone8,4":"iPhone SE",
                                                                                                                                                                                                                                /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
                                                                                                                                                                                                                                                      /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
                                                                                                                                                                                                                                                                            /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
                                                                                                                                                                                                                                                                                                  /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
                                                                                                                                                                                                                                                                                                                        /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
                                                                                                                                                                                                                                                                                                                                              /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
                                                                                                                                                                                                                                                                                                                                                                    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
                                                                                                                                                                                                                                                                                                                                                                                          /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
                                                                                                                                                                                                                                                                                                                                                                                                                /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]


public extension UIDevice {
    
    static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        return DeviceList[identifier] ?? identifier
    }
    
    static var isIphone5: Bool {
        return modelName == "iPhone 5" || modelName == "iPhone 5C" || modelName == "iPhone 5S" || modelName == "iPhone SE" || UIDevice.isSimulatorIPhone5
    }
    
    static var isIphone4: Bool {
        return modelName == "iPhone 4S" || modelName == "iPhone 4" || UIDevice.isSimulatorIPhone4
    }
    
    static var isIphone6: Bool {
        return modelName == "iPhone 6" || UIDevice.isSimulatorIPhone6
    }
    static var isIphone6Plus: Bool {
        return modelName == "iPhone 6 Plus" || UIDevice.isSimulatorIPhone6Plus
    }
    static var isIphone6S: Bool {
        return modelName == "iPhone 6S"
    }
    static var isIphone6SPlus: Bool {
        return modelName == "iPhone 6S Plus"
    }
    
    
    static var isIpad: Bool {
        if (UIDevice.currentDevice().model.rangeOfString("iPad") != nil) {
            return true
        }
        return false
    }
    
    static var isIphone: Bool {
        return !self.isIpad
    }
    
    /// Check if current device is iPhone4S (and earlier) relying on screen heigth
    static var isSimulatorIPhone4: Bool {
        return UIDevice.isSimulatorWithScreenHeigth(480)
    }
    
    /// Check if current device is iPhone5 relying on screen heigth
    static var isSimulatorIPhone5: Bool {
        return UIDevice.isSimulatorWithScreenHeigth(568)
    }
    
    /// Check if current device is iPhone6 relying on screen heigth
    static var isSimulatorIPhone6: Bool {
        return UIDevice.isSimulatorWithScreenHeigth(667)
    }
    
    /// Check if current device is iPhone6 Plus relying on screen heigth
    static var isSimulatorIPhone6Plus: Bool {
        return UIDevice.isSimulatorWithScreenHeigth(736)
    }
    
    private static func isSimulatorWithScreenHeigth(heigth: CGFloat) -> Bool {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        return modelName == "Simulator" && screenSize.height == heigth
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