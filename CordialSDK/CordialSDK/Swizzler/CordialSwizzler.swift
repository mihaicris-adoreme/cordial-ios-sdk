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
        
        if CordialApiConfiguration.shared.continueRestorationHandler != nil {
            self.swizzleContinueRestorationHandler()
        }
        
        if CordialApiConfiguration.shared.openOptionsHandler != nil {
            self.swizzleOpenOptions()
        }
    }
    
    private func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
            let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
        }
    }
    
    private func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
            let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didFailToRegisterForRemoteNotificationsWithError:))) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        }
    }
    
    private func swizzleDidReceiveRemoteNotificationfetchCompletionHandler() {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        let applicationSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
            let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        }
    }
    
    private func swizzleContinueRestorationHandler() {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        let applicationSelector = #selector(UIApplicationDelegate.application(_:continue:restorationHandler:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
            let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:continue:restorationHandler:))) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        }
    }
    
    private func swizzleOpenOptions() {
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        
        let applicationSelector = #selector(UIApplicationDelegate.application(_:open:options:))
        
        if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
            let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:open:options:))) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        }
    }
    
    // MARK: Swizzled methods realization
    
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        os_log("Device Token: [%{public}@]", log: OSLog.pushNotification, type: .info, token)
        
        if token != UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_DEVICE_TOKEN) {
            let upsertContactRequest = UpsertContactRequest(token: token)
            CordialAPI().upsertContact(upsertContactRequest: upsertContactRequest)
        }
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @objc func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let inApp = userInfo["in-app"] as? Bool, inApp, let mcID = userInfo["mcID"] as? String  {
            InAppMessageGetter().fetchInAppMessage(mcID: mcID)
        }
        
        completionHandler(.noData)
    }
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let continueRestorationHandler = CordialApiConfiguration.shared.continueRestorationHandler {
            let eventName = API.DEEP_LINKS_APP_OPEN_VIA_UNIVERSAL_LINK
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            return continueRestorationHandler.appOpenViaUniversalLink(application, continue: userActivity, restorationHandler: restorationHandler)
        }
        
        return false
    }
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let openOptionsHandler = CordialApiConfiguration.shared.openOptionsHandler {
            let eventName = API.DEEP_LINKS_APP_OPEN_VIA_URL_SCHEME
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            return openOptionsHandler.appOpenViaUrlScheme(app, open: url, options: options)
        }
        
        return false
    }
}
