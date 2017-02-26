//
//  TableViewSectionFooter.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 16/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class TableViewSectionFooter: UITableViewCell {
    
    var headerTitle: UILabel!
    var firstLoad = true
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(hexString: "157578")
        } else {
            self.backgroundColor = .clear
        }
    }
    
    override func awakeFromNib() {
        if firstLoad {
            print("const header")
            headerTitle = UILabel(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 24))
            headerTitle.textAlignment = .center
            headerTitle.adjustsFontSizeToFitWidth = true
            headerTitle.textColor = lightGreen
            self.backgroundColor = standardGreen
            self.addSubview(headerTitle)
            firstLoad = false
        }
    }
}
