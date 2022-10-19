//
//  CarouselGroupUserDefaults.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 28.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

struct CarouselGroupUserDefaults {
    
    private static let carouselGroupUserDefaults = UserDefaults.init(suiteName: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)

    static func set(_ value: Any?, forKey key: String) {
        self.carouselGroupUserDefaults?.set(value, forKey: key)
    }

}
