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

class SearchJourneyCell: UITableViewCell {
    
    var profileImage: UIImageView!
    var headline: UILabel!
    var followersBeats: UILabel!
    var firstLoad = true
    var imageActivity: UIActivityIndicatorView!
    var followButton: UIButton!
    
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
            headline = UILabel(frame: CGRect(x: 80, y: 15, width: width-100, height: 25))
            headline.textColor = .white
            headline.adjustsFontSizeToFitWidth = true
            followersBeats = UILabel(frame: CGRect(x: 80, y: 40, width: width-100, height: 10))
            followersBeats.textColor = lightGreen
            followersBeats.font = UIFont.systemFont(ofSize: 13)
            followButton = UIButton(frame: CGRect(x: width-64, y: height/2-31/2, width: 31, height: 31))
            
            let followImage = UIImage(named: "follow_icon")
            let followingImage = UIImage(named: "following_icon")
            
            followButton.setImage(followImage, for: .normal)
            followButton.setImage(followingImage, for: .highlighted)
            
            self.addSubview(profileImage)
            self.addSubview(imageActivity)
            self.addSubview(headline)
            self.addSubview(followersBeats)
            self.addSubview(followButton)
            self.firstLoad = false
        }
    }
    
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
