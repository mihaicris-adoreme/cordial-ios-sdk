//
//  NotificationManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications

public extension Notification.Name {
    
    static let cordialConnectedToInternet = Notification.Name("CordialConnectedToInternet")
    static let cordialNotConnectedToInternet = Notification.Name("CordialNotConnectedToInternet")
    
    static let cordialConnectionSettingsHasBeenChange = Notification.Name("CordialSDKConnectionSettingsHasBeenChange")
    
    static let cordialSendCustomEventsLogicError = Notification.Name("CordialSDKSendCustomEventsLogicError")
    static let cordialUpsertContactCartLogicError = Notification.Name("CordialSDKUpsertContactCartLogicError")
    static let cordialSendContactOrdersLogicError = Notification.Name("CordialSDKSendContactOrdersLogicError")
    static let cordialUpsertContactsLogicError = Notification.Name("CordialSDKUpsertContactsLogicError")
    static let cordialSendContactLogoutLogicError = Notification.Name("CordialSDKSendContactLogoutLogicError")
    static let cordialInAppMessageLogicError = Notification.Name("CordialSDKInAppMessageLogicError")
    static let cordialInboxMessagesMarkReadUnreadLogicError = Notification.Name("CordialSDKInboxMessagesMarkReadUnreadLogicError")
    static let cordialInboxMessageDeleteRequestLogicError = Notification.Name("CordialSDKInboxMessageDeleteRequestLogicError")
}

@objc public extension NSNotification {
    static let cordialConnectedToInternet = Notification.Name.cordialConnectedToInternet
    static let cordialNotConnectedToInternet = Notification.Name.cordialNotConnectedToInternet
    
    static let cordialConnectionSettingsHasBeenChange = Notification.Name.cordialConnectionSettingsHasBeenChange
    
    static let cordialSendCustomEventsLogicError = Notification.Name.cordialSendCustomEventsLogicError
    static let cordialUpsertContactCartLogicError = Notification.Name.cordialUpsertContactCartLogicError
    static let cordialSendContactOrdersLogicError = Notification.Name.cordialSendContactOrdersLogicError
    static let cordialUpsertContactsLogicError = Notification.Name.cordialUpsertContactsLogicError
    static let cordialSendContactLogoutLogicError = Notification.Name.cordialSendContactLogoutLogicError
    static let cordialInAppMessageLogicError = Notification.Name.cordialInAppMessageLogicError
    static let cordialInboxMessagesMarkReadUnreadLogicError = Notification.Name.cordialInboxMessagesMarkReadUnreadLogicError
}

class NotificationManager {
    
    static let shared = NotificationManager()
    
    var isNotificationManagerHasNotBeenSettedUp = true
    
    let appMovedToBackgroundThrottler = Throttler(minimumDelay: 1)
    var appMovedToBackgroundBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    let appMovedFromBackgroundThrottler = Throttler(minimumDelay: 1)

    private init() {
        let notificationCenter = NotificationCenter.default
        
        if self.isNotificationManagerHasNotBeenSettedUp {
            self.isNotificationManagerHasNotBeenSettedUp = false
            
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(handleDidFinishLaunch), name: UIApplication.didBecomeActiveNotification, object: nil)
        } 
    }
    
    @objc func appMovedToBackground() {
        self.appMovedToBackgroundBackgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let backgroundTaskID = self?.appMovedToBackgroundBackgroundTaskID else { return }
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
        })
        
        self.appMovedToBackgroundThrottler.throttle {
            self.appMovedToBackgroundProceed()
            
            if let backgroundTaskID = self.appMovedToBackgroundBackgroundTaskID {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                self.appMovedToBackgroundBackgroundTaskID = nil
            }
        }
    }
    
    func appMovedToBackgroundProceed() {
        let eventName = API.EVENT_NAME_APP_MOVED_TO_BACKGROUND
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "App moved to background")
    }
    
    @objc func appMovedFromBackground() {
        self.appMovedFromBackgroundThrottler.throttle {
            self.appMovedFromBackgroundProceed()
        }
    }
    
    func appMovedFromBackgroundProceed() {
        let eventName = API.EVENT_NAME_APP_MOVED_FROM_BACKGROUND
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.prepareCurrentPushNotificationStatus()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
        InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
    }
    
    @objc func connectionSettingsHasBeenChangeHandler() {
        InternalCordialAPI().removeCurrentMcID()
    }
    
    private func prepareCurrentPushNotificationStatus() {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings(completionHandler: { (settings) in
                let internalCordialAPI = InternalCordialAPI()
                
                let primaryKey = CordialAPI().getContactPrimaryKey()
                
                if let token = internalCordialAPI.getPushNotificationToken() {
                    if settings.authorizationStatus == .authorized {
                        if API.PUSH_NOTIFICATION_STATUS_ALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || !self.isSentUpsertContactsWithin24Hours() {
                            let status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                            
                            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
                            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
                            
                            internalCordialAPI.setPushNotificationStatus(status: status)
                        }
                    } else {
                        if API.PUSH_NOTIFICATION_STATUS_DISALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) || !self.isSentUpsertContactsWithin24Hours() {
                            let status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                            
                            let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
                            ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
                            
                            internalCordialAPI.setPushNotificationStatus(status: status)
                        }
                    }
                }
            })
        }
    }
    
    private func isSentUpsertContactsWithin24Hours() -> Bool {
        if let lastUpdateDateTimestamp = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE),
            let lastUpdateDate = CordialDateFormatter().getDateFromTimestamp(timestamp: lastUpdateDateTimestamp) {
            
            let distanceBetweenDates = abs(lastUpdateDate.timeIntervalSinceNow)
            let secondsInAnHour = 3600.0
            let hoursBetweenDates = distanceBetweenDates / secondsInAnHour

            if hoursBetweenDates < 24 {
                return true
            }
        }
        
        return false
    }
    
    @objc func handleDidFinishLaunch(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        
        let notificationCenter = NotificationCenter.default
        
        if !self.isNotificationManagerHasNotBeenSettedUp {
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            
            self.appMovedFromBackground()
        }
        
        if #available(iOS 13.0, *), InternalCordialAPI().isAppUseScenes() {
            notificationCenter.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
            
            notificationCenter.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        
        notificationCenter.removeObserver(self, name: .cordialConnectionSettingsHasBeenChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(connectionSettingsHasBeenChangeHandler), name: .cordialConnectionSettingsHasBeenChange, object: nil)
        
        CordialApiConfiguration.shared.cordialSwizzler.swizzleAppDelegateMethods()
    }

}
