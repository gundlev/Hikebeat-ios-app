//
//  Save.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 03/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import BrightFutures
import Result

func saveImageToDocs(fileName: String, image: UIImage) -> Future<Bool, NoError> {
    return Future { complete in
        DispatchQueue.global().async {
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: AnyObject = paths[0] as AnyObject
            let dataPath = documentsDirectory.appending(fileName)
            let success = (try? UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: dataPath), options: [.atomic])) != nil
            // do a complicated task and then hand the result to the promise:
            complete(.success(success))
        }
    }
}

func saveJourneyWithNoData(journeyJson:JSON, userId: String) -> Future<Bool, NoError> {
    print("JoruneyJson: ", journeyJson)
    return Future { complete in
        DispatchQueue.global().async {
            let headline = journeyJson["options"]["headline"].stringValue
            print("journey", journeyJson)
            
            var beats = [Beat]()
            
            let journey = Journey()
            journey.fill(journeyJson["slug"].stringValue, userId: userId, journeyId: journeyJson["_id"].stringValue, headline: journeyJson["options"]["headline"].stringValue, journeyDescription: journeyJson["options"]["headline"].stringValue, active: false, type: journeyJson["options"]["type"].stringValue, seqNumber: String(journeyJson["seqNumber"].intValue))
            let localRealm = try! Realm()
            print("Saving journey")
            try! localRealm.write() {
                localRealm.add(journey)
            }
            
            print("followers: ",journeyJson["followers"])
            if journeyJson["followers"] != nil {
                print("fucking nil")
                for (_,followerId) in journeyJson["followers"] {
                    print("Saving follower")
                    try! localRealm.write() {
                        let follower = Follower()
                        follower.userId = followerId.stringValue
                    }
                }

            }
            
            var finishedBeats = 0
            var failedBeats = 0
            
            if journeyJson["messages"] != nil {
                for (_, message) in journeyJson["messages"]  {
                    print("Slug: ", message["slug"].stringValue, " for journey: ", headline)
                    let mediaType = message["media"]["type"].stringValue
                    let mediaUrl = message["media"]["path"].stringValue
                    let mediaDataId = message["media"]["_id"].stringValue
                    
                    do {
                        print("saving beat")
                        try localRealm.write {
                            let beat = Beat()
                            beat.fill(message["emotion"].stringValue, journeyId: journey.journeyId, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, altitude: message["alt"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: mediaType, mediaData: nil, mediaDataId: mediaDataId, mediaUrl: mediaUrl, messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true, journey: journey)
                            localRealm.add(beat)
                            journey.beats.append(beat)
                        }
                    } catch {
                    }
                }
            }
            complete(.success(true))
        }
    }

}

//func saveJourney(journey:JSON, userId: String) -> Future<Bool, NoError> {
//    return Future { complete in
//        DispatchQueue.global().async {
//            let headline = journey["options"]["headline"].stringValue
//            print(headline)
//            
//            var beats = [Beat]()
//            
//            let dataJourney = Journey()
//            dataJourney.fill(journey["slug"].stringValue, userId: userId, journeyId: journey["_id"].stringValue, headline: journey["options"]["headline"].stringValue, journeyDescription: journey["options"]["headline"].stringValue, active: false, type: journey["options"]["type"].stringValue, seqNumber: String(journey["seqNumber"].intValue))
//            let localRealm = try! Realm()
//            print("Saving journey")
//            try! localRealm.write() {
//                localRealm.add(dataJourney)
//            }
//            print("followers: ",journey["followers"])
//            for (_,followerId) in journey["followers"] {
//                print("Saving follower")
//                try! localRealm.write() {
//                    let follower = Follower()
//                    follower.userId = followerId.stringValue
//                }
//            }
//            
//            var finishedBeats = 0
//            var failedBeats = 0
//            
//            for (_, message) in journey["messages"]  {
//                print("Slug: ", message["slug"].stringValue, " for journey: ", headline)
//                //print(message)
//                let mediaType = message["media"]["type"].stringValue
//                let mediaData = message["media"]["path"].stringValue
//                let mediaDataId = message["media"]["_id"].stringValue
//                
//                
//                if mediaData != "" && mediaType != "" {
//                    switch mediaType {
//                    case MediaType.image:
//                        let imageFuture = downloadAndStoreImage(mediaData: mediaData, beatId: message["_id"].stringValue)
//                        imageFuture.onSuccess(callback: { (image) in
//                            if image != nil {
//                                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//                                let documentsDirectory: AnyObject = paths[0] as AnyObject
//                                let fileName = "hikebeat_"+journey["_id"].stringValue+"_"+message["timeCapture"].stringValue+".jpg"
//                                let dataPath = documentsDirectory.appending("/media/"+fileName)
//                                let success = (try? UIImagePNGRepresentation(image!)!.write(to: URL(fileURLWithPath: dataPath), options: [.atomic])) != nil
//                                print("The image downloaded: ", success, " moving on to save")
//                                let beatFuture = saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: MediaType.image, mediaData: fileName, mediaDataId: mediaDataId, mediaUrl: mediaData)
//                                beatFuture.onSuccess(callback: { (beat) in
//                                    if beat != nil {
//                                        let localRealm = try! Realm()
//                                        let predicate = NSPredicate(format: "journeyId == %@", journey["_id"].stringValue)
//                                        let results = localRealm.objects(Journey.self).filter(predicate)
//                                        let lJourney = results[0]
//                                        beat!.journey = lJourney
////                                        beats.append(beat!)
//                                        print("YEAH saved beat, media and all.")
//                                        finishedBeats += 1
//                                        if (finishedBeats + failedBeats) == journey["messages"].count {
//                                            let tuple = (finishedBeats, failedBeats)
//                                            complete(.success(true))
//                                            
//                                        }
//                                    } else {
//                                        failedBeats += 1
//                                        if (finishedBeats + failedBeats) == journey["messages"].count {
//                                            complete(.success(false))
//                                        }
//                                    }
//                                })
//                            }
//                        })
//                        // download and stoe image
//                    case MediaType.video, MediaType.audio:
//                        var fileType = ".mp4"
//                        if mediaType == MediaType.audio {
//                            fileType = ".m4a"
//                        }
//                        let path = "/media/hikebeat_"+journey["_id"].stringValue+"_"+message["timeCapture"].stringValue+fileType
//                        let future = downloadAndStoreMedia(url: mediaData, path: path)
//                        future.onSuccess(callback: { (success) in
//                            if success {
//                                let beatFuture = saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: mediaType, mediaData: path, mediaDataId: mediaDataId, mediaUrl: mediaData)
//                                beatFuture.onSuccess(callback: { (beat) in
//                                    if beat != nil {
//                                        let localRealm = try! Realm()
//                                        let predicate = NSPredicate(format: "journeyId == %@", journey["_id"].stringValue)
//                                        let results = localRealm.objects(Journey.self).filter(predicate)
//                                        let lJourney = results[0]
//                                        beat!.journey = lJourney
////                                        beat!.journey = dataJourney
//                                        beats.append(beat!)
//                                        finishedBeats += 1
//                                        if (finishedBeats + failedBeats) == journey["messages"].count {
//                                            complete(.success(true))
//                                        }
//                                    } else {
//                                        failedBeats += 1
//                                        if (finishedBeats + failedBeats) == journey["messages"].count {
//                                            complete(.success(false))
//                                        }
//                                    }
//                                })
//                            }
//                        })
//                    default:
//                        print("unknown type of media")
//                    }
//
//                    
//                } else {
//                    let beatFuture = saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: nil, mediaData: nil, mediaDataId: nil, mediaUrl: nil)
//                    beatFuture.onSuccess(callback: { (beat) in
//                        if beat != nil {
//                            let localRealm = try! Realm()
//                            let predicate = NSPredicate(format: "journeyId == %@", journey["_id"].stringValue)
//                            let results = localRealm.objects(Journey.self).filter(predicate)
//                            let lJourney = results[0]
//                            beat!.journey = lJourney
////                            beat!.journey = dataJourney
//                            beats.append(beat!)
//                            finishedBeats += 1
//                            if (finishedBeats + failedBeats) == journey["messages"].count {
//                                complete(.success(true))
//                            }
//                        } else {
//                            failedBeats += 1
//                            if (finishedBeats + failedBeats) == journey["messages"].count {
//                                complete(.success(false))
//                            }
//                        }
//                    })
//                }
//            }
//        }
//    }
//}

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

//func saveBeatAndAddToJourney(_ message: JSON, journey: Journey, mediaType: String?, mediaData: String?, mediaDataId: String?, mediaUrl: String?) -> Future<Beat?, NoError> {
//    let promise = Promise<Beat?, NoError>()
//    let realm = try! Realm()
//    do {
//        print("saving beat")
//        try realm.write {
//            let beat = Beat()
//            beat.fill(message["emotion"].stringValue, journeyId: journey.journeyId, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, altitude: message["alt"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: mediaType, mediaData: mediaData, mediaDataId: mediaDataId, mediaUrl: mediaUrl, messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true)
//            realm.add(beat)
////            journey.beats.append(dataBeat)
//            promise.success(beat)
//        }
//    } catch {
//        promise.success(nil)
//    }
//    return promise.future
//}
