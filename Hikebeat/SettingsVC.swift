//
//  SettingsVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift
import Result
import BrightFutures

class SettingsVC: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var toUpload: (synced:Bool, changes: Results<(Change)>?, beats: Results<(Beat)>?)? = nil
    var numbers = (image: 0, video: 0, audio: 0)

    @IBOutlet weak var gpsSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var syncButton: UIButton!
    
    @IBOutlet weak var syncPictures: UIImageView!
    @IBOutlet weak var syncMemos: UIImageView!
    @IBOutlet weak var syncVideos: UIImageView!
    
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet weak var settingsContainer: UIView!
    
    @IBAction func startSync(sender: AnyObject) {
        print("Syncbutton pressed")
        if toUpload != nil {
            print("toUpload is not nil")
            let promise = syncAll(UIProgressView(), changes: self.toUpload!.changes!, beats: self.toUpload!.beats!)
            promise.onSuccess(callback: { (Bool) in
                self.checkSync()
            })
        } else {
            print("toUpload is nil")
        }
    }
    
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
        
        syncButton.backgroundColor = yellowColor
        
        gpsSwitch.on = userDefaults.boolForKey("GPS-check")
        
        checkSync()
    }
    
    override func viewDidAppear(animated: Bool) {
        checkSync()
    }
    
    func checkSync() {
        print(1)
        let synced = appDelegate.synced()
        if !synced.synced {
            print(2)
            self.toUpload = synced
            if !(synced.beats?.isEmpty)! {
                print(3)
                self.numbers = (image: 0, video: 0, audio: 0)
                for beat in self.toUpload!.beats! {
                    print(4)
                    switch beat.mediaType! {
                    case MediaType.image: self.numbers.image += 1
                    case MediaType.video: self.numbers.video += 1
                    case MediaType.audio: self.numbers.audio += 1
                    default: print("wrong")
                    }
                    print(4.5)
                }
            }
        }
        self.imageLabel.text = String(numbers.image) + " pictures\nawaiting\nsync"
        self.videoLabel.text = String(numbers.video) + " videos\nawaiting\nsync"
        self.memoLabel.text = String(numbers.audio) + " memos\nawaiting\nsync"
        setBorderAccordingToStatus(self.syncPictures, mediaType: MediaType.image)
        setBorderAccordingToStatus(self.syncVideos, mediaType: MediaType.video)
        setBorderAccordingToStatus(self.syncMemos, mediaType: MediaType.audio)
        print(5)
    }
    
    func setBorderAccordingToStatus(view: UIImageView, mediaType: String) {
        view.layer.borderWidth = 4
        var color:UIColor = greenColor
        switch mediaType {
            case MediaType.image:
                if self.numbers.image > 0 {
                    color = yellowColor
                }
            case MediaType.video:
                if self.numbers.video > 0 {
                    color = yellowColor
            }
            case MediaType.audio:
                if self.numbers.audio > 0 {
                    color = yellowColor
            }
            default: print("wrong")
        }
        view.layer.borderColor = color.CGColor
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
