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
    
    override func awakeFromNib() {
        if firstLoad {
            let width = UIScreen.main.bounds.width
            let height: CGFloat = 90
            self.backgroundColor = .clear
            profileImage = UIImageView(frame: CGRect(x: 15, y: 20, width: 50, height: 50))
            profileImage.layer.cornerRadius = profileImage.frame.width/2
            profileImage.layer.masksToBounds = true
            imageActivity = UIActivityIndicatorView(frame: CGRect(x: 15, y: 20, width: 50, height: 50))
            headline = UILabel(frame: CGRect(x: 80, y: 25, width: width-100, height: 25))
            headline.textColor = lightGreen
            headline.adjustsFontSizeToFitWidth = true
            followersBeats = UILabel(frame: CGRect(x: 80, y: 50, width: width-100, height: 10))
            followersBeats.textColor = .white
            followersBeats.font = UIFont.systemFont(ofSize: 13)
            self.addSubview(profileImage)
            self.addSubview(imageActivity)
            self.addSubview(headline)
            self.addSubview(followersBeats)
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
