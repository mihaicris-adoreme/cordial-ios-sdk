//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InternalCordialAPI {
    
    // MARK: Checking app for use scenes
    
    func isAppUseScenes() -> Bool {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(delegateClass, &methodCount)
        
        if var methodList = methodList, methodCount > 0 {
            for _ in 0..<methodCount {
                let method = methodList.pointee
                
                let selector = method_getName(method)
                let selectorName = String(cString: sel_getName(selector))
                
                let connectingSceneSessionSelectorName = "application:configurationForConnectingSceneSession:options:"
                
                if selectorName == connectingSceneSessionSelectorName {
                    return true
                }
                
                methodList = methodList.successor()
            }
        }
        
        return false
    }
        
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Set current mcID
    
    func setCurrentMcID(mcID: String) {
        UserDefaults.standard.set(mcID, forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        UserDefaults.standard.set(DateFormatter().getCurrentTimestamp(), forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Get mc tap time
    
    func getMcTapTime() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
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
    
    // MARK: Send Custom Event
    
    func sendCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        if !sendCustomEventRequest.eventName.hasPrefix(API.SYSTEM_EVENT_PREFIX) {
            CustomEventsSender().sendCustomEvents(sendCustomEventRequests: [sendCustomEventRequest])
        } else {
            let responseError = ResponseError(message: "Event name has system prefix", statusCode: nil, responseBody: nil, systemError: nil)
            CustomEventsSender().logicErrorHandler(sendCustomEventRequests: [sendCustomEventRequest], error: responseError)
        }
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
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        
        return nil
    }

    // MARK: Send first launch custom event
    
    func sendFirstLaunchCustomEvent() {
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.EVENT_NAME_FIRST_LAUNCH
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
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
    
    // MARK: Get push notification authorization status
    
    func getPushNotificationStatus() -> String {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
     
    // MARK: Set push notification authorization status
    
    func setPushNotificationStatus(status: String) {
        UserDefaults.standard.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
    }
    
    // MARK: Get push notification token
    
    func getPushNotificationToken() -> String? {
        return UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Set push notification token
    
    func setPushNotificationToken(token: String) {
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
}
