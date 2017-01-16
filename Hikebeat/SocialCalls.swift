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
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
//            print(response)
            let json = JSON(response.result.value)
            let jsonJourneys = json["data"]["docs"]
            var journeys = [Journey]()
            if jsonJourneys != nil {
                for (_, jsonJourney) in jsonJourneys {
                    let journey = Journey()
                    journey.headline = jsonJourney["options"]["headline"].stringValue
                    journey.journeyId = jsonJourney["_id"].stringValue
                    journey.numberOfBeats = jsonJourney["messageCount"].intValue
                    journey.ownerProfilePhotoUrl = jsonJourney["ownerProfilePhoto"].string
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
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            print("userResponse: ", response)
            let json = JSON(response.result.value)
            let jsonUsers = json["data"]["docs"]
            var users = [User]()
            if jsonUsers != nil {
                for (_, jsonUser) in jsonUsers {
                    print("User: ", jsonUser)
                    users.append(User(
                        id: jsonUser["_id"].stringValue,
                        username: jsonUser["username"].stringValue,
                        numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                        numberOfBeats: jsonUser["_id"].stringValue,
                        followerCount: jsonUser["followerCount"].stringValue,
                        followsCount: jsonUser["followsCount"].stringValue,
                        profilePhotoUrl: jsonUser["options"]["profilePhoto"].stringValue
                    ))
                }
            }
            complete(.success(users))
        }
    }
}

func searchUsers(queryString: String) -> Future<(users:[User], nextPage: String?), SearchError> {
    return Future { complete in
//        print("QueryString: ", queryString)
        let url = "\(IPAddress)search/users\(queryString)"
//        print("Url: ", url)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
//            print("UserResponse: ", response)
            guard response.response?.statusCode == 200 else {complete(.failure(.userSearch)); return}
            let json = JSON(response.result.value as Any)
            let jsonUsers = json["data"]["docs"]
            var users = [User]()
            if jsonUsers != nil {
                for (_, jsonUser) in jsonUsers {
//                    print("User: ", jsonUser)
                    users.append(User(
                        id: jsonUser["_id"].stringValue,
                        username: jsonUser["username"].stringValue,
                        numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                        numberOfBeats: jsonUser["_id"].stringValue,
                        followerCount: jsonUser["followerCount"].stringValue,
                        followsCount: jsonUser["followsCount"].stringValue,
                        profilePhotoUrl: jsonUser["options"]["profilePhoto"].stringValue
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

func searchJourneys(queryString: String) -> Future<(journeys:[Journey], nextPage: String?), SearchError> {
    return Future { complete in
        let url = "\(IPAddress)search/journeys\(queryString)"
        
        print("Url: ", url)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            let json = JSON(response.result.value as Any)
            guard response.response?.statusCode == 200 else {print(response.response?.statusCode); complete(.failure(.journeySearch)); return}
            let jsonJourneys = json["data"]["docs"]
            var journeys = [Journey]()
            if jsonJourneys != nil {
                for (_, jsonJourney) in jsonJourneys {
                    let journey = Journey()
                    journey.headline = jsonJourney["options"]["headline"].stringValue
                    journey.journeyId = jsonJourney["_id"].stringValue
                    journey.numberOfBeats = jsonJourney["messageCount"].intValue
                    journey.ownerProfilePhotoUrl = jsonJourney["ownerProfilePhoto"].string
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

//func searchUsers(searchString: String?, nextpage: String?) -> Future< {
//
//}
