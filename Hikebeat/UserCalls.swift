//
//  UserCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 15/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import BrightFutures
import Result

func getStats() -> Future<[String: String], UserCallError> {
    return Future { complete in
        let url = "\(IPAddress)stats"
        print("Performing stats check now")
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            print(response)
            guard response.response?.statusCode == 200 else {complete(.failure(.statsCall)); return}
            guard response.result.value != nil else {complete(.failure(.statsCall)); return}
            let json = JSON(response.result.value!)
            let followerCount = json["data"]["followerCount"].stringValue
            let followsCount = json["data"]["followsCount"].stringValue
            complete(.success(["followerCount": followerCount, "followsCount": followsCount]))
        }
    }
}
