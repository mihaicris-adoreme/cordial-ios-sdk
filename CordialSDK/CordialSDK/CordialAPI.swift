//
//  CordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class CordialAPI: NSObject {

    // MARK: Get timestamp
    
    internal func getTimestamp() -> String {
        let date = Date()
        let formatter = ISO8601DateFormatter()
        
        return formatter.string(from: date)
    }
    
    // MARK: Get device identifier
    
    internal func getDeviceIdentifier() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Send cache from CoreData
    
    internal func sendCacheFromCoreData() {
        if self.getContactPrimaryKey() != nil {
            let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
            if customEventRequests.count > 0 {
                CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
            }
            
            if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData() {
                ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
            }
            
            let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
            if sendContactOrderRequests.count > 0 {
                ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
            }
        }
        
        let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
        if upsertContactRequests.count > 0 {
            ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
        }
        
        if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.getContactLogoutRequestFromCoreData() {
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
        }
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
    // MARK: Get account key
    
    public func getAccountKey() -> String {
        if let accountKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY) {
            return accountKey
        }
        
        return CordialApiConfiguration.shared.accountKey
    }
    
    // MARK: Set account key
    
    public func setAccountKey(accountKey: String) {
        UserDefaults.standard.set(accountKey, forKey: API.USER_DEFAULTS_KEY_FOR_ACCOUNT_KEY)
    }
    
    // MARK: Get channel key
    
    public func getChannelKey() -> String {
        if let channelKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY) {
            return channelKey
        }
        
        return CordialApiConfiguration.shared.channelKey
    }
    
    // MARK: Set channel key
    
    public func setChannelKey(channelKey: String) {
        UserDefaults.standard.set(channelKey, forKey: API.USER_DEFAULTS_KEY_FOR_CHANNEL_KEY)
    }
    
    // MARK: Get base URL
    
    public func getBaseURL() -> String {
        if let baseURL = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL) {
            return baseURL
        }
        
        return CordialApiConfiguration.shared.baseURL
    }
    
    // MARK: Set base URL
    
    public func setBaseURL(baseURL: String) {
        if baseURL.last != "/" {
            UserDefaults.standard.set(baseURL + "/", forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
        } else {
            UserDefaults.standard.set(baseURL, forKey: API.USER_DEFAULTS_KEY_FOR_BASR_URL)
        }
    }
    
    // MARK: Get primary key
    
    public func getContactPrimaryKey() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Global alert
    
    public func showSystemAlert(title: String, message: String?) {
        DispatchQueue.main.async {
            if let currentVC = self.getActiveViewController() {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                
                currentVC.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Get active view controller
    
    private func getActiveViewController() -> UIViewController? {
        if var currentVC = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedVC = currentVC.presentedViewController {
                if let navVC = (presentedVC as? UINavigationController)?.viewControllers.last {
                    currentVC = navVC
                } else if let tabVC = (presentedVC as? UITabBarController)?.selectedViewController {
                    currentVC = tabVC
                } else {
                    currentVC = presentedVC
                }
            }
            
            return currentVC
        }
        
        return nil
    }
    
    // MARK: Show modal in-app message
    
    internal func showModalInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.getActiveViewController() {
                let webViewController = InAppMessageManager().getWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                activeViewController.present(webViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Show baner in-app message
    
    internal func showBanerInAppMessage(inAppMessageData: InAppMessageData) {
        DispatchQueue.main.async {
            if let activeViewController = self.getActiveViewController() {
                let webViewController = InAppMessageManager().getWebViewController(activeViewController: activeViewController, inAppMessageData: inAppMessageData)
                activeViewController.present(webViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Set Contact
    
    public func setContact(primaryKey: String) {
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: CoreDataManager.shared.contactLogoutRequest.entityName)
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey)
        self.upsertContact(upsertContactRequest: upsertContactRequest)
    }
    
    // MARK: Unset Contact
    
    public func unsetContact() {
        if let primaryKey = self.getContactPrimaryKey() {
            let sendContactLogoutRequest = SendContactLogoutRequest(primaryKey: primaryKey)
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            
            UserDefaults.standard.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
            UserDefaults.standard.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        }
    }
    
    // MARK: Upsert Contact
    
    public func upsertContact(upsertContactRequest: UpsertContactRequest) -> Void {
        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
    }

    // MARK: Send Custom Event
        
    public func sendCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        CustomEventsSender().sendCustomEvents(sendCustomEventRequests: [sendCustomEventRequest])
    }
    
    // MARK: Upsert Contact Cart
    
    public func upsertContactCart(cartItems: [CartItem]) {
        let upsertContactCartRequest = UpsertContactCartRequest(cartItems: cartItems)
        ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
    }
    
    // MARK: Send Order
    
    public func sendContactOrder(order: Order) {
        let sendContactOrderRequest = SendContactOrderRequest(order: order)
        ContactOrdersSender().sendContactOrders(sendContactOrderRequests: [sendContactOrderRequest])
    }
}
