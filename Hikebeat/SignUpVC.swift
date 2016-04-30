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

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var logoTypeface: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    
    @IBAction func signUp(sender: AnyObject) {
        if passwordField.text == rePasswordField.text && emailField.text != "" && usernameField.text != "" {
            
            let parameters = ["username": usernameField.text!, "password": passwordField.text!, "email": emailField.text!]
            print(parameters)
            
            Alamofire.request(.POST, IPAddress + "users", parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    print("user has been created")
                    let rawUser = JSON(response.result.value!)
                    let user = rawUser["data"][0]
                    print("This is the user: ",user)
                    
                    print("setting user")
                    self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                    
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
                    
                    self.userDefaults.setObject(optionsDictionary, forKey: "options")
                    self.userDefaults.setBool((user["options"]["notifications"].boolValue), forKey: "notifications")
                    self.userDefaults.setObject((user["options"]["name"].stringValue), forKey: "name")
                    self.userDefaults.setObject((user["options"]["gender"].stringValue), forKey: "gender")
                    self.userDefaults.setObject((user["options"]["nationality"].stringValue), forKey: "nationality")
                    self.userDefaults.setObject(journeyIdsArray, forKey: "journeyIds")
                    self.userDefaults.setObject(followingArray, forKey: "following")
                    self.userDefaults.setObject(deviceTokensArray, forKey: "deviceTokens")
                    self.userDefaults.setObject(user["_id"].stringValue, forKey: "_id")
                    self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                    self.userDefaults.setObject(user["email"].stringValue, forKey: "email")
                    self.userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                    self.userDefaults.setBool(true, forKey: "loggedIn")
                    self.userDefaults.setObject(permittedPhoneNumbersArray, forKey: "permittedPhoneNumbers")
                    
                    self.performSegueWithIdentifier("showMainAfterRegister", sender: self)
                    
                } else if response.response?.statusCode == 400 {
                    // email or username has been uses
                    print("email or username has been used")
                    print(response.result.value)
                    
                }
            }
        } else {
            // The password an repeatPassword is not the same.
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
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
        
        let paddingView3 = UIView(frame: CGRectMake(0, 0, 20, self.passwordField.frame.height))
        emailField.leftView = paddingView3
        emailField.leftViewMode = UITextFieldViewMode.Always
        
        emailField.rightView = paddingView3
        emailField.rightViewMode = UITextFieldViewMode.Always

        let paddingView4 = UIView(frame: CGRectMake(0, 0, 20, self.passwordField.frame.height))
        rePasswordField.leftView = paddingView4
        rePasswordField.leftViewMode = UITextFieldViewMode.Always
        
        rePasswordField.rightView = paddingView4
        rePasswordField.rightViewMode = UITextFieldViewMode.Always

        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
