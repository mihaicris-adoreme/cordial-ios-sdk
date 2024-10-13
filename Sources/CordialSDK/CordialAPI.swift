//
//  CordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

@objc public class CordialAPI: NSObject {
    
    // MARK: Get account key
    
    @objc public func getAccountKey() -> String {
        return CordialApiConfiguration.shared.accountKey
    }
    
    // MARK: Get channel key
    
    @objc public func getChannelKey() -> String {
        return CordialApiConfiguration.shared.channelKey
    }
    
    // MARK: Get events stream URL
    
    @objc public func getEventsStreamURL() -> String {
        return CordialApiConfiguration.shared.eventsStreamURL
    }
    
    // MARK: Get message hub URL
    
    @objc public func getMessageHubURL() -> String {        
        return CordialApiConfiguration.shared.messageHubURL
    }
    
    // MARK: Get primary key
    
    @objc public func getContactPrimaryKey() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Open deep link
    
    @objc public func openDeepLink(url: URL) {
        CordialVanityDeepLink().open(url: url)
    }
    
    // MARK: Get current mcID
    
    @objc public func getCurrentMcID() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: Set current mcID
    
    @objc public func setCurrentMcID(mcID: String) {
        InternalCordialAPI().savePreviousMcID()
        
        CordialUserDefaults.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        CordialUserDefaults.set(CordialDateFormatter().getCurrentTimestamp(), forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Set Contact
    
    @objc public func setContact(primaryKey: String?) {
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
    
    @objc public func unsetContact() {
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
    
    @objc public func upsertContact(attributes: Dictionary<String, AttributeValue>?) -> Void {
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPushNotificationToken()
        let status = internalCordialAPI.getPushNotificationStatus()
        
        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): self.getContactPrimaryKey(): \(self.getContactPrimaryKey() ?? "nil")",
            category: "CordialSDKAddedByAdoreMe"
        )

        if let primaryKey = self.getContactPrimaryKey() {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: attributes)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        } else {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: nil, status: status, attributes: attributes)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])

        }
    }
    
    // MARK: Send Custom Event
        
    @objc public func sendCustomEvent(eventName: String, properties: Dictionary<String, Any>?) {
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
    
    @objc public func flushEvents() {
        ThrottlerManager.shared.sendCustomEventRequest.throttle {
            CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "App requested")
        }
    }
    
    // MARK: Upsert Contact Cart
    
    @objc public func upsertContactCart(cartItems: [CartItem]) {
        let upsertContactCartRequest = UpsertContactCartRequest(cartItems: cartItems)
        ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
    }
    
    // MARK: Send Order
    
    @objc public func sendContactOrder(order: Order) {
        let mcID = self.getCurrentMcID()
        let sendContactOrderRequest = SendContactOrderRequest(mcID: mcID, order: order)
        ContactOrdersSender().sendContactOrders(sendContactOrderRequests: [sendContactOrderRequest])
    }
    
    // MARK: Register for push notifications
    
    @objc public func registerForPushNotifications(options: UNAuthorizationOptions, isEducational: Bool) {
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
    
    @objc public func registerForPushNotifications(options: UNAuthorizationOptions) {
        self.registerForPushNotifications(options: options, isEducational: false)
    }
}

