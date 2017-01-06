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
                for (_, jsonJourney) in jsonUsers {
//                    let journey = User(id: <#T##String#>, username: <#T##String#>, numberOfJourneys: <#T##String#>, numberOfBeats: <#T##String#>, numberOfFollowers: <#T##String#>, numberOfFollowing: <#T##String#>, profilePhoto: <#T##UIImage#>)

//                    users.append(journey)
                }
                
            }
            complete(.success(users))
        }
    }
}

func search(searchString: String) -> Future<(journeys: Journey, users: User), NoError> {
    return Future { complete in
        
    }
}

//func searchUsers(searchString: String?, nextpage: String?) -> Future< {
//
//}
