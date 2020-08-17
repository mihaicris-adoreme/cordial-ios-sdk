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
            let typeIAM = iam["type"] as? String {
                return typeIAM
        }
        
        return nil
    }
    
    // MARK: Get in app message display type
    
    func getDisplayTypeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let displayTypeIAM = iam["displayType"] as? String {
                return displayTypeIAM
        }
        
        return nil
    }
    
    // MARK: Get in app message inactive session display
    
    func getInactiveSessionDisplayIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let inactiveSessionDisplayString = iam["inactiveSessionDisplay"] as? String {
                return inactiveSessionDisplayString
        }
        
        return nil
    }
    
    // MARK: Get in app message expiration time
    
    func getExpirationTimeIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> String? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let expirationTime = iam["expirationTime"] as? String {
                return expirationTime
        }
        
        return nil
    }
    
    // MARK: Get in app message banner height
    
    func getBannerHeightIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let height = iam["height"] as? Int16 {
                return height
        }
        
        return nil
    }
    
    // MARK: Get in app message modal top margin
    
    func getModalTopMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let top = iam["top"] as? Int16 {
                return top
        }
        
        return nil
    }
    
    // MARK: Get in app message modal right margin
    
    func getModalRightMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let right = iam["right"] as? Int16 {
                return right
        }
        
        return nil
    }
    
    // MARK: Get in app message modal bottom margin
    
    func getModalBottomMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let bottom = iam["bottom"] as? Int16 {
                return bottom
        }
        
        return nil
    }
    
    // MARK: Get in app message modal left margin
    
    func getModalLeftMarginIAMCurrentPayloadType(userInfo: [AnyHashable : Any]) -> Int16? {
        if let system = userInfo["system"] as? [String: AnyObject],
            let iam = system["iam"] as? [String: AnyObject],
            let left = iam["left"] as? Int16 {
                return left
        }
        
        return nil
    }
}
