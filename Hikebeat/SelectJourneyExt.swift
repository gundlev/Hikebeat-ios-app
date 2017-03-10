//
//  SelectJourneyExt.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 09/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

extension ComposeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count: ", self.journeys!.count)
        print(self.journeys)
        return self.journeys!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectJourneyCell") as! SelectJourneyCell
        print(self.journeys)
        let journey = journeys![indexPath.row]
        if journey.active {
            cell.checkImage.image = UIImage(named: "following_icon")
            self.activeIndexpath = indexPath
        } else {
            cell.checkImage.image = UIImage()
        }
        cell.journeyTitle.text = journey.headline
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedJourney = self.journeys![indexPath.row]
        try! realm.write {
            if activeJourney != nil {
                self.activeJourney!.active = false
                let oldCell = tableView.cellForRow(at: self.activeIndexpath) as! SelectJourneyCell
                oldCell.checkImage.image = UIImage()
            }
            self.activeJourney = selectedJourney
            self.activeJourney!.active = true
            self.activeJourneyButton.setTitle(selectedJourney.headline, for: .normal)
        }
        tableView.reloadData()
        let center = self.tableViewSelectJourney.center
        animateSelectJourneyUp(animated: true)
        self.showingJourneySelect = false
    }
    
    func animateSelectJourneyUp(animated: Bool) {
        var duration: TimeInterval = 0
        if animated {
            duration = 0.5
        }
        let center = self.tableViewSelectJourney.center
        UIView.animate(withDuration: duration, animations: {
            self.tableViewSelectJourney.center = CGPoint(x: center.x, y:center.y-self.tableViewSelectJourney.frame.height)
        })
        
        activeJourneyButton.setImage(UIImage(named: "downArrow"), for: .normal)
        
        print("Starting y: \(center.y), Ending y: \(center.y-self.tableViewSelectJourney.frame.height)")
        handleViewPresentation()
    }
    
    func animateSelectJourneyDown(animated: Bool) {
//        self.tableViewSelectJourney.reloadData()
        var duration: TimeInterval = 0
        if animated {
            duration = 0.5
        }
        let center = self.tableViewSelectJourney.center
        UIView.animate(withDuration: duration, animations: {
            self.tableViewSelectJourney.center = CGPoint(x: center.x, y:center.y+self.tableViewSelectJourney.frame.height)
        })
        
        activeJourneyButton.setImage(UIImage(named: "upArrow"), for: .normal)
    }
    
}

