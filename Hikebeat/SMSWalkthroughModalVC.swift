//
//  SMSWalkthroughModalVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 3/15/17.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import UIKit

class SMSWalkthroughModalVC: HikebeatWalkthroughViewController {
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    override func viewDidLoad() {
        shouldAutoSlideshow = false
        super.viewDidLoad()
        print("walkthrough running.")

        pageControl?.isHidden = true
        scrollview.isScrollEnabled = false
        
        nextStepButton.layer.cornerRadius = 7.0
        nextStepButton.layer.masksToBounds = true
        
        let stb = UIStoryboard(name: "Main", bundle: nil)
        
        // Add all steps to the container
        let step_one = stb.instantiateViewController(withIdentifier: "SMS_modal_step_1")
        let step_two = stb.instantiateViewController(withIdentifier: "SMS_modal_step_2")
        let step_three = stb.instantiateViewController(withIdentifier: "SMS_modal_step_3")
        let step_four = stb.instantiateViewController(withIdentifier: "SMS_modal_step_4")
        let step_five = stb.instantiateViewController(withIdentifier: "SMS_modal_step_5")
        let step_one_repeat = stb.instantiateViewController(withIdentifier: "SMS_modal_step_1")
        
        // Attach the pages to the master
        self.add(viewController: step_one)
        self.add(viewController: step_two)
        self.add(viewController: step_three)
        self.add(viewController: step_four)
        self.add(viewController: step_five)
        self.add(viewController: step_one_repeat)
        
        // Animation style
        self.modalTransitionStyle = .crossDissolve
    }
    
    @IBAction func nextAction(_ sender: AnyObject) {
        if currentPage == 3 {
            nextStepButton.setTitle("Close", for: .normal)
        }
        
        if currentPage != 4 {
            nextPage()
        } else {
            performSegue(withIdentifier: "unwindToCompose", sender: nil)
        }
    }
}
