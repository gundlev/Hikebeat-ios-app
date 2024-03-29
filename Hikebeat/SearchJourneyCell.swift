//
//  SearchJourneyCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures
import SwiftyDrop
import RealmSwift

class SearchJourneyCell: UITableViewCell {
    
    var profileImage: UIImageView!
    var headline: UILabel!
    var followersBeats: UILabel!
    var firstLoad = true
    var imageActivity: UIActivityIndicatorView!
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
            let height: CGFloat = 70
            self.backgroundColor = standardGreen
            profileImage = UIImageView(frame: CGRect(x: 15, y: 10, width: 50, height: 50))
            profileImage.layer.cornerRadius = profileImage.frame.width/2
            profileImage.layer.masksToBounds = true
            imageActivity = UIActivityIndicatorView(frame: CGRect(x: 15, y: 10, width: 50, height: 50))
            headline = UILabel(frame: CGRect(x: 80, y: 16, width: width-200, height: 20))
            headline.textColor = .white
            headline.adjustsFontSizeToFitWidth = true
            followersBeats = UILabel(frame: CGRect(x: 80, y: 34, width: width-100, height: 20))
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
//            followButton = UIButton(frame: CGRect(x: width-64, y: height/2-31/2, width: 31, height: 31))
            
//            let followImage = UIImage(named: "follow_icon")
//            let followingImage = UIImage(named: "following_icon")
//            
//            followButton.setImage(followImage, for: .normal)
//            followButton.setImage(followingImage, for: .selected)
//            followButton.addTarget(self, action: #selector(self.followOrUnfollow), for: .touchUpInside)
            
            
            self.addSubview(profileImage)
            self.addSubview(imageActivity)
            self.addSubview(headline)
            self.addSubview(followersBeats)
            self.addSubview(followButton)
            self.firstLoad = false
        } else {
            self.followButton.changeJourneyTo(journey: journey)
            self.followersBeats.text = "\(self.journey.numberOfFollowers) followers | \(self.journey.numberOfBeats) beats"
        }
    }
    
//    func followOrUnfollow() {
//        guard hasNetworkConnection(show: true) else { return }
//        if journey.isFollowed {
//            // call unfollow
//            self.followButton.isSelected = false
//            unfollowJourney(journeyId: journey.journeyId)
//            .onSuccess(callback: { (success) in
//                let realm = try! Realm()
//                try! realm.write {
//                    self.journey.isFollowed = false
//                }
//            }).onFailure(callback: { (error) in
//                Drop.down("Could not unfollow journey, try again later.", state: .error)
//                self.followButton.isSelected = true
//            })
//        } else {
//            // call follow
//            self.followButton.isSelected = true
//            followJourney(journeyId: journey.journeyId)
//            .onSuccess(callback: { (success) in
//                let realm = try! Realm()
//                try! realm.write {
//                    self.journey.isFollowed = true
//                }
//            }).onFailure(callback: { (error) in
//                // do nothing
//                Drop.down("Could not follow journey, try again later.", state: .error)
//                self.followButton.isSelected = false
//            })
//        }
//    }
    
    func downloadProfileImage(imageUrl: String) -> Future<UIImage, HikebeatError> {
        return Future { complete in
            imageActivity.startAnimating()
            self.profileImage.image = UIImage()
            downloadImage(imageUrl: imageUrl)
            .onSuccess { (image) in
                self.profileImage.image = image
                self.imageActivity.stopAnimating()
                complete(.success(image))
            }.onFailure { (error) in
                print("Error: ", error)
                self.profileImage.image = UIImage(named: "DefaultProfile")
                complete(.failure(error))
            }
        }
    }
}
