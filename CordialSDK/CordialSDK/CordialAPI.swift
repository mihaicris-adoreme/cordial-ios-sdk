//
//  CordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objc public class CordialAPI: NSObject {
    
    // MARK: Get account key
    
    @objc public func getAccountKey() -> String {
        if let accountKey = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY) {
            return accountKey
        }
        
        return CordialApiConfiguration.shared.accountKey
    }
    
    // MARK: Set account key
    
    @objc public func setAccountKey(accountKey: String) {
        if accountKey != self.getAccountKey() {
            CordialUserDefaults.set(accountKey, forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY)
        }
    }
    
    // MARK: Get channel key
    
    @objc public func getChannelKey() -> String {
        if let channelKey = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY) {
            return channelKey
        }
        
        return CordialApiConfiguration.shared.channelKey
    }
    
    // MARK: Set channel key
    
    @objc public func setChannelKey(channelKey: String) {
        if channelKey != self.getChannelKey() {
            CordialUserDefaults.set(channelKey, forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY)
        }
    }
    
    // MARK: Get base URL
    
    @objc public func getBaseURL() -> String {
        if let baseURL = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL) {
            return baseURL
        }
        
        return CordialApiConfiguration.shared.baseURL
    }
    
    // MARK: Set base URL
    
    @objc public func setBaseURL(baseURL: String) {
        if baseURL != self.getBaseURL() {
            if baseURL.last != "/" {
                CordialUserDefaults.set("\(baseURL)/", forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
            } else {
                CordialUserDefaults.set(baseURL, forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
            }
        }
    }
    
    // MARK: Get primary key
    
    @objc public func getContactPrimaryKey() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Global alert
    
    @objc public func showSystemAlert(title: String, message: String?) {
        DispatchQueue.main.async {
            if let currentVC = InternalCordialAPI().getActiveViewController() {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                
                currentVC.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Get current mcID
    
    @objc public func getCurrentMcID() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: Set Contact
    
    @objc public func setContact(primaryKey: String?) {
        if let previousPrimaryKey = self.getContactPrimaryKey() {
            CordialUserDefaults.set(previousPrimaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
            CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: CoreDataManager.shared.contactLogoutRequest.entityName)
        
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPushNotificationToken()
        let status = internalCordialAPI.getPushNotificationStatus()
        
        let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
    }
    
    // MARK: Unset Contact
    
    @objc public func unsetContact() {
        CordialUserDefaults.set(false, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        
        if let primaryKey = self.getContactPrimaryKey() {
            let sendContactLogoutRequest = SendContactLogoutRequest(primaryKey: primaryKey)
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            
            CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
            CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        }
    }
    
    // MARK: Upsert Contact
    
    @objc public func upsertContact(attributes: Dictionary<String, String>?) -> Void {
        if let primaryKey = self.getContactPrimaryKey() {
            let internalCordialAPI = InternalCordialAPI()
            
            let token = internalCordialAPI.getPushNotificationToken()
            let status = internalCordialAPI.getPushNotificationStatus()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: attributes)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        }
    }
    
    // MARK: Send Custom Event
        
    @objc public func sendCustomEvent(eventName: String, properties: Dictionary<String, String>?) {
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
    
    @objc public func registerForPushNotifications(options: UNAuthorizationOptions) {
        if CordialApiConfiguration.shared.pushNotificationHandler != nil {
            CordialApiConfiguration.shared.cordialPushNotification.registerForPushNotifications(options: options)
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Register for push notifications failed. Error: [CordialPushNotificationHandler is not set]", log: OSLog.cordialPushNotification, type: .info)
            }
        }
    }
}

