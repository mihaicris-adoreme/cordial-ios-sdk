//
//  CordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialAPI: NSObject {
    
    // MARK: Get account key
    
    @objc public func getAccountKey() -> String {
        if let accountKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY) {
            return accountKey
        }
        
        return CordialApiConfiguration.shared.accountKey
    }
    
    // MARK: Set account key
    
    @objc public func setAccountKey(accountKey: String) {
        UserDefaults.standard.set(accountKey, forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY)
    }
    
    // MARK: Get channel key
    
    @objc public func getChannelKey() -> String {
        if let channelKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY) {
            return channelKey
        }
        
        return CordialApiConfiguration.shared.channelKey
    }
    
    // MARK: Set channel key
    
    @objc public func setChannelKey(channelKey: String) {
        UserDefaults.standard.set(channelKey, forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY)
    }
    
    // MARK: Get base URL
    
    @objc public func getBaseURL() -> String {
        if let baseURL = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL) {
            return baseURL
        }
        
        return CordialApiConfiguration.shared.baseURL
    }
    
    // MARK: Set base URL
    
    @objc public func setBaseURL(baseURL: String) {
        if baseURL.last != "/" {
            UserDefaults.standard.set(baseURL + "/", forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
        } else {
            UserDefaults.standard.set(baseURL, forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
        }
    }
    
    // MARK: Get primary key
    
    @objc public func getContactPrimaryKey() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
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
        
    // MARK: Set Contact
    
    @objc public func setContact(primaryKey: String) {
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: CoreDataManager.shared.contactLogoutRequest.entityName)
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey)
        self.upsertContact(upsertContactRequest: upsertContactRequest)
    }
    
    // MARK: Unset Contact
    
    @objc public func unsetContact() {
        if let primaryKey = self.getContactPrimaryKey() {
            let sendContactLogoutRequest = SendContactLogoutRequest(primaryKey: primaryKey)
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            
            UserDefaults.standard.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
            UserDefaults.standard.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        }
    }
    
    // MARK: Upsert Contact
    
    @objc public func upsertContact(upsertContactRequest: UpsertContactRequest) -> Void {
        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
    }

    // MARK: Send Custom Event
        
    @objc public func sendCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        CustomEventsSender().sendCustomEvents(sendCustomEventRequests: [sendCustomEventRequest])
    }
    
    // MARK: Upsert Contact Cart
    
    @objc public func upsertContactCart(cartItems: [CartItem]) {
        let upsertContactCartRequest = UpsertContactCartRequest(cartItems: cartItems)
        ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
    }
    
    // MARK: Send Order
    
    @objc public func sendContactOrder(order: Order) {
        let sendContactOrderRequest = SendContactOrderRequest(order: order)
        ContactOrdersSender().sendContactOrders(sendContactOrderRequests: [sendContactOrderRequest])
    }
}
