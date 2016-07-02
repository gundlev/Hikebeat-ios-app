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
import Alamofire

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
    
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var settingsContainer: UIView!
    
    
    @IBOutlet weak var dotsContainer: UIView!
    @IBOutlet weak var dot1: UIImageView!
    @IBOutlet weak var dot2: UIImageView!
    @IBOutlet weak var dot3: UIImageView!
    
    var animationInitialised: Bool!
    
    
    @IBAction func notificationChange(sender: UISwitch) {
        if SimpleReachability.isConnectedToNetwork() {
            let parameters:[String: AnyObject] = ["options" : [
                "notifications"  :  sender.on
                ]]
            let url = IPAddress + "users/" + userDefaults.stringForKey("_id")!
            print(url)
            Alamofire.request(.PUT, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    print("It has been changes in the db")
                    ChangeAction.update
                } else {
                    print("No connection or fail, saving change")
                    let realm = try! Realm()
                    try! realm.write() {
                        let change = Change()
                        let t = String(NSDate().timeIntervalSince1970)
                        let e = t.rangeOfString(".")
                        let timestamp = t.substringToIndex((e?.startIndex)!)
                        change.fill(InstanceType.user, timeCommitted: timestamp, stringValue: nil, boolValue: sender.on, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                        realm.add(change)
                    }
                }
            }
        } else {
            // Save to changes data structure when created.
            let realm = try! Realm()
            try! realm.write() {
                let change = Change()
                let t = String(NSDate().timeIntervalSince1970)
                let e = t.rangeOfString(".")
                let timestamp = t.substringToIndex((e?.startIndex)!)
                change.fill(InstanceType.user, timeCommitted: timestamp, stringValue: nil, boolValue: sender.on, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                realm.add(change)
            }
        }

    }
    
    @IBAction func GPSCheckChange(sender: UISwitch) {
        self.userDefaults.setBool(sender.on, forKey: "GPS-check")
    }
    
    @IBAction func startSync(sender: AnyObject) {
        print("Syncbutton pressed")
        if toUpload != nil {
            showDots()
            print("toUpload is not nil")
            let promise = syncAll(UIProgressView(), changes: self.toUpload!.changes!, beats: self.toUpload!.beats!)
            promise.onSuccess(callback: { (Bool) in
                let synced = self.checkSync()
                print("In callback")
                
                self.hideDots()
                
                if synced {
                    let t = String(NSDate().timeIntervalSince1970)
                    let e = t.rangeOfString(".")
                    let timestamp = t.substringToIndex((e?.startIndex)!)
                    self.userDefaults.setObject(timestamp, forKey: "lastSync")
                    self.lastSyncLabel.text = "Last synchronize: 0 days ago"
                }

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
        }else if (UIDevice.isIphone4){
            settingsContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.65, 0.65);
            settingsContainer.transform = CGAffineTransformTranslate( settingsContainer.transform, 0.0, -100.0  )
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        dot1.layer.cornerRadius = dot1.bounds.width/2
        dot1.layer.masksToBounds = true
        
        dot2.layer.cornerRadius = dot2.bounds.width/2
        dot2.layer.masksToBounds = true
        
        dot3.layer.cornerRadius = dot3.bounds.width/2
        dot3.layer.masksToBounds = true
        
        syncPictures.layer.cornerRadius = syncPictures.bounds.width/2
        syncMemos.layer.cornerRadius = syncMemos.bounds.width/2
        syncVideos.layer.cornerRadius = syncVideos.bounds.width/2
        syncButton.layer.cornerRadius = syncButton.bounds.height/2
        
        syncPictures.layer.masksToBounds = true
        syncMemos.layer.masksToBounds = true
        syncVideos.layer.masksToBounds = true
        syncButton.layer.masksToBounds = true
        
        syncButton.backgroundColor = yellowColor
        
        syncButton.titleLabel?.hidden = false
        dotsContainer.hidden = true
        animationInitialised = false
        
        gpsSwitch.on = userDefaults.boolForKey("GPS-check")
        gpsSwitch.on = userDefaults.boolForKey("notifications")
        let timestamp = userDefaults.stringForKey("lastSync")
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let firstDate = NSDate(timeIntervalSince1970: NSTimeInterval(Int(timestamp!)!))
        let secondDate = NSDate()
        let date1 = calendar.startOfDayForDate(firstDate)
        let date2 = calendar.startOfDayForDate(secondDate)
        
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: [])
        
        let numberOfDays = components.day
        lastSyncLabel.text = "Last synchronize: " + String(numberOfDays) + " days ago"
        
        checkSync()
    }
    
    override func viewDidAppear(animated: Bool) {
        if(!animationInitialised){
            let dots = [dot1,dot2,dot3]
            var delay = 0.0
            for dot in dots{
            
                UIView.animateWithDuration(0.4,delay: delay, options:   [.Repeat, .Autoreverse, .CurveEaseOut], animations: {
                    dot.center.y -= 15
                },completion:nil)
                delay+=0.2
            }
            animationInitialised = true
        }else{
            let dots = [dot1,dot2,dot3]
            var delay = 0.0
            for dot in dots{
                dot.center.y += 15
                UIView.animateWithDuration(0.4,delay: delay, options:   [.Repeat, .Autoreverse, .CurveEaseOut], animations: {
                    dot.center.y -= 15
                    },completion:nil)
                delay+=0.2
            }

        }
        checkSync()
    }

    func showDots(){
        syncButton.userInteractionEnabled = false
        dotsContainer.hidden = false
    }
    
    func hideDots(){
        syncButton.userInteractionEnabled = true
        dotsContainer.hidden = true
    }
    
    func checkSync() -> Bool {
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
                    print(beat.title)
                    print(beat.mediaType)
                    print(beat)
                    switch beat.mediaType! {
                    case MediaType.image: self.numbers.image += 1
                    case MediaType.video: self.numbers.video += 1
                    case MediaType.audio: self.numbers.audio += 1
                    default: print("wrong")
                    }
                    print(4.5)
                }
            }
        } else {
            self.numbers.image = 0
            self.numbers.video = 0
            self.numbers.audio = 0
        }
        self.imageLabel.text = String(numbers.image) + " pictures\nawaiting\nsync"
        self.videoLabel.text = String(numbers.video) + " videos\nawaiting\nsync"
        self.memoLabel.text = String(numbers.audio) + " memos\nawaiting\nsync"
        setBorderAccordingToStatus(self.syncPictures, mediaType: MediaType.image)
        setBorderAccordingToStatus(self.syncVideos, mediaType: MediaType.video)
        setBorderAccordingToStatus(self.syncMemos, mediaType: MediaType.audio)
        print(5)
        if synced.synced {
            return true
        } else {
            return false
        }
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
