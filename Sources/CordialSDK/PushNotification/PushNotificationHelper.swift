//
//  PushNotificationHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationHelper {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let pushNotificationParser = PushNotificationParser()
    
    func pushNotificationHasBeenTapped(userInfo: [AnyHashable : Any], completionHandler: () -> Void) {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings { settings in
                self.pushNotificationHasBeenTapped(userInfo: userInfo, authorizationStatus: settings.authorizationStatus)
            }
        }
        
        completionHandler()
    }
    
    private func pushNotificationHasBeenTapped(userInfo: [AnyHashable : Any], authorizationStatus: UNAuthorizationStatus) {
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
        
        LoggerManager.shared.info(message: "Push notification app open via tap. Payload: \(self.pushNotificationParser.getPayloadJSON(userInfo: userInfo))", category: "CordialSDKPushNotification")
        
        if let mcID = self.pushNotificationParser.getMcID(userInfo: userInfo) {
            self.cordialAPI.setCurrentMcID(mcID: mcID)
            
            if let isInAppMessageShown = CoreDataManager.shared.inAppMessagesShown.isInAppMessageShown(mcID: mcID),
               isInAppMessageShown {
                
                InAppMessageProcess.shared.removeInAppMessageFromCoreData(mcID: mcID)
                
                LoggerManager.shared.info(message: "IAM with mcID [\(mcID)] has been removed.", category: "CordialSDKInAppMessage")
            }
            
            if self.pushNotificationParser.isPayloadContainIAM(userInfo: userInfo),
               let inactiveSessionDisplayString = self.pushNotificationParser.getInactiveSessionDisplayIAM(userInfo: userInfo) {
                
                let inactiveSessionDisplay = InAppMessageGetter().getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
                
                if inactiveSessionDisplay == InAppMessageInactiveSessionDisplayType.hideInAppMessage {
                    CoreDataManager.shared.inAppMessagesRelated.putInAppMessageRelated(mcID: mcID)
                }
            }
        }
        
        let mcID = self.cordialAPI.getCurrentMcID()
        
        let systemEventsProperties = self.internalCordialAPI.getAuthorizationStatusSystemEventsProperties(authorizationStatus: authorizationStatus)
        let sendCustomEventRequest = SendCustomEventRequest(eventName: API.EVENT_NAME_PUSH_NOTIFICATION_TAP, mcID: mcID, properties: systemEventsProperties)
        self.internalCordialAPI.sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        if let carouselDeepLinks = CordialGroupUserDefaults.stringArray(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS),
           let carouselDeepLinkID = CordialGroupUserDefaults.integer(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID),
           carouselDeepLinks.indices.contains(carouselDeepLinkID),
           let url = URL(string: carouselDeepLinks[carouselDeepLinkID]) {
            
            self.internalCordialAPI.processPushNotificationDeepLink(url: url, userInfo: userInfo)
            
        } else if let url = self.pushNotificationParser.getDeepLinkURL(userInfo: userInfo) {
            self.internalCordialAPI.processPushNotificationDeepLink(url: url, userInfo: userInfo)
        }
        
        CordialGroupUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS)
        CordialGroupUserDefaults.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID)
    }
    
    func pushNotificationHasBeenForegroundDelivered(userInfo: [AnyHashable : Any], completionHandler: (UNNotificationPresentationOptions) -> Void) {
        DispatchQueue.main.async {
            self.pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
        }
        
        if !self.pushNotificationParser.isPayloadContainIAM(userInfo: userInfo) {
            if #available(iOS 14.0, *) {
                completionHandler([.list, .banner])
            } else {
                completionHandler([.alert])
            }
        } else if #available(iOS 14.0, *) {
            completionHandler([.list])
        }
    }
    
    private func pushNotificationHasBeenForegroundDelivered(userInfo: [AnyHashable : Any]) {
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
    
    private func additionalLoggingAdoreMe(settings: UNNotificationSettings) {
        let statusString: String
        switch settings.authorizationStatus {
        case .notDetermined:
            statusString = "NOT DETERMINED"
        case .denied:
            statusString = "DENIED"
        case .authorized:
            statusString = "AUTHORIZED"
        case .provisional:
            statusString = "PROVISIONAL"
        case .ephemeral:
            statusString = "EPHEMERAL"
        @unknown default:
            statusString = "swift unknown default"
        }

        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): Authorization Status: \(statusString)",
            category: "CordialSDKAddedByAdoreMe"
        )

        let userdefaultsValue = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) ?? "nil"

        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): UserDefaults USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS: \(userdefaultsValue)",
            category: "CordialSDKAddedByAdoreMe"
        )

        let condition = isUpsertContacts24HoursSelfHealingCanBeProcessed()

        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): isUpsertContacts24HoursSelfHealingCanBeProcessed: \(condition.description)",
            category: "CordialSDKAddedByAdoreMe"
        )
    }

    func prepareCurrentPushNotificationStatus() {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.additionalLoggingAdoreMe(settings: settings)

                    if !self.internalCordialAPI.isCurrentlyUpsertingContacts(),
                       let token = self.internalCordialAPI.getPushNotificationToken() {
                        
                        let primaryKey = CordialAPI().getContactPrimaryKey()
                        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                            if API.PUSH_NOTIFICATION_STATUS_ALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || self.isUpsertContacts24HoursSelfHealingCanBeProcessed() {
                                
                                let status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                                self.sentPushNotificationStatus(token: token, primaryKey: primaryKey, status: status, authorizationStatus: settings.authorizationStatus)
                            }
                        } else {
                            if API.PUSH_NOTIFICATION_STATUS_DISALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || self.isUpsertContacts24HoursSelfHealingCanBeProcessed() {
                                
                                let status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                                self.sentPushNotificationStatus(token: token, primaryKey: primaryKey, status: status, authorizationStatus: settings.authorizationStatus)
                            }
                        }
                    }
                }
            }
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
    
    private func sentPushNotificationStatus(token: String, primaryKey: String?, status: String, authorizationStatus: UNAuthorizationStatus) {        
        self.internalCordialAPI.setPushNotificationStatus(status: status, authorizationStatus: authorizationStatus)
        
        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): primaryKey: \(primaryKey ?? "nil")",
            category: "CordialSDKAddedByAdoreMe"
        )

        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): internalCordialAPI.isUserLogin(): \(self.internalCordialAPI.isUserLogin().description)",
            category: "CordialSDKAddedByAdoreMe"
        )

        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): !internalCordialAPI.hasUserBeenLoggedIn(): \((!self.internalCordialAPI.hasUserBeenLoggedIn()).description)",
            category: "CordialSDKAddedByAdoreMe"
        )

        if self.internalCordialAPI.isUserLogin() || !self.internalCordialAPI.hasUserBeenLoggedIn() {
            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
        }
    }
}
