//
//  FeaturedJourneyViewCell.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 9/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class FeaturedJourneyViewCell: UITableViewCell {

    @IBOutlet weak var journeyTitleLabel: UILabel!
    @IBOutlet weak var journeyProfileImage: UIImageView!
    @IBOutlet weak var journeyBackgroundImage: UIImageView!
    @IBOutlet weak var journeyInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
        journeyProfileImage.layer.cornerRadius = journeyProfileImage.bounds.height/2
        journeyProfileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
}
