//
//  TableViewSectionHeader.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 15/01/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class TableViewSectionHeader: UITableViewCell {
    
    var headerTitle: UILabel!
    var icon: UIImageView!
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
            icon = UIImageView(frame: CGRect(x: 20, y: 2, width: 40, height: 40))
            icon.contentMode = .scaleAspectFit
            icon.contentMode = .center
            headerTitle = UILabel(frame: CGRect(x: 80, y: 10, width: UIScreen.main.bounds.width-20, height: 24))
            headerTitle.adjustsFontSizeToFitWidth = true
            headerTitle.textColor = lightGreen
            self.backgroundColor = standardGreen
            self.addSubview(headerTitle)
            self.addSubview(icon)
            firstLoad = false
        }
    }
}
