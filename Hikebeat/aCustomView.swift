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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let translatedPoint = button!.convert(point, from: self)
        if(!self.clipsToBounds && !self.isHidden && self.alpha > 0.0){
        if (button!.bounds.contains(translatedPoint)) {
            print("Your button was pressed")
            return button!.hitTest(translatedPoint, with: event)
        }
        }
        return super.hitTest(point, with: event)
    }
    
}
