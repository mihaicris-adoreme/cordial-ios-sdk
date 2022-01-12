//
//  CordialPushNotificationParserInAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationParserInAppMessage {
    
    // MARK: Is payload contain in app message
    
    func isPayloadContainIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Bool {
        if let system = userInfo["system"] as? [String: AnyObject],
            let _ = system["iam"] as? [String: AnyObject] {
            return true
        }
        
        return false
    }
    
    // MARK: Get in app message type
    
    func getTypeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let typeIAM = InAppMessage().getTypeIAM(payload: iam) {
                return typeIAM
        }
        
        return nil
    }
    
    // MARK: Get in app message display type
    
    func getDisplayTypeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let displayTypeIAM = InAppMessage().getDisplayTypeIAM(payload: iam) {
                return displayTypeIAM
        }
        
        return nil
    }
    
    // MARK: Get in app message inactive session display
    
    func getInactiveSessionDisplayIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let inactiveSessionDisplayString = InAppMessage().getInactiveSessionDisplayIAM(payload: iam) {
                return inactiveSessionDisplayString
        }
        
        return nil
    }
    
    // MARK: Get in app message expiration time
    
    func getExpirationTimeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let expirationTime = InAppMessage().getExpirationTimeIAM(payload: iam) {
                return expirationTime
        }
        
        return nil
    }
    
    // MARK: Get in app message modal right margin
    
    func getModalRightMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let right = InAppMessage().getModalRightMarginIAM(payload: iam) {
                return right
        }
        
        return nil
    }
    
    // MARK: Get in app message modal left margin
    
    func getModalLeftMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let left = InAppMessage().getModalLeftMarginIAM(payload: iam) {
                return left
        }
        
        return nil
    }
}
