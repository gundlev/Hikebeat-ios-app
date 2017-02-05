//
//  DownloadMedia.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 09/08/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Result
import BrightFutures
import Alamofire
import SwiftyJSON

func downloadMediaForJourney(_ journey: Journey) {
    let beats = journey.beats
    for beat in beats {
        if beat.mediaType != nil && beat.mediaData == nil {
            // The beat contains media but none has been downloaded. Download media
            
        }
    }
}

func downloadAndStoreImage(mediaUrl: String, fileName: String) -> Future<UIImage?, NoError> {
    return Future { complete in
        Alamofire.request(mediaUrl).responseImage {
            response in
            print("Statuscoode image: ", response.response?.statusCode)
            print(response)
            if let image = response.result.value {
                print("Its an image!!!")
                saveImageToDocs(fileName: fileName, image: image)
                .onSuccess(callback: { (success) in
                    if success {
                        complete(.success(image))
                    } else {
                        print("failed at saving")
                        complete(.success(nil))
                    }
                })
            } else {
                complete(.success(nil))
            }
        }
    }
}

func downloadImage(imageUrl: String) -> Future<UIImage, HikebeatError> {
    return Future { complete in
        Alamofire.request(imageUrl).responseImage {
            response in
            print("response: ", response)
            print("Statuscoode: ", response.response?.statusCode as Any)
            if let image = response.result.value {
                complete(.success(image))
            } else {
                print("Downloading image from url failed: ", imageUrl)
                print("Failed getting image")
                print("image: ", response.result.value)
                complete(.failure(.profileImage))
            }
        }
    }
}


func downloadAndStoreMedia(url: String, fileName: String) -> Future<Bool, NoError> {

    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let fm = FileManager()
    
    let documentsDirectory: AnyObject = paths[0] as AnyObject
    let dataPath = documentsDirectory.appending(fileName)
    
    let pathURL = URL(fileURLWithPath: dataPath)
    let destination = DownloadRequest.suggestedDownloadDestination(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)

    let promise = Promise<Bool, NoError>()
    print("urlHere: ", url)
    Alamofire.request(url).responseData { response in
        print("value: ", response)
        if let data = response.result.value {
            if let _ = saveMediaToDocs(fileName: fileName, data: data) {
                promise.success(true)
            } else {
                promise.success(false)
            }
        } else {
            promise.success(false)
            print("Failed to get data")
        }
    }
    return promise.future
}
