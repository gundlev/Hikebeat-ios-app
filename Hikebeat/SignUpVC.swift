//
//  SignUpVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/27/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftyDrop

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var logoTypeface: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    
    
    @IBOutlet weak var signupContainer: UIView!
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        guard passwordField.text != "" else {missingValues(); return}
        guard rePasswordField.text != "" else {missingValues(); return}
        guard emailField.text != "" else {missingValues(); return}
        guard usernameField.text != "" else {missingValues(); return}
        guard passwordField.text == rePasswordField.text else {noneMatchingPasswords(); return}
        showActivity()
        let parameters = ["username": usernameField.text!, "password": passwordField.text!, "email": emailField.text!]
        print(parameters)
        
        Alamofire.request((IPAddress + "signup"), method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginHeaders).responseJSON { response in
            print(response)
            if response.response?.statusCode == 200 {
                print("user has been created")
                let rawUser = JSON(response.result.value!)
                let user = rawUser["data"]
                print("This is the user: ",user)
                
                print("setting user")
                self.userDefaults.set(user["username"].stringValue, forKey: "username")
                
                var optionsDictionary = [String:String]()
                for (key, value) in user["options"].dictionaryValue {
                    optionsDictionary[key] = value.stringValue
                }
                
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
                self.userDefaults.set((user["options"]["notifications"].boolValue), forKey: "notifications")
                self.userDefaults.set((user["options"]["name"].stringValue), forKey: "name")
                self.userDefaults.set((user["options"]["gender"].stringValue), forKey: "gender")
                self.userDefaults.set((user["options"]["nationality"].stringValue), forKey: "nationality")
                self.userDefaults.set(journeyIdsArray, forKey: "journeyIds")
                self.userDefaults.set(followingArray, forKey: "following")
                self.userDefaults.set(deviceTokensArray, forKey: "deviceTokens")
                self.userDefaults.set(user["_id"].stringValue, forKey: "_id")
                self.userDefaults.set(user["username"].stringValue, forKey: "username")
                self.userDefaults.set(user["email"].stringValue, forKey: "email")
                self.userDefaults.set(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                self.userDefaults.set(true, forKey: "loggedIn")
                self.userDefaults.set(permittedPhoneNumbersArray, forKey: "permittedPhoneNumbers")
                
                createMediaFolder()
                hideActivity()
                self.performSegue(withIdentifier: "showMainAfterRegister", sender: self)
                
            } else if response.response?.statusCode == 400 {
                hideActivity()
                // email or username has been uses
                print("email or username has been used")
//                    print(response.result.value)
                let json = JSON(response.result.value)
                if let errors = json["errors"].array {
                    var bannerText = ""
                    for var i in 0...errors.count-1 {
                        print(errors[i])
                        if i != 0 {
                            bannerText += "\n\n"
                        }
                        bannerText += "\(errors[i]["friendlyMessage"].stringValue)"
                    }
                    Drop.down(bannerText, state: .error)
//                        let banner = Banner(title: nil, subtitle: bannerText, image: nil, backgroundColor: .red, didTapBlock: nil)
//                        banner.dismissesOnTap = true
//                        banner.show(duration: 10.0)
                }
//                    SCLAlertView().showWarning("Sorry", subTitle: "\n" + json["meta"]["message"].stringValue)
            }
        }

    }
    
    func noneMatchingPasswords() {
        Drop.down("The passwords does not match. Please make sure that the password and re-type password feilds are identical.", state: .error, duration: 20, action: nil)
//        let banner = Banner(title: nil, subtitle: "The passwords does not match. Please make sure that the password and re-type password feilds are identical.", image: nil, backgroundColor: .red, didTapBlock: nil)
//        banner.dismissesOnTap = true
//        banner.show(duration: 10.0)
    }
    
    func missingValues() {
        Drop.down("Please make sure that all fields are filled.", state: .error, duration: 15, action: nil)
//        let banner = Banner(title: nil, subtitle: "Please make sure that all fields are filled", image: nil, backgroundColor: .red, didTapBlock: nil)
//        banner.dismissesOnTap = true
//        banner.show(duration: 10.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (UIDevice.isIphone5){
            signupContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
            signupContainer.transform = signupContainer.transform.translatedBy(x: 0.0, y: -50.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            signupContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            signupContainer.transform = signupContainer.transform.translatedBy(x: 0.0, y: 40.0  )
        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
            signupContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75)
            signupContainer.transform = signupContainer.transform.translatedBy(x: 0.0, y: -80.0  )
        }
        
        
        usernameField.layer.cornerRadius = usernameField.bounds.height/2
        passwordField.layer.cornerRadius = passwordField.bounds.height/2
        emailField.layer.cornerRadius = emailField.bounds.height/2
        rePasswordField.layer.cornerRadius = rePasswordField.bounds.height/2
        signUpButton.layer.cornerRadius = signUpButton.bounds.height/2
        
        usernameField.layer.masksToBounds = true
        passwordField.layer.masksToBounds = true
        emailField.layer.masksToBounds = true
        rePasswordField.layer.masksToBounds = true
        signUpButton.layer.masksToBounds = true
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.emailField.delegate = self
        self.rePasswordField.delegate = self
        
        
        
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
        
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.passwordField.frame.height))
        emailField.leftView = paddingView3
        emailField.leftViewMode = UITextFieldViewMode.always
        
        emailField.rightView = paddingView3
        emailField.rightViewMode = UITextFieldViewMode.always

        let paddingView4 = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.passwordField.frame.height))
        rePasswordField.leftView = paddingView4
        rePasswordField.leftViewMode = UITextFieldViewMode.always
        
        rePasswordField.rightView = paddingView4
        rePasswordField.rightViewMode = UITextFieldViewMode.always

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.usernameField{
            self.emailField.becomeFirstResponder()
            
        }else if textField==self.emailField{
            print("Why not?")
            self.passwordField.becomeFirstResponder()
            
        }else if textField==self.passwordField{
            self.rePasswordField.becomeFirstResponder()
            
        }else{
            print("Done pressed")
            textField.resignFirstResponder();
        }
        
        return true;
    }
    
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Notification) {
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
