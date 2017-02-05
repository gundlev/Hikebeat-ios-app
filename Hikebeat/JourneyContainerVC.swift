//
//  JourneyContainerVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 12/05/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class JourneyContainerVC: UIViewController {
    
    var save = true
    var journey: Journey?
    var fromVC = ""
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func journeyToSearch(_ unwindSegue: UIStoryboardSegue) {
        performSegue(withIdentifier: "backToSearch", sender: self)
    }
    
    @IBAction func journeyToShowAll(_ unwindSegue: UIStoryboardSegue) {
        performSegue(withIdentifier: "backToShowAll", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "instantiateContainer" {
            let vc = segue.destination as! JourneyVC
            vc.journey = self.journey
            vc.save = save
            vc.fromVC = fromVC
        }
    }
    
}
