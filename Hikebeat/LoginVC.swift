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
                print(1)
                var optionsDictionary = [String:String]()
                for (key, value) in user["options"].dictionaryValue {
                    optionsDictionary[key] = value.stringValue
                }
                print(2)
                //                let options = user["options"].dictionaryValue
                //                print("Options: ", options)
                print(3)
                var journeyIdsArray = [String]()
                for (value) in user["journeyIds"].arrayValue {
                    journeyIdsArray.append(value.stringValue)
                }
                print(4)
                var followingArray = [String]()
                for (value) in user["following"].arrayValue {
                    followingArray.append(value.stringValue)
                }
                
                var deviceTokensArray = [String]()
                for (value) in user["deviceTokens"].arrayValue {
                    deviceTokensArray.append(value.stringValue)
                }
                print(5)
                var permittedPhoneNumbersArray = [String]()
                for (value) in user["permittedPhoneNumbers"].arrayValue {
                    permittedPhoneNumbersArray.append(value.stringValue)
                }
                print(6)
                self.userDefaults.setObject(optionsDictionary, forKey: "options")
                self.userDefaults.setObject(journeyIdsArray, forKey: "journeyIds")
                self.userDefaults.setObject(followingArray, forKey: "following")
                self.userDefaults.setObject(deviceTokensArray, forKey: "deviceTokens")
                self.userDefaults.setObject(user["_id"].stringValue, forKey: "_id")
                self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                self.userDefaults.setObject(user["email"].stringValue, forKey: "email")
                //self.userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                self.userDefaults.setBool(true, forKey: "loggedIn")
                self.userDefaults.setObject(permittedPhoneNumbersArray, forKey: "permittedPhoneNumbers")
                self.userDefaults.setBool((user["options"]["notifications"].boolValue), forKey: "notifications")
                self.userDefaults.setObject((user["options"]["name"].stringValue), forKey: "name")
                self.userDefaults.setObject((user["options"]["gender"].stringValue), forKey: "gender")
                self.userDefaults.setObject((user["options"]["nationality"].stringValue), forKey: "nationality")
                self.userDefaults.setObject(true, forKey: "GPS-check")
                
                // handling profileImage
                let profilePhotoUrl = user["options"]["profilePhoto"].stringValue
                self.userDefaults.setObject(profilePhotoUrl, forKey: "profilePhotoUrl")
                
                if profilePhotoUrl != "" {
                    Alamofire.request(.GET, profilePhotoUrl).responseImage {
                        response in
                        if let image = response.result.value {
                            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                            let documentsDirectory: AnyObject = paths[0]
                            let fileName = "profileImage.png"
                            let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
                            let success = UIImagePNGRepresentation(image)!.writeToFile(dataPath, atomically: true)
                            print("The image download and save was: ", success)
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
                            print(8)
                            for (_, journey) in json {
                                let headline = journey["options"]["headline"].stringValue
                                print(headline)
                                //let active = user["activeJourneyId"].stringValue == journey["_id"].stringValue
                                
                                let dataJourney = Journey()
                                dataJourney.fill(journey["slug"].stringValue, userId: user["_id"].stringValue, journeyId: journey["_id"].stringValue, headline: journey["options"]["headline"].stringValue, journeyDescription: journey["options"]["headline"].stringValue, active: false, type: journey["options"]["type"].stringValue)
                                try! self.realm.write() {
                                    self.realm.add(dataJourney)
                                }
                                
                                for (_,followerId) in journey["followers"] {
                                    try! self.realm.write() {
                                        let follower = Follower()
                                        follower.userId = followerId.stringValue
                                    }
                                }
                                
                                for (_, message) in journey["messages"]  {
                                    print("Slug: ", message["slug"].stringValue, " for journey: ", headline)
                                    //print(message)
                                    let dataBeat = Beat()
                                    dataBeat.fill(message["headline"].stringValue, journeyId: journey["_id"].stringValue, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, altitude: message["alt"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: MediaType.none, mediaData: "", mediaDataId: "", messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true, journey: dataJourney)
                                    
                                    try! self.realm.write {
                                        self.realm.add(dataBeat)
                                        dataJourney.beats.append(dataBeat)
                                    }
                                    
                                }
                            }
                        }
                        
                    } else {
                        // something is wrong
                    }
                }
                print("This is what is saved: \n\n\n\n")
                let journeys = self.realm.objects(Journey)
                if journeys.isEmpty {
                    print("There is nothing")
                } else {
                    print(journeys.description)
                }
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
