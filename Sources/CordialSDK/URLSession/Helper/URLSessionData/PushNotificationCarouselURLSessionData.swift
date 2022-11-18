//
//  PushNotificationCarouselURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 16.11.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

class PushNotificationCarouselURLSessionData {
    
    let mcID: String
    let carousel: PushNotificationCarousel
    
    init(mcID: String, carousel: PushNotificationCarousel) {
        self.mcID = mcID
        self.carousel = carousel
    }
    
}
