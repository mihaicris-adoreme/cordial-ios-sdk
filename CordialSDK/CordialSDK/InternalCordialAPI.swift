//
//  InternalCordialAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/15/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

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
    
    // Get SDK resource bundle
    
    func getResourceBundle() -> Bundle? {
        let frameworkIdentifier = "io.cordial.sdk"
        let frameworkName = "CordialSDK"
        
        if let bundle = Bundle(identifier: frameworkIdentifier) {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Using resource bundle by framework identifier", log: OSLog.cordialInfo, type: .info)
            }
            
            return bundle
        }
        
        guard let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: frameworkName, withExtension: "bundle") else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Using resource bundle found in SPM way", log: OSLog.cordialInfo, type: .info)
            }
            
            return Bundle.resourceBundle
        }
        
        guard let resourceBundle = Bundle(url: resourceBundleURL) else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("ResourceBundle Error: [resourceBundle is nil] resourceBundleURL: [%{public}@] frameworkName: [%{public}@]", log: OSLog.cordialError, type: .error, resourceBundleURL.absoluteString, frameworkName)
            }
            return nil
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Using resource bundle of self object", log: OSLog.cordialInfo, type: .info)
        }
        
        return resourceBundle
    }

    // MARK: Remove All Cached Data
    
    func removeAllCachedData() {
        CoreDataManager.shared.deleteAllCoreData()
        self.removeCurrentMcID()
    }
    
    // MARK: Set isCurrentlyUpsertingContacts
    
    func setIsCurrentlyUpsertingContacts(_ isCurrentlyUpsertingContacts: Bool) {
        CordialUserDefaults.set(isCurrentlyUpsertingContacts, forKey: API.USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS)
    }
    
    // MARK: Get isCurrentlyUpsertingContacts
    
    func isCurrentlyUpsertingContacts() -> Bool {
        if let isCurrentlyUpsertingContacts = CordialUserDefaults.bool(forKey: API.USER_DEFAULTS_KEY_FOR_IS_CURRENTLY_UPSERTING_CONTACTS) {
            return isCurrentlyUpsertingContacts
        }
        
        return false
    }
        
    // MARK: Get device identifier
    
    func getDeviceIdentifier() -> String {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)!
    }
    
    // MARK: Get prepared remote notifications device token
    
    func getPreparedRemoteNotificationsDeviceToken(deviceToken: Data) -> String {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        
        return tokenParts.joined()
    }
    
    // MARK: Get contact key
    
    func getContactKey() -> String? {
        let cordialAPI = CordialAPI()
        
        var key: String?
        if let primaryKey = cordialAPI.getContactPrimaryKey() {
            key = primaryKey
        } else if let token = InternalCordialAPI().getPushNotificationToken() {
            let channelKey = cordialAPI.getChannelKey()
            key = "\(channelKey):\(token)"
        }
        
        return key
    }
    
    // MARK: Set primary key
    
    func setContactPrimaryKey(primaryKey: String) {
        CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
    
    // MARK: Get previous primary key
    
    @objc public func getPreviousContactPrimaryKey() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
    }
    
    // MARK: Remove previous primary key
    
    func removePreviousContactPrimaryKey() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
    }

    // MARK: Set previous primary key and remove current
    
    func setPreviousPrimaryKeyAndRemoveCurrent(previousPrimaryKey: String?) {
        CordialUserDefaults.set(previousPrimaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY)
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
    }
        
    // MARK: Remove current mcID
    
    @objc public func removeCurrentMcID() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Get mc tap time
    
    func getMcTapTime() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID_TAP_TIME)
    }
    
    // MARK: Set JSON Web Token
    
    func setCurrentJWT(JWT: String) {
        CordialUserDefaults.set(JWT, forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
        
        DispatchQueue.main.async {
            CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
        }
    }
    
    // MARK: Get JSON Web Token
    
    func getCurrentJWT() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
    }
    
    // MARK: Remove JSON Web Token
    
    func removeCurrentJWT() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_SDK_SECURITY_JWT)
    }
    
    // MARK: Is user login
    
    func isUserLogin() -> Bool {
        if let isUserLogin = CordialUserDefaults.bool(forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN) {
            return isUserLogin
        }
        
        return false
    }
    
    // MARK: Is user has been ever login
    
    func isUserHasBeenEverLogin() -> Bool {
        if CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN) == nil {
            return false
        }
        
        return true
    }
    
    // MARK: Send Any Custom Event
    
    func sendAnyCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        ThreadQueues.shared.queueSendCustomEvent.sync(flags: .barrier) {
            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: [sendCustomEventRequest])
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            if CordialApiConfiguration.shared.eventsBulkSize != 1 {
                os_log("Event [eventName: %{public}@, eventID: %{public}@] added to bulk", log: OSLog.cordialSendCustomEvents, type: .info, sendCustomEventRequest.eventName, sendCustomEventRequest.requestID)
            }
        }
        
        ThrottlerManager.shared.sendCustomEventRequest.throttle {
            if CoreDataManager.shared.customEventRequests.getQtyCachedCustomEventRequests() >= CordialApiConfiguration.shared.eventsBulkSize {
                CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "Bulk size is full")
            }
        }
    }
    
    // MARK: Send Custom Event
    
    func sendCustomEvent(sendCustomEventRequest: SendCustomEventRequest) {
        let customEventsSender = CustomEventsSender()
        
        if customEventsSender.isEventNameHaveSystemPrefix(sendCustomEventRequest: sendCustomEventRequest) {
            let responseError = ResponseError(message: "Event name has system prefix", statusCode: nil, responseBody: nil, systemError: nil)
            customEventsSender.logicErrorHandler(sendCustomEventRequests: [sendCustomEventRequest], error: responseError)
        } else {
            self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
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
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            self.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    // MARK: Prepare device identifier
    
    func prepareDeviceIdentifier() {
        if CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID) == nil {
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                CordialUserDefaults.set(deviceID, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
            } else {
                CordialUserDefaults.set(UUID().uuidString, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
            }
        }
    }
    
    // MARK: Open deep link
    
    func openDeepLink(url: URL) {
        // UIKit
        DispatchQueue.main.async {
            if let scheme = url.scheme, scheme.contains("http") {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = url
                
                if #available(iOS 13.0, *), self.isAppUseScenes(),
                    let scene = UIApplication.shared.connectedScenes.first {
                    
                    CordialSwizzler.shared.scene(scene, continue: userActivity)
                } else {
                    let _ = CordialSwizzler.shared.application(UIApplication.shared, continue: userActivity, restorationHandler: { _ in })
                }
            } else {
                UIApplication.shared.open(url)
            }
        }
        
        // SwiftUI
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: url, fallbackURL: nil)
            }
        }
    }
    
    // MARK: Sent event deep link open
    
    func sentEventDeepLinkOpen() {
        let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    // MARK: Get push notification authorization status
    
    func getPushNotificationStatus() -> String {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? API.PUSH_NOTIFICATION_STATUS_DISALLOW
    }
     
    // MARK: Set push notification authorization status
    
    func setPushNotificationStatus(status: String) {
        CordialUserDefaults.set(status, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS)
    }
    
    // MARK: Get push notification token
    
    func getPushNotificationToken() -> String? {
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Set push notification token
    
    func setPushNotificationToken(token: String) {
        CordialUserDefaults.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN)
    }
    
    // MARK: Get the latest sentAt IAM
    
    func getTheLatestSentAtInAppMessageDate() -> String? {        
        return CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    // MARK: Set the latest sentAt IAM
    
    func setTheLatestSentAtInAppMessageDate(sentAtTimestamp: String) {
        CordialUserDefaults.set(sentAtTimestamp, forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    func removeTheLatestSentAtInAppMessageDate() {
        CordialUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_THE_LATEST_SENT_AT_IN_APP_MESSAGE_DATE)
    }
    
    func removeContactTimestampFromCoreDataAndTheLatestSentAtInAppMessageDate() {
        CoreDataManager.shared.contactTimestampsURL.removeContactTimestampFromCoreData()
        self.removeTheLatestSentAtInAppMessageDate()
    }

}
