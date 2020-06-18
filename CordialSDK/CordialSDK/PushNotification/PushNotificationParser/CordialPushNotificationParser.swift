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
        if let deepLinkURL = self.deepLinksParser.getDeepLinkURLCurrentPayloadType(userInfo: userInfo) {
            return deepLinkURL
        }
        
        return self.deepLinksParser.getDeepLinkURLPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get deep link fallback URL
    
    func getDeepLinkFallbackURL(userInfo: [AnyHashable : Any]) -> URL? {
        if let fallbackURL = self.deepLinksParser.getDeepLinkFallbackURLCurrentPayloadType(userInfo: userInfo) {
            return fallbackURL
        }
        
        return self.deepLinksParser.getDeepLinkFallbackURLPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get mcID
    
    func getMcID(userInfo: [AnyHashable : Any]) -> String? {
        if let mcID = self.messageAttributionParser.getMcIdCurrentPayloadType(userInfo: userInfo) {
            return mcID
        }
        
        return self.messageAttributionParser.getMcIdPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: is payload contain in app message
    
    func isPayloadContainIAM(userInfo: [AnyHashable : Any]) -> Bool {
        return self.inAppMessageParser.isPayloadContainIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message type
    
    func getTypeIAM(userInfo: [AnyHashable : Any]) -> String? {
        if let typeIAM = self.inAppMessageParser.getTypeIAMCurrentPayloadType(userInfo: userInfo) {
            return typeIAM
        }
        
        return self.inAppMessageParser.getTypeIAMPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message display type
    
    func getDisplayTypeIAM(userInfo: [AnyHashable : Any]) -> String? {
        if let displayTypeIAM = self.inAppMessageParser.getDisplayTypeIAMCurrentPayloadType(userInfo: userInfo) {
            return displayTypeIAM
        }
        
        return self.inAppMessageParser.getDisplayTypeIAMPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message inactive session display
    
    func getInactiveSessionDisplayIAM(userInfo: [AnyHashable : Any]) -> String? {
        if let inactiveSessionDisplayIAM = self.inAppMessageParser.getInactiveSessionDisplayIAMCurrentPayloadType(userInfo: userInfo) {
            return inactiveSessionDisplayIAM
        }
        
        return self.inAppMessageParser.getInactiveSessionDisplayIAMPreviousPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message expiration time
    
    func getExpirationTimeIAM(userInfo: [AnyHashable : Any]) -> String? {
        if let expirationTimeIAM = self.inAppMessageParser.getExpirationTimeIAMCurrentPayloadType(userInfo: userInfo) {
            return expirationTimeIAM
        }
        
        return self.inAppMessageParser.getExpirationTimeIAMPreviousPayloadType(userInfo: userInfo)
    }
}

