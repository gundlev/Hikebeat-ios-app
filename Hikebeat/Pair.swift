//
//  Pair.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 23/02/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Pair: Object {
    dynamic var key: String?
    dynamic var value: String?
    dynamic var valueBool: Bool = false
    dynamic var valuePair: Pair?
//    dynamic var change: Change?
    
    func fill(key: String, value: String?, valueBool: Bool?, valuePair: Pair?) {
        self.key = key
        self.value = value
        self.valuePair = valuePair
        if valueBool != nil {
            self.valueBool = valueBool!
        }
//        self.change = change
    }
}
