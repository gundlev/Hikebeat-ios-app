//
//  SocialCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import BrightFutures
import Result
import UIKit

func getFeaturedJourneys(nextPage: String) -> Future<[Journey], NoError> {
    return Future { complete in
        print("requestin featured")
        let url = "\(IPAddress)search/journeys/featured\(nextPage)"
        print("Url: ", url)
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
//            print(response)
            
            guard successWith(response: response) else {
                complete(.success([Journey]()))
                return
            }
            
            let json = JSON(response.result.value)
            let jsonJourneys = json["data"]["docs"]
            var journeys = [Journey]()
            if jsonJourneys != nil {
                for (_, jsonJourney) in jsonJourneys {
                    let journey = Journey()
                    journey.headline = jsonJourney["headline"].stringValue
                    journey.journeyId = jsonJourney["_id"].stringValue
                    journey.numberOfBeats = jsonJourney["messageCount"].intValue
                    journey.ownerProfilePhotoUrl = jsonJourney["ownerProfilePhoto"].string
                    journey.slug = jsonJourney["slug"].string
                    journeys.append(journey)
                }

            }
            complete(.success(journeys))
        }
    }
}

func getFeaturedUsers(nextPage: String) -> Future<[User], NoError> {
    return Future { complete in
        print("requestin featured")
        let url = "\(IPAddress)search/users/featured\(nextPage)"
        print("Url: ", url)
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            print("userResponse: ", response)
            
            guard successWith(response: response) else {
                complete(.success([User]()))
                return
            }
            
            let json = JSON(response.result.value)
            let jsonUsers = json["data"]["docs"]
            var users = [User]()
            if jsonUsers != nil {
                for (_, jsonUser) in jsonUsers {
                    print("User: ", jsonUser)
                    
                    let visitedCountries = jsonUser["visitedCountries"].dictionaryObject as! Dictionary<String, Int>
                    let mostVisitedElement = visitedCountries.max { $0.1 < $1.1 }
                    let mostVisitedCountry = mostVisitedElement != nil ? mostVisitedElement!.key : "none"
                    
                    users.append(User(
                        id: jsonUser["_id"].stringValue,
                        username: jsonUser["username"].stringValue,
                        numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                        numberOfBeats: jsonUser["_id"].stringValue,
                        followerCount: jsonUser["followerCount"].stringValue,
                        followsCount: jsonUser["followsCount"].stringValue,
                        profilePhotoUrl: jsonUser["profilePhoto"].stringValue,
                        latestBeat: Date(timeIntervalSince1970: (jsonUsers["latestBeat"].doubleValue/1000)),
                        visitedCountries: visitedCountries,
                        mostVisitedCountry: mostVisitedCountry
                    ))
                }
            }
            complete(.success(users))
        }
    }
}

func searchUsers(queryString: String) -> Future<(users:[User], nextPage: String?), HikebeatError> {
    return Future { complete in
//        print("QueryString: ", queryString)
        let url = "\(IPAddress)search/users\(queryString)"
//        print("Url: ", url)
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
//            print("UserResponse: ", response)
            guard response.response?.statusCode == 200 else {complete(.failure(.userSearch)); return}
            let json = JSON(response.result.value as Any)
            let jsonUsers = json["data"]["docs"]
            var users = [User]()
            if jsonUsers != JSON.null {
                for (_, jsonUser) in jsonUsers {
//                    print("User: ", jsonUser)
                    let latestBeat = jsonUser["latestBeat"].doubleValue
                    var latestBeatDate: Date? = nil
                    if latestBeat != 0.0 {
                        latestBeatDate = Date(timeIntervalSince1970: (latestBeat/1000))
                    }
                    
                    let visitedCountries = jsonUser["visitedCountries"].dictionaryObject as! Dictionary<String, Int>
                    let mostVisitedElement = visitedCountries.max { $0.1 < $1.1 }
                    let mostVisitedCountry = mostVisitedElement != nil ? mostVisitedElement!.key : "none"
                    
                    users.append(User(
                        id: jsonUser["_id"].stringValue,
                        username: jsonUser["username"].stringValue,
                        numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                        numberOfBeats: jsonUser["messageCount"].stringValue,
                        followerCount: jsonUser["followerCount"].stringValue,
                        followsCount: jsonUser["followsCount"].stringValue,
                        profilePhotoUrl: jsonUser["profilePhoto"].stringValue,
                        latestBeat: latestBeatDate,
                        visitedCountries: visitedCountries,
                        mostVisitedCountry: mostVisitedCountry
                    ))
                }
            }
            let nextPageString = json["data"]["nextPageQueryString"].stringValue
            var nextPage: String?
            if nextPageString != "" {
                nextPage = nextPageString
            }
            let tuple = (users: users, nextPage: nextPage)
            complete(.success(tuple))
        }
    }
}

func searchJourneys(queryString: String) -> Future<(journeys:[Journey], nextPage: String?), HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)search/journeys\(queryString)"
        
        print("Url: ", url)
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            let json = JSON(response.result.value as Any)
            guard response.response?.statusCode == 200 else {print(response); complete(.failure(.journeySearch)); return}
            let jsonJourneys = json["data"]["docs"]
            print("search journey: ", jsonJourneys)
            var journeys = [Journey]()
            if jsonJourneys != JSON.null {
                for (_, jsonJourney) in jsonJourneys {
                    let journey = Journey()
                    journey.headline = jsonJourney["headline"].stringValue
                    journey.journeyId = jsonJourney["_id"].stringValue
                    journey.numberOfBeats = jsonJourney["messageCount"].intValue
                    journey.ownerProfilePhotoUrl = jsonJourney["ownerProfilePhoto"].string
                    journey.userId = jsonJourney["userId"].stringValue
                    journey.slug = jsonJourney["slug"].stringValue
                    journey.username = jsonJourney["username"].stringValue
                    journey.isFollowed = jsonJourney["isFollowed"].boolValue
                    journey.numberOfFollowers = jsonJourney["numberOfFollowers"].intValue
                    journeys.append(journey)
                }
            }

            let nextPageString = json["data"]["nextPageQueryString"].stringValue
            var nextPage: String?
            if nextPageString != "" {
                nextPage = nextPageString
            }
            let tuple = (journeys: journeys, nextPage: nextPage)
            complete(.success(tuple))
        }
    }
}

func getBeatsForJourney(userId: String, journeyId: String) -> Future<JSON, HikebeatError> {
    return Future { complete in
        let urlJourney = IPAddress + "users/\(userId)/journeys/\(journeyId)"
        print(urlJourney)
        getSessionManager().request(urlJourney, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            if response.response?.statusCode == 200 {
                if response.result.value != nil {
                    let rawJson = JSON(response.result.value!)
                    let messages = rawJson["data"]["messages"]
                    complete(.success(messages))
                }
            } else {
                complete(.failure(.getJourneyWithId))
            }
        }
    }
}

func followJourney(journeyId: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)journeys/\(journeyId)/follow"
        followUnfowllowCall(url: url)
        .onSuccess(callback: { (success) in
            complete(.success(success))
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
    }
}

func unfollowJourney(journeyId: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)journeys/\(journeyId)/unfollow"
        followUnfowllowCall(url: url)
            .onSuccess(callback: { (success) in
                complete(.success(success))
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
    }
}

func followUnfowllowCall(url: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let token = userDefaults.string(forKey: "device_token")
        if token == nil {
            registerForNotification()
        }
        postCall(url: url, parameters: [String: String](), headers: getHeader())
        .onSuccess(callback: { (response) in
            print("FOLLOW/UNFOLLOW response: ", response)
            if response.response?.statusCode == 200 {
                complete(.success(true))
            } else {
                let json = JSON(response.result.value!)
                showCallErrors(json: json)
                complete(.failure(.followUnfollow))
            }
        })
    }
}

func getUserWith(userId: String) -> Future<User, HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)users/\(userId)"
        getCall(url: url, headers: getHeader())
        .onSuccess(callback: { (response) in
            if response.response?.statusCode == 200 {
                print("userResponse: ", response)
                let jsonUser = JSON(response.result.value!)["data"]
                let latestBeat = jsonUser["latestBeat"].doubleValue
                var latestBeatDate: Date? = nil
                if latestBeat != 0.0 {
                    latestBeatDate = Date(timeIntervalSince1970: (latestBeat/1000))
                }
                
                let visitedCountries = jsonUser["visitedCountries"].dictionaryObject as! Dictionary<String, Int>
                let mostVisitedElement = visitedCountries.max { $0.1 < $1.1 }
                let mostVisitedCountry = mostVisitedElement != nil ? mostVisitedElement!.key : "none"
                
                let user = User(
                    id: jsonUser["_id"].stringValue,
                    username: jsonUser["username"].stringValue,
                    numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                    numberOfBeats: jsonUser["messageCount"].stringValue,
                    followerCount: jsonUser["followerCount"].stringValue,
                    followsCount: jsonUser["followsCount"].stringValue,
                    profilePhotoUrl: jsonUser["profilePhoto"].stringValue,
                    latestBeat: latestBeatDate,
                    visitedCountries: visitedCountries,
                    mostVisitedCountry: mostVisitedCountry
                )
                complete(.success(user))
            } else {
                let json = JSON(response.result.value!)
                showCallErrors(json: json)
                complete(.failure(.getUser))
            }
        })
    }
}
