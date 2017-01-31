//
//  JourneyCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 03/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Result
import BrightFutures
import Alamofire
import AlamofireImage
import SwiftyJSON

func getJourneysForUser(userId: String) -> Future<(finishedJourneys: Int, failedJourneys: Int)?, UserCallError>{
    return Future { complete in
        let urlJourney = IPAddress + "users/" + userId + "/journeys"
        print(urlJourney)
        Alamofire.request(urlJourney, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            print("JOURNEY: ", response)
            var finishedJourneys = 0
            var failedJourneys = 0
            if response.response?.statusCode == 200 {
                if response.result.value != nil {
                    let rawJson = JSON(response.result.value!)
                    let json = rawJson["data"]
                    for (_, journey) in json {
                        // saveJourney
                        saveJourneyWithNoData(journeyJson: journey, userId: userId)
                        .onSuccess(callback: { (success) in
                            if success {
                                finishedJourneys += 1
                                if (finishedJourneys + failedJourneys) == json.count {
                                    let tuple = (finishedJourneys, failedJourneys)
                                    complete(.success(tuple))
                                }
                            } else {
                                failedJourneys += 1
                                if (finishedJourneys + failedJourneys) == json.count {
                                    let tuple = (finishedJourneys, failedJourneys)
                                    complete(.success(tuple))
                                }
                            }
                        })
                    }
                }
            } else {
                complete(.failure(.getJourneysForUser))
            }
        }
    }
}

func deleteJourney(journeyId: String) -> Future<Bool, NoError> {
    return Future { complete in
        let userId = userDefaults.string(forKey: "_id")
        let urlJourney = IPAddress + "users/\(userId!)/journeys/\(journeyId)"
        print(urlJourney)
        Alamofire.request(urlJourney, method: .delete, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            print("Delete response: ", response)
            if response.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                complete(.success(false))
            }
        }
    }
}
