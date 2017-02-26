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

class Change: Object, Comparable {
    
    dynamic var timeCommitted: String = ""
    dynamic var changeType: String?
    var values = List<Pair>()
    
    func fill(
        _ changeType: ChangeType,
        values: Pair...) {
        
        self.timeCommitted = getTimeCommitted()
        self.changeType = changeType.rawValue
        for pair in values {
            self.values.append(pair)
        }
    }
}

func createSimpleChange(type: ChangeType, key: String, value: String?, valueBool: Bool?) -> Change {
    let change = Change()
    let pair = Pair()
    pair.fill(key: key, value: value, valueBool: valueBool, valuePair: nil)
    change.fill(type, values: pair)
    return change
}

func saveChange(change: Change) {
    let realm = try! Realm()
    guard shouldNotBeDouplicate(change: change) else {
        try! realm.write {
//            if change.values != nil {
//                realm.add(change.values!)
//            }
            realm.add(change)
        }
        return
    }
    let changes = realm.objects(Change.self).filter(NSPredicate(format: "changeType == %@", change.changeType!))
    if !changes.isEmpty {
        let oldChange = changes[0]
        try! realm.write {
            realm.delete(oldChange)
            realm.add(change)
        }
    } else {
        try! realm.write {
            realm.add(change)
        }
    }
}

func shouldNotBeDouplicate(change: Change) -> Bool {
    guard change.changeType != ChangeType.deleteJourney.rawValue else {return false}
    guard change.changeType != ChangeType.deleteBeat.rawValue else {return false}
    return true
}

func getTimeCommitted() -> String {
    let t = String(Date().timeIntervalSince1970)
    let e = t.range(of: ".")
    let timestamp = t.substring(to: (e?.lowerBound)!)
    return timestamp
}

enum ChangeType: String {
    case profileImage
    case name
    case permittedPhoneNumber
    case deleteJourney
    case deleteBeat
    case notifications
}

func <(lhs: Change, rhs: Change) -> Bool {
    return lhs.timeCommitted < rhs.timeCommitted
}

func ==(lhs: Change, rhs: Change) -> Bool {
    return lhs.timeCommitted == rhs.timeCommitted
}

