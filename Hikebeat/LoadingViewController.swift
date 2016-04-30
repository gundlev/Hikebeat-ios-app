//
//  LoadingViewController.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    var segueIdentifyer = ""
    
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var treesImageView: UIImageView!


    let bgGradient2 = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setNeedsStatusBarAppearanceUpdate()

        
        let loggedIn = userDefaults.boolForKey("loggedIn")
        if loggedIn {
            segueIdentifyer = "showMain"
        } else {
            segueIdentifyer = "showMain"
            //segueIdentifyer = "showLogin"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        let image = UIImage(named: "clouds")

        let scaledimage = UIImage(CGImage: image!.CGImage!, scale: 4, orientation: image!.imageOrientation)
        patternImageView.backgroundColor = UIColor(patternImage: scaledimage)
        
        self.patternImageView.center.x = -70
        
        UIView.animateWithDuration(10, delay:0.15, options: [.Repeat, .CurveLinear], animations: {
            self.patternImageView.center.x = 174
            },completion: nil)
        
        bgGradient2.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: circleImageView.bounds.size)
        bgGradient2.colors = [UIColor(red: (56/255.0), green: (157/255.0), blue: (133/255.0), alpha: 1).CGColor, UIColor(red: (71/255.0), green: (153/255.0), blue: (93/255.0), alpha: 1).CGColor]
        bgGradient2.zPosition = -1
        circleImageView.layer.addSublayer(bgGradient2)
        
        circleImageView.layer.borderWidth = 3.0
        circleImageView.layer.masksToBounds = false
        circleImageView.layer.borderColor = UIColor.whiteColor().CGColor
        circleImageView.layer.cornerRadius = 313/2
        circleImageView.clipsToBounds = true
        
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.9
        pulseAnimation.toValue = 1.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        logoImageView.layer.addAnimation(pulseAnimation, forKey: nil)
        
        
        treesImageView.rotate360Degrees(4, forever: true)
        
        
        //Jump to next in a sec
        _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(LoadingViewController.timeToMoveOn), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func timeToMoveOn() {
            self.performSegueWithIdentifier(segueIdentifyer, sender: self)

//        If already logged in:
//        self.performSegueWithIdentifier("showMain", sender: self)
    }
}
