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

class NewJourneyVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var active: UISwitch!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        titleField.layer.cornerRadius = titleField.bounds.height/2
        createButton.layer.cornerRadius = createButton.bounds.height/2
        
        titleField.layer.masksToBounds = true
        createButton.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.titleField.frame.height))
        titleField.leftView = paddingView
        titleField.leftViewMode = UITextFieldViewMode.Always
        
        titleField.rightView = paddingView
        titleField.rightViewMode = UITextFieldViewMode.Always
        
        // Do any additional setup after loading the view.
        
        self.titleField.delegate = self;
        titleField.becomeFirstResponder()
    }
    
    @IBAction func createNewJourney(sender: AnyObject) {
        if titleField.text?.characters.count > 1 {
            let parameters: [String: AnyObject] = ["options": ["headline": titleField.text!]]
            let url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/journeys"
            print(url)
            
            Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                print(response.result.value)
                print(response.response?.statusCode)
                if response.response?.statusCode == 200 {
                    let rawJson = JSON(response.result.value!)
                    let json = rawJson["data"][0]
                    print(json)
                    print("Journey Created!")
                    let realm = try! Realm()
                    try! realm.write() {
                        let journey = Journey()
                        journey.fill(json["slug"].stringValue, userId: json["userId"].stringValue, journeyId: json["_id"].stringValue, headline: json["options"]["headline"].stringValue, journeyDescription: nil, active: self.active.on, type: nil)
                        realm.add(journey)
                    }
                    self.performSegueWithIdentifier("backWhenCreated", sender: self)
                } else {
                    print(response)
                }
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backWhenCreated" {
            let vc = segue.destinationViewController as! JourneysVC
            if self.active.on {
                vc.removeOldActiveJourney()
            }
        }
    }
    
}
