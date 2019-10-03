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
    
    // MARK: Set current mcID
    
    func setCurrentMcID(mcID: String) {
        UserDefaults.standard.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
    }
    
    // MARK: JSON Web Token
    
    func setCurrentJWT(JWT: String) {
        UserDefaults.standard.set(JWT, forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
        self.sendCacheFromCoreData()
    }
    
    func getCurrentJWT() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
    }
    
    // MARK: Send System Event
    
    func sendSystemEvent(sendCustomEventRequest: SendCustomEventRequest) {
        CustomEventsSender().sendCustomEvents(sendCustomEventRequests: [sendCustomEventRequest])
    }
    
    // MARK: Send cache from CoreData
    
    func sendCacheFromCoreData() {
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

    // MARK: Send first launch custom event
    
    func sendFirstLaunchCustomEvent() {
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.EVENT_NAME_FIRST_LAUNCH
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            self.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Prepare device identifier
    
    func prepareDeviceIdentifier() {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            UserDefaults.standard.set(deviceID, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        } else {
            UserDefaults.standard.set(UUID().uuidString, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        }
    }
    
    // MARK: Open deep link
    
    func openDeepLink(url: URL) {
        if let scheme = url.scheme, scheme.contains("http") {
            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            userActivity.webpageURL = url
            let _ = UIApplication.shared.delegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
        } else {
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
}
