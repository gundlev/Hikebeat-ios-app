//
//  Journey.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Journey: Object {
    
    dynamic var slug: String? = nil
    dynamic var userId: String = ""
    dynamic var journeyId: String = ""
    dynamic var headline: String? = nil
    dynamic var journeyDescription: String?
    dynamic private var active: Bool = false
    dynamic var type: String? = nil
    var beats = List<Beat>()
    
    
    func fill(
    slug: String?,
    userId: String,
    journeyId: String,
    headline: String?,
    journeyDescription: String?,
    active: Bool,
    type: String) {
    
        self.slug = slug
        self.userId = userId
        self.journeyId = journeyId
        self.headline = headline
        self.journeyDescription = journeyDescription
        self.active = active
        self.type = type
    }
    //dynamic var activeString: String
 
//    required init(
//        slug: String?,
//        userId: String,
//        journeyId: String,
//        headline: String?,
//        journeyDescription: String?,
//        active: Bool,
//        type: String) {
//        
//        self.slug = slug
//        self.userId = userId
//        self.journeyId = journeyId
//        self.headline = headline
//        self.journeyDescription = journeyDescription
//        self.active = active
//        self.type = type
//        
//        super.init()
//    }
//    
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        super.init()
//    }
//    
//    required init(value: AnyObject, schema: RLMSchema) {
//        super.init()
//    }
//    
//    required init() {
//        super.init()
//    }
}
