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
import SwiftyDrop

class SettingsVC: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var toUpload: (synced:Bool, changes: Results<(Change)>, mediaBeats: Results<(Beat)>, messageBeats: Results<(Beat)>)? = nil
    var numbers = (image: 0, video: 0, audio: 0, message: 0)
    let realm = try! Realm()
    var modalPromise: Promise<String, NoError>!
    var currentModal: ModalVC?

    @IBOutlet weak var gpsSwitch: UISwitch!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var smsSwitch: UISwitch!
    @IBOutlet weak var mapLinesSwitch: UISwitch!
    
    @IBOutlet weak var syncPictures: UIImageView!
    @IBOutlet weak var syncMemos: UIImageView!
    @IBOutlet weak var syncVideos: UIImageView!
    @IBOutlet weak var syncMessages: UIImageView!
    
    @IBOutlet weak var syncMessagesBadge: UILabel!
    @IBOutlet weak var syncPicturesBadge: UILabel!
    @IBOutlet weak var syncVideosBadge: UILabel!
    @IBOutlet weak var syncMemosBadge: UILabel!
    
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var settingsContainer: aCustomView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var dotsContainer: UIView!
    @IBOutlet weak var dot1: UIImageView!
    @IBOutlet weak var dot2: UIImageView!
    @IBOutlet weak var dot3: UIImageView!
    
    var animationInitialised: Bool!
    
    @IBAction func backToSettings(_ sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func notificationsInfoPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addOkayButton()
        _ = alertView.showNotice("Notifications", subTitle: "Enable to get push notifications when the hikers you follow send new beats.")
    }
    
    @IBAction func gpsCheckInfoPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addOkayButton()
        _ = alertView.showNotice("GPS check", subTitle: "Enable to get warnings if the GPS signal is poor when sending a beat.")
    }
    
    @IBAction func smsFunctionalityInfoPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addOkayButton()
        _ = alertView.showNotice("SMS Functionality", subTitle: "Enable to automatically generate a SMS for a beat if you have no data connection. Alternatively, your beat is stored on the phone and synced later.")
    }

    @IBAction func toggleLinesInfoPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addOkayButton()
        _ = alertView.showNotice("Show/hide lines", subTitle: "Enable to show supporting lines between every two beats on the map view. They might be helpful for giving a sence of direction on the map.")
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {

        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addButton("Yes"){
            self.deleteAllLocalDataAndLogOut()
        }
        _ = alertView.addButton("No") {}
        _ = alertView.showNotice("Logout", subTitle: "Are you sure you want to logout? All local data will be deleted.")
    }
    
    @IBAction func smsChange(_ sender: UISwitch) {
        self.userDefaults.set(sender.isOn, forKey: "sms")
    }
    
    @IBAction func mapLinesChange(_ sender: UISwitch) {
        self.userDefaults.set(sender.isOn, forKey: "mapLines")
    }
    
    @IBAction func notificationChange(_ sender: UISwitch) {
        let change = createSimpleChange(type: .notifications, key: ChangeType.notifications.rawValue, value: nil, valueBool: sender.isOn)
        updateUser([change])
        .onSuccess { (success) in
            Drop.down("Your profile information was successfully updated!", state: .success)
        }.onFailure { (error) in
            Drop.down("Your changes will be updated the next time you sync", state: .info)
            saveChange(change: change)
        }
    }
    
    @IBAction func GPSCheckChange(_ sender: UISwitch) {
        self.userDefaults.set(sender.isOn, forKey: "GPS-check")
    }
    
    @IBAction func startSync(_ sender: AnyObject) {
        print("Syncbutton pressed")
        guard hasNetworkConnection(show: true) else { return }
        if toUpload != nil {
            // showModal
            self.modalPromise = Promise<String, NoError>()
            self.performSegue(withIdentifier: "showModal", sender: self)
//            showDots()
            print("toUpload is not nil")
            print("Modal: ", self.currentModal)
            print("Bar: ", self.currentModal?.progressBar)
            syncAll(self.currentModal?.progressBar, changes: self.toUpload!.changes, mediaBeats: self.toUpload!.mediaBeats, messageBeats: self.toUpload!.messageBeats)
            .onSuccess(callback: { (Bool) in
                let synced = self.checkSync()
                print("In callback")
//                self.hideDots()
                self.modalPromise.success("settings")
                
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
            Drop.down("There is no media or any messages to sync. Have an awesome day!", state: .success)
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
        syncMessages.layer.cornerRadius = syncMessages.bounds.width/2
        
        syncPicturesBadge.layer.cornerRadius = syncPicturesBadge.bounds.width/2
        syncMemosBadge.layer.cornerRadius = syncMemosBadge.bounds.width/2
        syncVideosBadge.layer.cornerRadius = syncVideosBadge.bounds.width/2
        syncMessagesBadge.layer.cornerRadius = syncMessagesBadge.bounds.width/2

        
        syncPictures.layer.masksToBounds = true
        syncMemos.layer.masksToBounds = true
        syncVideos.layer.masksToBounds = true
        syncButton.layer.masksToBounds = true
        syncMessages.layer.masksToBounds = true
        
        syncPicturesBadge.layer.masksToBounds = true
        syncMemosBadge.layer.masksToBounds = true
        syncVideosBadge.layer.masksToBounds = true
        syncMessagesBadge.layer.masksToBounds = true
        
        syncButton.backgroundColor = yellowColor
        
        syncButton.titleLabel?.isHidden = false
        dotsContainer.isHidden = true
        animationInitialised = false
        
        gpsSwitch.isOn = userDefaults.bool(forKey: "GPS-check")
        notificationSwitch.isOn = userDefaults.bool(forKey: "notifications")
        smsSwitch.isOn = userDefaults.bool(forKey: "sms")
        mapLinesSwitch.isOn = userDefaults.bool(forKey: "mapLines")
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
        _ = checkSync()
    }
    
    func deleteAllLocalDataAndLogOut() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let pathToMedia = URL(fileURLWithPath: documentDirectory).appendingPathComponent("/media")
//        pathToMedia.absoluteString
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
        let deviceToken = userDefaults.string(forKey: "device_token")
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        let ud = UserDefaults.standard
        ud.set(deviceToken, forKey: "device_token")
//        print("Testing, this chould be nil: ",userDefaults.object(forKey: "_id"))
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
        let synced = appDelegate.synced()
        if !synced.synced {
            self.toUpload = synced
            if !synced.mediaBeats.isEmpty {
                self.numbers = (image: 0, video: 0, audio: 0, message: 0)
                for beat in self.toUpload!.mediaBeats {
//                    print(4)
//                    print(beat.message)
//                    print(beat.mediaType)
//                    print(beat)
                    guard beat.mediaType != nil else {continue}
                    switch beat.mediaType! {
                    case MediaType.image: self.numbers.image += 1
                    case MediaType.video: self.numbers.video += 1
                    case MediaType.audio: self.numbers.audio += 1
                    default: print("wrong")
                    }
                }
            }
            self.numbers.message = (self.toUpload?.messageBeats.count)!
        } else {
            self.numbers.message = 0
            self.numbers.image = 0
            self.numbers.video = 0
            self.numbers.audio = 0
        }
        
        syncMessagesBadge.text = "\(self.numbers.message)"
        syncPicturesBadge.text = "\(self.numbers.image)"
        syncVideosBadge.text = "\(self.numbers.video)"
        syncMemosBadge.text = "\(self.numbers.audio)"
        
        setBorderAccordingToStatus(self.syncPictures, mediaType: MediaType.image)
        setBorderAccordingToStatus(self.syncVideos, mediaType: MediaType.video)
        setBorderAccordingToStatus(self.syncMemos, mediaType: MediaType.audio)
        setBorderAccordingToStatus(self.syncMessages, mediaType: MediaType.none)
        
        print(5)
        if synced.synced {
            return true
        } else {
            return false
        }
    }
    
    func setBorderAccordingToStatus(_ view: UIImageView, mediaType: String) {
        view.layer.borderWidth = 3
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
            case MediaType.none:
                if self.numbers.message > 0 {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else {return}
        switch segue.identifier! {
        case "showModal":
            let vc = segue.destination as! ModalVC
            vc.future = self.modalPromise.future
            print("lool")
            vc.text = "Synchronizing"
            if !((toUpload?.mediaBeats.isEmpty)!) {
                _ = vc.addProgressBar("Uploading local data")
            }
            self.currentModal = vc
        default: print("unknown segue from settings")
        }
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
