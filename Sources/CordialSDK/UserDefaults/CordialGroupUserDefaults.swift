//
//  CordialGroupUserDefaults.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

struct CordialGroupUserDefaults {
    
    private static let cordialGroupUserDefaults = UserDefaults.init(suiteName: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)
    
    static func set(_ value: Any?, forKey key: String) {
        self.cordialGroupUserDefaults?.set(value, forKey: key)
    }
    
    static func dictionary(forKey key: String) -> [String : Any]? {
        return self.cordialGroupUserDefaults?.dictionary(forKey: key)
    }
    
    static func stringArray(forKey key: String) -> [String]? {
        return self.cordialGroupUserDefaults?.stringArray(forKey: key)
    }
    
    static func integer(forKey key: String) -> Int? {
        return self.cordialGroupUserDefaults?.integer(forKey: key)
    }
    
    static func removeObject(forKey key: String) {
        self.cordialGroupUserDefaults?.removeObject(forKey: key)
    }
    
}
