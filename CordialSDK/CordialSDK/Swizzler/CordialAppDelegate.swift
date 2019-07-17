//
//  CordialAppDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

open class CordialAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Handle remote notification registration.
    
    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    // MARK: Handle universal links.
    
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return false
    }
    
    // MARK: Handle URL schemes.
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return false
    }
    
    // MARK: Handle background URLSession.
    
    open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
    }
}
