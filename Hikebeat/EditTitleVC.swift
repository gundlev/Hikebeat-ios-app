//
//  EditTitleVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditTitleVC: UIViewController, UITextFieldDelegate {
    
    var text = ""
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleField.text = self.text
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        titleField.layer.cornerRadius = titleField.bounds.height/2
        saveButton.layer.cornerRadius = saveButton.bounds.height/2

        titleField.layer.masksToBounds = true
        saveButton.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.titleField.frame.height))
        titleField.leftView = paddingView
        titleField.leftViewMode = UITextFieldViewMode.Always
        
        titleField.rightView = paddingView
        titleField.rightViewMode = UITextFieldViewMode.Always

        // Do any additional setup after loading the view.
        
        self.titleField.delegate = self;
        titleField.becomeFirstResponder()
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
        let vc = segue.destinationViewController as! ComposeVC
        let titleString = self.titleField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if titleString != "" {
            vc.titleText = titleString
            vc.applyGreenBorder(vc.editTitleButton)
        } else {
            vc.titleText = nil
            vc.removeGreenBorder(vc.editTitleButton)
        }
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
