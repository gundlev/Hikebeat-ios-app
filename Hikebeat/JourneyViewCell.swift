//
//  JourneyViewCell.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/29/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class JourneyViewCell: UITableViewCell {

    @IBOutlet weak var journeyStatusLabel: UILabel!
    @IBOutlet weak var journeyTitleLabel: UILabel!
    @IBOutlet weak var journeyTypeIcon: UIImageView!
    @IBOutlet weak var journeyDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
