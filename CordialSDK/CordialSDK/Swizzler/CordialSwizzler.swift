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
    
    static let shared = CordialSwizzler()
    
    private init() {}
    
    func swizzleAppAndSceneDelegateMethods() {
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            self.swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
            self.swizzleDidFailToRegisterForRemoteNotificationsWithError()
            self.swizzleDidReceiveRemoteNotificationfetchCompletionHandler()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Push notification related functions swizzled successfully", log: OSLog.cordialPushNotification, type: .info)
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Push notification related functions not swizzled: pushesConfiguration not equals to SDK value", log: OSLog.cordialPushNotification, type: .info)
            }
        }
                
        if CordialApiConfiguration.shared.cordialDeepLinksDelegate != nil {
            if #available(iOS 13.0, *), InternalCordialAPI().isAppUseScenes() {
                self.swizzleSceneContinue()
                self.swizzleSceneOpenURLContexts()
            } else {
                self.swizzleContinueRestorationHandler()
                self.swizzleOpenOptions()
            }
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Deep links related functions swizzled successfully", log: OSLog.cordialDeepLinks, type: .info)
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Deep links related functions not swizzled: Deep links delegate not setted up", log: OSLog.cordialDeepLinks, type: .info)
            }
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
    
    // MARK: Swizzle SceneDelegate universal links method.
    
    @available(iOS 13.0, *)
    private func swizzleSceneContinue() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.scene(_:continue:))) else { return }
        
        UIApplication.shared.connectedScenes.forEach { scene in
            let delegateClass: AnyClass! = object_getClass(scene.delegate)
            let sceneSelector = #selector(UISceneDelegate.scene(_:continue:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, sceneSelector) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            } else {
                class_addMethod(delegateClass, sceneSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
            }
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
    
    // MARK: Swizzle SceneDelegate URL schemes method.
    
    @available(iOS 13.0, *)
    private func swizzleSceneOpenURLContexts() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.scene(_:openURLContexts:))) else { return }
        
        UIApplication.shared.connectedScenes.forEach { scene in
            let delegateClass: AnyClass! = object_getClass(scene.delegate)
            let sceneSelector = #selector(UISceneDelegate.scene(_:openURLContexts:))
            
            if let originalMethod = class_getInstanceMethod(delegateClass, sceneSelector) {
                method_exchangeImplementations(originalMethod, swizzleMethod)
            } else {
                class_addMethod(delegateClass, sceneSelector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
            }
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
        CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("RegisterForRemoteNotifications fail with error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
        }
    }
    
    @objc func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        
        completionHandler(.noData)
    }
    
    // MARK: Swizzled AppDelegate universal links method.
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let cordialSwizzlerHelper = CordialSwizzlerHelper()
        
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return false
            }
            
            if let host = url.host,
               CordialApiConfiguration.shared.vanityDomains.contains(host) {
                
                NotificationManager.shared.emailDeepLink = url.absoluteString
            } else {
                cordialSwizzlerHelper.sentEventDeepLinlkOpen()
                cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil)
            }
            
            return true
        }
        
        return false
    }
    
    // MARK: Swizzled SceneDelegate universal links method.
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        let cordialSwizzlerHelper = CordialSwizzlerHelper()
        
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return
            }
            
            if let host = url.host,
               CordialApiConfiguration.shared.vanityDomains.contains(host) {
                
                NotificationManager.shared.emailDeepLink = url.absoluteString
            } else {
                cordialSwizzlerHelper.sentEventDeepLinlkOpen()
                cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, scene: scene)
            }
        }
    }
    
    // MARK: Swizzled AppDelegate URL schemes method.
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil)
            
            return true
        }
        
        return false
    }
    
    // MARK: Swizzle SceneDelegate URL schemes method.
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate, let url = URLContexts.first?.url {
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, scene: scene)
        }
    }
    
    // MARK: Swizzled AppDelegate background URLSession method.
    
    @objc func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        CordialURLSession.shared.backgroundCompletionHandler = completionHandler
    }
}
