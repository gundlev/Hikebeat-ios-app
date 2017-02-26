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


func sendChanges(_ progressView: UIProgressView, increase: Float, changes: Results<Change>) -> Future<Bool, HikebeatError> {
    return Future { complete in
        guard changes.count != 0 else {complete(.success(true)); return}
        var numberOfFails = 0
        print("There are \(changes.count) changes in total")
        for change in changes {
            // Utility functions
            func checkStatus() {
                if changes.count == 0 {
                    print("Done uploading changes with no fails")
                    complete(.success(true))
                } else if changes.count - numberOfFails == 0 {
                    print("Done uploading changes with ", numberOfFails, " fails")
                    complete(.failure(.uploadChange))
                }
            }
            
            func successOnChange() {
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(change)
                }
            }
            
            // Handling of changes
            switch ChangeType(rawValue: change.changeType!)! {
            case .profileImage:
                print("Updating profile image")
                uploadProfileImage(path: URL(fileURLWithPath: getProfileImagePath())) { (progress) in
                    print("Upload progress: ", progress)
                }.onSuccess { (success) in
                    successOnChange()
                    checkStatus()
                }.onFailure { (error) in
                    numberOfFails += 1
                    checkStatus()
                }
            case .name:
                print("Updating name")
                updateUser([change])
                .onSuccess { (success) in
                    successOnChange()
                    checkStatus()
                }.onFailure { (error) in
                    numberOfFails += 1
                    checkStatus()
                }
            case .permittedPhoneNumber:
                print("Updating permittedPhoneNumber")
                updateUser([change])
                .onSuccess { (success) in
                    successOnChange()
                    checkStatus()
                }.onFailure { (error) in
                    numberOfFails += 1
                    checkStatus()
                }
            case .deleteJourney:
                print("Deleting journey")
            case .deleteBeat:
                print("Deleting beat")
            case .notifications:
                print("changing notification")
                updateUser([change])
                .onSuccess { (success) in
                    successOnChange()
                    checkStatus()
                }.onFailure { (error) in
                    numberOfFails += 1
                    checkStatus()
                }
            }
        }
    }
//    
//    
//    
//    
//    let sortedChanges = changes.sorted()
//    let promise = Promise<Bool, HikebeatError>()
////    if changes != nil {
////        if changes?.count > 0 {
//            let future = asyncFunc(sortedChanges, progressView: progressView, increase: increase)
//            future.onSuccess{ success in
//                if success {
//                    promise.success(success)
//                } else {
//                    promise.failure(.uploadChange)
//                }
//            }
//            return promise.future
////        } else {
////            // There are no changes.
////            return nil
////        }
////    } else {
////        // Fetch did not succeed.
////        return nil
////    }
}

//private func asyncFunc(_ changesConst: [Change], progressView: UIProgressView, increase: Float) -> Future<Bool, NoError> {
//    return Future { complete in
//        
//        guard changesConst.count != 0 else {complete(.success(true)); return}
////        let userDefaults = UserDefaults.standard
////        
////        var changes = changesConst
////        let change = changes.first!
//        
//        
//        // Create same type of for-loop with counters as in sendBeats
//        for change in changesConst {
//            switch ChangeType(rawValue: change.changeType!)! {
//            case .profileImage:
//                uploadProfileImage(path: URL(fileURLWithPath: getProfileImagePath())) { (progress) in
//                    print("Upload progress: ", progress)
//                    }.onSuccess { (success) in
//                        let realm = try! Realm()
//                        realm.write {
//                            realm.delete(change)
//                        }
//                    }.onFailure { (error) in
//                        print(error)
//                        let localRealm = try! Realm()
//                        try! localRealm.write() {
//                            let change = Change()
//                            change.fill(.profileImage, values: nil)
//                            localRealm.add(change)
//                        }
//                }
//            case .name:
//                updateUser(changes)
//                    .onSuccess { (hasPermittedPhoneNumber) in
//                        
//                    }.onFailure { (error) in
//                }
//            case .permittedPhoneNumber:
//            case .deleteJourney:
//            case .notification:
//            }
//        }
//        
//        
//        
//        
//        
//        
//        // Creating json changes object
//        var jsonChangesBool = [String: Bool]()
//        var jsonChangesString = [String: String]()
//        var parameters:[String: AnyObject]?
//        
//        if change?.changeAction != ChangeAction.delete && change?.instanceType != InstanceType.profileImage {
//            
//            let property = change?.property!
//            if change!.stringValue == nil {
//                let boolValue = change!.boolValue
//                jsonChangesBool[property!] = boolValue
//            } else {
//                let stringValue = change!.stringValue
//                jsonChangesString[property!] = stringValue!
//            }
//        }
//        
////        func getProfileImagePath() -> String {
////            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
////            let documentsDirectory: AnyObject = paths[0] as AnyObject
////            let fileName = "/media/profile_image.jpg"
////            let dataPath = documentsDirectory.appending(fileName)
////            return dataPath
////        }
//        
//        // Creating url
//        var url = ""
//        switch change!.instanceType {
//        case InstanceType.beat:
//            url = IPAddress + "journeys/" + change!.instanceId! + "/messages/" + change!.timestamp!
//        case InstanceType.journey:
//            url = IPAddress + "users/" + userDefaults.string(forKey: "_id")! + "/journeys/" + change!.instanceId!
//        case InstanceType.user:
//            url = IPAddress + "users/" + userDefaults.string(forKey: "_id")!
//        case InstanceType.profileImage:
//            url = IPAddress + "users/" + userDefaults.string(forKey: "_id")! + "/profilePhoto"
//        default: print("Creating the url failed.")
//        }
//        print("Now sending to url: ", url)
//        
//        // Setting the HTTP method
//        var method = HTTPMethod.put
//        switch change!.changeAction {
//        case ChangeAction.delete:
//            method = HTTPMethod.delete
//        case ChangeAction.update:
//            method = HTTPMethod.put
//        default:
//            method = HTTPMethod.post
//        }
//        
//        // Sending change
//        
//        if change?.instanceType == InstanceType.profileImage {
//            var customHeader = getHeader()
//            customHeader["x-hikebeat-format"] = "jpg"
//            print("imagePath")
//            print((change?.stringValue!)!)
//            var path = getProfileImagePath()
//            Alamofire.upload(URL(fileURLWithPath: path), to: url,headers: customHeader).responseJSON { mediaResponse in
//                if mediaResponse.response?.statusCode == 200 {
//                    let rawImageJson = JSON(mediaResponse.result.value!)
//                    let mediaJson = rawImageJson["data"][0]
//                    print(mediaResponse)
//                    print("The image has been posted")
//                    let removed = changes.removeFirst()
//                    let realm = try! Realm()
//                    try! realm.write() {
//                        change?.uploaded = true
//                    }
//                    progressView.progress = progressView.progress + increase
//                    if changes.isEmpty {
//                        complete(.success(true))
//                    } else {
//                        lasyncFunc(changes, progressView: progressView, increase: increase)
//                        .onSuccess { success in
//                            complete(.success(success))
//                        }
//                    }
//                } else {
//                    print("Error posting the image")
//                    complete(.success(false))
//                    print(mediaResponse)
//                }
//                
//            }
//        } else {
//            var jsonChanges = [String: AnyObject]()
//            if jsonChangesBool.count > 0 {
//                jsonChanges = jsonChangesBool as [String: AnyObject]
//            } else {
//                jsonChanges = jsonChangesString as [String: AnyObject]
//            }
//            Alamofire.request(url, method: method, parameters: jsonChanges, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
//                if response.response?.statusCode == 200 {
//                    print(response.result.value)
//                    let removed = changes.removeFirst()
//                    let realm = try! Realm()
//                    try! realm.write() {
//                        change?.uploaded = true
//                    }
//                    progressView.progress = progressView.progress + increase
//                    print("Uplaoded and removed change with value: ", removed.stringValue)
//                    if changes.isEmpty {
//                        complete(.success(true))
//                    } else {
//                        let future = asyncFunc(changes, progressView: progressView, increase: increase)
//                        future.onSuccess { success in
//                            complete(.success(success))
//                        }
//                    }
//                } else {
//                    print("Something went wrong")
//                    complete(.success(false))
//                }
//            }
//        }
//    }
//}

