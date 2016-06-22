//
//  UniversalListOfJourneysVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 5/2/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class UniversalListOfJourneysVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var journeysTableView: UITableView!
    @IBOutlet weak var greenButton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var fromVC = ""
    
    var jStatuses = ["Active journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey"]
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jDates = ["22/4/16","17/3/16","26/2/16","12/2/16","11/1/16","10/10/15","3/7/15"]

    let darkGreen = UIColor(hexString: "#15676C")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        greenButton.layer.cornerRadius = greenButton.bounds.height/2
        greenButton.layer.masksToBounds = true

    }
    
    @IBAction func back(sender: AnyObject) {
        if fromVC == "profile" {
            performSegueWithIdentifier("backToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToSocial", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jTitles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.journeysTableView.dequeueReusableCellWithIdentifier("JourneyCell",forIndexPath: indexPath) as! JourneyViewCell
        
        cell.journeyDateLabel.text = jDates[indexPath.row]
        cell.journeyStatusLabel.text = jStatuses[indexPath.row]
        cell.journeyTitleLabel.text = jTitles[indexPath.row]
        
        cell.backgroundColor = UIColor.clearColor()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = darkGreen
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate.fastSegueHack = "social"
        performSegueWithIdentifier("showOtherJourney", sender: self)
        self.journeysTableView.deselectRowAtIndexPath(indexPath, animated: true)
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
