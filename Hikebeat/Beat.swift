//
//  Beat.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Beat: Object {
    
    dynamic var title: String?
    dynamic var journeyId: String
    dynamic var message: String?
    dynamic var latitude: String
    dynamic var longitude: String
    dynamic var altitude: String
    dynamic var timestamp: String
    dynamic var mediaType: String?
    dynamic var mediaData: String?
    dynamic var mediaDataId: String?
    dynamic var messageId: String?
    dynamic var mediaUploaded: Bool = false
    dynamic var messageUploaded: Bool = false
    dynamic var journey: Journey?
    
    required init(
        title: String?,
        journeyId: String,
        message: String?,
        latitude: String,
        longitude: String,
        altitude: String,
        timestamp: String,
        mediaType: String?,
        mediaData: String?,
        mediaDataId: String?,
        messageId: String?,
        mediaUploaded: Bool,
        messageUploaded: Bool,
        journey: Journey) {
        
        self.title = title
        self.journeyId = journeyId
        self.message = message
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
        self.mediaType = mediaType
        self.mediaData = mediaData
        self.mediaDataId = mediaDataId
        self.messageId = messageId
        self.mediaUploaded = mediaUploaded
        self.messageUploaded = messageUploaded
        self.journey = journey
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }

}