//
//  CordialSwizzler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/1/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class CordialSwizzler {
    
    static let shared = CordialSwizzler()
    
    private init() {}
    
    func swizzleAppAndSceneDelegateMethods() {
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            self.swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
            self.swizzleDidFailToRegisterForRemoteNotificationsWithError()
            
            LoggerManager.shared.info(message: "Push notification related functions swizzled successfully", category: "CordialSDKPushNotification")
        } else {
            LoggerManager.shared.info(message: "Push notification related functions not swizzled: pushesConfiguration not equals to SDK value", category: "CordialSDKPushNotification")
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
                
                LoggerManager.shared.info(message: "Deep links related functions swizzled successfully", category: "CordialSDKDeepLinks")
            } else {
                LoggerManager.shared.info(message: "Deep links related functions not swizzled: Deep links delegate not setted up", category: "CordialSDKDeepLinks")
            }
        } else {
            LoggerManager.shared.info(message: "Deep links related functions not swizzled: deepLinksConfiguration not equals to SDK value", category: "CordialSDKDeepLinks")
        }
        
        if CordialApiConfiguration.shared.backgroundURLSessionConfiguration == .SDK {
            self.swizzleAppHandleEventsForBackgroundURLSessionCompletionHandler()
            
            LoggerManager.shared.info(message: "Background URLSession related function swizzled successfully", category: "CordialSDKBackgroundURLSession")
        } else {
            LoggerManager.shared.info(message: "Background URLSession related function not swizzled: backgroundURLSessionConfiguration not equals to SDK value", category: "CordialSDKBackgroundURLSession")
        }
    }
    
    private func methodImplementations(delegate: AnyClass, selector: Selector, swizzleMethod: Method) {
        if let originalMethod = class_getInstanceMethod(delegate, selector) {
            method_exchangeImplementations(originalMethod, swizzleMethod)
        } else {
            class_addMethod(delegate, selector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))
        }
    }
    
    // MARK: - Swizzle AppDelegate remote notification registration methods
    
    private func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) else { return }
        guard let delegate = object_getClass(UIApplication.shared.delegate) else { return }
        let selector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
    }
    
    private func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:didFailToRegisterForRemoteNotificationsWithError:))) else { return }
        guard let delegate = object_getClass(UIApplication.shared.delegate) else { return }
        let selector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
    }
    
    // MARK: Swizzle AppDelegate universal links method
    
    private func swizzleAppContinueRestorationHandler() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:continue:restorationHandler:))) else { return }
        guard let delegate = object_getClass(UIApplication.shared.delegate) else { return }
        let selector = #selector(UIApplicationDelegate.application(_:continue:restorationHandler:))
        
        self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
    }
    
    // MARK: Swizzle SceneDelegate universal links method
    
    @available(iOS 13.0, *)
    private func swizzleSceneContinue() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.scene(_:continue:))) else { return }
        
        UIApplication.shared.connectedScenes.forEach { scene in
            guard let delegate = object_getClass(scene.delegate) else { return }
            let selector = #selector(UISceneDelegate.scene(_:continue:))
            
            self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
        }
    }
    
    // MARK: Swizzle AppDelegate URL schemes method
    
    private func swizzleAppOpenOptions() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:open:options:))) else { return }
        guard let delegate = object_getClass(UIApplication.shared.delegate) else { return }
        let selector = #selector(UIApplicationDelegate.application(_:open:options:))
        
        self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
    }
    
    // MARK: Swizzle SceneDelegate URL schemes method
    
    @available(iOS 13.0, *)
    private func swizzleSceneOpenURLContexts() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.scene(_:openURLContexts:))) else { return }
        
        UIApplication.shared.connectedScenes.forEach { scene in
            guard let delegate = object_getClass(scene.delegate) else { return }
            let selector = #selector(UISceneDelegate.scene(_:openURLContexts:))
            
            self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
        }
    }
    
    // MARK: Swizzle AppDelegate background URLSession method
    
    private func swizzleAppHandleEventsForBackgroundURLSessionCompletionHandler() {
        guard let swizzleMethod = class_getInstanceMethod(CordialSwizzler.self, #selector(self.application(_:handleEventsForBackgroundURLSession:completionHandler:))) else { return }
        guard let delegate = object_getClass(UIApplication.shared.delegate) else { return }
        let selector = #selector(UIApplicationDelegate.application(_:handleEventsForBackgroundURLSession:completionHandler:))
        
        self.methodImplementations(delegate: delegate, selector: selector, swizzleMethod: swizzleMethod)
    }
    
    // MARK: Swizzled AppDelegate remote notification registration methods
    
    @objc func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    @objc func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LoggerManager.shared.error(message: "RegisterForRemoteNotifications fail with error: [\(error.localizedDescription)]", category: "CordialSDKPushNotification")
    }
    
    // MARK: Swizzled AppDelegate universal links method
    
    @objc func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return CordialSwizzlerHelper().processAppContinueRestorationHandler(userActivity: userActivity)
    }
    
    // MARK: Swizzled SceneDelegate universal links method
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        CordialSwizzlerHelper().processSceneContinue(userActivity: userActivity, scene: scene)
    }
    
    // MARK: Swizzled AppDelegate URL schemes method
    
    @objc func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return CordialSwizzlerHelper().processAppOpenOptions(url: url)
    }
    
    // MARK: Swizzled SceneDelegate URL schemes method
    
    @available(iOS 13.0, *)
    @objc func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            LoggerManager.shared.error(message: "DeepLink URL is absent or not in a valid format", category: "CordialSDKDeepLinks")
            
            return
        }
        
        CordialSwizzlerHelper().processSceneOpenURLContexts(url: url, scene: scene)
    }
    
    // MARK: Swizzled AppDelegate background URLSession method
    
    @objc func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        CordialSwizzlerHelper().swizzleAppHandleEventsForBackgroundURLSessionCompletionHandler(identifier: identifier, completionHandler: completionHandler)
    }
}
