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

let phoneNumber = "004530962591"

let MediaPathPrefix = "media/"

public let APIname = "bzb42utJUw1ZuWSJVmpLdwXMxScgwXOu4ZrAoL8spEJstyjuroTnnIts2m5Qgxo"
public let APIPass = "1dfpjdS6gmkDtdQQKbJVy4HezMK4mQYaIWgwyljbdYpMFJO3knQy012Lk2zBVS0"
public let Headers = [
    "Content-Type": "application/json",
    "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA=="
]

public let IPAddress = "https://hikebeat.rocks/api/"

func getUserExample() -> JSON {
    
    let user: JSON = ["_id": "00000001","username": "nsg", "permittedPhoneNumbers": ["+4531585010", "+4528357657"], "email": "Niklas@gundlev.dk", "journeyIds": ["J1","J2","J4"], "options": ["name": "Niklas Stokkebro Gundlev", "gender": "Male", "nationality": "Denmark", "notifications": true], "following": ["U2","U3","U4"], "activeJourneyId": "J1", "deviceTokens": ["gfhkdsgafigudsbfudabslifbdksa", "fgdhsaægfildgbfldasbilfuda"]]
    return user
}

func hex(_ number: Double) -> String {
    number
    let d = String(number)
    let e = d.range(of: ".")
    let s1 = d.substring(to: (e?.lowerBound)!)
    let s2 = d.substring(from: (e?.upperBound)!)
    
    // Check for leading zeroes in s2 and creating string
    var countZeroes = 0
    for char in s2.characters {
        if char == "0" {
            countZeroes += 1
        } else {
            break
        }
    }
    var zeroString = ""
    if countZeroes > 0 {
        for _ in 1...countZeroes {
            zeroString += "0"
        }
    }
    // Cast to Int
    let n1 = Int(s1)
    let n2 = Int(s2)
    
    // Create hex
    if s1 == "-0" {
        let st = "-0." + zeroString + String(n2!, radix: 36)
        return st
    } else {
        if n2 == 0 {
            let st = String(n1!, radix: 36)
            return st
        }
        let st = String(n1!, radix: 36) + "." + zeroString + String(n2!, radix: 36)
        return st
    }
    
    
    
}

//func getNewJourney(context: NSManagedObjectContext, active: Bool) -> DataJourney {
//    
//    let rand = randomStringWithLength(5)
//    
//    let journey = DataJourney(context: context, slug: "Journey-" + (rand as String), userId: NSUUID().UUIDString, journeyId: "56253f2b30f2c21d7905cdac", headline: "My awesome trip " + (rand as String), journeyDescription: "I am going to travel around the great coutry of " + (rand as String), active: active, type: "straight")
//    
//    return journey
//}

func randomStringWithLength (_ len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    

    
    for _ in 0...len-1{
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString
}

func alert(_ alertTitle: String, alertMessage: String, vc: UIViewController, actions:(title: String, style: UIAlertActionStyle, function: ()->())...) {
    let alertController = UIAlertController(title: alertTitle, message:
        alertMessage, preferredStyle: UIAlertControllerStyle.alert)
    
    for action in actions {
        alertController.addAction(UIAlertAction(title: action.title, style: action.style ,handler: {(alert: UIAlertAction!) in
            action.function()
        }))
    }
    vc.present(alertController, animated: true, completion: nil)
}

