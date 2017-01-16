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
import BRYXBanner

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
        guard titleField.text != nil else {return}
        guard titleField.text! != "" else {
            let banner = Banner(title: nil, subtitle: "Journey headline can not be empty.", image: nil, backgroundColor: .red, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 10.0)
            return
        }
        if titleField.text?.characters.count > 1 {
            let parameters: [String: Any] = ["options": ["headline": titleField.text!]]
            let url = IPAddress + "users/journeys"
            print(url)
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Headers).responseJSON { response in
                print(response.result.value)
                print(response.response?.statusCode)
                if response.response?.statusCode == 200 {
                    let rawJson = JSON(response.result.value!)
                    let json = rawJson["data"]
                    print(json)
                    print("Journey Created!")
                    let realm = try! Realm()
                    try! realm.write() {
                        let journey = Journey()
                        journey.fill(json["slug"].stringValue, userId: json["userId"].stringValue, journeyId: json["_id"].stringValue, headline: json["options"]["headline"].stringValue, journeyDescription: nil, active: self.active.isOn, type: nil, seqNumber: String(json["seqNumber"].intValue))
                        realm.add(journey)
                    }
                    self.performSegue(withIdentifier: "backWhenCreated", sender: self)
                } else {
                    print(response)
                }
            }
        }

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
        return false
    }
    
    func keyboardWillShow(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backWhenCreated" {
            let vc = segue.destination as! JourneysVC
            if self.active.isOn {
                vc.removeOldActiveJourney()
            }
        }
    }
    
}
