//
//  SendChanges.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import BrightFutures
import RealmSwift
import Result
import SwiftyJSON

//TODO: Implement onError and completeWithFail


func sendChanges(progressView: UIProgressView, increase: Float, changes: Results<Change>) -> Future<Bool, NoError> {
    let sortedChanges = changes.sort()
    let promise = Promise<Bool, NoError>()
//    if changes != nil {
//        if changes?.count > 0 {
            let future = asyncFunc(sortedChanges, progressView: progressView, increase: increase)
            future.onSuccess{ success in
                if success {
                    promise.success(success)
                } else {
                    // Should be fail
                    promise.success(success)
                }
            }
            return promise.future
//        } else {
//            // There are no changes.
//            return nil
//        }
//    } else {
//        // Fetch did not succeed.
//        return nil
//    }
}

private func asyncFunc(changesConst: [Change], progressView: UIProgressView, increase: Float) -> Future<Bool, NoError> {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var changes = changesConst
    let change = changes.first
    
    // Creating json changes object
    var jsonChanges = [String: AnyObject]()
    var parameters:[String: AnyObject]?
    
    if change?.changeAction != ChangeAction.delete && change?.instanceType != InstanceType.profileImage {
        
        let property = change?.property!
        if change!.stringValue == nil {
            let boolValue = change!.boolValue
            jsonChanges["options"] = [property! : boolValue]
        } else {
            let stringValue = change!.stringValue
            jsonChanges["options"] = [property! : stringValue!]
        }
        
//        
//        
//        // Creating the array of changes even though there will only be one.
//        var changesArray = [[String: AnyObject]]()
//        // Printing the timeCommitted to see sequence
//        print(change!.timeCommitted)
//        // Creating the change dictionary object
//        var changeObject = [String : AnyObject]()
//        // Setting property
//        if change!.stringValue == nil {
//            // The change is a bool value
//            changeObject[(change?.property!)!] = change!.boolValue
//            
//            
////            parameters = ["options": [
////                change!.property  :   change!.value
////            ]]
////            
////            jsonChanges = ["options": [
////                change.property  :   change.value
////            ]]
//        } else {
//            // The change is a stringvalue
//            changeObject[(change?.property)!] = change!.stringValue
//        }
//        // Adding change object to changes array
//        changesArray.append(changeObject)
//        // Adding changes array to json changes object
//        jsonChanges["changes"] = changesArray
    }
    
    func getProfileImagePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let fileName = "media/profile_image.jpg"
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        return dataPath
    }

    
    // Creating url
    var url = ""
    switch change!.instanceType {
    case InstanceType.beat:
        url = IPAddress + "journeys/" + change!.instanceId! + "/messages/" + change!.timestamp!
    case InstanceType.journey:
        url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/journeys/" + change!.instanceId!
    case InstanceType.user:
        url = IPAddress + "users/" + userDefaults.stringForKey("_id")!
    case InstanceType.profileImage:
        url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/profilePhoto"
    default: print("Creating the url failed.")
    }
    print("Now sending to url: ", url)
    
    // Creating the promise
    let p = Promise<Bool, NoError>()
    
    // Setting the HTTP method
    var method = Method.PUT
    switch change!.changeAction {
    case ChangeAction.delete:
        method = Method.DELETE
    case ChangeAction.update:
        method = Method.PUT
    default:
        method = Method.POST
    }
    
    // Sending change
    
    if change?.instanceType == InstanceType.profileImage {
        var customHeader = Headers
        customHeader["x-hikebeat-format"] = "jpg"
        print("imagePath")
        print((change?.stringValue!)!)
        var path = getProfileImagePath()
        Alamofire.upload(.POST, url,headers: customHeader, file: NSURL(fileURLWithPath: path)).responseJSON { mediaResponse in
            if mediaResponse.response?.statusCode == 200 {
                let rawImageJson = JSON(mediaResponse.result.value!)
                let mediaJson = rawImageJson["data"][0]
                print(mediaResponse)
                print("The image has been posted")
                let removed = changes.removeFirst()
                let realm = try! Realm()
                try! realm.write() {
                    change?.uploaded = true
                }
                progressView.progress = progressView.progress + increase
                if changes.isEmpty {
                    p.success(true)
                } else {
                    let future = asyncFunc(changes, progressView: progressView, increase: increase)
                    future.onSuccess { success in
                        p.success(success)
                    }
                }
            } else {
                print("Error posting the image")
                p.success(false)
                print(mediaResponse)
            }
            
        }
    } else {
        Alamofire.request(method, url, parameters: jsonChanges, encoding: .JSON, headers: Headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                print(response.result.value)
                let removed = changes.removeFirst()
                let realm = try! Realm()
                try! realm.write() {
                    change?.uploaded = true
                }
                progressView.progress = progressView.progress + increase
                print("Uplaoded and removed change with value: ", removed.stringValue)
                if changes.isEmpty {
                    p.success(true)
                } else {
                    let future = asyncFunc(changes, progressView: progressView, increase: increase)
                    future.onSuccess { success in
                        p.success(success)
                    }
                }
            } else {
                print("Something went wrong")
                p.success(false)
            }
        }
    }
    


    return p.future
}

