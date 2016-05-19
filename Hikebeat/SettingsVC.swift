//
//  SettingsVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var gpsSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var syncButton: UIButton!
    
    @IBOutlet weak var syncPictures: UIImageView!
    @IBOutlet weak var syncMemos: UIImageView!
    @IBOutlet weak var syncVideos: UIImageView!
    
    
    @IBOutlet weak var settingsContainer: UIView!
    
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
    let yellowColor = UIColor(red:248/255.0, green:231/255.0, blue:28/255.0, alpha:1.00)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (UIDevice.isIphone5){
            settingsContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
            settingsContainer.transform = CGAffineTransformTranslate( settingsContainer.transform, 0.0, -50.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
                settingsContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                settingsContainer.transform = CGAffineTransformTranslate( settingsContainer.transform, 0.0, 40.0  )
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        syncPictures.layer.cornerRadius = syncPictures.bounds.width/2
        syncMemos.layer.cornerRadius = syncMemos.bounds.width/2
        syncVideos.layer.cornerRadius = syncVideos.bounds.width/2
        syncButton.layer.cornerRadius = syncButton.bounds.height/2
        
        syncPictures.layer.masksToBounds = true
        syncMemos.layer.masksToBounds = true
        syncVideos.layer.masksToBounds = true
        syncButton.layer.masksToBounds = true
        
        
        syncPictures.layer.borderWidth = 4
        syncPictures.layer.borderColor = yellowColor.CGColor
        
        syncMemos.layer.borderWidth = 4
        syncMemos.layer.borderColor = yellowColor.CGColor
        
        syncVideos.layer.borderWidth = 4
        syncVideos.layer.borderColor = yellowColor.CGColor
        
        syncButton.backgroundColor = yellowColor
        
        //gpsSwitch.on = userDefaults.boolForKey("GPS-check")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
