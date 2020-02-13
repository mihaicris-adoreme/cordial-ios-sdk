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

    func registerForPushNotifications(options: UNAuthorizationOptions) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
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
    
    private func getDeepLinkURL(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject], let deepLinkURLString = deepLinkJSON["url"] as? String, let deepLinkURL = URL(string: deepLinkURLString) {
            return deepLinkURL
        } else if let deepLinkJSONString = userInfo["deepLink"] as? String, let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
            do {
                if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject], let deepLinkURLString = deepLinkJSON["url"] as? String {
                    let deepLinkURL = URL(string: deepLinkURLString)
                    
                    return deepLinkURL
                }
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    private func getDeepLinkFallbackURL(userInfo: [AnyHashable : Any]) -> URL? {
        if let deepLinkJSON = userInfo["deepLink"] as? [String: AnyObject], let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String, let fallbackURL = URL(string: fallbackURLString) {
            return fallbackURL
        } else if let deepLinkJSONString = userInfo["deepLink"] as? String, let deepLinkJSONData = deepLinkJSONString.data(using: .utf8) {
            do {
                if let deepLinkJSON = try JSONSerialization.jsonObject(with: deepLinkJSONData, options: []) as? [String: AnyObject], let fallbackURLString = deepLinkJSON["fallbackUrl"] as? String {
                    let fallbackURL = URL(string: fallbackURLString)
                    
                    return fallbackURL
                }
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when user made a notification tap.
        let userInfo = response.notification.request.content.userInfo
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Push notification app open via tap. Payload: %{public}@", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        if let mcID = userInfo["mcID"] as? String {
            self.internalCordialAPI.setCurrentMcID(mcID: mcID)
            
            if CoreDataManager.shared.inAppMessagesShown.isInAppMessageHasBeenShown(mcID: mcID) {
                InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
            }
            
            if InAppMessage().isPayloadContainInAppMessage(userInfo: userInfo) {
                if let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID), inAppMessageParams.inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    DispatchQueue.main.async {
                        if !(UIApplication.shared.applicationState == .active) {
                            InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
                            
                            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                                os_log("IAM with mcID [%{public}@] has been removed.", log: OSLog.cordialInAppMessage, type: .info, mcID)
                            }
                        }
                    }
                }
            }
        }
        
        let mcID = self.cordialAPI.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATION_TAP, mcID: mcID, properties: nil)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let deepLinkURL = self.getDeepLinkURL(userInfo: userInfo), let cordialDeepLinksHandler = CordialApiConfiguration.shared.cordialDeepLinksHandler {
    
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_DEEP_LINK_OPEN, mcID: mcID, properties: nil)
            self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            if let fallbackURL = self.getDeepLinkFallbackURL(userInfo: userInfo) {
                if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL, scene: scene)
                } else {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL)
                }
            } else {
                if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: nil, scene: scene)
                } else {
                    cordialDeepLinksHandler.openDeepLink(url: deepLinkURL, fallbackURL: nil)
                }
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
        let mcID = self.cordialAPI.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let pushNotificationHandler = CordialApiConfiguration.shared.pushNotificationHandler, !InAppMessage().isPayloadContainInAppMessage(userInfo: userInfo) {
            pushNotificationHandler.notificationDeliveredInForeground(notificationContent: userInfo) {
                completionHandler([.alert])
            }
        }
    }
}
