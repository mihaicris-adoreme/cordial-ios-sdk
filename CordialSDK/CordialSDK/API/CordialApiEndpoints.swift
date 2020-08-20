//
//  CordialApiEndpoints.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/11/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialApiEndpoints {
    
    let cordialAPI = CordialAPI()
    
    func getCustomEventsURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/events"
    }
    
    func getContactsURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contacts"
    }
    
    func getContactLogoutURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contact/logout"
    }
    
    func getContactCartURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/contact/cart"
    }
    
    func getOrdersURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/orders"
    }
    
    func getInAppMessageURL(mcID: String) -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        let replacedBaseURL = baseURL.replacingFirstOccurrence(of: "events-stream", with: "message-hub")
        
        return "\(replacedBaseURL)mobile/message/\(mcID)"
    }
    
    func getSDKSecurityURL(secret: String) -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return "\(baseURL)mobile/auth/\(secret)"
    }
    
    func getInboxMessagesURL(primaryKey: String) -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        let deviceId = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(baseURL)inbox/messages/\(primaryKey)/\(deviceId)"
    }
}
