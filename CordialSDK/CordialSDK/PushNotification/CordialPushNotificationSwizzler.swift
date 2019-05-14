//
//  CordialPushNotificationSwizzler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/1/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationSwizzler {
    
    let applicationDelegate: UIApplicationDelegate?
    
    init() {
        self.applicationDelegate = UIApplication.shared.delegate
    }
    
    func swizzleAppDelegateMethods() {
        self.swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
        self.swizzleDidFailToRegisterForRemoteNotificationsWithError()
    }
    
    func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialPushNotificationSwizzler.self, #selector(application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
                    method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        if let delegate = applicationDelegate {
            let delegateClass: AnyClass! = object_getClass(delegate)
            
            let applicationSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, applicationSelector),
                let swizzleMethod = class_getInstanceMethod(CordialPushNotificationSwizzler.self, #selector(application(_:didFailToRegisterForRemoteNotificationsWithError:))) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            }
        }
    }
    
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        UserDefaults.standard.set(token, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_TOKEN)
        
        let upsertContactRequest = UpsertContactRequest(token: token)
        CordialAPI().upsertContact(upsertContactRequest: upsertContactRequest)
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
