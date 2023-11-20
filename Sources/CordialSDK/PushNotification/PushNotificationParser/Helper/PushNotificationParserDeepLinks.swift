//
//  PushNotificationParserDeepLinks.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class PushNotificationParserDeepLinks {
    
    // MARK: Get deep link URL
    
    func getDeepLinkURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject],
            let deepLinkURLString = deepLinkJSON["url"] as? String,
            let deepLinkURL = URL(string: deepLinkURLString) {
                return deepLinkURL
        }
        
        return nil
    }
    
    // MARK: Get vanity deep link URL
    
    func getVanityDeepLinkURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject],
            let vanityDeepLinkURLString = deepLinkJSON["vanityUrl"] as? String,
            let vanityDeepLinkURL = URL(string: vanityDeepLinkURLString) {
                return vanityDeepLinkURL
        }
        
        return nil
    }
    
    // MARK: Get fallback deep link URL
    
    func getDeepLinkFallbackURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject],
            let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String,
            let fallbackURL = URL(string: fallbackURLString) {
                return fallbackURL
        }
        
        return nil
    }
    
}
