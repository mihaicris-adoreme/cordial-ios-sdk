//
//  CordialPushNotificationParserDeepLinks.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialPushNotificationParserDeepLinks {
    
    // MARK: Get deep link URL
    
    func getDeepLinkURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSON = system["deepLink"] as? [String: AnyObject],
            let deepLinkURLString = deepLinkJSON["url"] as? String,
            let deepLinkURL = URL(string: deepLinkURLString) {
                return deepLinkURL
        } else if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSONString = system["deepLink"] as? String,
            let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
                do {
                    if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject],
                        let deepLinkURLString = deepLinkJSON["url"] as? String {
                            let deepLinkURL = URL(string: deepLinkURLString)
                            
                            return deepLinkURL
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
                    }
                }
        }
        
        return nil
    }
    
    func getDeepLinkURLPreviousPayloadType(userInfo: [AnyHashable : Any]) -> URL?  {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject],
            let deepLinkURLString = deepLinkJSON["url"] as? String,
            let deepLinkURL = URL(string: deepLinkURLString) {
                return deepLinkURL
        } else if let deepLinkJSONString = userInfo["deepLink"] as? String,
            let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
                do {
                    if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject],
                        let deepLinkURLString = deepLinkJSON["url"] as? String {
                            let deepLinkURL = URL(string: deepLinkURLString)
                            
                            return deepLinkURL
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
                    }
                }
        }
        
        return nil
    }
    
    // MARK: Get deep link encoded URL
    
    func getDeepLinkEncodedURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSON = system["deepLink"] as? [String: AnyObject],
            let encodedDeepLinkURLString = deepLinkJSON["encodedUrl"] as? String,
            let encodedDeepLinkURL = URL(string: encodedDeepLinkURLString) {
                return encodedDeepLinkURL
        } else if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSONString = system["deepLink"] as? String,
            let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
                do {
                    if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject],
                        let encodedDeepLinkURLString = deepLinkJSON["encodedUrl"] as? String {
                            let encodedDeepLinkURL = URL(string: encodedDeepLinkURLString)
                            
                            return encodedDeepLinkURL
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
                    }
                }
        }
        
        return nil
    }
    
    // MARK: Get fallback deep link URL
    
    func getDeepLinkFallbackURLCurrentPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSON = system["deepLink"] as? [String: AnyObject],
            let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String,
            let fallbackURL = URL(string: fallbackURLString) {
                return fallbackURL
        } else if let system = userInfo["system"] as? [String: AnyObject],
            let deepLinkJSONString = system["deepLink"] as? String,
            let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
                do {
                    if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject],
                        let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String {
                            let fallbackURL = URL(string: fallbackURLString)
                            
                            return fallbackURL
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
                    }
                }
        }
        
        return nil
    }
    
    func getDeepLinkFallbackURLPreviousPayloadType(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject],
            let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String,
            let fallbackURL = URL(string: fallbackURLString) {
                return fallbackURL
        } else if let deepLinkJSONString = userInfo["deepLink"] as? String,
            let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
                do {
                    if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject],
                        let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String {
                            let fallbackURL = URL(string: fallbackURLString)
                            
                            return fallbackURL
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
                    }
                }
        }
        
        return nil
    }
    
}
