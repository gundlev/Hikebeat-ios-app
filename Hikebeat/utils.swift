//
//  utils.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 31/01/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import UserNotifications

public let darkGreen = UIColor(colorLiteralRed: 21/255, green: 103/255, blue: 108/255, alpha: 1)
public let standardGreen = UIColor(colorLiteralRed: 62/255, green: 155/255, blue: 118/255, alpha: 1)
public let lightGreen = UIColor(colorLiteralRed: 188/255, green: 246/255, blue: 0, alpha: 1)


public func getPathToFileFromName(_ name: String) -> URL? {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = URL(fileURLWithPath: documentDirectory).appendingPathComponent("media/"+name)
    return pathToFile
}

public func createMediaFolder() -> Bool {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let dataPath = documentsDirectory.appending("/media")
    
    do {
        try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        print("Media folder created")
        return true
    } catch let error as NSError {
        print("Failed creating the media folder")
        print(error.localizedDescription);
        return false
    }
}

public func registerForNotification() {
    if #available(iOS 10.0, *) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            
            // Enable or disable features based on authorization.
            if granted == true {
                print("Allow")
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                print("Don't Allow")
            }
        }
    } else {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        // Fallback on earlier versions
    }
}

public func covertToMedia(_ pathToInputFile : URL, pathToOuputFile: URL, fileType: String) -> Bool {
    
    let asset = AVAsset(url: pathToInputFile)
    
    let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    
    print(AVAssetExportSession.exportPresets(compatibleWith: asset))
    
    session?.outputURL = pathToOuputFile
    session?.outputFileType = fileType
    
    session?.exportAsynchronously(completionHandler: { () -> Void in
        print("The session is done exporting")
    })
    
    let assetOut = AVAsset(url: pathToOuputFile)
    
    print(assetOut.description)
    
    return true
}

public func numberToEmotion(_ number: String) -> String {
    switch number {
    case "1":
        return "tired"
    case "2":
        return "sad"
    case "3":
        return "anxious"
    case "4":
        return "angry"
    case "5":
        return "relaxed"
    case "6":
        return "excited"
    case "7":
        return "love"
    case "8":
        return "happy"
    default:
        return ""
    }
}


public func emotionToNumber(_ number: String) -> String {
    switch number {
    case "tired":
        return "1"
    case "sad":
        return "2"
    case "anxious":
        return "3"
    case "angry":
        return "4"
    case "relaxed":
        return "5"
    case "excited":
        return "6"
    case "love":
        return "7"
    case "happy":
        return "8"
    default:
        return ""
    }
}

extension UIApplication {
    class func openAppSettings() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}


func hex(_ number: Double) -> String {
    number
    let d = String(number)
    let e = d.range(of: ".")
    let s1 = d.substring(to: (e?.lowerBound)!)
    let s2 = d.substring(from: (e?.upperBound)!)
    
    // Check for leading zeroes in s2 and creating string
    var countZeroes = 0
    for char in s2.characters {
        if char == "0" {
            countZeroes += 1
        } else {
            break
        }
    }
    var zeroString = ""
    if countZeroes > 0 {
        for _ in 1...countZeroes {
            zeroString += "0"
        }
    }
    // Cast to Int
    let n1 = Int(s1)
    let n2 = Int(s2)
    
    // Create hex
    if s1 == "-0" {
        let st = "-0." + zeroString + String(n2!, radix: 36)
        return st
    } else {
        if n2 == 0 {
            let st = String(n1!, radix: 36)
            return st
        }
        let st = String(n1!, radix: 36) + "." + zeroString + String(n2!, radix: 36)
        return st
    }
}

func getProfileImagePath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let fileName = "/media/profile_image.jpg"
    let dataPath = documentsDirectory.appending(fileName)
    return dataPath
}

func randomStringWithLength (_ len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    
    
    for _ in 0...len-1{
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString
}

func alert(_ alertTitle: String, alertMessage: String, vc: UIViewController, actions:(title: String, style: UIAlertActionStyle, function: ()->())...) {
    let alertController = UIAlertController(title: alertTitle, message:
        alertMessage, preferredStyle: UIAlertControllerStyle.alert)
    
    for action in actions {
        alertController.addAction(UIAlertAction(title: action.title, style: action.style ,handler: {(alert: UIAlertAction!) in
            action.function()
        }))
    }
    vc.present(alertController, animated: true, completion: nil)
}

