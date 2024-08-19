//
//  CordialInitUserDefaults.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.08.2024.
//  Copyright © 2024 cordial.io. All rights reserved.
//

import Foundation

struct CordialInitUserDefaults {

    private static let cordialInitUserDefaults = UserDefaults.init(suiteName: "io.cordial.sdk.init.UserDefaults")

    static func set(_ value: Any?, forKey key: String) {
        self.cordialInitUserDefaults?.set(value, forKey: key)
    }

    static func string(forKey key: String) -> String? {
        return self.cordialInitUserDefaults?.string(forKey: key)
    }
}
