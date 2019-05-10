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

class CordialPushNotification: NSObject, UNUserNotificationCenterDelegate {
    
    let cordialAPI = CordialAPI()

    func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
        }
        
        center.delegate = self
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called to let your app know which action was selected by the user for a given notification.
        let userInfo = response.notification.request.content.userInfo
        
        let eventName = API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_APP_OPEN_VIA_TAP
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: ["payload": userInfo.description])
        cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler {
            pushNotificationHandler.appOpenViaNotificationTap(notificationContent: userInfo) {
                completionHandler()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when a notification is delivered to a foreground app.
        let userInfo = notification.request.content.userInfo
        
        let eventName = API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: ["payload": userInfo.description])
        cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler {
            pushNotificationHandler.notificationDeliveredInForeground(notificationContent: userInfo) {
                completionHandler([.alert, .badge])
            }
        }
    }
}
