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
    var progressBar: UIProgressView?
    var progressBarTitle: UILabel?
    let screenSize: CGRect = UIScreen.main.bounds
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)

    @IBOutlet weak var infoContainer: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        infoContainer.layer.cornerRadius = infoContainer.bounds.height/6
        infoContainer.layer.masksToBounds = true
       
        self.future.onSuccess { (success) in
            _ = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.backToCompose), userInfo: nil, repeats: false)
            self.infoContainer.image = UIImage(named: "Checkcheck")
        }
    }
    
    func addProgressBar(_ titleText: String) -> UIProgressView{
        progressBar = UIProgressView(frame: CGRect(x: 20, y: ((screenSize.height/3)*2)+20, width: screenSize.width-40, height: 20))
        progressBar?.progressTintColor = greenColor
        progressBar?.trackTintColor = UIColor.white
        progressBarTitle = UILabel(frame: CGRect(x: 20, y: ((screenSize.height/3)*2)+40, width: screenSize.width-40, height: 30))
        progressBarTitle?.textAlignment = .center
        progressBarTitle?.text = titleText
        progressBarTitle?.textColor = UIColor.white
        self.view.addSubview(progressBar!)
        self.view.addSubview(progressBarTitle!)
        return progressBar!
    }
    
    func setProgress(_ progress: Float) {
        self.progressBar?.progress = progress
    }
    
    func removeProgressBar() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pulse(infoContainer)
    }

    func pulse(_ view:UIView)
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
        
        view.layer.add(animationGroup, forKey: "pulse")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToCompose(){
        performSegue(withIdentifier: "goBackToCompose", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
        switch segue.identifier! {
        
        case "goBackToCompose":
            let vc = segue.destination as! ComposeVC
//            vc.clearAllForNewBeat()
        
        default:
            break
        }
        
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
