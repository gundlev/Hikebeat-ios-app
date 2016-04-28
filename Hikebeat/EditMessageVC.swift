//
//  EditMessageVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/26/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditMessageVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageField: UITextView!
    var placeholderLabel : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMessageVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMessageVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        messageField.layer.cornerRadius = messageField.bounds.height/8
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        
        messageField.layer.masksToBounds = true
        saveButton.layer.masksToBounds = true
        
        messageField.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        
        
        messageField.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "  Message"
        placeholderLabel.font = UIFont.systemFontOfSize(messageField.font!.pointSize)
        placeholderLabel.sizeToFit()
        messageField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, messageField.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !messageField.text.isEmpty
        
        
        messageField.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -170
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
