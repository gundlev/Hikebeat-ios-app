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

public func getPathToFileFromName(name: String) -> NSURL? {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent("media/"+name)
    return pathToFile
}

public func covertToMedia(pathToInputFile : NSURL, pathToOuputFile: NSURL, fileType: String) -> Bool {
    
    let asset = AVAsset(URL: pathToInputFile)
    
    let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    
    print(AVAssetExportSession.exportPresetsCompatibleWithAsset(asset))
    
    session?.outputURL = pathToOuputFile
    session?.outputFileType = fileType
    
    session?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
        print("The session is done exporting")
    })
    
    let assetOut = AVAsset(URL: pathToOuputFile)
    
    print(assetOut.description)
    
    return true
}

public func numberToEmotion(number: String) -> String {
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


public func emotionToNumber(number: String) -> String {
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
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
}