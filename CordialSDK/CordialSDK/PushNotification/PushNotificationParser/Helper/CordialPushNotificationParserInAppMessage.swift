//
//  CordialPushNotificationParserInAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParserInAppMessage {
    
    // MARK: Get in app message type
    
    func getTypeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject], let typeIAM = system["type"] as? String {
            return typeIAM
        }
        
        return nil
    }
    
    func getTypeIAMPreviousPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let typeIAM = userInfo["type"] as? String {
            return typeIAM
        }
        
        return nil
    }
    
    // MARK: Get in app message display type
    
    func getDisplayTypeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject], let displayTypeIAM = system["displayType"] as? String {
            return displayTypeIAM
        }
        
        return nil
    }
    
    func getDisplayTypeIAMPreviousPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let displayTypeIAM = userInfo["displayType"] as? String {
            return displayTypeIAM
        }
        
        return nil
    }
}
