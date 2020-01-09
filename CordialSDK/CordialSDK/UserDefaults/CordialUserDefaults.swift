//
//  CordialUserDefaults.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.01.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

struct CordialUserDefaults {
    
    private static let cordialUserDefaults = UserDefaults.init(suiteName: "io.cordial.sdk.UserDefaults")

    static func set(_ value: String, forKey key: String) {
        cordialUserDefaults?.set(value, forKey: key)
    }
    
    static func set(_ value: Bool, forKey key: String) {
        cordialUserDefaults?.set(value, forKey: key)
    }
    
    static func set(_ value: Double, forKey key: String) {
        cordialUserDefaults?.set(value, forKey: key)
    }
    
    static func removeObject(forKey key: String) {
        cordialUserDefaults?.removeObject(forKey: key)
    }
    
    static func string(forKey key: String) -> String? {
        return cordialUserDefaults?.string(forKey: key)
    }
    
    static func bool(forKey key: String) -> Bool? {
        return cordialUserDefaults?.bool(forKey: key)
    }
    
    static func double(forKey key: String) -> Double? {
        return cordialUserDefaults?.double(forKey: key)
    }
}
