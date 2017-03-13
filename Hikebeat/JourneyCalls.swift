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

func getJourneysForUser(userId: String) -> Future<(finishedJourneys: Int, failedJourneys: Int)?, HikebeatError>{
    return Future { complete in
        let urlJourney = IPAddress + "users/" + userId + "/journeys"
        print(urlJourney)
        getCall(url: urlJourney, headers: getHeader())
        .onSuccess(callback: { (response) in
            var finishedJourneys = 0
            var failedJourneys = 0
            if response.response?.statusCode == 200 {
                if response.result.value != nil {
                    let rawJson = JSON(response.result.value!)
                    let json = rawJson["data"]
                    for (_, journey) in json {
                        // saveJourney
                        saveJourneyWithNoData(journeyJson: journey, userId: userId)
                            .onSuccess(callback: { (journey) in
                                finishedJourneys += 1
                                if (finishedJourneys + failedJourneys) == json.count {
                                    let tuple = (finishedJourneys, failedJourneys)
                                    complete(.success(tuple))
                                }
                            }).onFailure(callback: { (error) in
                                failedJourneys += 1
                                if (finishedJourneys + failedJourneys) == json.count {
                                    let tuple = (finishedJourneys, failedJourneys)
                                    complete(.success(tuple))
                                }
                            })
                    }
                }
            } else {
                complete(.failure(.getJourneysForUser))
            }
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
//        getSessionManager().request(urlJourney, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
//            print("JOURNEY: ", response)
//            var finishedJourneys = 0
//            var failedJourneys = 0
//            if response.response?.statusCode == 200 {
//                if response.result.value != nil {
//                    let rawJson = JSON(response.result.value!)
//                    let json = rawJson["data"]
//                    for (_, journey) in json {
//                        // saveJourney
//                        saveJourneyWithNoData(journeyJson: journey, userId: userId)
//                        .onSuccess(callback: { (journey) in
//                            finishedJourneys += 1
//                            if (finishedJourneys + failedJourneys) == json.count {
//                                let tuple = (finishedJourneys, failedJourneys)
//                                complete(.success(tuple))
//                            }
//                        }).onFailure(callback: { (error) in
//                            failedJourneys += 1
//                            if (finishedJourneys + failedJourneys) == json.count {
//                                let tuple = (finishedJourneys, failedJourneys)
//                                complete(.success(tuple))
//                            }
//                        })
//                    }
//                }
//            } else {
//                complete(.failure(.getJourneysForUser))
//            }
//        }
    }
}

func deleteJourney(journeyId: String) -> Future<Bool, NoError> {
    return Future { complete in
        let userId = userDefaults.string(forKey: "_id")
        let urlJourney = IPAddress + "users/\(userId!)/journeys/\(journeyId)"
        print(urlJourney)
        getSessionManager().request(urlJourney, method: .delete, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            print("Delete response: ", response)
            
            guard successWith(response: response) else {
                complete(.success(false))
                return
            }
            
            if response.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                complete(.success(false))
            }
        }
    }
}

func createNewJourneyCall(headline: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let parameters: [String: Any] = ["headline": headline]
        let url = IPAddress + "users/journeys"
        guard hasNetworkConnection(show: true) else {complete(.failure(.noNetworkConnection)); return}
        getSessionManager().request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON {
            response in
            guard successWith(response: response) else {
                complete(.failure(.callFailed))
                return
            }
            if response.response?.statusCode == 200 {
                let rawJson = JSON(response.result.value!)
                let json = rawJson["data"]
                print(json)
                let realm = try! Realm()
                try! realm.write() {
                    let journeys = realm.objects(Journey.self).filter("active = \(true)")
                    if !(journeys.isEmpty) {
                        let j = journeys[0]
                        j.active = false
                    }
                    let journey = Journey()
                    journey.fill(json["slug"].stringValue, userId: json["userId"].stringValue, journeyId: json["_id"].stringValue, headline: json["headline"].stringValue, journeyDescription: nil, active: false, type: nil, seqNumber: String(json["seqNumber"].intValue), latestBeat: Date(timeIntervalSince1970: (json["latestBeat"].doubleValue/1000)), username: json["username"].stringValue)
                    journey.active = true
                    realm.add(journey)
                    complete(.success(true))
                }
            } else {
                showCallErrors(json: JSON(response.result.value!))
                complete(.failure(.createNewJourneyCall))
            }
        }

    }
}

func getNumberOfFollowersFor(journeyId: String) -> Future<Int, HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)journeys/\(journeyId)/followers/count"
        print("URL count: ", url)
        getCall(url: url, headers: getHeader())
        .onSuccess(callback: { (response) in
            print("Followers count response: ", response)
            if response.response?.statusCode == 200 {
                if response.result.value != nil {
                    let json = JSON(response.result.value!)
                    complete(.success(json["data"]["count"].intValue))
                } else {
                    complete(.failure(.followersForJourney))
                }
            } else {
                complete(.failure(.followersForJourney))
            }
        }).onFailure(callback: { (error) in
            print("Error: ", error)
            complete(.failure(.followersForJourney))
        })
    }
}

//func getJourneyWithId(userId: String, journeyId: String) -> Future<Journey, HikebeatError> {
//    return Future { complete in
//        let urlJourney = IPAddress + "users/\(userId)/journeys/\(journeyId)"
//        print(urlJourney)
//        getSessionManager().request(urlJourney, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
//            if response.response?.statusCode == 200 {
//                if response.result.value != nil {
//                    let rawJson = JSON(response.result.value!)
//                    let json = rawJson["data"]
//                    saveJourneyWithNoData(journeyJson: json, userId: userId)
//                    .onSuccess(callback: { (journey) in
//                        complete(.success(journey))
//                    }).onFailure(callback: { (error) in
//                        complete(.failure(error))
//                    })
//                    
//                }
//            } else {
//                complete(.failure(.getJourneyWithId))
//            }
//        }
//    }
//}
