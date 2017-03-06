//
//  ForgottenPasswordViewController.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 3/5/17.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import UIKit

class ForgottenPasswordViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var forgottenContainer: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (UIDevice.isIphone5){
            forgottenContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85);
            forgottenContainer.transform = forgottenContainer.transform.translatedBy(x: 0.0, y: -50.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            forgottenContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1);
            forgottenContainer.transform = forgottenContainer.transform.translatedBy(x: 0.0, y: 40.0  )
        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
            forgottenContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75);
            forgottenContainer.transform = forgottenContainer.transform.translatedBy(x: 0.0, y: -120.0  )
        }

        
        usernameField.layer.cornerRadius = usernameField.bounds.height/2
        sendButton.layer.cornerRadius = sendButton.bounds.height/2
        
        usernameField.layer.masksToBounds = true
        sendButton.layer.masksToBounds = true
        
        self.usernameField.delegate = self;
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.usernameField.frame.height))
        usernameField.leftView = paddingView
        usernameField.leftViewMode = UITextFieldViewMode.always
        
        usernameField.rightView = paddingView
        usernameField.rightViewMode = UITextFieldViewMode.always
        
        usernameField.text = ""//"ben"
        
        NotificationCenter.default.addObserver(self, selector: #selector(ForgottenPasswordViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ForgottenPasswordViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
