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
    
    let centerButton = UIButton(type: UIButtonType.Custom)
    
    override func viewDidLoad() {
        addCenterButton()
        self.selectedIndex = 1
        self.tabBar.barTintColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.tabBar.tintColor = UIColor(red:176/255.0, green:250/255.0, blue:0, alpha:1.00)
        self.tabBar.translucent = false

    }
    
    func addCenterButton() {

        let selected = UIImage(named: "TabBarMainSelected")!
        let unselected = UIImage(named: "TabBarMainUnselected")!
        centerButton.frame = CGRectMake(0.0, 0.0, selected.size.width, selected.size.height)
        
        /* 
         Purposefully setting UIControlState reversed to avoid having the button return to normal when holding a pres.
         This should be fixed at some point but works perfectly right now. This means that the state "Selected" is true when
         it is not selected and visa versa.
        */
        centerButton.setBackgroundImage(selected, forState: UIControlState.Normal)
        centerButton.setBackgroundImage(unselected, forState: UIControlState.Selected)
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.selected = false
        centerButton.addTarget(self, action: #selector(HikebeatTabBarVC.centerButtonPressed), forControlEvents: UIControlEvents.TouchDown)
        
        let heightDifference = self.tabBar.frame.size.height/2;

        var center:CGPoint = self.tabBar.center;
        center.y = center.y - heightDifference;
        centerButton.center = center;
        
        self.view.addSubview(centerButton)

//        centerButton.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin;
        
    }
    
    func centerButtonPressed() {
        print("button pressed")
        self.selectedIndex = 1
        // Reverse, the button is actually pressed here.
        centerButton.selected = false
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        if item.tag != 1 {
            // Reverse, the button is actually not pressed here.
            centerButton.selected = true
        } else {
            // Reverse, the button is actually pressed here.
            centerButton.selected = false
        }
    }
}
