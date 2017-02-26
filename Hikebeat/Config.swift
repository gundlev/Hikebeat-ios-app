//
//  Settings.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/09/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

//let phoneNumber = "004530962591"

public let IPAddress = "https://hikebeat-api-production.herokuapp.com/api/v1/" //"http://192.168.1.144:3000/api/v1/"


public let userDefaults = UserDefaults.standard

let MediaPathPrefix = "media/"

public let APIname = "bzb42utJUw1ZuWSJVmpLdwXMxScgwXOu4ZrAoL8spEJstyjuroTnnIts2m5Qgxo"
public let APIPass = "1dfpjdS6gmkDtdQQKbJVy4HezMK4mQYaIWgwyljbdYpMFJO3knQy012Lk2zBVS0"
//public let Headers = [
//    "Content-Type": "application/json",
//    "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA==",
//    "x-access-token": userDefaults.string(forKey: "token")!
//]

public func getHeader() -> [String:String] {
    return [
        "Content-Type": "application/json",
        "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA==",
        "x-access-token": userDefaults.string(forKey: "token")!
    ]
}

public let LoginHeaders = [
    "Content-Type": "application/json",
    "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA=="
]

func getUserExample() -> JSON {
    
    let user: JSON = ["_id": "00000001","username": "nsg", "permittedPhoneNumber": ["+4531585010", "+4528357657"], "email": "Niklas@gundlev.dk", "journeyIds": ["J1","J2","J4"], "options": ["name": "Niklas Stokkebro Gundlev", "gender": "Male", "nationality": "Denmark", "notifications": true], "following": ["U2","U3","U4"], "activeJourneyId": "J1", "deviceTokens": ["gfhkdsgafigudsbfudabslifbdksa", "fgdhsaægfildgbfldasbilfuda"]]
    return user
}
