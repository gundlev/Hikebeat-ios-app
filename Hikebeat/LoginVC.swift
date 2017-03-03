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
import SwiftyDrop
import FacebookCore

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
        
        usernameField.text = ""//"ben"
        passwordField.text = ""//"ABC123"
        
        
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
        
        guard usernameField.text != "" && passwordField.text != nil else {
            Drop.down("Email and password can not be empty.", state: .error, duration: 20, action: nil)
            return
        }
        /** Parameters to send to the API.*/
        showActivity()
        self.view.endEditing(true)
        
        loginUsername(username: usernameField.text!, password: passwordField.text!)
        .onSuccess(callback: { (success) in
            AppEventsLogger.log("Login email")
            self.performSegue(withIdentifier: "justLoggedIn", sender: self)
        }).onFailure(callback: { (error) in
            // Drops should already be handled.
        })
        /* Sending POST to API to check if the user exists. Will return a json with the user.*/
//        getSessionManager().request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginHeaders).responseJSON { response in
//            print("Raw: ", response)
//
//            if response.response?.statusCode == 200 {
////                self.performSegue(withIdentifier: "justLoggedIn", sender: self)
//                if response.result.value != nil {
//                    let json = JSON(response.result.value!)
//                    handleUserAfterLogin(json: json)
//                    .onSuccess(callback: { (success) in
//
//                        hideActivity()
//                    }).onFailure(callback: { (error) in
//                        print("Error: ", error)
//                        hideActivity()
//                    })
//                } else {
//                    _ = SCLAlertView().showError("No such user", subTitle: "The username and password you have provided does not match any users in our database.")
//                    hideActivity()
//                }
//                
//            } else  {
//                // User not authorized
//                print("Not Auth!!")
//                hideActivity()
//                let json = JSON(response.result.value)
//                showCallErrors(json: json)
//            }
//        }
    }
    
//    func createMediaFolder() -> Bool {
//        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        let documentsDirectory: AnyObject = paths[0] as AnyObject
//        let dataPath = documentsDirectory.appending("/media")
//        let tempPath = documentsDirectory.appending("/temp")
//
//        do {
//            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
//            try FileManager.default.createDirectory(atPath: tempPath, withIntermediateDirectories: false, attributes: nil)
//            print("Media folder created")
//            return true
//        } catch let error as NSError {
//            print("Failed creating the media folder")
//            print(error.localizedDescription);
//            return false
//        }
//    }
    
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
