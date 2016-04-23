//
//  LoadingViewController.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var treesImageView: UIImageView!

    let bgGradient = CAGradientLayer()
    let bgGradient2 = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: 47, green: 160, blue: 165, alpha: 1).CGColor, UIColor(red: 79, green: 150, blue: 68, alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        let image = UIImage(named: "clouds")

        let scaledimage = UIImage(CGImage: image!.CGImage!, scale: 4, orientation: image!.imageOrientation)
        patternImageView.backgroundColor = UIColor(patternImage: scaledimage)
        
        self.patternImageView.center.x = 0
        
        UIView.animateWithDuration(10, delay:0.15, options: [.Repeat, .CurveLinear], animations: {
            self.patternImageView.center.x = 174
            },completion: nil)
        
        
        bgGradient2.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: circleImageView.bounds.size)
        bgGradient2.colors = [UIColor(red: 56, green: 157, blue: 133, alpha: 1).CGColor, UIColor(red: 71, green: 153, blue: 93, alpha: 1).CGColor]
        bgGradient2.zPosition = -1
        circleImageView.layer.addSublayer(bgGradient2)
        
        circleImageView.layer.borderWidth = 3.0
        circleImageView.layer.masksToBounds = false
        circleImageView.layer.borderColor = UIColor.whiteColor().CGColor
        circleImageView.layer.cornerRadius = 323/2
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
