//
//  CordialPushNotificationHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import os.log

class CordialPushNotificationHelper {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let pushNotificationParser = CordialPushNotificationParser()
    
    func pushNotificationHasBeenTapped(userInfo: [AnyHashable : Any], completionHandler: () -> Void) {
        self.pushNotificationHasBeenTapped(userInfo: userInfo)
        
        completionHandler()
    }
    
    func pushNotificationHasBeenTapped(userInfo: [AnyHashable : Any]) {
        // UIKit
        if let pushNotificationDelegate = CordialApiConfiguration.shared.pushNotificationDelegate {
            pushNotificationDelegate.appOpenViaNotificationTap(notificationContent: userInfo)
        }
        
        // SwiftUI
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                CordialSwiftUIPushNotificationPublisher.shared.publishAppOpenViaNotificationTap(notificationContent: userInfo)
            }
        }
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Push notification app open via tap. Payload: %{public}@", log: OSLog.cordialPushNotification, type: .info, userInfo)
        }
        
        if let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo) {
            self.cordialAPI.setCurrentMcID(mcID: mcID)
            
            DispatchQueue.main.async {
                if let isInAppMessageHasBeenShown = CoreDataManager.shared.inAppMessagesShown.isInAppMessageHasBeenShown(mcID: mcID),
                   isInAppMessageHasBeenShown {
                    
                    InAppMessageProcess.shared.deleteInAppMessageFromCoreDataByMcID(mcID: mcID)
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("IAM with mcID [%{public}@] has been removed.", log: OSLog.cordialInAppMessage, type: .info, mcID)
                    }
                }
            }
            
            if self.pushNotificationParser.isPayloadContainIAM(userInfo: userInfo),
               let inactiveSessionDisplayString = self.pushNotificationParser.getInactiveSessionDisplayIAM(userInfo: userInfo) {
                
                let inactiveSessionDisplay = InAppMessageGetter().getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
                
                if inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    ThreadQueues.shared.queueInAppMessage.sync(flags: .barrier) {
                        CoreDataManager.shared.inAppMessagesRelated.setRelatedStatusToInAppMessagesRelatedCoreData(mcID: mcID)
                    }
                }
            }
        }
        
        let mcID = self.cordialAPI.getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATION_TAP, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let deepLinkURL = self.pushNotificationParser.getDeepLinkURL(userInfo: userInfo) {
    
            InAppMessageProcess.shared.isPresentedInAppMessage = false
            
            let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_DEEP_LINK_OPEN, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
            
            // UIKit
            if let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
                DispatchQueue.main.async {
                    if let fallbackURL = self.pushNotificationParser.getDeepLinkFallbackURL(userInfo: userInfo) {
                        if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                            cordialDeepLinksDelegate.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL, scene: scene, completionHandler: { deepLinkActionType in
                                
                                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                            })
                        } else {
                            cordialDeepLinksDelegate.openDeepLink(url: deepLinkURL, fallbackURL: fallbackURL, completionHandler: { deepLinkActionType in
                                
                                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                            })
                        }
                    } else {
                        if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                            cordialDeepLinksDelegate.openDeepLink(url: deepLinkURL, fallbackURL: nil, scene: scene, completionHandler: { deepLinkActionType in
                                
                                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                            })
                        } else {
                            cordialDeepLinksDelegate.openDeepLink(url: deepLinkURL, fallbackURL: nil, completionHandler: { deepLinkActionType in
                                
                                InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                            })
                        }
                    }
                }
            }
            
            // SwiftUI
            if #available(iOS 13.0, *) {
                DispatchQueue.main.async {
                    if let fallbackURL = self.pushNotificationParser.getDeepLinkFallbackURL(userInfo: userInfo) {
                        CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: deepLinkURL, fallbackURL: fallbackURL, completionHandler: { deepLinkActionType in
                            
                            InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                        })
                    } else {
                        CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(url: deepLinkURL, fallbackURL: nil, completionHandler: { deepLinkActionType in
                            
                            InternalCordialAPI().deepLinkAction(deepLinkActionType: deepLinkActionType)
                        })
                    }
                }
            }
        }
    }
    
    func pushNotificationHasBeenForegroundDelivered(userInfo: [AnyHashable : Any], completionHandler: (UNNotificationPresentationOptions) -> Void) {
        self.pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
        
        if !self.pushNotificationParser.isPayloadContainIAM(userInfo: userInfo) {
            completionHandler([.alert])
        }
    }
    
    func pushNotificationHasBeenForegroundDelivered(userInfo: [AnyHashable : Any]) {
        // UIKit
        if let pushNotificationDelegate = CordialApiConfiguration.shared.pushNotificationDelegate {
            pushNotificationDelegate.notificationDeliveredInForeground(notificationContent: userInfo)
        }
        
        // SwiftUI
        if #available(iOS 13.0, *) {
            DispatchQueue.main.async {
                CordialSwiftUIPushNotificationPublisher.shared.publishNotificationDeliveredInForeground(notificationContent: userInfo)
            }
        }
        
        let eventName = API.EVENT_NAME_PUSH_NOTIFICATION_DELIVERED_FOREGROUND
        let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo)
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    func prepareCurrentPushNotificationStatus() {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings(completionHandler: { (settings) in
                DispatchQueue.main.async {
                    if !self.internalCordialAPI.isCurrentlyUpsertingContacts(),
                       let token = self.internalCordialAPI.getPushNotificationToken() {
                        
                        let primaryKey = CordialAPI().getContactPrimaryKey()
                        
                        if settings.authorizationStatus == .authorized {
                            if API.PUSH_NOTIFICATION_STATUS_ALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || self.isUpsertContacts24HoursSelfHealingCanBeProcessed() {
                                
                                let status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                                self.sentPushNotificationStatus(token: token, primaryKey: primaryKey, status: status)
                            }
                        } else {
                            if API.PUSH_NOTIFICATION_STATUS_DISALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || self.isUpsertContacts24HoursSelfHealingCanBeProcessed() {
                                
                                let status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                                self.sentPushNotificationStatus(token: token, primaryKey: primaryKey, status: status)
                            }
                        }
                    }
                }
            })
        }
    }
    
    private func sentPushNotificationStatus(token: String, primaryKey: String?, status: String) {
        self.internalCordialAPI.setPushNotificationStatus(status: status)
        
        if self.internalCordialAPI.isUserLogin() || !self.internalCordialAPI.isUserHasBeenEverLogin() {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        }
    }
    
    private func isUpsertContacts24HoursSelfHealingCanBeProcessed() -> Bool {
        if let lastUpdateDateTimestamp = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE),
            let lastUpdateDate = CordialDateFormatter().getDateFromTimestamp(timestamp: lastUpdateDateTimestamp) {
            
            let distanceBetweenDates = abs(lastUpdateDate.timeIntervalSinceNow)
            let secondsInAnHour = 3600.0
            let hoursBetweenDates = distanceBetweenDates / secondsInAnHour

            if hoursBetweenDates < 24 {
                return false
            }
        }
        
        return true
    }
}
