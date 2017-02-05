//
//  WalkthroughVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 12/11/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import FacebookLogin
import FacebookCore

class WalkthroughVC: HikebeatWalkthroughViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("walkthrough running.")
        signUpButton.layer.cornerRadius = 7.0
        signUpButton.layer.masksToBounds = true

        facebookButton.layer.cornerRadius = 7.0
        facebookButton.layer.masksToBounds = true
        
        let stb = UIStoryboard(name: "Main", bundle: nil)
        
        // Add all steps to the container
        let step_one = stb.instantiateViewController(withIdentifier: "welcome_step_1")
        let step_two = stb.instantiateViewController(withIdentifier: "welcome_step_2")
        let step_three = stb.instantiateViewController(withIdentifier: "welcome_step_3")
        let step_four = stb.instantiateViewController(withIdentifier: "welcome_step_4")
        let step_five = stb.instantiateViewController(withIdentifier: "welcome_step_5")
        
        // Duplicate of the first step for infinite scrolling effect
        let step_last_repeat_step_one = stb.instantiateViewController(withIdentifier: "welcome_step_1")
        
        // Attach the pages to the master
        self.add(viewController: step_one)
        self.add(viewController: step_two)
        self.add(viewController: step_three)
        self.add(viewController: step_four)
        self.add(viewController: step_five)
        
        // Attach step one again, so that we achieve the infinte scroll effect
        self.add(viewController: step_last_repeat_step_one)
        
        // Animation style
        self.modalTransitionStyle = .crossDissolve
        
        // Present the welcome screen

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
        loginWithFacebook(viewController: self)
        .onSuccess { (success) in
            AppEventsLogger.log("Login facebook")
            self.performSegue(withIdentifier: "loggedIn", sender: self)
        }.onFailure { (error) in
            print("Something went wrong in the facebook login")
        }
    }
}
