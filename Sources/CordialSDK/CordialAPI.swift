//
//  CordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

@objcMembers public class CordialAPI: NSObject {
    
    // MARK: Get account key
    
    public func getAccountKey() -> String {
        return CordialApiConfiguration.shared.accountKey
    }
    
    // MARK: Get channel key
    
    public func getChannelKey() -> String {
        return CordialApiConfiguration.shared.channelKey
    }
    
    // MARK: Get events stream URL
    
    public func getEventsStreamURL() -> String {
        return CordialApiConfiguration.shared.eventsStreamURL
    }
    
    // MARK: Get message hub URL
    
    public func getMessageHubURL() -> String {
        return CordialApiConfiguration.shared.messageHubURL
    }
    
    // MARK: Get primary key
    
    public func getContactPrimaryKey() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Open deep link
    
    public func openDeepLink(url: URL) {
        CordialVanityDeepLink().open(url: url)
    }
    
    // MARK: Get current mcID
    
    public func getCurrentMcID() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: Set current mcID
    
    public func setCurrentMcID(mcID: String) {
        InternalCordialAPI().savePreviousMcID()
        
        CordialUserDefaults.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        CordialUserDefaults.set(CordialDateFormatter().getCurrentTimestamp(), forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Set Contact
    
    public func setContact(primaryKey: String?) {
        let internalCordialAPI = InternalCordialAPI()
        
        let previousPrimaryKey = self.getContactPrimaryKey()
        
        internalCordialAPI.setPreviousContactPrimaryKey(previousPrimaryKey: previousPrimaryKey)
        
        CoreDataManager.shared.contactLogoutRequest.deleteAllContactLogoutRequests()
        
        internalCordialAPI.removeContactTimestampAndTheLatestSentAtInAppMessageDate()
        
        let token = internalCordialAPI.getPushNotificationToken()
        let status = internalCordialAPI.getPushNotificationStatus()
        
        let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
    }
    
    // MARK: Unset Contact
    
    public func unsetContact() {
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            CordialUserDefaults.set(false, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
            
            internalCordialAPI.removeContactTimestampAndTheLatestSentAtInAppMessageDate()
            
            let previousPrimaryKey = self.getContactPrimaryKey()
            
            let sendContactLogoutRequest = SendContactLogoutRequest(primaryKey: previousPrimaryKey)
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            
            internalCordialAPI.setPreviousContactPrimaryKey(previousPrimaryKey: previousPrimaryKey)
        } else {
            LoggerManager.shared.error(message: "Sending contact logout failed. Error: [User no login]", category: "CordialSDKPushNotification")
        }
    }
    
    // MARK: Upsert Contact
    
    public func upsertContact(attributes: Dictionary<String, AttributeValue>?) -> Void {
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPushNotificationToken()
        let status = internalCordialAPI.getPushNotificationStatus()
        
        if let primaryKey = self.getContactPrimaryKey() {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: attributes)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        } else {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: nil, status: status, attributes: attributes)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])

        }
    }
    
    // MARK: Send Custom Event
        
    public func sendCustomEvent(eventName: String, properties: Dictionary<String, Any>?) {
        let mcID = self.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: properties)
        
        let customEventsSender = CustomEventsSender()
        
        if customEventsSender.isEventNameHaveSystemPrefix(sendCustomEventRequest: sendCustomEventRequest) {
            let responseError = ResponseError(message: "Event name has system prefix", statusCode: nil, responseBody: nil, systemError: nil)
            customEventsSender.logicErrorHandler(sendCustomEventRequests: [sendCustomEventRequest], error: responseError)
        } else {
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Flush Custom Events
    
    public func flushEvents() {
        ThrottlerManager.shared.sendCustomEventRequest.throttle {
            CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "App requested")
        }
    }
    
    // MARK: Upsert Contact Cart
    
    public func upsertContactCart(cartItems: [CartItem]) {
        let upsertContactCartRequest = UpsertContactCartRequest(cartItems: cartItems)
        ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
    }
    
    // MARK: Send Order
    
    public func sendContactOrder(order: Order) {
        let mcID = self.getCurrentMcID()
        let sendContactOrderRequest = SendContactOrderRequest(mcID: mcID, order: order)
        ContactOrdersSender().sendContactOrders(sendContactOrderRequests: [sendContactOrderRequest])
    }
    
    // MARK: Register for push notifications
    
    public func registerForPushNotifications(options: UNAuthorizationOptions, isEducational: Bool) {
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            if !InternalCordialAPI().getPushNotificationCategories().isEmpty && !options.contains(.providesAppNotificationSettings) {
                let newOptions = options.union([.providesAppNotificationSettings])
                CordialPushNotification.shared.providesAppNotificationSettings(options: newOptions, isEducational: isEducational)
            } else {
                CordialPushNotification.shared.registerForPushNotifications(options: options)
            }
        } else {
            LoggerManager.shared.info(message: "Register for push notifications failed: pushesConfiguration not equals to SDK value", category: "CordialSDKPushNotification")
        }
    }
    
    public func registerForPushNotifications(options: UNAuthorizationOptions) {
        self.registerForPushNotifications(options: options, isEducational: false)
    }

    public func registerForPushNotifications(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            CordialPushNotification.shared.registerForPushNotifications(options: options, completionHandler: completionHandler)
        } else {
            LoggerManager.shared.info(message: "Register for push notifications failed: pushesConfiguration not equals to SDK value", category: "CordialSDKPushNotification")
        }
    }
}

