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

    static func set(_ value: Any?, forKey key: String) {
        self.cordialUserDefaults?.set(value, forKey: key)
    }
     
    static func object(forKey key: String) -> Any? {
        return cordialUserDefaults?.object(forKey: key)
    }
    
    static func integer(forKey key: String) -> Int? {
        return self.cordialUserDefaults?.integer(forKey: key)
    }
    
    static func string(forKey key: String) -> String? {
        return self.cordialUserDefaults?.string(forKey: key)
    }
    
    static func bool(forKey key: String) -> Bool? {
        return self.cordialUserDefaults?.bool(forKey: key)
    }
    
    static func double(forKey key: String) -> Double? {
        return self.cordialUserDefaults?.double(forKey: key)
    }
    
    static func removeObject(forKey key: String) {
        self.cordialUserDefaults?.removeObject(forKey: key)
    }
    
    static func deleteAll() {
        LoggerManager.shared.infoAdoreMe("Deleting all cordial user defaults")
        let dictionary = self.cordialUserDefaults?.dictionaryRepresentation()
        dictionary?.keys.forEach { key in
            self.removeObject(forKey: key)
        }
    }
}
