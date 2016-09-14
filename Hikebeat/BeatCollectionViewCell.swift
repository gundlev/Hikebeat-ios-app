//
//  BeatCollectionViewCell.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class BeatCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var beatContainer: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var beatMessage: UITextView!
    @IBOutlet weak var beatTitle: UILabel!
    @IBOutlet weak var journeyTitle: UILabel!
    @IBOutlet weak var beatImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var beatTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var mediaType: UILabel!
    @IBOutlet weak var mediaLength: UILabel!
    
    override func awakeFromNib() {
        self.scrollView.scrollEnabled = false
    }
    
}
