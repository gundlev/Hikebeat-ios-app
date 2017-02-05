//
//  SendBeats.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 16/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
import RealmSwift

func sendBeats(_ messageBeats: Results<Beat>, progressView: UIProgressView, increase: Float) -> Future<Bool, HikebeatError> {
    return Future { complete in
        guard messageBeats.count != 0 else {complete(.success(true)); return}
        let total = messageBeats.count
        var count = 0
        var numberOfFails = 0
        for beat in messageBeats {
            uploadBeat(beat: beat)
            .onSuccess(callback: { (messageId) in
                let realm = try! Realm()
                print("Before2: \(messageBeats.count)")

                try! realm.write() {
                    beat.messageId = messageId
                    beat.messageUploaded = true
                }
                print("After2: \(messageBeats.count)")

                count += 1
                if messageBeats.count == 0 {
                    print("Done uploading beats with no fails")
                    complete(.success(true))
                } else if messageBeats.count - numberOfFails == 0 {
                    print("Done uploading beats with ", numberOfFails, " fails")
                    complete(.failure(.uploadBeat))
                }
            }).onFailure(callback: { (error) in
                print("Error: ", error)
                numberOfFails += 1
                if messageBeats.count == count + numberOfFails {
                    print("Done uploading beats with ", numberOfFails, " fails")
                    complete(.failure(.uploadBeat))
                }
            })
        }
    }
}

