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
import FacebookLogin
import ContactsUI


func getStats() -> Future<[String: String], HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)stats"
        print("Performing stats check now")
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
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

func refreshToken() -> Future<String, HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)refresh-token"
        let headers = getHeader()
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response)
            guard response.response?.statusCode == 200 else {complete(.failure(.refreshTokenCall)); return}
            guard response.result.value != nil else {complete(.failure(.refreshTokenCall)); return}
            let json = JSON(response.result.value!)
            let newToken = json["data"].stringValue
            userDefaults.set(newToken, forKey: "token")
            complete(.success(newToken))
        }
    }
}

func loginWithFacebook(viewController: UIViewController) -> Future<Bool, HikebeatError> {
    return Future { complete in
        guard hasNetworkConnection(show: true) else {complete(.failure(.noNetworkConnection)); return}
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn([ .publicProfile, .email, .userFriends ], viewController: viewController) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                complete(.failure(.facebookLogin))
            case .cancelled:
                print("User cancelled login.")
                complete(.failure(.facebookLogin))
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print(grantedPermissions)
                print(declinedPermissions)
                print("Logged in!")
                print("token: ", accessToken.authenticationToken)
                let url = IPAddress + "auth/facebook"
                let parameters = ["access_token": accessToken.authenticationToken]
                showActivity()
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginHeaders).responseJSON {
                    response in
                    if response.response?.statusCode == 200 {
                        print("Facebook Respose: ", response)
                        print(response.result.value as Any)
                        let json = JSON(response.result.value!)
                        handleUserAfterLogin(json: json)
                            .onSuccess(callback: { (success) in
                                hideActivity()
                                complete(.success(success))
                            }).onFailure(callback: { (error) in
                                hideActivity()
                                complete(.failure(error))
                                
                            })
                    } else {
                        print("response: ", response)
                        showCallErrors(json: JSON(response.result.value))
                        complete(.failure(.facebookLogin))
                    }
                }
            }
        }
    }
}

func handleUserAfterLogin(json: JSON) -> Future<Bool, HikebeatError> {
    return Future { complete in
        _ = createMediaFolder()

        let user = json["data"]["user"]
        let token = json["data"]["token"].stringValue
        userDefaults.set(token, forKey: "token")
        print("Responsio: ", json)
        print("setting user")
        userDefaults.set(user["username"].stringValue, forKey: "username")

        var journeyIdsArray = [String]()
        for (value) in user["journeyIds"].arrayValue {
            journeyIdsArray.append(value.stringValue)
        }
        
        var followingArray = [String]()
        for (value) in user["following"].arrayValue {
            followingArray.append(value.stringValue)
        }
        
        var deviceTokensArray = [String]()
        for (value) in user["deviceTokens"].arrayValue {
            deviceTokensArray.append(value.stringValue)
        }

        userDefaults.set(user["permittedPhoneNumber"].stringValue, forKey: "permittedPhoneNumber")

        
        userDefaults.set(user["followerCount"].stringValue, forKey: "followerCount")
        userDefaults.set(user["followsCount"].stringValue, forKey: "followsCount")
        
        userDefaults.set(journeyIdsArray, forKey: "journeyIds")
        userDefaults.set(followingArray, forKey: "following")
        userDefaults.set(deviceTokensArray, forKey: "deviceTokens")
        userDefaults.set(user["_id"].stringValue, forKey: "_id")
        userDefaults.set(user["username"].stringValue, forKey: "username")
        userDefaults.set(user["email"].stringValue, forKey: "email")
        print("Numberoo: ", user["simCard"]["phoneNumber"].stringValue)
        userDefaults.set(user["simCard"]["phoneNumber"].stringValue, forKey: "hikebeat_phoneNumber")
        let phoneNumber = userDefaults.string(forKey: "hikebeat_phoneNumber")!
        print("Number: ", phoneNumber)
        //userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
        userDefaults.set(true, forKey: "loggedIn")
        let t = String(Date().timeIntervalSince1970)
        let e = t.range(of: ".")
        let timestamp = t.substring(to: (e?.lowerBound)!)
        userDefaults.set(timestamp, forKey: "lastSync")
//        let numbers = user["permittedPhoneNumbers"].arrayValue
//        print("numbers: ", numbers)
//        if !numbers.isEmpty {
//            let number = numbers[0].stringValue
//            print("number: ", number)
//            userDefaults.set(number, forKey: "permittedPhoneNumbers")
//        } else {
//            userDefaults.set("", forKey: "permittedPhoneNumbers")
//        }
        
        userDefaults.set((user["notifications"].boolValue), forKey: "notifications")
        userDefaults.set((user["name"].stringValue), forKey: "name")
        userDefaults.set((user["gender"].stringValue), forKey: "gender")
        userDefaults.set((user["nationality"].stringValue), forKey: "nationality")
        userDefaults.set(true, forKey: "GPS-check")
        
        // handling profileImage
        let profilePhotoUrl = user["profilePhoto"].stringValue
        userDefaults.set(profilePhotoUrl, forKey: "profilePhotoUrl")
        
        if profilePhotoUrl != "" {
            print("There's a profile image!")
            
            Alamofire.request(profilePhotoUrl).responseImage {
                response in
                let priority = DispatchQueue.GlobalQueuePriority.default
                DispatchQueue.global(priority: priority).async {
                    
                    if let image = response.result.value {
                        
                        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                        let documentsDirectory: AnyObject = paths[0] as AnyObject
                        let fileName = "/media/profile_image.jpg"
                        let dataPath = documentsDirectory.appending(fileName)
                        let success = (try? UIImagePNGRepresentation(image)!.write(to: URL(fileURLWithPath: dataPath), options: [.atomic])) != nil
                        print("The image download and save was: ", success)
                    } else {
                        print("could not resolve to image")
                        print(response)
                    }
                }
            }
        }
        
        /* Get all the journeys*/
        print("Getting the journeys")
        if !journeyIdsArray.isEmpty {
            getJourneysForUser(userId: user["_id"].stringValue)
            .onSuccess(callback: { (tuple) in
                complete(.success(true))
            }).onFailure(callback: { (error) in
                complete(.failure(error))
            })
        } else {
            complete(.success(true))
        }

    }
}
// arr: [(property: String, value: String)]
func updateUser(_ changes: [Change]) -> Future<Bool, HikebeatError> {
    return Future { complete in
        print("Starting user update")
        guard hasNetworkConnection(show: false) else { print("No network");complete(.failure(.noNetworkConnection)); return }
        var parameters = [String:Any]()
        for change in changes {
            print(change)
            print("Values: ", change.values)
            print("changeType: ", change.changeType)
            let values = change.values.first!
            if values.value != nil {
                parameters[values.key!] = values.value!
            } else {
                parameters[values.key!] = values.valueBool
            }
        }
        let url = IPAddress + "users"
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            if response.response?.statusCode == 200 {
                print("update user response: ", response)
                complete(.success(true))
            } else {
                complete(.failure(.updateUserCall))
            }
        }
    }
}
