//
//  FollowingJourneysList.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 03/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import Foundation
import BrightFutures
class FollowingJourneysList: Any, PaginatingList {
    
    var nextPageString: String? = ""
    var type: ListType
    var results = [Any]()
    
    init() {
        self.type = .journey
    }
    
    func nextPage() -> Future<[Any], HikebeatError> {
        return Future { complete in
            guard nextPageString != nil else { complete(.success([Journey]())); return }
            getJourneysFollowing(queryString: "\(nextPageString!)")
            .onSuccess(callback: { (tuple) in
                self.nextPageString = tuple.nextPage
                for journey in tuple.journeys {
                    self.results.append(journey)
                }
                complete(.success(tuple.journeys))
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
        }
    }
    
    func hasNextpage() -> Bool {
        return self.nextPageString != nil
    }
}
