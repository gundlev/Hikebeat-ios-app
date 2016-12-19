//
//  User.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation

class User: Any {
    var id: String
    var username: String
    var numberOfJourneys: String
    var numberOfBeats: String
    var numberOfFollowers: String
    var numberOfFollowing: String
    var profilePhoto: UIImage
    
    init(id: String,
        username: String,
        numberOfJourneys: String,
        numberOfBeats: String,
        numberOfFollowers: String,
        numberOfFollowing: String,
        profilePhoto: UIImage) {
        self.id = id
        self.username = username
        self.numberOfBeats = numberOfBeats
        self.numberOfJourneys = numberOfJourneys
        self.numberOfFollowers = numberOfFollowers
        self.numberOfFollowing = numberOfFollowing
        self.profilePhoto = profilePhoto
    }
}
