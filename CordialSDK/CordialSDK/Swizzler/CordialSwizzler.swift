//
//  CordialSwizzler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/1/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialSwizzler {
    
    func swizzleAppDelegateMethods() {
        if CordialApiConfiguration.shared.pushNotificationHandler != nil {
            self.swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
            self.swizzleDidFailToRegisterForRemoteNotificationsWithError()
            self.swizzleDidReceiveRemoteNotificationfetchCompletionHandler()
        }
                
        if CordialApiConfiguration.shared.cordialDeepLinksHandler != nil {
            self.swizzleContinueRestorationHandler()
            self.swizzleOpenOptions()
        }
        
        self.swizzleHandleEventsForBackgroundURLSessionCompletionHandler()
    }
    
    // MARK: - Swizzle AppDelegate remote notification registration methods.
    
    private func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    private func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didFailToRegisterForRemoteNotificationsWithError:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    private func swizzleDidReceiveRemoteNotificationfetchCompletionHandler() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    // MARK: Swizzle AppDelegate universal links method.
    
    private func swizzleContinueRestorationHandler() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:continue:restorationHandler:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:continue:restorationHandler:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    // MARK: Swizzle AppDelegate URL schemes method.
    
    private func swizzleOpenOptions() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:open:options:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:open:options:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    // MARK: Swizzle AppDelegate background URLSession method.
    
    private func swizzleHandleEventsForBackgroundURLSessionCompletionHandler() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:handleEventsForBackgroundURLSession:completionHandler:))) else { return }
        
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let applicationSelector = #selector(UIApplicationDelegate.application(_:handleEventsForBackgroundURLSession:completionHandler:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegateClass, applicationSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    // MARK: Swizzled AppDelegate remote notification registration methods.
    
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Device Token: [%{public}@]", log: OSLog.cordialPushNotification, type: .info, token)
        }
        
        let internalCordialAPI = InternalCordialAPI()
        
        if token != internalCordialAPI.getPushNotificationToken() {
            let primaryKey = CordialAPI().getContactPrimaryKey()
            let status = internalCordialAPI.getPushNotificationStatus()
            
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
            
            internalCordialAPI.setPushNotificationToken(token: token)
        }
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("RegisterForRemoteNotifications fail with error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
    }
    
    @objc func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Silent push notification received. Payload: [%{public}@]", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        if let mcID = userInfo["mcID"] as? String {
            InternalCordialAPI().setCurrentMcID(mcID: mcID)
            
            if InAppMessage().isPayloadContainInAppMessage(userInfo: userInfo) {
                InAppMessageGetter().startFetchInAppMessage(userInfo: userInfo)
            }
        }
        
        completionHandler(.noData)
    }
    
    // MARK: Swizzled AppDelegate universal links method.
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let cordialDeepLinksHandler = CordialApiConfiguration.shared.cordialDeepLinksHandler {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return false
            }
            
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
            InternalCordialAPI().sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksHandler.openDeepLink(url: url, fallbackURL: nil)
            
            return true
        }
        
        return false
    }
    
    // MARK: Swizzled AppDelegate URL schemes method.
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let cordialDeepLinksHandler = CordialApiConfiguration.shared.cordialDeepLinksHandler {
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
            InternalCordialAPI().sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksHandler.openDeepLink(url: url, fallbackURL: nil)
            
            return true
        }
        
        return false
    }
    
    // MARK: Swizzled AppDelegate background URLSession method.
    
    @objc func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        CordialURLSession.shared.backgroundCompletionHandler = completionHandler
    }
}
