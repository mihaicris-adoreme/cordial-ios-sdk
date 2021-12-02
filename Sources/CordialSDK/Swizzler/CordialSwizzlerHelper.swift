//
//  CordialSwizzlerHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import os.log

class CordialSwizzlerHelper {
    
    // MARK: Push notification
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any]) {
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Silent push notification received. Payload: %{public}@", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        let pushNotificationParser = CordialPushNotificationParser()
        
        if pushNotificationParser.isPayloadContainIAM(userInfo: userInfo) {
            switch CordialApiConfiguration.shared.inAppMessagesDeliveryConfiguration {
            case .silentPushes:
                InAppMessageGetter().startFetchInAppMessage(userInfo: userInfo)
            case .directDelivery:
                InAppMessagesGetter().startFetchInAppMessages(isSilentPushDeliveryEvent: true)
            }
        }
        
        if pushNotificationParser.isPayloadContainInboxMessage(userInfo: userInfo),
           let mcID = pushNotificationParser.getMcID(userInfo: userInfo) {
            
            CoreDataManager.shared.inboxMessagesCache.removeInboxMessageFromCoreData(mcID: mcID)
            CoreDataManager.shared.inboxMessagesContent.removeInboxMessageContentFromCoreData(mcID: mcID)
            
            // UIKit
            if let inboxMessageDelegate = CordialApiConfiguration.shared.inboxMessageDelegate {
                inboxMessageDelegate.newInboxMessageDelivered(mcID: mcID)
            }
            
            // SwiftUI
            if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                    CordialSwiftUIInboxMessagePublisher.shared.publishNewInboxMessageDelivered(mcID: mcID)
                }
            }
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        let internalCordialAPI = InternalCordialAPI()
        
        let token = internalCordialAPI.getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)
        
        // UIKit
        if let pushNotificationDelegate = CordialApiConfiguration.shared.pushNotificationDelegate {
            pushNotificationDelegate.apnsTokenReceived(token: token)
        }
        
        // SwiftUI
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                CordialSwiftUIPushNotificationPublisher.shared.publishApnsTokenReceived(token: token)
            }
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Device Token: [%{public}@]", log: OSLog.cordialPushNotification, type: .info, token)
        }
        
        if internalCordialAPI.isUserLogin() || !internalCordialAPI.isUserHasBeenEverLogin() {
            self.preparePushNotificationStatus(token: token)
        }
    }
    
    private func preparePushNotificationStatus(token: String) {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            var status = String()
            
            current.getNotificationSettings(completionHandler: { (settings) in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                    } else {
                        status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                    }
                    
                    InternalCordialAPI().setPushNotificationStatus(status: status)
                    
                    self.sendPushNotificationToken(token: token, status: status)
                }
            })
        }
    }
    
    private func sendPushNotificationToken(token: String, status: String) {
        InternalCordialAPI().setPushNotificationToken(token: token)
        
        let primaryKey = CordialAPI().getContactPrimaryKey()
        
        let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
    }
    
    // MARK: Deep links

    func processAppContinueRestorationHandler(userActivity: NSUserActivity) -> Bool {
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return false
            }
            
            if let host = url.host,
               CordialApiConfiguration.shared.vanityDomains.contains(host) {
                
                NotificationManager.shared.vanityDeepLink = url.absoluteString
            } else {
                InternalCordialAPI().sentEventDeepLinkOpen()
                cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, completionHandler: { deepLinkActionType in

                    InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                })
            }
            
            return true
        }
        
        return false
    }

    func processAppOpenOptions(url: URL) -> Bool {
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, completionHandler: { deepLinkActionType in
                
                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
            })
            
            return true
        }
        
        return false
    }
    
    @available(iOS 13.0, *)
    func processSceneContinue(userActivity: NSUserActivity, scene: UIScene) {
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return
            }
            
            if let host = url.host,
               CordialApiConfiguration.shared.vanityDomains.contains(host) {
                
                NotificationManager.shared.vanityDeepLink = url.absoluteString
            } else {
                InternalCordialAPI().sentEventDeepLinkOpen()
                cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, scene: scene, completionHandler: { deepLinkActionType in
                    
                    InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                })
            }
        }
    }
    
    @available(iOS 13.0, *)
    func processSceneOpenURLContexts(URLContexts: Set<UIOpenURLContext>, scene: UIScene) {
        if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate, let url = URLContexts.first?.url {
            let eventName = API.EVENT_NAME_DEEP_LINK_OPEN
            let mcID = CordialAPI().getCurrentMcID()
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            cordialDeepLinksDelegate.openDeepLink(url: url, fallbackURL: nil, scene: scene, completionHandler: { deepLinkActionType in
                
                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
            })
        }
    }
        
    // MARK: Background URL session
    
    func swizzleAppHandleEventsForBackgroundURLSessionCompletionHandler(identifier: String, completionHandler: @escaping () -> Void) {
        if CordialURLSessionConfigurationHandler().isCordialURLSession(identifier: identifier) {
            CordialURLSession.shared.backgroundCompletionHandler = completionHandler
        }
    }

}
