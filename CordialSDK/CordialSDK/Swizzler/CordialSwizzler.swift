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
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Push notification related functions swizzled successfully", log: OSLog.cordialPushNotification, type: .info)
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Push notification related functions not swizzled: pushesConfiguration not equals to SDK value", log: OSLog.cordialPushNotification, type: .info)
            }
        }
        
        if CordialApiConfiguration.shared.deepLinksConfiguration == .SDK {
            if CordialApiConfiguration.shared.cordialDeepLinksDelegate != nil {
                if #available(iOS 13.0, *), InternalCordialAPI().isAppUseScenes() {
                    self.swizzleSceneContinue()
                    self.swizzleSceneOpenURLContexts()
                } else {
                    self.swizzleAppContinueRestorationHandler()
                    self.swizzleAppOpenOptions()
                }
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Deep links related functions swizzled successfully", log: OSLog.cordialDeepLinks, type: .info)
                }
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Deep links related functions not swizzled: Deep links delegate not setted up", log: OSLog.cordialDeepLinks, type: .info)
                }
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Deep links related functions not swizzled: deepLinksConfiguration not equals to SDK value", log: OSLog.cordialDeepLinks, type: .info)
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
    
    // MARK: Swizzle AppDelegate universal links method.
    
    private func swizzleAppContinueRestorationHandler() {
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
    
    private func swizzleAppOpenOptions() {
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
    
    // MARK: Swizzled AppDelegate universal links method.
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        return CordialSwizzlerHelper().processAppContinueRestorationHandler(userActivity: userActivity)
    }
    
    // MARK: Swizzled SceneDelegate universal links method.
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        CordialSwizzlerHelper().processSceneContinue(userActivity: userActivity, scene: scene)
    }
    
    // MARK: Swizzled AppDelegate URL schemes method.
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return CordialSwizzlerHelper().processAppOpenOptions(url: url)
    }
    
    // MARK: Swizzle SceneDelegate URL schemes method.
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        CordialSwizzlerHelper().processSceneOpenURLContexts(URLContexts: URLContexts, scene: scene)
    }
    
    // MARK: Swizzled AppDelegate background URLSession method.
    
    @objc func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        CordialURLSession.shared.backgroundCompletionHandler = completionHandler
    }
}
