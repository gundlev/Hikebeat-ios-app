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

    let userDefaults = UserDefaults.standard
    //let realm = try! Realm()

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
    
    @IBAction func signup(_ sender: AnyObject) {
        performSegue(withIdentifier: "showRegister", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (UIDevice.isIphone5){
            loginContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85);
            loginContainer.transform = loginContainer.transform.translatedBy(x: 0.0, y: -50.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            loginContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1);
            loginContainer.transform = loginContainer.transform.translatedBy(x: 0.0, y: 40.0  )
        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
            loginContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75);
            loginContainer.transform = loginContainer.transform.translatedBy(x: 0.0, y: -120.0  )
        }

        
        usernameField.layer.cornerRadius = usernameField.bounds.height/2
        passwordField.layer.cornerRadius = passwordField.bounds.height/2
        loginButton.layer.cornerRadius = loginButton.bounds.height/2
        
        usernameField.layer.masksToBounds = true
        passwordField.layer.masksToBounds = true
        loginButton.layer.masksToBounds = true

        self.usernameField.delegate = self;
        self.passwordField.delegate = self;
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.usernameField.frame.height))
        usernameField.leftView = paddingView
        usernameField.leftViewMode = UITextFieldViewMode.always
        
        usernameField.rightView = paddingView
        usernameField.rightViewMode = UITextFieldViewMode.always

        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.passwordField.frame.height))
        passwordField.leftView = paddingView2
        passwordField.leftViewMode = UITextFieldViewMode.always
        
        passwordField.rightView = paddingView2
        passwordField.rightViewMode = UITextFieldViewMode.always
        
        usernameField.text = "john1"
        passwordField.text = "gkBB1991"
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    @IBAction func showRegister(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "showRegister", sender: self)
        
    }
    
    @IBAction func login(_ sender: AnyObject) {
        print("logging in now")
        /** Parameters to send to the API.*/
        let parameters = ["username": usernameField.text!, "password": passwordField.text!]
        
//        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task

            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                print("This is run on the main queue, after the previous code in outer block")
//            })
        
        
        /* Sending POST to API to check if the user exists. Will return a json with the user.*/
        Alamofire.request((IPAddress + "auth"), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginHeaders).responseJSON { response in
            print("Raw: ", response)

            if response.response?.statusCode == 200 {
//                self.performSegue(withIdentifier: "justLoggedIn", sender: self)
//                let json = JSON(response.result.value!)
                
                
                
                
                
                
                let createdMediaFolder = self.createMediaFolder()
//                print("value: ", response.result.value)
                let firstJson = JSON(response.result.value!)
                let user = firstJson["data"]["user"]
                let token = firstJson["data"]["token"].stringValue
                self.userDefaults.set(token, forKey: "token")
                print("Responsio: ", firstJson)
                print("setting user")
                self.userDefaults.set(user["username"].stringValue, forKey: "username")
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
                
                self.userDefaults.set(user["followerCount"].stringValue, forKey: "followerCount")
                self.userDefaults.set(user["followsCount"].stringValue, forKey: "followsCount")
                
                self.userDefaults.set(optionsDictionary, forKey: "options")
                self.userDefaults.set(journeyIdsArray, forKey: "journeyIds")
                self.userDefaults.set(followingArray, forKey: "following")
                self.userDefaults.set(deviceTokensArray, forKey: "deviceTokens")
                self.userDefaults.set(user["_id"].stringValue, forKey: "_id")
                self.userDefaults.set(user["username"].stringValue, forKey: "username")
                self.userDefaults.set(user["email"].stringValue, forKey: "email")
                print("Numberoo: ", user["simCard"]["phoneNumber"].stringValue)
                self.userDefaults.set(user["simCard"]["phoneNumber"].stringValue, forKey: "hikebeat_phoneNumber")
                let phoneNumber = self.userDefaults.string(forKey: "hikebeat_phoneNumber")!
                print("Number: ", phoneNumber)
                //self.userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                self.userDefaults.set(true, forKey: "loggedIn")
                let t = String(Date().timeIntervalSince1970)
                let e = t.range(of: ".")
                let timestamp = t.substring(to: (e?.lowerBound)!)
                self.userDefaults.set(timestamp, forKey: "lastSync")
                let numbers = user["options"]["permittedPhoneNumbers"].arrayValue
                print("numbers: ", numbers)
                if !numbers.isEmpty {
                    let number = numbers[0].stringValue
                    print("number: ", number)
                    self.userDefaults.set(number, forKey: "permittedPhoneNumbers")
                } else {
                    self.userDefaults.set("", forKey: "permittedPhoneNumbers")
                }
                
                self.userDefaults.set((user["options"]["notifications"].boolValue), forKey: "notifications")
                self.userDefaults.set((user["options"]["name"].stringValue), forKey: "name")
                self.userDefaults.set((user["options"]["gender"].stringValue), forKey: "gender")
                self.userDefaults.set((user["options"]["nationality"].stringValue), forKey: "nationality")
                self.userDefaults.set(true, forKey: "GPS-check")
                
                // handling profileImage
                let profilePhotoUrl = user["options"]["profilePhoto"].stringValue
                self.userDefaults.set(profilePhotoUrl, forKey: "profilePhotoUrl")
                
                if profilePhotoUrl != "" {
                    print("There's a profile image!")
                    
//                    Request.addAcceptableImageContentTypes(["image/jpg"])
                    Alamofire.request(profilePhotoUrl).responseImage {
                        response in
                            
                        print("Statuscoode: ", response.response?.statusCode)
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
                
                /* Get all the journeys*/
                print("Getting the journeys")
                
                let journeysFuture = getJourneysForUser(userId: user["_id"].stringValue)
                journeysFuture.onSuccess(callback: { (tuple) in
                    print("FINISHED: ", tuple)
                })
                
                
                /* Enter the app when logged in*/

                self.performSegue(withIdentifier: "justLoggedIn", sender: self)
                
            } else if response.response?.statusCode == 401 {
                // User not authorized
                print("Not Auth!!")
            } else if response.response?.statusCode == 400 {
                // Wrong username or password
                
                print(response.result.value)
                let errorJson = JSON(response.result.value!)
                switch errorJson["msg"].stringValue {
                case "User not authenticated":
                    print("Wrong username or password")
                    SCLAlertView().showError("Wrong credentials!", subTitle: "Your username or password does not match any user in our database.")
                case "User email has not been verified":
                    print("Email has not been verified")
                    SCLAlertView().showWarning("Missing email verification", subTitle: "Your have not verified your email address. Please check your email and follow the verification instructions.")
                default:
                    print("Unknown error")
                }
            }
            //first call
//            })
        }
        //end of bg thread
//        }
        
        
    }
    
    func createMediaFolder() -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appending("/media")
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            print("Media folder created")
            return true
        } catch let error as NSError {
            print("Failed creating the media folder")
            print(error.localizedDescription);
            return false
        }
    }
    
    func saveMediaToDocs(_ mediaData: Data, journeyId: String, timestamp: String, fileType: String) -> String? {
        
//        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//        dispatch_async(backgroundQueue, {
//            print("This is run on the background queue")
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let fileName = "/media/hikebeat_"+journeyId+"_"+timestamp+fileType
        let dataPath = documentsDirectory.appending(fileName)
        let success = (try? mediaData.write(to: URL(fileURLWithPath: dataPath), options: [])) != nil
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
        
    }
    
//    func saveBeatAndAddToJourney(_ message: JSON, journey: Journey, mediaType: String?, mediaData: String?, mediaDataId: String?, mediaUrl: String?) {
////        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
////        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
////        dispatch_async(backgroundQueue, {
////            print("This is run on the background queue")
//        
//        let localRealm = try! Realm()
//        let dataBeat = Beat()
//        dataBeat.fill(message["emotion"].stringValue, journeyId: journey.journeyId, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, altitude: message["alt"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: mediaType, mediaData: mediaData, mediaDataId: mediaDataId, mediaUrl: mediaUrl, messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true)
//        try! localRealm.write {
//            localRealm.add(dataBeat)
//            journey.beats.append(dataBeat)
//        }
////        })
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == self.usernameField{
            self.passwordField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder();
        }

        return true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        backgroundPicture.center.x = 430
//        UIView.animateWithDuration(60, delay:0, options: [.Repeat, .CurveLinear, .Autoreverse], animations: {
//            self.backgroundPicture.center.x = 0
//            },completion: nil)
    }
    
    func keyboardWillShow(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Foundation.Notification) {
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
