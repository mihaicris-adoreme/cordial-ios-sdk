//
//  CordialPushNotificationParserMessageAttribution.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParserMessageAttribution {
    
    // MARK: Get mcID
    
    func getMcIdCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let messageAttribution = system["messageAttribution"] as? [String: AnyObject],
            let mcID = messageAttribution["mcID"] as? String {
                return mcID
        }
        
        return nil
    }
    
}
