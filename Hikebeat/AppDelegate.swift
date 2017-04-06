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
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import Branch

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
            _ = startLocationManager()
        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            _ = startLocationManager()
        }
//        registerForNotification()
        
        AppEventsLogger.activate(application)
        
        if let window = window, let image = UIImage(named: "fakeload") {
            window.layer.contents = image.cgImage
        }
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, automaticallyDisplayDeepLinkController: true, deepLinkHandler: { params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                print("params: %@", params?.description)
            }
        })
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
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
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
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
        print("you check now")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if shouldRefreshToken() {
            refreshToken()
            .onSuccess { (token) in
                print("Token refreshed: ", token)
            }.onFailure(callback: { (error) in
                print("Error: ", error)
            })
        }

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if reachability?.currentReachabilityStatus != Reachability.NetworkStatus.notReachable {
            print("checking for number now")
            if userDefaults.bool(forKey: "loggedIn") {
                let future = updateSimCard()
                future.onSuccess { (success) in
                    print("Change made to sim card: ", success)
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    internal func synced() -> (synced:Bool, changes: Results<(Change)>, mediaBeats: Results<(Beat)>, messageBeats: Results<(Beat)>) {
        let realmLocal = try! Realm()
        print("starting sync method now")
        let mediaQuery = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "mediaUploaded == %@", false as CVarArg), NSPredicate(format: "mediaData != %@", "")])
        let beatQuery = NSPredicate(format: "messageUploaded == %@", false as CVarArg)
//        let changeQuery = NSPredicate(format: "uploaded = %@", false as CVarArg)
        let media = realmLocal.objects(Beat.self).filter(mediaQuery)
        let beats = realmLocal.objects(Beat.self).filter(beatQuery)
        let changes = realmLocal.objects(Change.self)
        print("Are there changes? ", !changes.isEmpty)
        print("Are there media? ", !media.isEmpty)
        print("Are there beats? ", !beats.isEmpty)
        return ((changes.isEmpty && beats.isEmpty && media.isEmpty), changes, media, beats)
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
        print("got new notofication settings")
        print(notificationSettings)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // What to do when app recieves notification
//        UIApplication.shared.applicationIconBadgeNumber += 1
        print("recieved notification 1")
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("This is the token:")
        print(deviceToken)
        
        var devToken = String(format: "%@", deviceToken as CVarArg)
        print(devToken)
        devToken = devToken.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        devToken = devToken.replacingOccurrences(of: " ", with: "")
        
        print(devToken)
        userDefaults.set(devToken, forKey: "device_token")
        updateDeviceToken(token: devToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("fetch noti")
        UIApplication.shared.applicationIconBadgeNumber += 1
        print(userInfo)
        print("_________________")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        UIApplication.shared.applicationIconBadgeNumber += 1
        print("recieved notification 2")

    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
//        UIApplication.shared.applicationIconBadgeNumber += 1
        print("recieved notification 3")

    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("presenting")
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        Branch.getInstance().handleDeepLink(url);

        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }

}

