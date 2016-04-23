//
//  Change.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 18/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Change: Object {
    
    dynamic var instanceType: String = ""
    dynamic var timeCommitted: String = ""
    dynamic var stringValue: String? = nil
    dynamic var boolValue: Bool = false
    dynamic var property: String? = nil
    dynamic var instanceId: String? = nil
    dynamic var changeAction: String = ""
    dynamic var timestamp: String? = nil
    
    func fill(
        instanceType: String,
        timeCommitted: String,
        stringValue: String?,
        boolValue: Bool,
        property: String?,
        instanceId: String?,
        changeAction: String,
        timestamp: String?) {
        
        self.instanceType = instanceType
        self.timeCommitted = timeCommitted
        self.stringValue = stringValue
        self.boolValue = boolValue
        self.property = property
        self.instanceId = instanceId
        self.changeAction = changeAction
        self.timestamp = timestamp

    }
    
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