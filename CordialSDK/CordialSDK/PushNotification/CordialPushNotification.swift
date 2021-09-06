//
//  CordialPushNotification.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
import os.log

class CordialPushNotification: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = CordialPushNotification()
    
    private override init() {}
    
    let pushNotificationHelper = CordialPushNotificationHelper()

    func registerForPushNotifications(options: UNAuthorizationOptions) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            notificationCenter.delegate = self
        }
    }
    
    func registerForSilentPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        if CordialApiConfiguration.shared.pushesConfiguration == .SDK {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when user made a notification tap.
        let userInfo = response.notification.request.content.userInfo
        
        self.pushNotificationHelper.pushNotificationHasBeenTapped(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when notification is delivered to a foreground app.
        let userInfo = notification.request.content.userInfo
        
        self.pushNotificationHelper.pushNotificationHasBeenForegroundDelivered(userInfo: userInfo, completionHandler: completionHandler)
    }
}
