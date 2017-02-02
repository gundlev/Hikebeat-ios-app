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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var journeys: [Journey]!
    let realm = try! Realm()
    var activeJourney: Journey?
    var activeIndexpath: Int?
    //var activeIndexpath:NSIndexPath? // selected in the collectionview
    var selectedIndexPath: IndexPath? // selected in the tableview
    let greenColor = UIColor(colorLiteralRed: 198/255, green: 255/255, blue: 0, alpha: 1)
    let yellowColor = UIColor.yellow//UIColor(colorLiteralRed: 254/255, green: 237/255, blue: 9, alpha: 1)
    
    let darkGreen = UIColor(hexString: "#15676C")
    let highlightColor = UIColor(hexString: "#157578")
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.activeJourneysCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.activeJourneysCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.activeJourneysCollectionView.contentInset = insets
        self.activeJourneysCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if journeys.isEmpty {
            performSegue(withIdentifier: "showNewJourney", sender: self)
        }
        self.journeysTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIDevice.isIphone5){
            
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.activeJourneyButton.transform = activeJourneyButton.transform.translatedBy(x: 0.0, y: 10.0  )
            
            // Magic line of code setting the constraints back correctly.
            journeysTableView.transform = activeJourneyButton.transform.translatedBy(x: 0.0, y: 0.0 )
        }

        let journeysUnsorted = self.realm.objects(Journey.self)
        self.journeys = journeysUnsorted.reversed()
        
        for journey in self.journeys {
            if journey.active {
                self.activeIndexpath = self.journeys.index(where: {$0.journeyId == journey.journeyId})
            }
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        activeJourneyButton.layer.cornerRadius = activeJourneyButton.bounds.height/2
        activeJourneyButton.layer.masksToBounds = true
        
        let footer = self.journeysTableView.footerView(forSection: 0)
        footer?.backgroundColor = UIColor.clear
        footer?.contentView.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.activeIndexpath != nil {
            let indexpath = IndexPath(item: self.activeIndexpath!, section: 0)
            self.activeJourneysCollectionView.scrollToItem(at: indexpath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToJourneys(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindWhenCreatedJourney(_ unwindSegue: UIStoryboardSegue) {
        self.journeys = self.realm.objects(Journey.self).reversed()
        self.activeJourneysCollectionView.reloadData()
        self.journeysTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count //jTitles.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let journey = self.journeys[indexPath.row]
            self.journeys.remove(at: indexPath.row)
            let future = deleteJourney(journeyId: journey.journeyId)
            future.onSuccess(callback: { (success) in
                if success {
                    try! self.realm.write {
                        self.realm.delete(journey)
                    }
                } else {
                    //TODO: save deletion in changes.
                }
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.journeysTableView.dequeueReusableCell(withIdentifier: "JourneyCell",for: indexPath) as! JourneyViewCell
        
        let journey = journeys[(indexPath as NSIndexPath).row]
        
        let beats = journey.beats.sorted(byProperty: "timestamp")

        
        
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
        
        cell.backgroundColor = UIColor.clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = highlightColor
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }
    
    @IBAction func showNewJourneyVC(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "showNewJourney", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.fastSegueHack = "journeys"
        self.selectedIndexPath = indexPath
        performSegue(withIdentifier: "showJourney", sender: self)
        self.journeysTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getAllJourneys() {
        
    }


}

extension JourneysVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return journeys.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let journey = self.journeys[(indexPath as NSIndexPath).item]
        print(1)
        if journey.active {
            print(1.1)
            changeSetOfCells((indexPath as NSIndexPath).item, active: false)
            activeJourneyButton.isHighlighted = false
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
                let indexP = IndexPath(item: self.activeIndexpath!, section: 0)
                changeSetOfCells(self.activeIndexpath!, active: false)
                try! realm.write() {
                    self.activeJourney!.active = false
                }
            }
            activeJourneyButton.isHighlighted = true
            activeJourneyButton.backgroundColor = greenColor
            changeSetOfCells((indexPath as NSIndexPath).item, active: true)
            try! realm.write() {
                journey.active = true
                self.activeIndexpath = (indexPath as NSIndexPath).item
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
    
    func changeSetOfCells(_ item: Int, active: Bool) {
        print("item: ", item)
        let indexPath = IndexPath(item: item, section: 0)
        var labelText = "Inactive journey"
        var imageName = "NotActivatedBadge"
        if active {
            labelText = "Active journey"
            imageName = "ActivatedBadge"
        }
        print(3)
        if let tableCell = self.journeysTableView.cellForRow(at: indexPath) as? JourneyViewCell {
            tableCell.journeyStatusLabel.text = labelText
        }
        print(4)
        if let collectionCell = self.activeJourneysCollectionView.cellForItem(at: indexPath) as? ActiveJourneyCollectionViewCell {
            collectionCell.badgeImage.image = UIImage(named: imageName)
        }
        print(6)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveJourneyCell", for: indexPath) as! ActiveJourneyCollectionViewCell
        
        let journey = self.journeys[(indexPath as NSIndexPath).item]
        cell.journeyTitleLabel.text = journey.headline
        cell.backgroundColor = UIColor.clear
        if journey.active {
            self.activeJourney = journey
            self.activeIndexpath = (indexPath as NSIndexPath).item
            cell.badgeImage.image = UIImage(named: "ActivatedBadge")
            activeJourneyButton.isHighlighted = true
            activeJourneyButton.backgroundColor = greenColor
        } else {
            cell.badgeImage.image = UIImage(named: "NotActivatedBadge")
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showJourney" {
            let vc = segue.destination as! JourneyContainerVC
            vc.journey = self.journeys[((selectedIndexPath as NSIndexPath?)?.row)!]
        }
    }
    
}
