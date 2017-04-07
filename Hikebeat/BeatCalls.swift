//
//  BeatCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 03/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
import SwiftyDrop
import SwiftyJSON
import Alamofire

func sendTextBeat(beat: Beat) -> Future<JSON, HikebeatError> {
    return Future { complete in
        let url = IPAddress + "journeys/\(beat.journeyId)/messages"
        
        // "headline": localTitle, "text": localMessage,
        var parameters: [String: Any] = ["lat": beat.latitude, "lng": beat.longitude, "alt": beat.altitude, "timeCapture": beat.timestamp]
        if beat.emotion != nil {
            parameters["emotion"] = emotionToNumber(beat.emotion!)
        }
        if beat.message != nil {
            parameters["text"] = beat.message
        }
        postCall(url: url, parameters: parameters, headers: getHeader())
        .onSuccess(callback: { (response) in
            print("response BEAT: ", response)
            if response.response?.statusCode == 200 && response.result.value != nil {
                complete(.success(JSON(response.result.value!)))
            } else {
                complete(.failure(.beatMessageError))
            }
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
    }
}

func deleteBeat(messageId: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        guard hasNetworkConnection(show: false) else { complete(.failure(.noNetworkConnection)); return }
        let url = IPAddress + "messages/\(messageId)"
        
        getSessionManager().request(url, method: .delete, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            print("Delete response: ", response)
            
            guard successWith(response: response) else {
                complete(.failure(.deleteBeat))
                return
            }
            
            if response.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                complete(.failure(.deleteBeat))
            }
        }
    }
}
