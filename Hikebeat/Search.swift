//
//  Search.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 15/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
// users?query=\(searchString)&items=1000
class Search: Any, PaginatingList {
    var searchString: String? = nil
    var nextPageString: String? = nil
    var type: ListType
    var results = [Any]()
    
    init(type: ListType) {
        self.type = type
//        switch self.type {
//        case .user:
//            for var i in 1...2 {
//                self.results.append(User(id: "\(i)", username: "user\(i)", numberOfJourneys: "\(i)", numberOfBeats: "\(i)", followerCount: "\(i)", followsCount: "\(i)", profilePhotoUrl: "https://s3-eu-central-1.amazonaws.com/hikebeat-production/profile-photo/584b11170ea3e40be50ac796_587b81ae64b701001287a5d1.jpg"))
//            }
//        case .journey:
//            for var i in 1...3 {
//                let journey = Journey()
//                journey.headline = "headline \(i)"
//                journey.journeyId = " \(i)"
//                journey.numberOfBeats = i
//                journey.ownerProfilePhotoUrl = "https://s3-eu-central-1.amazonaws.com/hikebeat-production/profile-photo/584b11170ea3e40be50ac796_587b81ae64b701001287a5d1.jpg"
//                self.results.append(journey)
//            }
//        }
    }
    
    func startSearch(searchText: String) -> Future<[Any], HikebeatError> {
        return Future { complete in
//            nextPageString = nil
//            results = nil
            switch self.type {
            case .user:
                searchUsers(queryString: "?query=\(searchText)&items=10")
                .onSuccess(callback: { (tuple) in
                    self.results = tuple.users
                    self.nextPageString = tuple.nextPage
                    complete(.success(tuple.users))
                }).onFailure(callback: { (error) in
                    print("startSearch: ", error)
                    complete(.failure(error))
                })
            case .journey:
                searchJourneys(queryString: "?query=\(searchText)&items=10")
                .onSuccess(callback: { (tuple) in
                    self.results = tuple.journeys
                    self.nextPageString = tuple.nextPage
                    complete(.success(tuple.journeys))
                }).onFailure(callback: { (error) in
                    print("startSearch: ", error)
                    complete(.failure(error))
                })
            default: complete(.failure(.noSuchListType))
            }
        }
    }
    
    func nextPage() -> Future<[Any], HikebeatError> {
        return Future { complete in
            guard self.nextPageString != nil else { complete(.success([Any]())); return }
            switch self.type {
            case .user:
                searchUsers(queryString: nextPageString!)
                .onSuccess(callback: { (tuple) in
                    for user in tuple.users {
                        self.results.append(user)
                    }
                    self.nextPageString = tuple.nextPage
                    complete(.success(tuple.users))
                }).onFailure(callback: { (error) in
                    print("Error")
                    complete(.failure(error))
                })
            case .journey:
                searchJourneys(queryString: nextPageString!)
                .onSuccess(callback: { (tuple) in
                    for journey in tuple.journeys {
                        self.results.append(journey)
                    }
                    self.nextPageString = tuple.nextPage
                    complete(.success(tuple.journeys))
                }).onFailure(callback: { (error) in
                    print("Error")
                    complete(.failure(error))
                })
            default: complete(.failure(.noSuchListType))
            }
        }
    }
    
    func hasNextpage() -> Bool {
        return self.nextPageString != nil
    }
    
}
