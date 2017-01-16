//
//  SearchUserCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures

class SearchUserCell: UITableViewCell {
    
    var profileImage: UIImageView!
    var username: UILabel!
    var journeyIcon: UIImageView!
    var numberOfJourneys: UILabel!
    var followersBeats: UILabel!
    var firstLoad = true
    var imageActivity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        if firstLoad {
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 70
            self.backgroundColor = standardGreen
            profileImage = UIImageView(frame: CGRect(x: 20, y: 10, width: 50, height: 50))
            profileImage.layer.cornerRadius = profileImage.frame.width/2
            profileImage.layer.masksToBounds = true
            imageActivity = UIActivityIndicatorView(frame: CGRect(x: 20, y: 10, width: 50, height: 50))
            username = UILabel(frame: CGRect(x: 80, y: 15, width: width-160, height: 30))
            username.textColor = .white
            username.adjustsFontSizeToFitWidth = true
            journeyIcon = UIImageView(frame: CGRect(x: width-60, y: 15, width: 20, height: 25))
            journeyIcon.contentMode = .scaleAspectFit
            journeyIcon.image = UIImage(named: "tiny_backpack")
            numberOfJourneys = UILabel(frame: CGRect(x: width-100, y: 40, width: 100, height: 20))
            numberOfJourneys.textColor = .white
            numberOfJourneys.textAlignment = .center
            numberOfJourneys.font = UIFont.systemFont(ofSize: 13)
            followersBeats = UILabel(frame: CGRect(x: 80, y: 40, width: width-100, height: 10))
            followersBeats.textColor = .white
            followersBeats.font = UIFont.systemFont(ofSize: 13)
            self.addSubview(profileImage)
            self.addSubview(username)
            self.addSubview(imageActivity)
            self.addSubview(journeyIcon)
            self.addSubview(numberOfJourneys)
            self.firstLoad = false
        }
    }
    
    func downloadProfileImage(imageUrl: String) -> Future<UIImage, MediaDownloadError> {
        return Future { complete in
            imageActivity.startAnimating()
            self.profileImage.image = UIImage(named: "DefaultProfile")
            downloadImage(imageUrl: imageUrl)
                .onSuccess { (image) in
                    self.profileImage.image = image
                    self.imageActivity.stopAnimating()
                    complete(.success(image))
                }.onFailure { (error) in
                    print("Error: ", error)
                    complete(.failure(error))
            }
        }
    }
}
