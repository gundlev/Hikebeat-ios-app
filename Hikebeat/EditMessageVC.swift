//
//  EditMessageVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/26/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditMessageVC: UIViewController, UITextViewDelegate {

    var text = ""
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var messageField: UITextView!
    var placeholderLabel : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageField.text = self.text
        NotificationCenter.default.addObserver(self, selector: #selector(EditMessageVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(EditMessageVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        messageField.layer.cornerRadius = messageField.bounds.height/8
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        
        messageField.layer.masksToBounds = true
        saveButton.layer.masksToBounds = true
        
        messageField.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        
        
        messageField.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "  Message"
        placeholderLabel.font = UIFont.systemFont(ofSize: messageField.font!.pointSize)
        placeholderLabel.sizeToFit()
        messageField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: messageField.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !messageField.text.isEmpty
        
        
        messageField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.messageField.isFirstResponder {
            view.endEditing(true)
            
        } else {
            performSegue(withIdentifier: "backToCompose", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -170
    }
    
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ComposeVC
        let messageString = self.messageField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if messageString != "" {
            vc.messageText = messageString
            vc.applyGreenBorder(vc.editMessageButton)
        } else {
            vc.messageText = nil
            vc.removeGreenBorder(vc.editMessageButton)
        }

    }
    

}
