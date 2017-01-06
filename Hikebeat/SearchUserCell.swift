//
//  SearchUserCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SearchUserCell: UITableViewCell {
    
    var profileImage: UIImageView!
    var headline: UILabel!
    var journeyIcon: UIImageView!
    var numberOfJourneys: UILabel!
    var firstLoad = true
    
    override func awakeFromNib() {
        if firstLoad {
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 90
            self.backgroundColor = .clear
            profileImage = UIImageView(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
            profileImage.layer.cornerRadius = profileImage.frame.width/2
            profileImage.layer.masksToBounds = true
            setProfileImage()
            headline = UILabel(frame: CGRect(x: 80, y: 30, width: width-160, height: 30))
            headline.textColor = lightGreen
            headline.adjustsFontSizeToFitWidth = true
            journeyIcon = UIImageView(frame: CGRect(x: width-60, y: 25, width: 25, height: 25))
            journeyIcon.image = UIImage(named: "tiny_backpack")
            numberOfJourneys = UILabel(frame: CGRect(x: 80, y: 50, width: width-100, height: 10))
            numberOfJourneys.textColor = .white
            numberOfJourneys.font = UIFont.systemFont(ofSize: 13)
            self.addSubview(profileImage)
            self.addSubview(headline)
//            self.addSubview(followersBeats)
            self.firstLoad = false
        }
    }
    
    func setProfileImage() {
        let dataPath = getProfileImagePath()
        let image = UIImage(contentsOfFile: dataPath)
        if image != nil {
            self.profileImage.image = image
            print("setting profile image")
        } else {
            self.profileImage.image = UIImage(named: "DefaultProfile")
        }
    }
}
