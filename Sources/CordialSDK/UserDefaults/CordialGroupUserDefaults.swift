//
//  CordialGroupUserDefaults.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

struct CordialGroupUserDefaults {
    
    private static let cordialUserDefaults = UserDefaults.init(suiteName: "group.cordial.sdk")
    
    static func stringArray(forKey key: String) -> [String]? {
        return self.cordialUserDefaults?.stringArray(forKey: key)
    }
    
}
