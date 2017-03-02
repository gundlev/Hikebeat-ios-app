//
//  UserList.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 02/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures
class UserList: Any, PaginatingList {
    
    var nextPageString: String? = ""
    var type: ListType
    var results = [Any]()
    var from: String!
    
    init(from: String) {
        self.from = from
        self.type = .user
    }
    
    func nextPage() -> Future<[Any], HikebeatError> {
        return Future { complete in
            guard nextPageString != nil else { complete(.success([User]())); return }
            getUsers(from: "\(from)\(nextPageString)")
            .onSuccess(callback: { (tuple) in
                self.nextPageString = tuple.nextPage
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
