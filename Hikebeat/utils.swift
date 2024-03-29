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
import BrightFutures
import JWTDecode
import NVActivityIndicatorView
import SwiftyDrop
import SwiftyJSON
import Alamofire

public let darkGreen = UIColor(colorLiteralRed: 21/255, green: 103/255, blue: 108/255, alpha: 1)
public let standardGreen = UIColor(colorLiteralRed: 62/255, green: 155/255, blue: 118/255, alpha: 1)
public let lightGreen = UIColor(colorLiteralRed: 189/255, green: 244/255, blue: 0, alpha: 1)
public let yellowColor = UIColor(hexString: "#F7E70A")!

func showActivity() {
    let activityData = ActivityData(size: nil, message: nil, messageFont: nil, type: NVActivityIndicatorType.lineSpinFadeLoader, color: nil, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil)
    
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
}

func hideActivity() {
    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
}

func hasNetworkConnection(show: Bool) -> Bool {
    let reachability = Reachability()
    if reachability?.currentReachabilityStatus == Reachability.NetworkStatus.notReachable {
        if show {
            Drop.down("No network connection", state: .error)
        }
        return false
    } else {
        return true
    }
}

func showCallErrors(json: JSON) {
    if let errors = json["errors"].array {
        var bannerText = ""
        for var i in 0...errors.count-1 {
            print(errors[i])
            if i != 0 {
                bannerText += "\n\n"
            }
            bannerText += "\(errors[i]["friendlyMessage"].stringValue)"
        }
        Drop.down(bannerText, state: .error)
    } else {
        Drop.down("Something went wrong", state: .error)
    }
}

func shouldRefreshToken() -> Bool {
    print("TOEKN REFRESH")
    guard let token = userDefaults.string(forKey: "token") else {return false}
    do {
        let jwt = try decode(jwt: token)
        let expTimestamp = jwt.body["exp"]
        let date = Date(timeIntervalSince1970: expTimestamp as! TimeInterval)
        let now = Date()
        let cal = Calendar.current
        let dayComponents = (cal as NSCalendar).components(.day, from: now, to: date, options: [])
        let days = dayComponents.day!
        return days > 30
    } catch {
        print("error")
        return false
    }
    return true
}

func downloadImage(imageUrl: String, activityIndicator: UIActivityIndicatorView) -> Future<UIImage, HikebeatError> {
    return Future { complete in
        activityIndicator.startAnimating()
        downloadImage(imageUrl: imageUrl)
        .onSuccess { (image) in
            activityIndicator.stopAnimating()
            complete(.success(image))
        }.onFailure { (error) in
            print("Error: ", error)
            complete(.failure(error))
        }
    }
}

public func getTimeSince(date: Date) -> String {
    //    let date = Date(timeIntervalSince1970: TimeInterval(Double(timestamp)!/1000))
//    print("Time since date: ", date)
    let now = Date()
//    print("Date now: ", now)
    let cal = Calendar.current
    let secComponents = (cal as NSCalendar).components(.second, from: date, to: now, options: [])
    let minComponents = (cal as NSCalendar).components(.minute, from: date, to: now, options: [])
    let hourComponents = (cal as NSCalendar).components(.hour, from: date, to: now, options: [])
    let dayComponents = (cal as NSCalendar).components(.day, from: date, to: now, options: [])
    let monthComponents = (cal as NSCalendar).components(.month, from: date, to: now, options: [])
    let yearComponents = (cal as NSCalendar).components(.year, from: date, to: now, options: [])
    let seconds = abs(secComponents.second!)
    let minutes = abs(minComponents.minute!)
    let hours = abs(hourComponents.hour!)
    let days = abs(dayComponents.day!)
    let weeks = days/7
    let months = abs(monthComponents.month!)
    let years = abs(yearComponents.year!)
//
//    print("---------------------------------")
//    print(seconds)
//    print(minutes)
//    print(hours)
//    print(days)
//    print(weeks)
//    print(months)
//    print("---------------------------------")
    
    if seconds < 60 {
        var element = " second"
        if seconds > 1 {
            element = " seconds"
        }
        return String(describing: seconds) + element
    } else if minutes < 60 {
        var element = " minute"
        if minutes > 1 {
            element = " minutes"
        }
        return String(describing: minutes) + element
    } else if hours < 24 {
        var element = " hour"
        if hours > 1 {
            element = " hours"
        }
        return String(describing: hours) + element
    } else if days < 7 {
        var element = " day"
        if days > 1 {
            element = " days"
        }
        return String(describing: days) + element
    } else if weeks < 4 {
        var element = " week"
        if weeks > 1 {
            element = " weeks"
        }
        return String(describing: weeks) + element
    } else if months < 12 {
        var element = " month"
        if months > 1 {
            element = " months"
        }
        return String(describing: months) + element
    } else {
        var element = " year"
        if years > 1 {
            element = " years"
        }
        return String(describing: years) + element
    }
}

public func getPathToFileFromName(_ name: String) -> URL? {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = URL(fileURLWithPath: documentDirectory).appendingPathComponent(name)
    return pathToFile
}

func getImagePath(_ path: String) -> String {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let dataPath = documentsDirectory.appending(path)
    return dataPath
}

public func createMediaFolder() -> Bool {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let dataPath = documentsDirectory.appending("/media")
    let tempPath = documentsDirectory.appending("/temp")
    
    do {
        try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        try FileManager.default.createDirectory(atPath: tempPath, withIntermediateDirectories: false, attributes: nil)
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
                print("Allow for notifications")
                UIApplication.shared.registerForRemoteNotifications()
                userDefaults.set(true, forKey: "notifications")
            } else {
                print("Don't Allow for notifications")
            }
        }
    } else {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        // Fallback on earlier versions
    }
}

func covertToMedia(_ pathToInputFile : URL, pathToOuputFile: URL, fileType: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let asset = AVAsset(url: pathToInputFile)
        let data = NSData(contentsOf: pathToInputFile)!
        print("File size before compression: \(Double(data.length / 1048)) kb")
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            complete(.failure(.avAssetExportFail))
            return
        }
//        print(AVAssetExportSession.exportPresets(compatibleWith: asset))
        print("input path: ", pathToInputFile)
        print("output path: ", pathToOuputFile)
        session.outputURL = pathToOuputFile
        session.outputFileType = fileType
        session.shouldOptimizeForNetworkUse = true
        session.exportAsynchronously(completionHandler: { () -> Void in
            print("The session is done exporting")
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                let compressedData = NSData(contentsOf: pathToOuputFile)
                print("File size after compression: \(Double((compressedData?.length)! / 1048)) kb")
                complete(.success(true))
                break
            case .failed:
                complete(.failure(.compressionFailed))
                break
            case .cancelled:
                complete(.failure(.compressionCancelled))

                break
            }

    //        let data = NSData(contentsOf: pathToOuputFile)!
    //        print("File size after compression: \(Double(data.length / 1048)) kb")
        })
    }
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

