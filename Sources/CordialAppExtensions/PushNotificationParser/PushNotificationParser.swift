//
//  PushNotificationParser.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 19.11.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation

class PushNotificationParser {
    
    private let messageAttributionParser = PushNotificationParserMessageAttribution()
    private let carouselParser = PushNotificationParserCarousel()
    
    // MARK: Get mcID
    
    func getMcID(userInfo: [AnyHashable : Any]) -> String? {
        if let mcID = self.messageAttributionParser.getMcIdCurrentPayloadType(userInfo: userInfo) {
            return mcID
        }
        
        return self.messageAttributionParser.getMcIdPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get push notification carousels
    
    func getPushNotificationCarousels(userInfo: [AnyHashable : Any]) -> [PushNotificationCarousel] {
        return self.carouselParser.getPushNotificationCarouselsCurrentPayloadType(userInfo: userInfo)
    }
}

