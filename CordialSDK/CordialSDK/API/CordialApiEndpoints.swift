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
    
    // MARK: Events Stream URLs
    
    private func getEventsStreamBaseURL() -> String {
        return self.cordialAPI.getBaseURL()
    }
    
    func getCustomEventsURL() -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/events"
    }
    
    func getContactsURL() -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/contacts"
    }
    
    func getContactLogoutURL() -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/contact/logout"
    }
    
    func getContactCartURL() -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/contact/cart"
    }
    
    func getOrdersURL() -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/orders"
    }
    
    func getSDKSecurityURL(secret: String) -> String {
        let baseURL = self.getEventsStreamBaseURL()
        
        return "\(baseURL)mobile/auth/\(secret)"
    }
    
    // MARK: Message Hub URLs
    
    private func getMessageHubBaseURL() -> String {
        let baseURL = self.cordialAPI.getBaseURL()
        
        return baseURL.replacingFirstOccurrence(of: "events-stream", with: "message-hub")
    }
    
    func getContactTimestampsURL(contactKey: String) -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(baseURL)timestamps/\(contactKey)/\(deviceID)"
    }
    
    func getInAppMessagesURL(contactKey: String) -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(baseURL)mobile/messages/\(contactKey)/\(deviceID)"
    }
    
    func getInAppMessageURL(mcID: String) -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        return "\(baseURL)mobile/message/\(mcID)"
    }
    
    func getInboxMessagesURL(contactKey: String) -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(baseURL)inbox/messages/\(contactKey)/\(deviceID)"
    }
    
    func getInboxMessagesMarkReadUnreadURL() -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        return "\(baseURL)inbox/read"
    }
    
    func getInboxMessageURL(contactKey: String, mcID: String) -> String {
        let baseURL = self.getMessageHubBaseURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(baseURL)inbox/message/\(contactKey)/\(deviceID)/\(mcID)"
    }
}
