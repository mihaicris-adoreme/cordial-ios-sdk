//
//  PushNotificationParserInboxMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class PushNotificationParserInboxMessage {
    
    // MARK: Is payload contain inbox message
    
    func isPayloadContainInboxMessageCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Bool {
        if let system = userInfo["system"] as? [String: AnyObject],
            let _ = system["inbox"] as? [String: AnyObject] {
            return true
        }
        
        return false
    }
    
}
