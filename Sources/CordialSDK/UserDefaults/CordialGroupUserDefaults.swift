//
//  CordialGroupUserDefaults.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

struct CordialGroupUserDefaults {
    
    private static let cordialUserDefaults = UserDefaults.init(suiteName: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)
    
    static func stringArray(forKey key: String) -> [String]? {
        return self.cordialUserDefaults?.stringArray(forKey: key)
    }
    
    static func integer(forKey key: String) -> Int? {
        return self.cordialUserDefaults?.integer(forKey: key)
    }
    
    static func removeObject(forKey key: String) {
        self.cordialUserDefaults?.removeObject(forKey: key)
    }
    
}
