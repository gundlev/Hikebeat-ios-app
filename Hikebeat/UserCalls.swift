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
import SwiftyDrop


func getStats() -> Future<[String: String], HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)stats"
        print("Performing stats check now")
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
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
        getSessionManager().request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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

func loginUsername(username: String, password: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let parameters = ["username": username, "password": password]
        let url = IPAddress + "auth"
        postCall(url: url, parameters: parameters, headers: LoginHeaders)
        .onSuccess(callback: { (response) in
            handleSignupAndLogin(response: response)
            .onSuccess(callback: { (success) in
                complete(.success(success))
            }).onFailure(callback: { (error) in
                print("Error: ", error)
                complete(.failure(.loginError))
            })
        }).onFailure(callback: { (error) in
            print("Error: ", error)
            Drop.down("Sorry! Something went wrong, please try again later.", state: .error)
            complete(.failure(.loginError))
        })
    }
}

func signupUsername(username: String, password: String, email: String) -> Future<Bool, HikebeatError> {
    return Future { complete in
        let parameters = ["username": username, "password": password, "email": email]
        let url = IPAddress + "signup"
        postCall(url: url, parameters: parameters, headers: LoginHeaders)
        .onSuccess(callback: { (response) in
            handleSignupAndLogin(response: response)
            .onSuccess(callback: { (success) in
                complete(.success(success))
            }).onFailure(callback: { (error) in
                print("Error: ", error)
                complete(.failure(.signupError))
            })
        }).onFailure(callback: { (error) in
            print("Error: ", error)
            Drop.down("Sorry! Something went wrong, please try again later.", state: .error)
            complete(.failure(.signupError))
        })
    }
}

func handleSignupAndLogin(response: DataResponse<Any>) -> Future<Bool, HikebeatError> {
    return Future { complete in
        if response.response?.statusCode == 200 {
            if response.result.value != nil {
                let json = JSON(response.result.value!)
                handleUserAfterLogin(json: json)
                .onSuccess(callback: { (success) in
                    hideActivity()
                    complete(.success(true))
                }).onFailure(callback: { (error) in
                    print("Error: ", error)
                    hideActivity()
                    Drop.down("Could not get the journeys for this user.", state: .error)
                    complete(.failure(error))
                })
            } else {
                complete(.failure(.handleUserSignupLogin))
            }
        } else  {
            // User not authorized
            print("Not Auth!!")
            hideActivity()
            let json = JSON(response.result.value!)
            showCallErrors(json: json)
            complete(.failure(.handleUserSignupLogin))
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
                getSessionManager().request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginHeaders).responseJSON {
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
        userDefaults.set(true, forKey: "sms")

        print("Responsio: ", json)
        print("setting user")
        userDefaults.set(user["username"].stringValue, forKey: "username")

        var journeyIdsArray = [String]()
        for (value) in user["journeyIds"].arrayValue {
            journeyIdsArray.append(value.stringValue)
        }
        userDefaults.set(journeyIdsArray, forKey: "journeyIds")
        
        var followingArray = [String]()
        for (value) in user["following"].arrayValue {
            followingArray.append(value.stringValue)
        }
        userDefaults.set(followingArray, forKey: "following")
        
        var deviceTokensArray = [String]()
        for (value) in user["deviceTokens"].arrayValue {
            deviceTokensArray.append(value.stringValue)
        }
        userDefaults.set(deviceTokensArray, forKey: "deviceTokens")

        userDefaults.set(user["permittedPhoneNumber"].stringValue, forKey: "permittedPhoneNumber")
        userDefaults.set(user["followerCount"].stringValue, forKey: "followerCount")
        userDefaults.set(user["followsCount"].stringValue, forKey: "followsCount")
        
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
            
            getSessionManager().request(profilePhotoUrl).responseImage {
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
        getSessionManager().request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
            if response.response?.statusCode == 200 {
                print("update user response: ", response)
                complete(.success(true))
            } else {
                complete(.failure(.updateUserCall))
            }
        }
    }
}

func getFollowersForJourney(queryString: String, journeyId: String) -> Future<(users:[User], nextPage: String?), HikebeatError> {
    return Future { complete in
        // NOT THE RIGHT URL!!! Should include specific journey. Call is get followers for journey
        let url = "\(IPAddress)journeys/\(journeyId)/followers\(queryString)"
        getCall(url: url, headers: getHeader())
        .onSuccess(callback: { (response) in
            guard response.response?.statusCode == 200 else {
                showCallErrors(json: JSON(response.result.value!))
                complete(.failure(.getUsers));
                print("Responsio: ", response)
                print("urlio: ", url)
                return
            }
            print("Responsio: ", response)
            print("urlio: ", url)
            guard response.result.value != nil else { complete(.failure(.getUsers)); return }
            
            let json = JSON(response.result.value!)
            let jsonUsers = json["data"]["followers"]
            var users = [User]()
            if jsonUsers != JSON.null {
                for (_, jsonUser) in jsonUsers {
                    let latestBeat = jsonUser["latestBeat"].doubleValue
                    var latestBeatDate: Date? = nil
                    if latestBeat != 0.0 {
                        latestBeatDate = Date(timeIntervalSince1970: (latestBeat/1000))
                    }
                    
                    users.append(User(
                        id: jsonUser["_id"].stringValue,
                        username: jsonUser["username"].stringValue,
                        numberOfJourneys: String(jsonUser["journeyIds"].arrayValue.count),
                        numberOfBeats: jsonUser["_id"].stringValue,
                        followerCount: jsonUser["followerCount"].stringValue,
                        followsCount: jsonUser["followsCount"].stringValue,
                        profilePhotoUrl: jsonUser["profilePhoto"].stringValue,
                        latestBeat: latestBeatDate
                    ))
                }
            }
            let nextPageString = json["data"]["nextPageQueryString"].stringValue
            var nextPage: String?
            if nextPageString != "" {
                nextPage = nextPageString
            }
            print("users: ", users)
            let tuple = (users: users, nextPage: nextPage)
            complete(.success(tuple))

            
        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })
    }
}

func getJourneysFollowing(queryString: String) -> Future<(journeys:[Journey], nextPage: String?), HikebeatError> {
    return Future { complete in
        let url = "\(IPAddress)users/following/journeys\(queryString)"
        print("URL: ", url)
        getCall(url: url, headers: getHeader())
        .onSuccess(callback: { (response) in
            guard response.response?.statusCode == 200 && response.result.value != nil else {
                showCallErrors(json: JSON(response.result.value!))
                print(response)
                complete(.failure(.getUsers));
                return
            }
            let json = JSON(response.result.value!)
            let jsonJourneys = json["data"]["journeys"]
            print("search journey: ", jsonJourneys)
            var journeys = [Journey]()
            if jsonJourneys != JSON.null {
                for (_, jsonJourney) in jsonJourneys {
                    let journey = Journey()
                    journey.headline = jsonJourney["headline"].stringValue
                    journey.journeyId = jsonJourney["_id"].stringValue
                    journey.numberOfBeats = jsonJourney["messageCount"].intValue
                    journey.ownerProfilePhotoUrl = jsonJourney["ownerProfilePhoto"].string
                    journey.userId = jsonJourney["userId"].stringValue
                    journey.slug = jsonJourney["slug"].stringValue
                    journey.username = jsonJourney["username"].stringValue
                    journey.isFollowed = true
                    journey.numberOfFollowers = jsonJourney["numberOfFollowers"].intValue
                    journeys.append(journey)
                }
            }
            
            let nextPageString = json["data"]["nextPageQueryString"].stringValue
            var nextPage: String?
            if nextPageString != "" {
                nextPage = nextPageString
            }
            let tuple = (journeys: journeys, nextPage: nextPage)
            complete(.success(tuple))

        }).onFailure(callback: { (error) in
            complete(.failure(error))
        })

    }
}
