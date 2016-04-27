//
//  SignUpVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/27/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var logoTypeface: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    
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

        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
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
