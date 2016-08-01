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

class Beat: Object, Comparable {
    
    dynamic var emotion: String? = nil
    dynamic var journeyId: String = ""
    dynamic var message: String? = nil
    dynamic var latitude: String = ""
    dynamic var longitude: String = ""
    dynamic var altitude: String = ""
    dynamic var timestamp: String = ""
    dynamic var mediaType: String? = nil
    dynamic var mediaData: String? = nil
    dynamic var mediaDataId: String? = nil
    dynamic var messageId: String? = nil
    dynamic var mediaUploaded: Bool = false
    dynamic var messageUploaded: Bool = false
    dynamic var journey:Journey? = nil
    dynamic var isTextMessage: Bool = false
    
    func fill(
        emotion: String?,
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
        
        self.emotion = emotion
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
    }
    
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        print("1")
//        super.init()
//    }
//    
//    required init(value: AnyObject, schema: RLMSchema) {
//        print("2")
//        super.init()
//    }
//    
//    required init() {
//        print("init 3")
//        super.init()
//    }

}

func <(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

func ==(lhs: Beat, rhs: Beat) -> Bool {
    return lhs.timestamp == rhs.timestamp
}