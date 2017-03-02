//
//  PaginatingList.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 02/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import BrightFutures

protocol PaginatingList {
    var nextPageString: String? { get set }
    var type: ListType { get set }
    var results: [Any]  { get set }
    
    func nextPage() -> Future<[Any], HikebeatError>
    func hasNextpage() -> Bool
}

enum ListType: String {
    case journey
    case user
    case follower
    case following
}
