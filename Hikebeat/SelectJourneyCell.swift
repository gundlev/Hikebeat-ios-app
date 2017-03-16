//
//  SelectJourneyCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 09/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SelectJourneyCell: UITableViewCell {
    
    @IBOutlet weak var journeyTitle: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(hexString: "157578")
        } else {
            self.backgroundColor = .clear
        }
    }
}
