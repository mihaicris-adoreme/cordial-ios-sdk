//
//  CordialPushNotificationParser.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParser {
    
    private let deepLinksParser = CordialPushNotificationParserDeepLinks()
    private let messageAttributionParser = CordialPushNotificationParserMessageAttribution()
    private let inAppMessageParser = CordialPushNotificationParserInAppMessage()
    
    // MARK: Get deep link URL
    
    func getDeepLinkURL(userInfo: [AnyHashable : Any]) -> URL? {
        return self.deepLinksParser.getDeepLinkURLCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get deep link fallback URL
    
    func getDeepLinkFallbackURL(userInfo: [AnyHashable : Any]) -> URL? {
        return self.deepLinksParser.getDeepLinkFallbackURLCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get mcID
    
    func getMcID(userInfo: [AnyHashable : Any]) -> String? {
        return self.messageAttributionParser.getMcIdCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Is payload contain in app message
    
    func isPayloadContainIAM(userInfo: [AnyHashable : Any]) -> Bool {
        return self.inAppMessageParser.isPayloadContainIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message type
    
    func getTypeIAM(userInfo: [AnyHashable : Any]) -> String? {
        return self.inAppMessageParser.getTypeIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message display type
    
    func getDisplayTypeIAM(userInfo: [AnyHashable : Any]) -> String? {
        return self.inAppMessageParser.getDisplayTypeIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message inactive session display
    
    func getInactiveSessionDisplayIAM(userInfo: [AnyHashable : Any]) -> String? {
        return self.inAppMessageParser.getInactiveSessionDisplayIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message expiration time
    
    func getExpirationTimeIAM(userInfo: [AnyHashable : Any]) -> String? {        
        return self.inAppMessageParser.getExpirationTimeIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message banner height
    
    func getBannerHeightIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getBannerHeightIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message modal top margin
    
    func getModalTopMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalTopMarginIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message modal right margin
    
    func getModalRightMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalRightMarginIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message modal bottom margin
    
    func getModalBottomMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalBottomMarginIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message modal left margin
    
    func getModalLeftMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalLeftMarginIAMCurrentPayloadType(userInfo: userInfo)
    }

}

