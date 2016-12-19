//
//  WalkthroughVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 12/11/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation

class WalkthroughVC: HikebeatWalkthroughViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        signUpButton.layer.cornerRadius = 7.0
        signUpButton.layer.masksToBounds = true

        facebookButton.layer.cornerRadius = 7.0
        facebookButton.layer.masksToBounds = true
        
    }
    
    
    @IBAction func unwindToWalkthrough(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func showSignUpAction(_ sender: AnyObject) {
        performSegue(withIdentifier: "showSignUp", sender: self)
    }
    
    @IBAction func showLoginAction(_ sender: AnyObject) {
        performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    @IBAction func facebookAction(_ sender: AnyObject) {
        //TODO attach fb login
    }
}
