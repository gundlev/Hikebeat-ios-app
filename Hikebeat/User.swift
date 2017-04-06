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
    var followerCount: String
    var followsCount: String
    var profilePhoto: UIImage?
    var profilePhotoUrl: String
    var latestBeat: Date?
    var visitedCountries: Dictionary<String,Int>
    var mostVisitedCountry: String
    
    init(id: String,
        username: String,
        numberOfJourneys: String,
        numberOfBeats: String,
        followerCount: String,
        followsCount: String,
        profilePhotoUrl: String,
        latestBeat: Date?,
        visitedCountries: Dictionary<String,Int>,
        mostVisitedCountry: String) {
        self.id = id
        self.username = username
        self.numberOfBeats = numberOfBeats
        self.numberOfJourneys = numberOfJourneys
        self.followerCount = followerCount
        self.followsCount = followsCount
        self.profilePhotoUrl = profilePhotoUrl
        self.latestBeat = latestBeat
        self.visitedCountries = visitedCountries
        self.mostVisitedCountry = mostVisitedCountry
    }
}
