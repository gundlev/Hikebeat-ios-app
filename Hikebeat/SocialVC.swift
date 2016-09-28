//
//  SocialVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class SocialVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var journeysTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jInfos = ["123 followers | 25 beats","123 followers | 25 beats","123 followers | 25 beats","123 followers | 25 beats","123 followers | 25 beats","123 followers | 25 beats","123 followers | 25 beats"]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
            
        }else if(UIDevice.isIphone6SPlus || UIDevice.isIphone6Plus){
        
        } else if(UIDevice.isIphone4 || UIDevice.isIpad){
          
        }

        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchButton.layer.cornerRadius = searchButton.bounds.height/2
        searchButton.layer.masksToBounds = true
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0)
        searchButton.titleEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0)
        
    }
    
    @IBAction func unwindToSocial(_ unwindSegue: UIStoryboardSegue) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.journeysTableView.dequeueReusableCell(withIdentifier: "FeaturedCell",for: indexPath) as! FeaturedJourneyViewCell
        
        cell.journeyInfoLabel.text = jInfos[(indexPath as NSIndexPath).row]
        cell.journeyTitleLabel.text = jTitles[(indexPath as NSIndexPath).row]
        cell.journeyProfileImage.image = UIImage(named: "DimiInTheHouse")
                

        cell.backgroundColor = UIColor.clear
        
//        let bgColorView = UIView()
//        bgColorView.backgroundColor = darkGreen
//        cell.selectedBackgroundView = bgColorView
//        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.fastSegueHack = "social"
        performSegue(withIdentifier: "showOtherJourney", sender: self)
        self.journeysTableView.deselectRow(at: indexPath, animated: true)
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
