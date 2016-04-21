//
//  AppDelegate.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locManager: CLLocationManager = CLLocationManager()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var reachability: Reachability!
    let realm = try! Realm()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        let beat = Beat(title: "First", journeyId: "dgihdla7wt3oæ", message: "This is the first", latitude: "12.5489264", longitude: "54.74893278", altitude: "12.5", timestamp: "6329861323", mediaType: nil, mediaData: "", mediaDataId: nil, messageId: nil, mediaUploaded: false, messageUploaded: false, journey: Journey())
//        print(beat)
//        try! realm.write {
//            realm.add(beat)
//        }
        
        
        self.startReachability()
        
        // Setting op locationManager
        locManager.delegate = self;
        locManager.requestWhenInUseAuthorization()
        self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locManager.distanceFilter = 1
        self.locManager.startUpdatingLocation()
        self.locManager.startUpdatingHeading()

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func synced() -> Bool {
        let realmLocal = try! Realm()
        print("starting sync method")
        let beatsQuery = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [NSPredicate(format: "mediaUploaded = %@", false), NSPredicate(format: "mediaData = %@", "")])
        let beats = realmLocal.objects(Beat).filter(beatsQuery)
        let changes = realmLocal.objects(Change)
        if beats.isEmpty && changes.isEmpty {
            print("all empty")
            return true
        } else {
            print("There's something")
            print(beats)
            return false
        }
    }
    
    func startReachability() {
        print("startReachability")
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            print("Success reachability")
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            let sync = self.synced()
                if !sync {
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
}

