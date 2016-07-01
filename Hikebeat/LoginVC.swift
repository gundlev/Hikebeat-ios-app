//
//  LoginVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/27/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import RealmSwift

class LoginVC: UIViewController, UITextFieldDelegate {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let realm = try! Realm()

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var logoOutline: UIImageView!
    @IBOutlet weak var logoTypeface: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var newSignupButton: UIButton!
    
    @IBOutlet weak var bgPosition: NSLayoutConstraint!
    
    @IBOutlet weak var loginContainer: UIView!
    
    @IBAction func signup(sender: AnyObject) {
        performSegueWithIdentifier("showRegister", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (UIDevice.isIphone5){
            loginContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
            loginContainer.transform = CGAffineTransformTranslate( loginContainer.transform, 0.0, -50.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            loginContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            loginContainer.transform = CGAffineTransformTranslate( loginContainer.transform, 0.0, 40.0  )
        }else if(UIDevice.isIphone4){
            loginContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
            loginContainer.transform = CGAffineTransformTranslate( loginContainer.transform, 0.0, -120.0  )
        }

        
        usernameField.layer.cornerRadius = usernameField.bounds.height/2
        passwordField.layer.cornerRadius = passwordField.bounds.height/2
        loginButton.layer.cornerRadius = loginButton.bounds.height/2
        
        usernameField.layer.masksToBounds = true
        passwordField.layer.masksToBounds = true
        loginButton.layer.masksToBounds = true

        self.usernameField.delegate = self;
        self.passwordField.delegate = self;
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 20, self.usernameField.frame.height))
        usernameField.leftView = paddingView
        usernameField.leftViewMode = UITextFieldViewMode.Always
        
        usernameField.rightView = paddingView
        usernameField.rightViewMode = UITextFieldViewMode.Always

        
        let paddingView2 = UIView(frame: CGRectMake(0, 0, 20, self.passwordField.frame.height))
        passwordField.leftView = paddingView2
        passwordField.leftViewMode = UITextFieldViewMode.Always
        
        passwordField.rightView = paddingView2
        passwordField.rightViewMode = UITextFieldViewMode.Always
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }

    
    @IBAction func showRegister(sender: AnyObject) {
        
        performSegueWithIdentifier("showRegister", sender: self)
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        /** Parameters to send to the API.*/
        let parameters = ["username": usernameField.text!, "password": passwordField.text!]
        
        
        /* Sending POST to API to check if the user exists. Will return a json with the user.*/
        Alamofire.request(.POST, IPAddress + "auth", parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
            
            print("Response: ",response)
            print(response.response?.statusCode)
            
            if response.response?.statusCode == 200 {
                print("value: ", response.result.value)
                let firstJson = JSON(response.result.value!)
                let user = firstJson["data"][0]
                
                print("setting user")
                self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                var optionsDictionary = [String:String]()
                for (key, value) in user["options"].dictionaryValue {
                    optionsDictionary[key] = value.stringValue
                }
                //                let options = user["options"].dictionaryValue
                //                print("Options: ", options)
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
                var permittedPhoneNumbersArray = [String]()
                for (value) in user["permittedPhoneNumbers"].arrayValue {
                    permittedPhoneNumbersArray.append(value.stringValue)
                }
                self.userDefaults.setObject(optionsDictionary, forKey: "options")
                self.userDefaults.setObject(journeyIdsArray, forKey: "journeyIds")
                self.userDefaults.setObject(followingArray, forKey: "following")
                self.userDefaults.setObject(deviceTokensArray, forKey: "deviceTokens")
                self.userDefaults.setObject(user["_id"].stringValue, forKey: "_id")
                self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                self.userDefaults.setObject(user["email"].stringValue, forKey: "email")
                //self.userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                self.userDefaults.setBool(true, forKey: "loggedIn")
                let t = String(NSDate().timeIntervalSince1970)
                let e = t.rangeOfString(".")
                let timestamp = t.substringToIndex((e?.startIndex)!)
                self.userDefaults.setObject(timestamp, forKey: "lastSync")
                let numbers = user["permittedPhoneNumbers"].arrayValue
                var number = ""
                if !numbers.isEmpty {
                    number = numbers[0].stringValue
                }
                self.userDefaults.setObject(number, forKey: "permittedPhoneNumbers")
                self.userDefaults.setBool((user["options"]["notifications"].boolValue), forKey: "notifications")
                self.userDefaults.setObject((user["options"]["name"].stringValue), forKey: "name")
                self.userDefaults.setObject((user["options"]["gender"].stringValue), forKey: "gender")
                self.userDefaults.setObject((user["options"]["nationality"].stringValue), forKey: "nationality")
                self.userDefaults.setObject(true, forKey: "GPS-check")
                
                // handling profileImage
                let profilePhotoUrl = user["options"]["profilePhoto"].stringValue
                self.userDefaults.setObject(profilePhotoUrl, forKey: "profilePhotoUrl")
                
                if profilePhotoUrl != "" {
                    print("There's a profile image!")
                    Request.addAcceptableImageContentTypes(["image/jpg"])
                    Alamofire.request(.GET, profilePhotoUrl).responseImage {
                        response in
                        print("Statuscoode: ", response.response?.statusCode)
                        if let image = response.result.value {
                            
                            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                            let documentsDirectory: AnyObject = paths[0]
                            let fileName = "profile_image.jpg"
                            let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
                            let success = UIImagePNGRepresentation(image)!.writeToFile(dataPath, atomically: true)
                            print("The image download and save was: ", success)
                        } else {
                            print("could not resolve to image")
                            print(response)
                        }
                    }
                }
                
                
                /* Get all the journeys*/
                print("Getting the journeys")
                let urlJourney = IPAddress + "users/" + user["_id"].stringValue + "/journeys"
                print(urlJourney)
                Alamofire.request(.GET, urlJourney, encoding: .JSON, headers: Headers).responseJSON { response in
                    print(response.response?.statusCode)
                    print(response)
                    if response.response?.statusCode == 200 {
                        if response.result.value != nil {
                            //print(response.result.value!)
                            let rawJson = JSON(response.result.value!)
                            let json = rawJson["data"]
                            //print(json)
                            for (_, journey) in json {
                                let headline = journey["options"]["headline"].stringValue
                                print(headline)
                                //let active = user["activeJourneyId"].stringValue == journey["_id"].stringValue
                                
                                let dataJourney = Journey()
                                dataJourney.fill(journey["slug"].stringValue, userId: user["_id"].stringValue, journeyId: journey["_id"].stringValue, headline: journey["options"]["headline"].stringValue, journeyDescription: journey["options"]["headline"].stringValue, active: false, type: journey["options"]["type"].stringValue)
                                print(1)
                                let localRealm = try! Realm()
                                try! localRealm.write() {
                                    localRealm.add(dataJourney)
                                }
                                print(2)
                                
                                for (_,followerId) in journey["followers"] {
                                    print(3)
                                    try! localRealm.write() {
                                        let follower = Follower()
                                        follower.userId = followerId.stringValue
                                    }
                                    print(4)
                                }
                                
                                for (_, message) in journey["messages"]  {
                                    print("Slug: ", message["slug"].stringValue, " for journey: ", headline)
                                    //print(message)
                                    let mediaType = message["media"]["type"].stringValue
                                    let mediaData = message["media"]["path"].stringValue
                                    let mediaDataId = message["media"]["_id"].stringValue

                                    
                                    if mediaData != "" && mediaType != "" {
                                        switch mediaType {
                                        case MediaType.image:
                                            Request.addAcceptableImageContentTypes(["image/jpg"])
                                            Alamofire.request(.GET, mediaData).responseImage {
                                                response in
                                                print("Statuscoode: ", response.response?.statusCode)
                                                if let image = response.result.value {
                                                    
                                                    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                                    let documentsDirectory: AnyObject = paths[0]
                                                    let fileName = "hikebeat_"+journey["_id"].stringValue+"_"+message["timeCapture"].stringValue+".jpg"
                                                    let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
                                                    let success = UIImagePNGRepresentation(image)!.writeToFile(dataPath, atomically: true)
                                                    print("The image downloaded: ", success, " moving on to save")
                                                    self.saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: MediaType.image, mediaData: fileName, mediaDataId: mediaDataId)
                                                } else {
                                                    print("could not resolve to image")
                                                    print(response)
                                                }
                                            }
                                        case MediaType.video, MediaType.audio:
                                            var fileType = ".mp4"
                                            if mediaType == MediaType.audio {
                                                fileType = ".m4a"
                                            }
                                            
                                            Alamofire.download(.GET, mediaData, destination: { (temporaryURL, response) in
                                                let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                                                let documentsDirectory: AnyObject = paths[0]
                                                let fileName = "hikebeat_"+journey["_id"].stringValue+"_"+message["timeCapture"].stringValue+fileType
                                                let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)

                                                return NSURL(fileURLWithPath: dataPath)
                                            }).response { _, _, _, error in
                                                if let error = error {
                                                    print("Failed with error: \(error)")
                                                } else {
                                                    let fileName = "hikebeat_"+journey["_id"].stringValue+"_"+message["timeCapture"].stringValue+fileType
                                                    self.saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: mediaType, mediaData: fileName, mediaDataId: mediaDataId)
                                                    print("Downloaded file successfully")
                                                }
                                            }
                                            
                                        default:
                                            print("unknown type of media")
                                        }
                                    } else {
                                        self.saveBeatAndAddToJourney(message, journey: dataJourney, mediaType: nil, mediaData: nil, mediaDataId: nil)
                                    }
                                    
                                //hjkfhdsjfhjdksf
                                    
                                }
                            }
                        }
                        
                    } else {
                        // something is wrong
                    }
                }
                print("This is what is saved: \n\n\n\n")
                print(5)
                let localRealm = try! Realm()
                let journeys = localRealm.objects(Journey)
                if journeys.isEmpty {
                    print("There is nothing")
                } else {
                    print(journeys.description)
                }
                print(6)
                /* Enter the app when logged in*/
                self.performSegueWithIdentifier("justLoggedIn", sender: self)
            } else if response.response?.statusCode == 401 {
                // User not authorized
                print("Not Auth!!")
            } else if response.response?.statusCode == 400 {
                // Wrong username or password
                print("Wrong username or password")
            }
            
            
        }
    }
    
    func saveMediaToDocs(mediaData: NSData, journeyId: String, timestamp: String, fileType: String) -> String? {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        let documentsDirectory: AnyObject = paths[0]
        let fileName = "hikebeat_"+journeyId+"_"+timestamp+fileType
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        let success = mediaData.writeToFile(dataPath, atomically: false)
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
    }
    
    func saveBeatAndAddToJourney(message: JSON, journey: Journey, mediaType: String?, mediaData: String?, mediaDataId: String?) {
        let dataBeat = Beat()
        dataBeat.fill(message["headline"].stringValue, journeyId: journey.journeyId, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, altitude: message["alt"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: mediaType, mediaData: mediaData, mediaDataId: mediaDataId, messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true, journey: journey)
        let localRealm = try! Realm()
        try! localRealm.write {
            localRealm.add(dataBeat)
            journey.beats.append(dataBeat)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        if textField == self.usernameField{
            self.passwordField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder();
        }

        return true;
    }
    
    override func viewDidAppear(animated: Bool) {
//        backgroundPicture.center.x = 430
//        UIView.animateWithDuration(60, delay:0, options: [.Repeat, .CurveLinear, .Autoreverse], animations: {
//            self.backgroundPicture.center.x = 0
//            },completion: nil)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
