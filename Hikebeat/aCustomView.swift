//
//  aCustomView.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 7/3/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class aCustomView: UIView {

    var button:UIButton?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let translatedPoint = button!.convertPoint(point, fromView: self)
        if(!self.clipsToBounds && !self.hidden && self.alpha > 0.0){
        if (CGRectContainsPoint(button!.bounds, translatedPoint)) {
            print("Your button was pressed")
            return button!.hitTest(translatedPoint, withEvent: event)
        }
        }
        return super.hitTest(point, withEvent: event)
    }
    
}
