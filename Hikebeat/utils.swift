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

public func getPathToFileFromName(_ name: String) -> URL? {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = URL(fileURLWithPath: documentDirectory).appendingPathComponent("media/"+name)
    return pathToFile
}

func saveMediaToDocs(fileName: String, data: Data) -> String? {
    print("Image name: ", fileName)
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let dataPath = documentsDirectory.appending("/"+fileName)
    print("datapath: ", dataPath)
    let url = Foundation.URL(fileURLWithPath: dataPath)
    let fm = FileManager()
    let folderPath = documentsDirectory.appending("/media")
    if fm.fileExists(atPath: folderPath) {
        print("file aldready exists")
    } else {
        print("file doesn't exist")
        let folderUrl =  Foundation.URL(fileURLWithPath: folderPath)//documentsDirectory.appendingPathComponent("images")!
        
        do {
            try FileManager.default.createDirectory(atPath: folderUrl.path, withIntermediateDirectories: false, attributes: nil)
            print("is the directory now created? ", fm.fileExists(atPath: folderPath))
        } catch {
            print("Folder failed to be created")
        }
    }
    print("URL: ", url)
    
    do {
        try data.write(to: url, options: Data.WritingOptions.atomicWrite)
        //try? imageData.write(to: Foundation.URL(fileURLWithPath: dataPath), options: [])
        print("Success at saving")
        return fileName
    } catch {
        print("Error saving image")
        return nil
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
