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
        
        let allSteps = [step_one, step_two, step_three, step_four, step_five, step_last_repeat_step_one]
        
        if (UIDevice.isIphone4 || UIDevice.isIpad){
            allSteps.forEach {
                
                guard let containerView = $0.view else{
                    return
                }
                
                containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65)
                containerView.transform = containerView.transform.translatedBy(x: 0.0, y: -110.0)
                
                let myLayer = CALayer()
                if let imageView = containerView.subviews[0] as? UIImageView,
                   let myImage = imageView.image?.cgImage{
                
                let magicNumber = UIScreen.main.bounds.height < 667 ? -20 : -110
                    
                myLayer.frame = CGRect(x: -UIScreen.main.bounds.width/3.7, y: CGFloat(magicNumber), width: UIScreen.main.bounds.width*1.65, height: UIScreen.main.bounds.height*1.65)
                myLayer.contents = myImage
                
                containerView.subviews[0].clipsToBounds = false
                containerView.clipsToBounds = false
                containerView.subviews[0].layer.addSublayer(myLayer)
                }
            }
        }
        
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
