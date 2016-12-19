//
//  SearchJourneyCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SearchJourneyCell: UITableViewCell {
    
    var profileImage: UIImageView!
    var headline: UILabel!
    var followersBeats: UILabel!
    var firstLoad = true
    
    override func awakeFromNib() {
        if firstLoad {
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 90
            self.backgroundColor = .clear
            profileImage = UIImageView(frame: CGRect(x: 20, y: 20, width: 50, height: 50))
            setProfileImage()
//            headline = UILabel(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
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
