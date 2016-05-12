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
    
    var journey: Journey?
    override func viewDidLoad() {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "instantiateContainer" {
            let vc = segue.destinationViewController as! JourneyVC
            vc.journey = self.journey
        }
    }
    
}
