//
//  TableViewPaginationFooter.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 05/02/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class TableViewPaginationFooter: UITableViewCell {
    
    var footerTitle: UILabel!
    var firstLoad = true
    var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        if firstLoad {
            print("const header")
            activityIndicator = UIActivityIndicatorView(frame: self.frame)
            activityIndicator.hidesWhenStopped = true
            footerTitle = UILabel(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 24))
            footerTitle.textAlignment = .center
            footerTitle.adjustsFontSizeToFitWidth = true
            footerTitle.textColor = lightGreen
            self.backgroundColor = standardGreen
            self.addSubview(footerTitle)
            firstLoad = false
        }
    }
    
    func startActivity() {
        self.activityIndicator.startAnimating()
        self.footerTitle.isHidden = true
    }
    
    func stopActivity() {
        self.activityIndicator.stopAnimating()
        self.footerTitle.isHidden = false
    }
}
