//
//  SyncAll.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData
import BrightFutures
import Result
import RealmSwift
import Realm

func syncAll(progressView: UIProgressView, changes: Results<(Change)>, beats: Results<(Beat)>) -> Future<Bool, NoError> {
    // Performing fetch
    let promise = Promise<Bool, NoError>()
    
    // Figure increase to use for progressView
    let uploadsToDo = beats.count + changes.count
    let increase = Float((100/Float(uploadsToDo))/100)
    
    if beats.count > 0 {
        let beatFuture = sendBeats(beats, progressView: progressView, increase: increase)
        
        beatFuture.onSuccess{ (successBeats) in
            if changes.count > 0 {
                print("SyncAll: syncronizing changes")
                let changeFuture = sendChanges(progressView, increase: increase, changes: changes)
                
                changeFuture.onSuccess{ successChanges in
                    print("SyncAll: Success on changes and beats")
                    promise.success(successChanges && successBeats)
                }
            } else {
                print("SyncAll: Success on beats alone")
                promise.success(successBeats)
            }
        }
    } else if beats.count == 0 && changes.count > 0 {
        if changes.count > 0 {
            let changeFuture = sendChanges(progressView, increase: increase, changes: changes)
            print("SyncAll: syncronizing changes")
            changeFuture.onSuccess{ success in
                print("SyncAll: Success on changes")
                promise.success(success)
            }
        }
    } else {
        print("r")
        promise.success(true)
    }
    
    return promise.future

}

