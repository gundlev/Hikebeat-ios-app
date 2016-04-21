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
    
    dynamic var instanceType: String
    dynamic var timeCommitted: String
    dynamic var stringValue: String?
    dynamic var boolValue: Bool
    dynamic var property: String?
    dynamic var instanceId: String?
    dynamic var changeAction: String
    dynamic var timestamp: String?
    
    required init(
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
        
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        //fatalError("init(realm:schema:) has not been implemented")
        self.instanceType = ""
        self.timeCommitted = ""
        self.stringValue = ""
        self.boolValue = false
        self.property = ""
        self.instanceId = ""
        self.changeAction = ""
        self.timestamp = ""
        super.init()
    }
    
    required init(value: AnyObject, schema: RLMSchema) {
        //fatalError("init(value:schema:) has not been implemented")
        self.instanceType = ""
        self.timeCommitted = ""
        self.stringValue = ""
        self.boolValue = false
        self.property = ""
        self.instanceId = ""
        self.changeAction = ""
        self.timestamp = ""
        super.init()
    }
    
    required init() {
        //fatalError("init() has not been implemented")
        self.instanceType = ""
        self.timeCommitted = ""
        self.stringValue = ""
        self.boolValue = false
        self.property = ""
        self.instanceId = ""
        self.changeAction = ""
        self.timestamp = ""
        super.init()
    }

}