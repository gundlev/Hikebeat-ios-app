//
//  AppDelegate.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreLocation
import Realm
import RealmSwift
import Result
import UserNotifications
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locManager: CLLocationManager = CLLocationManager()
    let userDefaults = UserDefaults.standard
    var reachability: Reachability!
    
    //a fast hack for displaying which VC initated a segue transition Social vs Journeys
    var fastSegueHack = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        UIApplication.shared.applicationIconBadgeNumber = 0

        UIApplication.shared.statusBarStyle = .lightContent
        self.startReachability()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            startLocationManager()
        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorized {
            startLocationManager()
        }
//        registerForNotification()
        return true
    }
    
    func startLocationManager() -> Bool {
        // Setting op locationManager

        locManager.delegate = self;
        locManager.requestWhenInUseAuthorization()
        self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locManager.distanceFilter = 1
        self.locManager.startUpdatingLocation()
        self.locManager.startUpdatingHeading()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    internal func synced() -> (synced:Bool, changes: Results<(Change)>?, beats: Results<(Beat)>?) {
        let realmLocal = try! Realm()
        print("starting sync method")
        let beatsQuery = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "mediaUploaded = %@", false as CVarArg), NSPredicate(format: "mediaData != %@", "")])
        let changeQuery = NSPredicate(format: "uploaded = %@", false as CVarArg)
        let beats = realmLocal.objects(Beat.self).filter(beatsQuery)
        let changes = realmLocal.objects(Change.self).filter(changeQuery)
        if beats.isEmpty && changes.isEmpty {
            print("all empty")
            return (true, nil, nil)
        } else {
            print("There's something")
            print("Are there changes? ", !changes.isEmpty)
            print("Are there beats? ", !beats.isEmpty)
            print(beats)
            print(changes)
            return (false, changes, beats)
        }
    }
    
    func startReachability() {
        print("startReachability")
        do {
            reachability = Reachability()
            try reachability.startNotifier()
            print("Success reachability")
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            let sync = self.synced()
                if !sync.synced {
                    print("There are things to be uploaded")
//                    if !self.currentlyShowingNotie {
//                        print("There are no current Notie showing")
//                        
//                        dispatch_async(dispatch_get_main_queue()) {
//                            print("Reachable")
//                            if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
//                                if #available(iOS 9.0, *) {
//                                    let notie = Notie(view: topController.view, message: "Network connection! Would you like to start syncronizing now?", style: .Confirm)
//                                    notie.leftButtonAction = {
//                                        // Add your left button action here
//                                        notie.dismiss()
//                                        let progressNotie = Notie(view: topController.view, message: " ", style: .Progress)
//                                        progressNotie.show()
//                                        let future = syncAll(progressNotie.progressView, stack: self.stack)
//                                        
//                                        if future != nil {
//                                            future!.onSuccess{ success in
//                                                progressNotie.dismiss()
//                                                if success {
//                                                    print("All is syncronized!")
//                                                    self.currentlyShowingNotie = false
//                                                } else {
//                                                    print("Not everything was syncronized!")
//                                                }
//                                            }
//                                        } else {
//                                            print("Failed to fetch")
//                                            progressNotie.dismiss()
//                                        }
//                                        //                                        _ = Upload(notie: progressNotie, appDelegate: self)
//                                    }
//                                    notie.rightButtonAction = {
//                                        // Add your right button action here
//                                        notie.dismiss()
//                                        self.currentlyShowingNotie = false
//                                    }
//                                    notie.show()
//                                    self.currentlyShowingNotie = true
//                                    notie.progressView.progress = 0
//                                    
//                                } else {
//                                    // Fallback on earlier versions
//                                }
//                            }
//                        }
//                    } else {
//                        print("A notie is already showing!")
//                    }
                } else {
                    print("nothing to sync")
                }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /*
    Utility functions
*/
    func getLocation() -> CLLocation? {
        
        var currentLocation: CLLocation?
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            print("it does get here")
            currentLocation = locManager.location
        }
        currentLocation?.coordinate.latitude
        print("location 1. lat: ", currentLocation?.coordinate.latitude, "lng: ", currentLocation?.coordinate.longitude)
        return currentLocation
    }
    
    
    
/*
    Notification stuff
*/
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // What to do when app recieves notification
        UIApplication.shared.applicationIconBadgeNumber += 1
        print("recieved notification")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("This is the token:")
        print(deviceToken)
        
        var devToken = String(format: "%@", deviceToken as CVarArg)
        devToken = devToken.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        devToken = devToken.replacingOccurrences(of: " ", with: "")
        
        print(devToken)
        userDefaults.set(devToken, forKey: "device_token")
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber += 1
        completionHandler([.alert, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }

}

