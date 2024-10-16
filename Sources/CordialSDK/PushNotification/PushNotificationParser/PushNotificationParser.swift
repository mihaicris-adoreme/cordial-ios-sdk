//
//  PushNotificationParser.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class PushNotificationParser {
    
    private let deepLinksParser = PushNotificationParserDeepLinks()
    private let messageAttributionParser = PushNotificationParserMessageAttribution()
    private let inAppMessageParser = PushNotificationParserInAppMessage()
    private let inboxMessageParser = PushNotificationParserInboxMessage()
    private let carouselParser = PushNotificationParserCarousel()
    
    // MARK: Get payload JSON
    
    func getPayloadJSON(userInfo: [AnyHashable : Any]) -> String {
        var payload = userInfo.description
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
           let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? Dictionary<String, Any> {
            
            payload = API.getDictionaryJSON(dictionary)
        }
        
        return payload
    }
    
    // MARK: Get deep link URL
    
    func getDeepLinkURL(userInfo: [AnyHashable : Any]) -> URL? {
        return self.deepLinksParser.getDeepLinkURLCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get vanity deep link URL
    
    func getVanityDeepLinkURL(userInfo: [AnyHashable : Any]) -> URL? {
        return self.deepLinksParser.getVanityDeepLinkURLCurrentPayloadType(userInfo: userInfo)
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
    
    // MARK: Get in app message modal right margin
    
    func getModalRightMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalRightMarginIAMCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get in app message modal left margin
    
    func getModalLeftMarginIAM(userInfo: [AnyHashable : Any]) -> Int16? {
        return self.inAppMessageParser.getModalLeftMarginIAMCurrentPayloadType(userInfo: userInfo)
    }

    // MARK: Is payload contain inbox message
    
    func isPayloadContainInboxMessage(userInfo: [AnyHashable : Any]) -> Bool {
        return self.inboxMessageParser.isPayloadContainInboxMessageCurrentPayloadType(userInfo: userInfo)
    }
    
    // MARK: Get push notification carousels
    
    func getPushNotificationCarousels(userInfo: [AnyHashable : Any]) -> [PushNotificationCarousel] {
        return self.carouselParser.getPushNotificationCarouselsCurrentPayloadType(userInfo: userInfo)
    }
}

