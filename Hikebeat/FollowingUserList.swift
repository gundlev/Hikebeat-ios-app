//
//  FollowingUserList.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 02/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
class FollowingUsersList: Any, PaginatingList {
    
    var nextPageString: String? = ""
    var type: ListType
    var results = [Any]()
    
    init(from: String) {
        self.type = .user
    }
    
    func nextPage() -> Future<[Any], HikebeatError> {
        return Future { complete in
            guard nextPageString != nil else { complete(.success([User]())); return }
            getFollowersForJourney(queryString: "\(nextPageString)")
            .onSuccess(callback: { (tuple) in
                self.nextPageString = tuple.nextPage
                for user in tuple.users {
                    self.results.append(user)
                }
                complete(.success(tuple.users))
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
        }
    }
    
    func hasNextpage() -> Bool {
        return self.nextPageString != nil
    }
}
