//
//  LoadingViewController.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var circleImageView: UIImageView!
    @IBOutlet weak var patternImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var treesImageView: UIImageView!


    let bgGradient2 = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        let image = UIImage(named: "clouds")

        let scaledimage = UIImage(cgImage: image!.cgImage!, scale: 4, orientation: image!.imageOrientation)
        patternImageView.backgroundColor = UIColor(patternImage: scaledimage)
        
        self.patternImageView.center.x = -70
        
        UIView.animate(withDuration: 10, delay:0.15, options: [.repeat, .curveLinear], animations: {
            self.patternImageView.center.x = 174
            },completion: nil)
        
        bgGradient2.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: circleImageView.bounds.size)
        bgGradient2.colors = [UIColor(red: (56/255.0), green: (157/255.0), blue: (133/255.0), alpha: 1).cgColor, UIColor(red: (71/255.0), green: (153/255.0), blue: (93/255.0), alpha: 1).cgColor]
        bgGradient2.zPosition = -1
        circleImageView.layer.addSublayer(bgGradient2)
        
        circleImageView.layer.borderWidth = 3.0
        circleImageView.layer.masksToBounds = false
        circleImageView.layer.borderColor = UIColor.white.cgColor
        circleImageView.layer.cornerRadius = 313/2
        circleImageView.clipsToBounds = true
        
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0.9
        pulseAnimation.toValue = 1.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        logoImageView.layer.add(pulseAnimation, forKey: nil)
        
        
        treesImageView.rotate360Degrees(4, forever: true)
        
        
        //Jump to next in a sec
        _ = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(LoadingViewController.timeToMoveOn), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    func timeToMoveOn() {
        if userDefaults.bool(forKey: "loggedIn") {
            self.performSegue(withIdentifier: "showMain", sender: self)
        } else {
            presentWelcome()
        }
    }
    
    func presentWelcome() {
        self.performSegue(withIdentifier: "showWalkThrough", sender: self)
//        // Init a new welcome
//        let stb = UIStoryboard(name: "Main", bundle: nil)
//        let welcome = stb.instantiateViewController(withIdentifier: "welcome_container") as! HikebeatWalkthroughViewController
//        
//        // Add all steps to the container
//        let step_one = stb.instantiateViewController(withIdentifier: "welcome_step_1")
//        let step_two = stb.instantiateViewController(withIdentifier: "welcome_step_2")
//        let step_three = stb.instantiateViewController(withIdentifier: "welcome_step_3")
//        let step_four = stb.instantiateViewController(withIdentifier: "welcome_step_4")
//        let step_five = stb.instantiateViewController(withIdentifier: "welcome_step_5")
//        
//        // Duplicate of the first step for infinite scrolling effect
//        let step_last_repeat_step_one = stb.instantiateViewController(withIdentifier: "welcome_step_1")
//        
//        // Attach the pages to the master
//        welcome.add(viewController: step_one)
//        welcome.add(viewController: step_two)
//        welcome.add(viewController: step_three)
//        welcome.add(viewController: step_four)
//        welcome.add(viewController: step_five)
//        
//        // Attach step one again, so that we achieve the infinte scroll effect
//        welcome.add(viewController: step_last_repeat_step_one)
//        
//        // Animation style
//        welcome.modalTransitionStyle = .crossDissolve
//        
//        // Present the welcome screen
//        self.present(welcome, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        switch segue.identifier! {
        case "showMain":
            let vc = segue.destination as! HikebeatTabBarVC
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.tabBarVC = vc
        default: return
        }
    }
}

