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
    
    let centerButton = UIButton(type: UIButtonType.custom)
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
    
    override func viewDidLoad() {
        addCenterButton()
        self.selectedIndex = 2
        self.tabBar.barTintColor = UIColor(red:0.082, green:0.404, blue:0.424, alpha:1.00)
        self.tabBar.tintColor = greenColor
        self.tabBar.isTranslucent = false
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: greenColor], for: UIControlState.selected)
       
        
        let items = self.tabBar.items
        
        for item in items! {
            switch item.title! {
            case "Journeys":
                item.selectedImage = UIImage(named:"JourneysSelected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item.image = UIImage(named:"JourneysUnselected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            case "Social":
                item.selectedImage = UIImage(named:"SocialSelected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item.image = UIImage(named:"SocialUnselected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            case "Settings":
                item.selectedImage = UIImage(named:"SettingsSelected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item.image = UIImage(named:"SettingsUnselected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            case "Profile":
                item.selectedImage = UIImage(named:"ProfileSelected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
                item.image = UIImage(named:"ProfileUnselected")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            default:
                print("default")
            }
        }
    }
    
    func addCenterButton() {
        
        let selected = UIImage(named: "TabBarMainSelected")!
        let unselected = UIImage(named: "TabBarMainUnselected")!
        centerButton.frame = CGRect(x: 0.0, y: 0.0, width: selected.size.width, height: selected.size.height)
        
        /*
         Purposefully setting UIControlState reversed to avoid having the button return to normal when holding a pres.
         This should be fixed at some point but works perfectly right now. This means that the state "Selected" is true when
         it is not selected and visa versa.
         */
        centerButton.setBackgroundImage(selected, for: UIControlState())
        centerButton.setBackgroundImage(unselected, for: UIControlState.selected)
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.isSelected = false
        centerButton.addTarget(self, action: #selector(centerButtonPressed), for: UIControlEvents.touchDown)
        
        let heightDifference = self.tabBar.frame.size.height/2;
        
        var center:CGPoint = self.tabBar.center;
        center.y = center.y - heightDifference;
        centerButton.center = center;
        
        self.view.addSubview(centerButton)
        
        //        centerButton.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin;
        
    }
    
    func centerButtonPressed() {
        self.selectedIndex = 2
        // Reverse, the button is actually pressed here.
        centerButton.isSelected = false
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 2 {
            // Reverse, the button is actually pressed here.
            centerButton.isSelected = false
        } else {
            // Reverse, the button is actually not pressed here.
            centerButton.isSelected = true
        }
        
    }
    
    func deselectCenterButton() {
        centerButton.isSelected = true
    }
}
