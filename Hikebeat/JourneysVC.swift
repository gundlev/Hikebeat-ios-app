//
//  JourneysVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift

class JourneysVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var activeJourneysCollectionView: UICollectionView!
    @IBOutlet weak var journeysTableView: UITableView!
    @IBOutlet weak var activeJourneyButton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var journeys: Results<Journey>!
    let realm = try! Realm()
    var activeJourney: Journey?
    var activeIndexpath:NSIndexPath? // selected in the collectionview
    var selectedIndexPath: NSIndexPath? // selected in the tableview

    var jStatuses = ["Active journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey"]
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jDates = ["22/4/16","17/3/16","26/2/16","12/2/16","11/1/16","10/10/15","3/7/15"]
    
    let darkGreen = UIColor(hexString: "#15676C")
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.activeJourneysCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.activeJourneysCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.activeJourneysCollectionView.contentInset = insets
        self.activeJourneysCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.journeys = self.realm.objects(Journey)
        print(journeys)
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        activeJourneyButton.layer.cornerRadius = activeJourneyButton.bounds.height/2
        activeJourneyButton.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToJourneys(unwindSegue: UIStoryboardSegue) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count //jTitles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.journeysTableView.dequeueReusableCellWithIdentifier("JourneyCell",forIndexPath: indexPath) as! JourneyViewCell
        
        let journey = journeys[indexPath.row]
        
        cell.journeyDateLabel.text = jDates[indexPath.row]
        var statusLabel = ""
        if journey.active {
            statusLabel = "Active journey"
        } else {
            statusLabel = "Inactive journey"
        }
        
        cell.journeyStatusLabel.text = statusLabel
        cell.journeyTitleLabel.text = journey.headline!
        
        cell.backgroundColor = UIColor.clearColor()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = darkGreen
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }
    
    @IBAction func showNewJourneyVC(sender: AnyObject) {
        
        performSegueWithIdentifier("showNewJourney", sender: self)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        appDelegate.fastSegueHack = "journeys"
        self.selectedIndexPath = indexPath
        performSegueWithIdentifier("showJourney", sender: self)
        self.journeysTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getAllJourneys() {
        
    }


}

extension JourneysVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journeys.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let journey = self.journeys[indexPath.item]
        
        if journey.active {
            changeSetOfCells(indexPath, active: false)
            try! realm.write() {
                journey.active = false
                self.activeJourney = nil
                self.activeIndexpath = nil
            }
        } else {
            if self.activeJourney != nil && self.activeIndexpath != nil {
                changeSetOfCells(self.activeIndexpath!, active: false)
                try! realm.write() {
                    self.activeJourney!.active = false
                }
            }
            changeSetOfCells(indexPath, active: true)
            try! realm.write() {
                journey.active = true
                self.activeIndexpath = indexPath
                self.activeJourney = journey
            }
        }
    }
    
    func changeSetOfCells(indexPath: NSIndexPath, active: Bool) {
        var labelText = "Finished journey"
        var imageName = "NotActivatedBadge"
        if active {
            labelText = "Active journey"
            imageName = "ActivatedBadge"
        }
        let tableCell = self.journeysTableView.cellForRowAtIndexPath(indexPath) as! JourneyViewCell
        tableCell.journeyStatusLabel.text = labelText
        let collectionCell = self.activeJourneysCollectionView.cellForItemAtIndexPath(indexPath) as! ActiveJourneyCollectionViewCell
        collectionCell.badgeImage.image = UIImage(named: imageName)
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActiveJourneyCell", forIndexPath: indexPath) as! ActiveJourneyCollectionViewCell
        
        let journey = self.journeys[indexPath.item]
        print(1)
        cell.journeyTitleLabel.text = journey.headline
        cell.backgroundColor = UIColor.clearColor()
        if journey.active {
            self.activeJourney = journey
            self.activeIndexpath = indexPath
            cell.badgeImage.image = UIImage(named: "ActivatedBadge")
        } else {
            cell.badgeImage.image = UIImage(named: "NotActivatedBadge")
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showJourney" {
            let vc = segue.destinationViewController as! JourneyContainerVC
            vc.journey = self.journeys[(selectedIndexPath?.row)!]
        }
    }
    
}
