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
    
    dynamic var slug: String?
    dynamic var userId: String
    dynamic var journeyId: String
    dynamic var headline: String?
    dynamic var journeyDescription: String?
    dynamic private var active: Bool
    dynamic var type: String
    var beats = List<Beat>()
    //dynamic var activeString: String
 
    required init(
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
