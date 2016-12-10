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
    
    let userDefaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var toUpload: (synced:Bool, changes: Results<(Change)>?, beats: Results<(Beat)>?)? = nil
    var numbers = (image: 0, video: 0, audio: 0)
    let realm = try! Realm()

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
    @IBOutlet weak var settingsContainer: aCustomView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var dotsContainer: UIView!
    @IBOutlet weak var dot1: UIImageView!
    @IBOutlet weak var dot2: UIImageView!
    @IBOutlet weak var dot3: UIImageView!
    
    var animationInitialised: Bool!
    
    @IBAction func logoutAction(_ sender: AnyObject) {

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Yes"){
            self.deleteAllLocalDataAndLogOut()
        }
        alertView.addButton("No") {}
        alertView.showNotice("Logout", subTitle: "Are you sure you want to logout? All local data will be deleted.")
    }
    
    
    @IBAction func notificationChange(_ sender: UISwitch) {
        let reachability = Reachability()
        if reachability?.currentReachabilityStatus != Reachability.NetworkStatus.notReachable {
            let parameters:[String: Any] = ["options" : [
                "notifications"  :  sender.isOn
                ]]
            let url = IPAddress + "users/" + userDefaults.string(forKey: "_id")!
            print(url)
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    print("It has been changes in the db")
                    ChangeAction.update
                } else {
                    print("No connection or fail, saving change")
                    let realm = try! Realm()
                    try! realm.write() {
                        let change = Change()
                        let t = String(Date().timeIntervalSince1970)
                        let e = t.range(of: ".")
                        let timestamp = t.substring(to: (e?.lowerBound)!)
                        change.fill(InstanceType.user, timeCommitted: timestamp, stringValue: nil, boolValue: sender.isOn, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                        realm.add(change)
                    }
                }
            }
        } else {
            // Save to changes data structure when created.
            let realm = try! Realm()
            try! realm.write() {
                let change = Change()
                let t = String(Date().timeIntervalSince1970)
                let e = t.range(of: ".")
                let timestamp = t.substring(to: (e?.lowerBound)!)
                change.fill(InstanceType.user, timeCommitted: timestamp, stringValue: nil, boolValue: sender.isOn, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                realm.add(change)
            }
        }

    }
    
    @IBAction func GPSCheckChange(_ sender: UISwitch) {
        self.userDefaults.set(sender.isOn, forKey: "GPS-check")
    }
    
    @IBAction func startSync(_ sender: AnyObject) {
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
                    let t = String(Date().timeIntervalSince1970)
                    let e = t.range(of: ".")
                    let timestamp = t.substring(to: (e?.lowerBound)!)
                    self.userDefaults.set(timestamp, forKey: "lastSync")
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
            settingsContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85);
            settingsContainer.transform = settingsContainer.transform.translatedBy(x: 0.0, y: -50.0  )
            settingsContainer.button = syncButton
            
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
                settingsContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1);
                settingsContainer.transform = settingsContainer.transform.translatedBy(x: 0.0, y: 40.0  )
            settingsContainer.button = syncButton
            
        }else if (UIDevice.isIphone4 || UIDevice.isIpad){
            settingsContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65);
            settingsContainer.transform = settingsContainer.transform.translatedBy(x: 0.0, y: -100.0  )
            
            settingsContainer.button = syncButton
        }
        
        settingsContainer.button = syncButton
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
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
        
        syncButton.titleLabel?.isHidden = false
        dotsContainer.isHidden = true
        animationInitialised = false
        
        gpsSwitch.isOn = userDefaults.bool(forKey: "GPS-check")
        notificationSwitch.isOn = userDefaults.bool(forKey: "notifications")
        let timestamp = userDefaults.string(forKey: "lastSync")
        let firstDate: Date!
        if timestamp == nil {
            firstDate = Date()
        } else {
            firstDate = Date(timeIntervalSince1970: Foundation.TimeInterval(Int(timestamp!)!))
        }
        let calendar: Calendar = Calendar.current
        let secondDate = Date()
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        let flags = NSCalendar.Unit.day
        let components = (calendar as NSCalendar).components(flags, from: date1, to: date2, options: [])
        
        let numberOfDays = components.day
        lastSyncLabel.text = "Last synchronize: " + String(describing: numberOfDays!) + " days ago"
        
//        checkSync()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!animationInitialised){
            let dots = [dot1,dot2,dot3]
            var delay = 0.0
            for dot in dots{
            
                UIView.animate(withDuration: 0.4,delay: delay, options:   [.repeat, .autoreverse, .curveEaseOut], animations: {
                    dot?.center.y -= 15
                },completion:nil)
                delay+=0.2
            }
            animationInitialised = true
        }else{
            let dots = [dot1,dot2,dot3]
            var delay = 0.0
            for dot in dots{
                dot?.center.y += 15
                UIView.animate(withDuration: 0.4,delay: delay, options:   [.repeat, .autoreverse, .curveEaseOut], animations: {
                    dot?.center.y -= 15
                    },completion:nil)
                delay+=0.2
            }

        }
        checkSync()
    }
    
    func deleteAllLocalDataAndLogOut() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let pathToMedia = URL(fileURLWithPath: documentDirectory).appendingPathComponent("/media")
        pathToMedia.absoluteString
        let fileManager = FileManager.default
        try! realm.write {
            realm.deleteAll()
        }
        do {
            print("Media folder exists: ", fileManager.fileExists(atPath: pathToMedia.absoluteString))
            try fileManager.removeItem(at: pathToMedia)
            print("Media folder exists: ", fileManager.fileExists(atPath: pathToMedia.absoluteString))
            print("Media Folder deleted")

            print("Successfully deleted all!")
            resetUserDefaults()
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
            print("mediafolder couldn't be deleted.")
        }
    }
    
    func resetUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        print("Testing, this chould be nil: ",userDefaults.object(forKey: "_id"))
        print("UserDefaults has been removed")
    }

    func showDots(){
        syncButton.isUserInteractionEnabled = false
        dotsContainer.isHidden = false
    }
    
    func hideDots(){
        syncButton.isUserInteractionEnabled = true
        dotsContainer.isHidden = true
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
                    print(beat.message)
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
        
        if numbers.image==1{
            self.imageLabel.text = String(numbers.image) + " picture\nawaiting\nsync"
        }else{
            self.imageLabel.text = String(numbers.image) + " pictures\nawaiting\nsync"
        }

        if numbers.video==1{
            self.videoLabel.text = String(numbers.video) + " video\nawaiting\nsync"
        }else{
            self.videoLabel.text = String(numbers.video) + " videos\nawaiting\nsync"
        }
        
        if numbers.audio==1{
            self.memoLabel.text = String(numbers.audio) + " memo\nawaiting\nsync"
        }else{
            self.memoLabel.text = String(numbers.audio) + " memos\nawaiting\nsync"
        }

        
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
    
    func setBorderAccordingToStatus(_ view: UIImageView, mediaType: String) {
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
        view.layer.borderColor = color.cgColor
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
