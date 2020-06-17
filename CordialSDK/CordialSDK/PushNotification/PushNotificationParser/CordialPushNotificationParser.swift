//
//  CordialPushNotificationParser.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParser {
    
    let deepLinksParser = CordialPushNotificationParserDeepLinks()
    
    func getDeepLinkURL(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkURL = self.deepLinksParser.getDeepLinkURLCurrentPayloadType(userInfo: userInfo) {
            return deepLinkURL
        }
        
        return self.deepLinksParser.getDeepLinkURLPreviousPayloadType(userInfo: userInfo)
    }
    
    func getDeepLinkFallbackURL(userInfo: [AnyHashable : Any]) -> URL? {
        if let fallbackURL = self.deepLinksParser.getDeepLinkFallbackURLCurrentPayloadType(userInfo: userInfo) {
            return fallbackURL
        }
        
        return self.deepLinksParser.getDeepLinkFallbackURLPreviousPayloadType(userInfo: userInfo)
    }
    
}

