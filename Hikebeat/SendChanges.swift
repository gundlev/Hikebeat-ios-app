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
    
    if change?.changeAction != ChangeAction.delete {
        // Creating the array of changes even though there will only be one.
        var changesArray = [[String: AnyObject]]()
        // Printing the timeCommitted to see sequence
        print(change!.timeCommitted)
        // Creating the change dictionary object
        var changeObject = [String : AnyObject]()
        // Setting property
        changeObject["property"] = change!.property
        if change!.stringValue == nil {
            // The change is a bool value
            changeObject["value"] = change!.boolValue
        } else {
            // The change is a stringvalue
            changeObject["value"] = change!.stringValue
        }
        // Adding change object to changes array
        changesArray.append(changeObject)
        // Adding changes array to json changes object
        jsonChanges["changes"] = changesArray
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
    Alamofire.request(method, url, parameters: jsonChanges, encoding: .JSON, headers: Headers).responseJSON { response in
        if response.response?.statusCode == 200 {
            print(response.result.value)
            let removed = changes.removeFirst()
            let realm = try! Realm()
            realm.delete(change!)
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

    return p.future
}

