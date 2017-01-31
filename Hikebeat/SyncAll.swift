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

func syncAll(_ progressView: UIProgressView, changes: Results<(Change)>, mediaBeats: Results<(Beat)>, messageBeats: Results<(Beat)>) -> Future<Bool, SyncError> {
    return Future { complete in
        // Figure increase to use for progressView
        let uploadsToDo = mediaBeats.count + changes.count + messageBeats.count
        let increase = Float((100/Float(uploadsToDo))/100)
        var succeeded = 0
        var failed = 0
        let total = 3
        
        sendChanges(progressView, increase: increase, changes: changes)
        .onSuccess(callback: { (success) in
            print("Success on changes")
            succeeded += 1
            if succeeded == total {
                complete(.success(true))
            } else if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        }).onFailure(callback: { (error) in
            failed += 1
            print("Failed send changes with: ", error)
            if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        })
        
        sendMedia(mediaBeats, progressView: progressView, increase: increase)
        .onSuccess(callback: { (success) in
            print("Success on media")
            succeeded += 1
            if succeeded == total {
                complete(.success(true))
            } else if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        }).onFailure(callback: { (error) in
            failed += 1
            print("Failed send media with: ", error)
            if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        })
        
        sendBeats(messageBeats, progressView: progressView, increase: increase)
        .onSuccess(callback: { (success) in
            print("Success on beats")
            succeeded += 1
            if succeeded == total {
                complete(.success(true))
            } else if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        }).onFailure(callback: { (error) in
            failed += 1
            print("Failed send beats with: ", error)
            if succeeded + failed == total {
                complete(.failure(.uploadAll))
            }
        })
        
//        if mediaBeats.count != 0 {
//            sendMedia(mediaBeats, progressView: progressView, increase: increase)
//            .onSuccess{ (successBeats) in
//                    if changes.count > 0 {
//                        print("SyncAll: syncronizing changes")
//                        let changeFuture = sendChanges(progressView, increase: increase, changes: changes)
//                        
//                        changeFuture.onSuccess{ successChanges in
//                            print("SyncAll: Success on changes and beats")
//                            promise.success(successChanges && successBeats)
//                        }
//                    } else {
//                        print("SyncAll: Success on beats alone")
//                        promise.success(successBeats)
//                    }
//            }
//        } else if mediaBeats.count == 0 && changes.count > 0 {
//            if changes.count > 0 {
//                let changeFuture = sendChanges(progressView, increase: increase, changes: changes)
//                print("SyncAll: syncronizing changes")
//                changeFuture.onSuccess{ success in
//                    print("SyncAll: Success on changes")
//                    promise.success(success)
//                }
//            }
//        } else {
//            print("r")
//            promise.success(true)
//        }
    }
}

