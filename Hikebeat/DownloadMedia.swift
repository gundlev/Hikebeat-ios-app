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

func downloadAndStoreMedia(url: String, name: String) -> Future<Bool, NoError> {
    let promise = Promise<Bool, NoError>()
    print("urlHere: ", url)
    Alamofire.request(url).responseData { response in
        print("value: ", response)
        if let data = response.result.value {
            if let _ = saveMediaToDocs(fileName: name, data: data) {
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
