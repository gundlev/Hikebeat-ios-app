//
//  JourneyVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import MapKit

class JourneyVC: UIViewController {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var socialContainerView: UIView!
    @IBOutlet weak var journeyMap: MKMapView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        let socialGradient = CAGradientLayer()
        socialGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: socialContainerView.bounds.size)
        socialGradient.colors = [UIColor(hexString: "054D51")!.CGColor, UIColor(hexString: "2E7E5D")!.CGColor]
        socialGradient.zPosition = -1
        socialContainerView.layer.addSublayer(socialGradient)
        
        let initialLocation = CLLocation(latitude: 55.6596349, longitude: 12.5909584)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        journeyMap.setRegion(coordinateRegion, animated: true)
        
        titleButton.layer.cornerRadius = titleButton.bounds.height/2
        titleButton.layer.masksToBounds = true
        
        profileImage.layer.cornerRadius = profileImage.bounds.height/2
        profileImage.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goBack(sender: AnyObject) {
        
        if appDelegate.fastSegueHack=="social"{
            performSegueWithIdentifier("unwindSocialHack", sender: self)
        }else{
            performSegueWithIdentifier("unwindJourneysHack", sender: self)
        }
        
    }
    
    @IBAction func unwindToJourney(unwindSegue: UIStoryboardSegue) {
        
    }

    @IBAction func showFirstBeat(sender: AnyObject) {
        
        performSegueWithIdentifier("showBeat", sender: self)
        
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
