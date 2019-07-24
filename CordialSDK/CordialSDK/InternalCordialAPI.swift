//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InternalCordialAPI {
    
    let cordialAPI = CordialAPI()
    let dateFormatter = ISO8601DateFormatter()
    
    // MARK: Get current timestamp
    
    func getCurrentTimestamp() -> String {
        let date = Date()
        
        return dateFormatter.string(from: date)
    }
    
    // MARK: Get date from timestamp
    
    func getDateFromTimestamp(timestamp: String) -> Date? {
        return dateFormatter.date(from: timestamp)
    }
    
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    func saveMcID(mcID: String) {
        UserDefaults.standard.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: Send cache from CoreData
    
    func sendCacheFromCoreData() {
        if cordialAPI.getContactPrimaryKey() != nil {
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
    
    // MARK: Get active view controller
    
    func getActiveViewController() -> UIViewController? {
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

}
