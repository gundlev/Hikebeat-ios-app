//
//  SCLExtensions.swift
//  SCLAlertView
//
//  Created by Christian Cabarrocas on 16/04/16.
//  Copyright © 2016 Alexey Poimtsev. All rights reserved.
//

import UIKit

extension Int {
    
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}

extension UInt {
    
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}

extension SCLAlertView {
    func addOkayButton() -> SCLButton {
        let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
        let darkColor = UIColor(hexString: "15676C")
        
        return addButton("Okay", backgroundColor: greenColor, textColor: darkColor, showDurationStatus: true) {}
    }
    
    func addCancelButton() -> SCLButton {
        return addButton("Cancel", backgroundColor: .darkGray, textColor: .white, showDurationStatus: true) {}
    }
    
    func addGreenButton(_ msg: String, action: @escaping () -> Void) -> SCLButton {
        let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
        let darkColor = UIColor(hexString: "15676C")
        
        return addButton(msg, backgroundColor: greenColor, textColor: darkColor, showDurationStatus: true, action: action)
    }
    
    func addYellowButton(_ msg: String, action: @escaping () -> Void) -> SCLButton {
        let yellowColor = UIColor(hexString: "F8E71C")
        let darkColor = UIColor(hexString: "15676C")
        
        return addButton(msg, backgroundColor: yellowColor, textColor: darkColor, showDurationStatus: true, action: action)
    }
    
    func addGreyButton(_ msg: String, action: @escaping () -> Void) -> SCLButton {
        return addButton(msg, backgroundColor: .darkGray, textColor: .white, showDurationStatus: true, action: action)
    }
}
