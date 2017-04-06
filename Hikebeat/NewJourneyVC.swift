//
//  EditTitleVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import SwiftyDrop

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NewJourneyVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var active: UISwitch!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    let userDefaults = UserDefaults.standard
    var journeysVC: JourneysVC!
    var journeyCreated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        titleField.layer.cornerRadius = titleField.bounds.height/2
        createButton.layer.cornerRadius = createButton.bounds.height/2
        
        titleField.layer.masksToBounds = true
        createButton.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.titleField.frame.height))
        titleField.leftView = paddingView
        titleField.leftViewMode = UITextFieldViewMode.always
        
        titleField.rightView = paddingView
        titleField.rightViewMode = UITextFieldViewMode.always
        
        // Do any additional setup after loading the view.
        
        self.titleField.delegate = self;
        titleField.becomeFirstResponder()
    }
    
    @IBAction func createNewJourney(_ sender: AnyObject) {
        createJourney()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.titleField.isFirstResponder {
            view.endEditing(true)
        } else {
            performSegue(withIdentifier: "backToJourneyModelTap", sender: self)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        createJourney()
        return false
    }
    
    func createJourney() {
        guard titleField.text != nil else {return}
        guard titleField.text! != "" else {
            Drop.down("Journey headline can not be empty.", state: .error)
            return
        }
        if titleField.text?.characters.count > 0 {
            showActivity()
            let journeyTitle = (titleField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            createNewJourneyCall(headline: journeyTitle)
            .onSuccess(callback: { (success) in
                self.journeyCreated = true
                hideActivity()
                self.performSegue(withIdentifier: "backWhenCreated", sender: self)
            }).onFailure(callback: { (error) in
                print("Failed in creating new journey")
                hideActivity()
            })
        }
    }
    
    func keyboardWillShow(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if journeyCreated {
            let tabVC = journeysVC.tabBarController as! HikebeatTabBarVC
            tabVC.centerButtonPressed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backWhenCreated" {
            let vc = segue.destination as! JourneysVC
//            let tabVC = vc.tabBarController as! HikebeatTabBarVC
//            tabVC.centerButtonPressed()
        }
    }
    
}
