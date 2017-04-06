//
//  ProfileJourneyCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 31/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures
import SwiftyDrop
import RealmSwift

class ProfileJourneyCell: UITableViewCell {
    
    var headline: UILabel!
    var followersBeats: UILabel!
    var firstLoad = true
    var followButton: SmallFollowButton!
    var journey: Journey!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(hexString: "157578")
        } else {
            self.backgroundColor = .clear
        }
    }
    
    override func awakeFromNib() {
        if firstLoad {
            let width = UIScreen.main.bounds.width
            self.backgroundColor = standardGreen
            headline = UILabel(frame: CGRect(x: 30, y: 16, width: width-100, height: 20))
            headline.textColor = .white
            headline.adjustsFontSizeToFitWidth = true
            followersBeats = UILabel(frame: CGRect(x: 30, y: 34, width: width-100, height: 20))
            followersBeats.textColor = lightGreen
            followersBeats.font = UIFont.systemFont(ofSize: 13)
            let followButtonFrame = CGRect(x: width-100, y: 22.5, width: 75, height: 25)
            self.followersBeats.text = "\(self.journey.numberOfFollowers) followers | \(self.journey.numberOfBeats) beats"
            followButton = SmallFollowButton(frame: followButtonFrame, isFollowing: journey.isFollowed, journey: journey, onPress: {
                success in
                if success {
                    self.followersBeats.text = "\(self.journey.numberOfFollowers) followers | \(self.journey.numberOfBeats) beats"
                }
                print("Taped follow button")
            })

            self.addSubview(headline)
            self.addSubview(followersBeats)
            self.addSubview(followButton)
            self.firstLoad = false
        } else {
            self.followButton.changeJourneyTo(journey: journey)
            self.followersBeats.text = "\(self.journey.numberOfFollowers) followers | \(self.journey.numberOfBeats) beats"
        }
    }
}
