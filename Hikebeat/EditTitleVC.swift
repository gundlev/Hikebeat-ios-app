//
//  EditTitleVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditTitleVC: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.layer.cornerRadius = titleField.bounds.height/2
        saveButton.layer.cornerRadius = saveButton.bounds.height/2

        titleField.layer.masksToBounds = true
        saveButton.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.titleField.frame.height))
        titleField.leftView = paddingView
        titleField.leftViewMode = UITextFieldViewMode.Always

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
