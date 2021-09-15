//
//  CordialApiEndpoints.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/11/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialApiEndpoints {
        
    // MARK: Events Stream URLs
    
    func getCustomEventsURL() -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/events"
    }
    
    func getContactsURL() -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/contacts"
    }
    
    func getContactLogoutURL() -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/contact/logout"
    }
    
    func getContactCartURL() -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/contact/cart"
    }
    
    func getOrdersURL() -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/orders"
    }
    
    func getSDKSecurityURL(secret: String) -> String {
        let eventsStreamURL = CordialAPI().getEventsStreamURL()
        
        return "\(eventsStreamURL)mobile/auth/\(secret)"
    }
    
    // MARK: Message Hub URLs
    
    func getContactTimestampsURL(contactKey: String) -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(messageHubURL)timestamps/\(contactKey)/\(deviceID)"
    }
    
    func getInAppMessagesURL(contactKey: String) -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(messageHubURL)mobile/messages/\(contactKey)/\(deviceID)"
    }
    
    func getInAppMessageURL(mcID: String) -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        return "\(messageHubURL)mobile/message/\(mcID)"
    }
    
    func getInboxMessagesURL(contactKey: String) -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(messageHubURL)inbox/messages/\(contactKey)/\(deviceID)"
    }
    
    func getInboxMessagesMarkReadUnreadURL() -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        return "\(messageHubURL)inbox/read"
    }
    
    func getInboxMessageURL(contactKey: String, mcID: String) -> String {
        let messageHubURL = CordialAPI().getMessageHubURL()
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        
        return "\(messageHubURL)inbox/message/\(contactKey)/\(deviceID)/\(mcID)"
    }
}
