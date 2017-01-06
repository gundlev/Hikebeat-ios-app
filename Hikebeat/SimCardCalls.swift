//
//  SimCardCalls.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 21/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import BrightFutures
import Result

func updateSimCard() -> Future<Bool, NoError> {
    return Future { complete in
        let url = "\(IPAddress)simcard-check"
        print("Performing cim card check now")
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
            print(response)
            let json = JSON(response.result.value)
            print("SimCard check response: ", json)
            let isActive = json["data"]["isActive"].boolValue
            if isActive {
                complete(.success(false))
            } else {
                let phoneNumber = json["data"]["phoneNumber"].stringValue
                guard phoneNumber != nil else {complete(.success(false)); return}
                print("New Phone Number being set: ", phoneNumber)
                userDefaults.set(phoneNumber, forKey: "hikebeat_phoneNumber")
                complete(.success(true))
            }
            
        }
    }
}
