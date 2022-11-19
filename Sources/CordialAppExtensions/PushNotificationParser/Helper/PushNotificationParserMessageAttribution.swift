//
//  PushNotificationParserMessageAttribution.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 19.11.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation

class PushNotificationParserMessageAttribution {
    
    // MARK: Get mcID
    
    func getMcIdCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let messageAttribution = system["messageAttribution"] as? [String: AnyObject],
            let mcID = messageAttribution["mcID"] as? String {
                return mcID
        }
        
        return nil
    }
    
    func getMcIdPreviousPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let mcID = userInfo["mcID"] as? String {
            return mcID
        }
        
        return nil
    }
    
}
