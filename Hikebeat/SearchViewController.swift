//
//  SearchViewController.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 9/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    
    @IBOutlet weak var SearchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.view.layoutIfNeeded()
        SearchField.layer.cornerRadius = SearchField.bounds.height/2
        SearchField.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.SearchField.frame.height))
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 47, height: self.SearchField.frame.height))
        SearchField.leftView = paddingView2
        SearchField.leftViewMode = UITextFieldViewMode.always
        
        SearchField.rightView = paddingView
        SearchField.rightViewMode = UITextFieldViewMode.always
    }

    override func viewDidAppear(_ animated: Bool) {
      
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
