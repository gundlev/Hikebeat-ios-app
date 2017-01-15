//
//  UploadBeats.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import BrightFutures
import UIKit
import Result
import RealmSwift
import SwiftyJSON

func sendBeats(_ beats: Results<Beat>, progressView: UIProgressView, increase: Float) -> Future<Bool, NoError> {
    
    let promise = Promise<Bool, NoError>()
    var count = 0
    var numberOfFails = 0
    for beat in beats {
        print(beat.mediaUploaded)
        let filePath = getPathToFileFromName(beat.mediaData!)!
        uploadeMediaForBeat(type: beat.mediaType!, path: filePath, journeyId: beat.journeyId, timeCapture: beat.timestamp, progressCallback: { (progress) in
            print("Progress: ", progress)
        }).onSuccess(callback: { (fileKey) in
            let realm = try! Realm()
            try! realm.write() {
                beat.mediaDataId = fileKey
                beat.mediaUploaded = true
            }
            count += 1
            if beats.count == 0 {
                print("Done uploading beats with no fails")
                promise.success(true)
                //                    appDelegate.currentlyShowingNotie = false
            } else if beats.count - numberOfFails == 0 {
                print("Done uploading beats with ", numberOfFails, " fails")
                promise.success(false)
            }
        }).onFailure(callback: { (error) in
            print("Error: ", error)
            numberOfFails += 1
            promise.success(false)
        })
    }
    return promise.future
}

    
        /** Parameters to send to the API.*/
       // let parameters: [String: AnyObject] = ["timeCapture": beat.timestamp, "journeyId": beat.journeyId, "data": beat.mediaData!]
        
//        var customHeader = Headers
//        customHeader["x-hikebeat-timecapture"] = beat.timestamp
//        customHeader["x-hikebeat-type"] = beat.mediaType!
//        
////        let filePath = getPathToFileFromName(beat.mediaData!)
//        
//        /** The URL for the post*/
//        let url = IPAddress + "journeys/" + beat.journeyId + "/media"
//        
//        Alamofire.upload(filePath, to: url, headers: customHeader).uploadProgress { progress in
//            //print(totalBytesWritten)
//            
//            // This closure is NOT called on the main queue for performance
//            // reasons. To update your ui, dispatch to the main queue.
//            DispatchQueue.main.async {
////                print("Total bytes written on main queue: \(totalBytesWritten)")
////                print("Bytes writtn now: \(totalBytesWritten)")
////                let byteIncreasePercentage = Float(bytesWritten) / Float(totalBytesExpectedToWrite)
////                let localIncrease = increase * byteIncreasePercentage
////                progressView.progress = progressView.progress + localIncrease
//            }
//        }.responseJSON { response in
////            print("This is the media response: ", response)
//            print("ResponseCode: ", response.response?.statusCode)
//            print("Response: ", response.response)
//            print("Value", response.result.value)
//            if response.response?.statusCode == 200 {
//                let json = JSON(response.result.value!)
//                print("Success for beat: ", beat.message)
//                let realm = try! Realm()
//                try! realm.write() {
//                    beat.mediaDataId = json["_id"].stringValue
//                    beat.mediaUploaded = true
//                }
//                print("There are ", beats.count, " to be uploaded")
////                print("Increasing progress by: ", increase)
////                print("Progress before: ", progressView.progress)
////                progressView.progress = progressView.progress + increase
////                print("Progress after: ", progressView.progress)
//                print(4)
//                count += 1
//                print("beats.count: ", beats.count)
//                print("count: ",count)
//                print("numberOfFails: ", numberOfFails)
//                if beats.count == 0 {
//                    print("Done uploading beats with no fails")
//                    promise.success(true)
//                    //                    appDelegate.currentlyShowingNotie = false
//                } else if beats.count - numberOfFails == 0 {
//                    print("Done uploading beats with ", numberOfFails, " fails")
//                    promise.success(false)
//                }
//                //print(5)
//            } else {
//                print("y")
//                numberOfFails += 1
//                promise.success(false)
//            }
//            
//        }
//
//    }

