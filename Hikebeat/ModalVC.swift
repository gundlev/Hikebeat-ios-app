//
//  ModalVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import Result
import BrightFutures

class ModalVC: UIViewController {
    
    var future: Future<Bool, NoError>!

    @IBOutlet weak var infoContainer: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        infoContainer.layer.cornerRadius = infoContainer.bounds.height/6
        infoContainer.layer.masksToBounds = true
       
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.backToCompose), userInfo: nil, repeats: false)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.pulse(infoContainer)
    }

    func pulse(view:UIView)
    {
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 0.6
        pulse1.fromValue = 1
        pulse1.toValue = 0.8
        pulse1.autoreverses = true
        pulse1.repeatCount = 2
        pulse1.initialVelocity = 0.1
        pulse1.damping = 0.8
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.7
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]
        
        view.layer.addAnimation(animationGroup, forKey: "pulse")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToCompose(){
        performSegueWithIdentifier("goBackToCompose", sender: self)
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
