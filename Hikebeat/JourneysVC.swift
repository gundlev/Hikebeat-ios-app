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

    
    @IBOutlet weak var collectionBG: UIImageView!
    @IBOutlet weak var activeJourneysCollectionView: UICollectionView!
    @IBOutlet weak var journeysTableView: UITableView!
    @IBOutlet weak var activeJourneyButton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var journeys: Results<Journey>!
    let realm = try! Realm()
    var activeJourney: Journey?
    var activeIndexpath: Int?
    //var activeIndexpath:NSIndexPath? // selected in the collectionview
    var selectedIndexPath: NSIndexPath? // selected in the tableview
    let greenColor = UIColor(colorLiteralRed: 198/255, green: 255/255, blue: 0, alpha: 1)
    let yellowColor = UIColor.yellowColor()//UIColor(colorLiteralRed: 254/255, green: 237/255, blue: 9, alpha: 1)
    
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
    
    override func viewWillAppear(animated: Bool) {
        self.journeysTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIDevice.isIphone5){
            
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.activeJourneyButton.transform = CGAffineTransformTranslate( activeJourneyButton.transform, 0.0, 10.0  )
            
            // Magic line of code setting the constraints back correctly.
            journeysTableView.transform = CGAffineTransformTranslate(activeJourneyButton.transform, 0.0, 0.0 )
        }

        // Do any additional setup after loading the view.
        self.journeys = self.realm.objects(Journey)
        for journey in self.journeys {
            if journey.active {
                self.activeIndexpath = self.journeys.indexOf(journey)
            }
        }
        print(journeys)
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        activeJourneyButton.layer.cornerRadius = activeJourneyButton.bounds.height/2
        activeJourneyButton.layer.masksToBounds = true
        
        let footer = self.journeysTableView.footerViewForSection(0)
        footer?.backgroundColor = UIColor.clearColor()
        footer?.contentView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.activeIndexpath != nil {
            let indexpath = NSIndexPath(forItem: self.activeIndexpath!, inSection: 0)
            self.activeJourneysCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToJourneys(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindWhenCreatedJourney(unwindSegue: UIStoryboardSegue) {
        self.journeys = self.realm.objects(Journey)
        self.activeJourneysCollectionView.reloadData()
        self.journeysTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count //jTitles.count
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.journeysTableView.dequeueReusableCellWithIdentifier("JourneyCell",forIndexPath: indexPath) as! JourneyViewCell
        
        let journey = journeys[indexPath.row]
        
        let beats = journey.beats.sorted("timestamp")
        if beats.isEmpty {
            cell.journeyDateLabel.text = "No beats"
        } else {
//            let beat = beats.first
//            let formatter = NSDateFormatter()
//            let date = NSDate(timeIntervalSince1970: NSTimeInterval(Int(beat!.timestamp)!))
//            formatter.dateFormat = "d/M/YY"
//            let timeString = formatter.stringFromDate(date)
            cell.journeyDateLabel.text = String(beats.count) + " beats"
        }
        
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
        print(1)
        if journey.active {
            print(1.1)
            changeSetOfCells(indexPath.item, active: false)
            activeJourneyButton.highlighted = false
            activeJourneyButton.backgroundColor = yellowColor
            try! realm.write() {
                journey.active = false
                self.activeJourney = nil
                self.activeIndexpath = nil
            }
        } else {
            print(1.2)
            if self.activeJourney != nil && self.activeIndexpath != nil {
                print(1.3)
                print("IndexPath :", self.activeIndexpath)
                let indexP = NSIndexPath(forItem: self.activeIndexpath!, inSection: 0)
                changeSetOfCells(self.activeIndexpath!, active: false)
                try! realm.write() {
                    self.activeJourney!.active = false
                }
            }
            activeJourneyButton.highlighted = true
            activeJourneyButton.backgroundColor = greenColor
            changeSetOfCells(indexPath.item, active: true)
            try! realm.write() {
                journey.active = true
                self.activeIndexpath = indexPath.item
                self.activeJourney = journey
            }
        }
        print(2)
    }
    
    func removeOldActiveJourney() {
        try! realm.write() {
            self.activeJourney?.active = false
        }
        self.activeJourney = nil
        self.activeIndexpath = nil
        
//        if self.activeIndexpath != nil {
//            changeSetOfCells(NSIndexPath(forItem: self.activeIndexpath!, inSection: 0), active: false)
//            let journey = self.journeys[self.activeIndexpath!]
//            try! realm.write() {
//                journey.active = false
//            }
//        }
    }
    
    func changeSetOfCells(item: Int, active: Bool) {
        print("item: ", item)
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        var labelText = "Inactive journey"
        var imageName = "NotActivatedBadge"
        if active {
            labelText = "Active journey"
            imageName = "ActivatedBadge"
        }
        print(3)
        if let tableCell = self.journeysTableView.cellForRowAtIndexPath(indexPath) as? JourneyViewCell {
            tableCell.journeyStatusLabel.text = labelText
        }
        print(4)
        if let collectionCell = self.activeJourneysCollectionView.cellForItemAtIndexPath(indexPath) as? ActiveJourneyCollectionViewCell {
            collectionCell.badgeImage.image = UIImage(named: imageName)
        }
        print(6)

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActiveJourneyCell", forIndexPath: indexPath) as! ActiveJourneyCollectionViewCell
        
        let journey = self.journeys[indexPath.item]
        cell.journeyTitleLabel.text = journey.headline
        cell.backgroundColor = UIColor.clearColor()
        if journey.active {
            self.activeJourney = journey
            self.activeIndexpath = indexPath.item
            cell.badgeImage.image = UIImage(named: "ActivatedBadge")
            activeJourneyButton.highlighted = true
            activeJourneyButton.backgroundColor = greenColor
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
