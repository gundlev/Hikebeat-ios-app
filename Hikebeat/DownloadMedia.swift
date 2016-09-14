//
//  DownloadMedia.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 09/08/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Result
import BrightFutures
import Alamofire
import SwiftyJSON

func downloadMediaForJourney(journey: Journey) {
    let beats = journey.beats
    for beat in beats {
        if beat.mediaType != nil && beat.mediaData == nil {
            // The beat contains media but none has been downloaded. Download media
            
        }
    }
}
