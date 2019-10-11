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
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()

    func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        notificationCenter.delegate = self
    }
    
    func getNotificationSettings() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        notificationCenter.delegate = self
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when user made a notification tap.
        let userInfo = response.notification.request.content.userInfo
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Push notification app open via tap. Payload: [%{public}@]", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        if let mcID = userInfo["mcID"] as? String {
            self.internalCordialAPI.setCurrentMcID(mcID: mcID)
            
            if InAppMessage().isPayloadContainInAppMessage(userInfo: userInfo) {
                if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID), inAppMessageParams.inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    DispatchQueue.main.async {
                        if !(UIApplication.shared.applicationState == .active) {
                            CoreDataManager.shared.inAppMessagesCache.deleteInAppMessageDataByMcID(mcID: mcID)
                            CoreDataManager.shared.inAppMessagesParam.deleteInAppMessageParamsByMcID(mcID: mcID)
                            
                            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                                os_log("IAM with mcID [%{public}@] has been removed.", log: OSLog.cordialInAppMessage, type: .info, mcID)
                            }
                        }
                    }
                }
            }
        }
        
        let eventName = API.EVENT_NAME_PUSH_NOTIFICATION_TAP
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        self.internalCordialAPI.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        do {
            if let deepLink = userInfo["deepLink"] as? String, let deepLinkData = deepLink.data(using: .utf8) {
                let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkData, options: []) as! [String: AnyObject]
                if let deepLinkURLString = deepLinkJSON["url"] as? String, let deepLinkURL = URL(string: deepLinkURLString), let cordialDeepLinksHandler = CordialApiConfiguration.shared.cordialDeepLinksHandler {
                    
                    let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
                    let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
                    self.internalCordialAPI.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
                    
                    if let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String, let fallbackURL = URL(string: fallbackURLString) {
                        cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL) 
                    } else {
                        cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: nil)
                    }
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode notification payload. Error: [%{public}@]", log: OSLog.cordialPushNotification, type: .error, error.localizedDescription)
            }
        }
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler {
            pushNotificationHandler.appOpenViaNotificationTap(notificationContent: userInfo) {
                completionHandler()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when notification is delivered to a foreground app.
        let userInfo = notification.request.content.userInfo
        
        let eventName = API.EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        self.internalCordialAPI.sendSystemEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler {
            pushNotificationHandler.notificationDeliveredInForeground(notificationContent: userInfo) {
                completionHandler([.alert, .badge])
            }
        }
    }
}
