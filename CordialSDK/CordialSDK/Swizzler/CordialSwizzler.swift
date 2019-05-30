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
    
    let applicationDelegate: UIApplicationDelegate?
    
    init() {
        self.applicationDelegate = UIApplication.shared.delegate
    }
    
    func swizzleAppDelegateMethods() {
        if CordialApiConfiguration.shared.pushNotificationHandler != nil {
            self.swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
            self.swizzleDidFailToRegisterForRemoteNotificationsWithError()
        }
        
        if CordialApiConfiguration.shared.continueRestorationHandler != nil {
            self.swizzleContinueRestorationHandler()
        }
        
        if CordialApiConfiguration.shared.openOptionsHandler != nil {
            self.swizzleOpenOptions()
        }
    }
    
    func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
                    method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(application(_:didFailToRegisterForRemoteNotificationsWithError:))) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    func swizzleContinueRestorationHandler() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:continue:restorationHandler:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(application(_:continue:restorationHandler:))) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    func swizzleOpenOptions() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:open:options:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(application(_:open:options:))) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        os_log("Device Token: [%{public}@]", log: OSLog.pushNotification, type: .info, token)
        
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_TOKEN)
        
        let upsertContactRequest = UpsertContactRequest(token: token)
        CordialAPI().upsertContact(upsertContactRequest: upsertContactRequest)
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let continueRestorationHandler = CordialApiConfiguration.shared.continueRestorationHandler {
            let eventName = API.USER_DEFAULTS_KEY_FOR_DEEP_LINKS_APP_OPEN_VIA_UNIVERSAL_LINK
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            return continueRestorationHandler.appOpenViaUniversalLink(application, continue: userActivity, restorationHandler: restorationHandler)
        }
        
        return false
    }
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let openOptionsHandler = CordialApiConfiguration.shared.openOptionsHandler {
            let eventName = API.USER_DEFAULTS_KEY_FOR_DEEP_LINKS_APP_OPEN_VIA_URL_SCHEME
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            return openOptionsHandler.appOpenViaUrlScheme(app, open: url, options: options)
        }
        
        return false
    }
}
