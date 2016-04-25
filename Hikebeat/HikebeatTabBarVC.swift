//
//  HikebeatTabBarVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 23/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class HikebeatTabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        addCenterButton()
        self.tabBar.tintColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.tabBar.backgroundColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.view.tintColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.view.backgroundColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.tabBar.translucent = false
        
        //self.view.tintColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
    }
    
    func addCenterButton() {

        let centerButton = UIButton(type: UIButtonType.Custom)
        let selected = UIImage(named: "TabBarMainSelected")!
        let unselected = UIImage(named: "TabBarMainUnselected")!
        centerButton.frame = CGRectMake(0.0, 0.0, selected.size.width, selected.size.height)
        centerButton.setBackgroundImage(selected, forState: UIControlState.Selected)
        centerButton.setBackgroundImage(selected, forState: UIControlState.Highlighted)
        centerButton.setBackgroundImage(unselected, forState: UIControlState.Normal)
        centerButton.selected = true
        
        var heightDifference = self.tabBar.frame.size.height/2;
//        if (heightDifference < 0) {
//            centerButton.center = self.tabBar.center;
//        } else {
            var center:CGPoint = self.tabBar.center;
            center.y = center.y - heightDifference;
            centerButton.center = center;
//        }
        
        self.view.addSubview(centerButton)

//        centerButton.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin;
        
    }
}
