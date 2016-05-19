//
//  ProfileVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class ProfileVC: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let realm = try! Realm()

    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var numberOfJourneys: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
//            searchFieldLabelView.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, -40.0  )
//            searchField.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
//            searchButton.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.followersButton.transform = CGAffineTransformTranslate( followersButton.transform, 0.0, 10.0  )
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        followersButton.layer.cornerRadius = followersButton.bounds.height/2
        followersButton.layer.masksToBounds = true
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        profilePicture.layer.masksToBounds = true
        
        // Setting labels to values
        self.usernameLabel.text = "@" + userDefaults.stringForKey("username")!
        self.nameLabel.text = userDefaults.stringForKey("name")!
        self.emailLabel.text = userDefaults.stringForKey("email")!
        //        self.phoneNoLabel.text = userDefaults.stringForKey("")!
        self.nationalityLabel.text = userDefaults.stringForKey("nationality")!
        self.genderLabel.text = userDefaults.stringForKey("gender")!
        
        // Settings number of journeys
        let journeys = realm.objects(Journey)
        self.numberOfJourneys.text = String(journeys.count)
        
        // Setting profileImage if there is one
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let fileName = "profileImage.png"
        let imagePath = documentsDirectory.stringByAppendingPathComponent(fileName)
        let image = UIImage(contentsOfFile: imagePath)
        if image != nil {
            profilePicture.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
