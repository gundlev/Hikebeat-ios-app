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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var fromVC = ""
    
    var jStatuses = ["Active journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey"]
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jDates = ["22/4/16","17/3/16","26/2/16","12/2/16","11/1/16","10/10/15","3/7/15"]

    let darkGreen = UIColor(hexString: "#15676C")
    let highlightColor = UIColor(hexString: "#157578")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        greenButton.layer.cornerRadius = greenButton.bounds.height/2
        greenButton.layer.masksToBounds = true

    }
    
    @IBAction func back(_ sender: AnyObject) {
        if fromVC == "profile" {
            performSegue(withIdentifier: "backToProfile", sender: self)
        } else {
            performSegue(withIdentifier: "backToSocial", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.journeysTableView.dequeueReusableCell(withIdentifier: "JourneyCell",for: indexPath) as! JourneyViewCell
        
        cell.journeyDateLabel.text = jDates[(indexPath as NSIndexPath).row]
        cell.journeyStatusLabel.text = jStatuses[(indexPath as NSIndexPath).row]
        cell.journeyTitleLabel.text = jTitles[(indexPath as NSIndexPath).row]
        
        cell.backgroundColor = UIColor.clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightColor
        cell.selectedBackgroundView = bgColorView
        
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
