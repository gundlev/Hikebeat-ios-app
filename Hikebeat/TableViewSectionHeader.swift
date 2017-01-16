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
    
    override func awakeFromNib() {
        if firstLoad {
            print("const header")
            icon = UIImageView(frame: CGRect(x: 33, y: 10, width: 24, height: 24))
            icon.contentMode = .scaleAspectFit
            headerTitle = UILabel(frame: CGRect(x: 70, y: 10, width: UIScreen.main.bounds.width-20, height: 24))
            headerTitle.adjustsFontSizeToFitWidth = true
            headerTitle.textColor = lightGreen
            self.backgroundColor = standardGreen
            self.addSubview(headerTitle)
            self.addSubview(icon)
            firstLoad = false
        }
    }
}
