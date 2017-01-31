//
//  ComposeCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 16/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
import Alamofire
import SwiftyJSON

func uploadBeat(beat: Beat) -> Future<String, SyncError> {
    return Future { complete in
        let url = IPAddress + "journeys/" + beat.journeyId + "/messages"
        print("url: ", url)
        var parameters: [String: Any] = ["lat": beat.latitude, "lng": beat.longitude, "alt": beat.altitude, "timeCapture": beat.timestamp]
        if beat.emotion != nil {
            parameters["emotion"] = emotionToNumber((beat.emotion)!)
        }
        if beat.message != nil {
            parameters["text"] = beat.message
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                print("The text was send")

                let rawMessageJson = JSON(response.result.value!)
                let messageJson = rawMessageJson["data"][0]
                complete(.success(messageJson["_id"].stringValue))
            } else {
                complete(.failure(.uploadBeat))
            }
        }
    }
}
