//
//  SyncAll.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import BrightFutures
import Result
import RealmSwift
import Realm

func syncAll(_ progressView: UIProgressView?, changes: Results<(Change)>, mediaBeats: Results<(Beat)>, messageBeats: Results<(Beat)>) -> Future<Bool, HikebeatError> {
    return Future { complete in
        
        var succeeded = 0
        var failed = 0
        let total = 3
        
        sendChanges(changes)
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
        
        sendMedia(mediaBeats, progressView: (progressView != nil) ? progressView! : UIProgressView())
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
        
        sendBeats(messageBeats)
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
    }
}

func journeyIsInSync(journeyId: String) -> Bool {
    let realmLocal = try! Realm()
    let mediaQuery = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "mediaUploaded == %@", false as CVarArg), NSPredicate(format: "mediaData != %@", ""), NSPredicate(format: "journeyId == %@", journeyId)])
    let beatQuery = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "messageUploaded == %@", false as CVarArg), NSPredicate(format: "journeyId == %@", journeyId)])
    let media = realmLocal.objects(Beat.self).filter(mediaQuery)
    let beats = realmLocal.objects(Beat.self).filter(beatQuery)
    
    print("media: ", media)
    print("beats: ", beats)
    print("empty: ", media.isEmpty && beats.isEmpty)
    return media.isEmpty && beats.isEmpty
}

